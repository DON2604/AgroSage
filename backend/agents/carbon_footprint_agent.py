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
from modules.memory_handler import store_crux  

load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

llm = ChatGroq(
    model_name="llama3-70b-8192",
    temperature=0.7,
    groq_api_key=groq_api_key
)

llm2 = ChatGroq(
    model_name="llama-3.3-70b-versatile",
    temperature=0.5,
    groq_api_key=groq_api_key
)

search = DuckDuckGoSearchRun()
search_tool = Tool(
    name="Web Search",
    func=search.run,
    description="Useful for finding recent data on carbon emission factors and reduction strategies"
)

def carbon_footprint_analyzer():
    db_chain = SQLDatabaseChain.from_llm(llm2, db, verbose=True)
    qns1 = db_chain("GIVE ONLY THE SQL QUERY to select Farm_ID, Crop_Type, Fertilizer_Usage_kg, Pesticide_Usage_kg from farmer_advisor")
    gen_query = extract_sql_query(qns1["result"])
    farm_data = run_query(gen_query)
    farm_str = " ".join([row[1] for row in farm_data])

    carbon_calc_prompt = PromptTemplate(
        input_variables=["farm_data"],
        template="""
        Using the following farm data from the farmer_advisor table: {farm_data}
        Calculate the carbon footprint for each farm with emission factors:
        - Fertilizer: 5.2 kg CO2e/kg
        - Pesticide: 16.6 kg CO2e/kg
        
        Provide the response strictly in this format:
        - Farm Data: <list of Farm_ID, Crop_Type, Carbon_Footprint (kg CO2e)>
        - Total Carbon Footprint: <sum of all footprints in kg CO2e>
        """
    )

    carbon_calc_chain = carbon_calc_prompt | llm

    reduction_insights_prompt = PromptTemplate(
        input_variables=["farm_data"],
        template="""
        For the following farm data: {farm_data}
        Provide reduction insights based on Fertilizer_Usage_kg and Pesticide_Usage_kg:
        - If Fertilizer_Usage_kg > 50, suggest "Reduce fertilizer use by 20% with precision farming"
        - If Pesticide_Usage_kg > 5, suggest "Switch to organic pesticides, reducing emissions by 30%"
        
        Calculate potential reduction in kg CO2e:
        - Fertilizer reduction: 20% of fertilizer contribution (Fertilizer_Usage_kg * 5.2)
        - Pesticide reduction: 30% of pesticide contribution (Pesticide_Usage_kg * 16.6)
        
        Provide the response strictly in this format:
        - Reduction Insights:
          - <Farm_ID>:
            - Crop_Type: <crop>
            - Insights: <list of applicable strategies>
            - Estimated_Reduction: <total reduction in kg CO2e>
        """
    )

    reduction_insights_chain = reduction_insights_prompt | llm

    web_carbon_trends_prompt = PromptTemplate(
        input_variables=["farm_str"],
        template="""
        Research recent carbon footprint reduction strategies for crops like {farm_str}.
        Identify 2 effective strategies and their estimated reduction percentages.
        Provide analysis in EXACTLY this format:
        
        - Reduction Strategies:
          - Strategy 1:
            - Description: <strategy description>
            - Reduction_Percentage: <percentage>
            - Source: <source name>
          - Strategy 2:
            - Description: <strategy description>
            - Reduction_Percentage: <percentage>
            - Source: <source name>
        """
    )

    def web_carbon_trends_analysis(farm_str):
        search_query = f"2024 carbon footprint reduction strategies for farming crops like {farm_str} site:.edu OR site:.gov OR site:.org"
        search_results = search_tool.run(search_query)
        
        prompt = web_carbon_trends_prompt.format(farm_str=farm_str)
        return llm.invoke(prompt + "\n\nRecent Reports:\n" + search_results[:2000])

    analysis_chain = RunnableParallel(
        carbon_calc=carbon_calc_chain,
        reduction_insights=reduction_insights_chain,
        web_carbon_trends=lambda x: web_carbon_trends_analysis(x["farm_str"])
    )

    farm_data_str = str(farm_data)  
    analysis_result = analysis_chain.invoke({
        "farm_data": farm_data_str,
        "farm_str": farm_str
    })

    store_crux("carbon_footprint_agent_insight", analysis_result["carbon_calc"].content.strip(), update=True)
    store_crux("carbon_footprint_agent_recommendation", analysis_result["reduction_insights"].content.strip(), update=True)
    store_crux("carbon_footprint_agent_trends", analysis_result["web_carbon_trends"].content.strip(), update=True)

    print(analysis_result["carbon_calc"].content.strip())
    print(analysis_result["reduction_insights"].content.strip())
    print(analysis_result["web_carbon_trends"].content.strip())

    return {
        "carbon_footprint_calculation": analysis_result["carbon_calc"].content.strip(),
        "reduction_insights": analysis_result["reduction_insights"].content.strip(),
        "web_carbon_trends": analysis_result["web_carbon_trends"].content.strip()
    }
