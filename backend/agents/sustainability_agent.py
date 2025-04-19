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
    description="Useful for finding recent trends and data about crop sustainability from web sources"
)

def farm_advisor(crop_type):
    querycropstr = ""
    db_chain = SQLDatabaseChain.from_llm(llm2, db, verbose=True)
    qns1 = db_chain("GIVE ONLY THE SQL QUERY to find the Crop_Type with respect to Crop_Yield_ton and Sustainability_Score in descending order")
    print(qns1['result'])
    gen_query = extract_sql_query(qns1["result"])
    querydata = run_query(gen_query)
    for i in querydata:
        querycropstr = querycropstr + " " + i[0]  

    sustainability_analysis_prompt = PromptTemplate(
        input_variables=["crop_type"],
        template="""
        Analyze the sustainability score for {crop_type} in the farm_advisory table, including the parameters 
        (Soil_pH, Soil_Moisture, Temperature_C, Rainfall_mm, Fertilizer_Usage_kg, Pesticide_Usage_kg, Crop_Yield_ton) 
        that determine its score.
        
        Provide the response strictly in this format:
        - Sustainability Scores: <list of scores of crop_type>
        - Parameters: <list of parameters per crop_type>
        - Analysis: <short explanation of what drives the score>
        """
    )

    sustainability_analysis_chain = sustainability_analysis_prompt | llm

    top3_comparison_prompt = PromptTemplate(
        input_variables=["crop_type", "querycropstr"],
        template="""
        List the top 3 extra crops by average sustainability score in the farm_advisory table, and compare their parameters 
        (Soil_pH, Soil_Moisture, Temperature_C, Rainfall_mm, Fertilizer_Usage_kg, Pesticide_Usage_kg, Crop_Yield_ton) 
        with those of {crop_type}, considering the context of these crops: {querycropstr}.
        
        Provide the response strictly in this format:
        - Top 3 Crops: <list of crops with average sustainability scores>
        - Parameters Comparison: < abide by this example:
            -<Crop 1>:
            - Parameters: <example output excatly like this : Corn: Soil_pH (6.8), Soil_Moisture (25%), Temperature_C (25), Rainfall_mm (700), Fertilizer_Usage_kg (180), Pesticide_Usage_kg (6), Crop_Yield_ton (3.0)>
            -<Crop 2>:
            - Parameters: <example output excatly like this : Corn: Soil_pH (6.8), Soil_Moisture (25%), Temperature_C (25), Rainfall_mm (700), Fertilizer_Usage_kg (180), Pesticide_Usage_kg (6), Crop_Yield_ton (3.0)>
            -<Crop 3>:
            - Parameters: <example output excatly like this : Corn: Soil_pH (6.8), Soil_Moisture (25%), Temperature_C (25), Rainfall_mm (700), Fertilizer_Usage_kg (180), Pesticide_Usage_kg (6), Crop_Yield_ton (3.0)>
            >
        - Insights: <short comparison summary 1 line>
        """
    )

    top3_comparison_chain = top3_comparison_prompt | llm
    
    web_trends_prompt = PromptTemplate(
        input_variables=["crop_type"],
        template="""
        Research recent trends in sustainable agriculture focusing on {crop_type} and identify 
        2 other crops that are currently trending for their sustainability (with reasons why they're trending).
        For all 3 crops ({crop_type} plus 2 trending crops), provide analysis in EXACTLY this format nothing additional:
        
        - Trending Crops:
          - {crop_type}: 
            - Parameters: <example output excatly like this : Corn: Soil_pH (6.8), Soil_Moisture (25%), Temperature_C (25), Rainfall_mm (700), Fertilizer_Usage_kg (180), Pesticide_Usage_kg (6), Crop_Yield_ton (3.0)>
            - Strength: <main sustainability strength>
            - Source: <source mentioning this>
          - <Crop 1>:
            - Parameters: <example output excatly like this : Corn: Soil_pH (6.8), Soil_Moisture (25%), Temperature_C (25), Rainfall_mm (700), Fertilizer_Usage_kg (180), Pesticide_Usage_kg (6), Crop_Yield_ton (3.0)>
            - Strength: <why trending just few words>
            - Source: <just name source mentioning this>
          - <Crop 2>:
            - Parameters: <Soil_pH, Water_Needs, Climate_Adaptability>
            - Strength: <why trending just few words>
            - Source: <just name source mentioning this 1 line>
        """
    )

    def web_trends_analysis(crop_type):
        search_query = f"2024 sustainable agriculture trends {crop_type} compared to other crops best practices site:.edu OR site:.gov OR site:.org"
        search_results = search_tool.run(search_query)
        
        prompt = web_trends_prompt.format(crop_type=crop_type)
        return llm.invoke(prompt + "\n\nRecent Reports:\n" + search_results[:2000])

    analysis_chain = RunnableParallel(
        sustainability=sustainability_analysis_chain,
        top3_comparison=top3_comparison_chain,
        web_trends=lambda x: web_trends_analysis(x["crop_type"])
    )

    analysis_result = analysis_chain.invoke({
        "crop_type": crop_type,
        "querycropstr": querycropstr.strip()  
    })

    store_crux("sustainability_agent", analysis_result["sustainability"].content.strip(),update=True)
    store_crux("sustainability_agent", analysis_result["top3_comparison"].content.strip(),update=True)
    store_crux("sustainability_agent", analysis_result["web_trends"].content.strip(),update=True)

    print(analysis_result["sustainability"].content.strip())
    print(analysis_result["top3_comparison"].content.strip())
    print(analysis_result["web_trends"].content.strip())

    return {
        "sustainability_analysis": analysis_result["sustainability"].content.strip(),
        "top3_comparison": analysis_result["top3_comparison"].content.strip(),
        "web_trends": analysis_result["web_trends"].content.strip()
    }