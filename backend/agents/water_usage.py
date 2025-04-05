from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from langchain.schema.runnable import RunnableParallel
from langchain_community.utilities import SQLDatabase
from langchain_experimental.sql import SQLDatabaseChain 
from langchain_community.tools import DuckDuckGoSearchRun
from langchain.agents import Tool
from dotenv import load_dotenv
import os
import sys
from pathlib import Path

script_dir = Path(__file__).parent.absolute()
db_path = script_dir.parent / "db" / "farming_memory.db"
db = SQLDatabase.from_uri(f"sqlite:///{db_path}")

sys.path.append(str(Path(__file__).parent.parent))
from modules.query_extract_run import extract_sql_query, run_query
from modules.memory_handler import store_crux  # Import store_crux function

load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

llm = ChatGroq(
    model_name="llama3-70b-8192",
    temperature=0.7,
    groq_api_key=groq_api_key
)

llm2 = ChatGroq(
    model_name="qwen-2.5-coder-32b",
    temperature=0.5,
    groq_api_key=groq_api_key
)

search = DuckDuckGoSearchRun()
search_tool = Tool(
    name="Web Search",
    func=search.run,
    description="Useful for finding recent data on water usage and conservation strategies in farming"
)

def water_usage_tracker_agent():
    db_chain = SQLDatabaseChain.from_llm(llm2, db, verbose=True)
    qns1 = db_chain("GIVE ONLY THE SQL QUERY to select Farm_ID, Crop_Type, Soil_Moisture, Rainfall_mm from farmer_advisor")
    gen_query = extract_sql_query(qns1["result"])
    farm_data = run_query(gen_query)
    farm_str = " ".join([row[1] for row in farm_data])  

    water_calc_prompt = PromptTemplate(
        input_variables=["farm_data"],
        template="""
        Given the following farm data from the farmer_advisor table: {farm_data}
        Calculate the estimated water usage (in liters) for each farm based on:
        - Soil_Moisture (%): Lower moisture increases irrigation needs
        - Rainfall_mm: Higher rainfall reduces irrigation needs
        - Crop_Type: Use approximate water needs (Wheat: 500 mm, Soybean: 450 mm, Corn: 600 mm, Rice: 1200 mm over growing season)
        
        Assumptions:
        - Irrigation needed = Crop water need - Rainfall_mm
        - If Soil_Moisture < 20%, increase irrigation by 20%
        - Convert mm to liters assuming 1 mm = 10,000 liters/ha, assume 1 ha per farm
        - If irrigation needed is negative, use 0
        
        Do NOT generate Python code. Perform the calculations directly and provide the response strictly in this format:
        - Farm Data: <list of (Farm_ID, Crop_Type, Water_Usage in liters)>
        - Total Water Usage: <sum of all water usage in liters>
        """
    )

    water_calc_chain = water_calc_prompt | llm

    conservation_insights_prompt = PromptTemplate(
        input_variables=["farm_data"],
        template="""
        For the following farm data: {farm_data}
        Provide water conservation insights based on Soil_Moisture, Rainfall_mm, and Crop_Type:
        - If Soil_Moisture < 20%, suggest "Implement drip irrigation to reduce water use by 30%"
        - If Rainfall_mm < 100, suggest "Use rainwater harvesting to supplement by 20%"
        - If Crop_Type is Rice, suggest "Adopt alternate wetting and drying (AWD) to save 25%"
        
        Calculate potential water savings in liters:
        - Drip irrigation: 30% of water usage
        - Rainwater harvesting: 20% of water usage
        - AWD for Rice: 25% of water usage
        
        Provide the response strictly in this format avoid giving same crops give for differnt types:
        - Conservation Insights:
          - <Farm_ID>:
            - Crop_Type: <crop>
            - Insights: <only 1 line of applicable strategies>
            - Estimated_Savings: <total savings in liters>
        """
    )

    conservation_insights_chain = conservation_insights_prompt | llm

    web_water_trends_prompt = PromptTemplate(
        input_variables=["farm_str"],
        template="""
        Research recent water conservation strategies for crops like {farm_str}.
        Identify 2 effective strategies and their estimated savings percentages.
        Provide analysis in EXACTLY this format:
        
        - Conservation Strategies:
          - Strategy 1:
            - Description: <strategy description>
            - Savings_Percentage: <percentage>
            - Source: <source name>
          - Strategy 2:
            - Description: <strategy description>
            - Savings_Percentage: <percentage>
            - Source: <source name>
        """
    )

    def web_water_trends_analysis(farm_str):
        search_query = f"2024 water conservation strategies for farming crops like {farm_str} site:.edu OR site:.gov OR site:.org"
        search_results = search_tool.run(search_query)
        
        prompt = web_water_trends_prompt.format(farm_str=farm_str)
        return llm.invoke(prompt + "\n\nRecent Reports:\n" + search_results[:2000])

    analysis_chain = RunnableParallel(
        water_calc=water_calc_chain,
        conservation_insights=conservation_insights_chain,
        web_water_trends=lambda x: web_water_trends_analysis(x["farm_str"])
    )

    farm_data_str = str(farm_data)  
    analysis_result = analysis_chain.invoke({
        "farm_data": farm_data_str,
        "farm_str": farm_str
    })

    # Store key insights into memory (update instead of adding new rows)
    store_crux("water_usage_agent_farm_data", farm_data, update=True)
    store_crux("water_usage_agent_calculation", analysis_result["water_calc"].content.strip(), update=True)
    store_crux("water_usage_agent_conservation", analysis_result["conservation_insights"].content.strip(), update=True)
    store_crux("water_usage_agent_trends", analysis_result["web_water_trends"].content.strip(), update=True)

    print("Farm Data:", farm_data)
    print("Water Usage Calculation:", analysis_result["water_calc"].content.strip())
    print("Conservation Insights:", analysis_result["conservation_insights"].content.strip())
    print("Web Water Trends:", analysis_result["web_water_trends"].content.strip())

    return {
        "farm_data": farm_data,
        "water_usage_calculation": analysis_result["water_calc"].content.strip(),
        "conservation_insights": analysis_result["conservation_insights"].content.strip(),
        "web_water_trends": analysis_result["web_water_trends"].content.strip()
    }

