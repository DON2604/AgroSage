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
    description="Useful for finding recent trends and data about crop market trends from web sources"
)

def market_trend_analyzer(crop_type):
    querycropstr = ""
    db_chain = SQLDatabaseChain.from_llm(llm2, db, verbose=True)
    qns1 = db_chain("GIVE ONLY THE SQL QUERY to find the Crop_Type with respect to Market_Price_per_ton, Demand_Index, Supply_Index in descending order")
    print(qns1['result'])
    gen_query = extract_sql_query(qns1["result"])
    querydata = run_query(gen_query)
    for i in querydata:
        querycropstr = querycropstr + " " + i[0]  

    market_analysis_prompt = PromptTemplate(
        input_variables=["crop_type"],
        template="""
        Analyze the market trends for {crop_type} in the market_data table, including the parameters 
        (Market_Price_per_ton, Demand_Index, Supply_Index, Competitor_Price_per_ton, Economic_Indicator, Weather_Impact_Score, Seasonal_Factor, Consumer_Trend_Index).
        
        Provide the response strictly in this format:
        - Rising or non rising inedex Analysis: <True (if rising)/False (if going down), reason 1 line>
        """
    )

    market_analysis_chain = market_analysis_prompt | llm

    top3_market_comparison_prompt = PromptTemplate(
        input_variables=["crop_type", "querycropstr"],
        template="""
        List the top 3 extra crops by average market performance in the market_data table, and compare their parameters 
        (Market_Price_per_ton, Demand_Index, Supply_Index, Competitor_Price_per_ton, Economic_Indicator, Weather_Impact_Score, Seasonal_Factor, Consumer_Trend_Index) 
        with those of {crop_type}, considering the context of these crops: {querycropstr}.
        
        Provide the response strictly in this format:
        - Top 3 Crops: <list of crops with average market performance>
        - Parameters Comparison: < abide by this example:
            -<Crop 1>:
            - Parameters: <example output exactly like this : Corn: Market_Price_per_ton (300), Demand_Index (150), Supply_Index (80), Competitor_Price_per_ton (280), Economic_Indicator (1.1), Weather_Impact_Score (50), Seasonal_Factor (Medium), Consumer_Trend_Index (120)>
            -<Crop 2>:
            - Parameters: <example output exactly like this : Corn: Market_Price_per_ton (300), Demand_Index (150), Supply_Index (80), Competitor_Price_per_ton (280), Economic_Indicator (1.1), Weather_Impact_Score (50), Seasonal_Factor (Medium), Consumer_Trend_Index (120)>
            -<Crop 3>:
            - Parameters: <example output exactly like this : Corn: Market_Price_per_ton (300), Demand_Index (150), Supply_Index (80), Competitor_Price_per_ton (280), Economic_Indicator (1.1), Weather_Impact_Score (50), Seasonal_Factor (Medium), Consumer_Trend_Index (120)>
            >
        - Insights: <short comparison summary 1 line>
        """
    )

    top3_market_comparison_chain = top3_market_comparison_prompt | llm
    
    web_market_trends_prompt = PromptTemplate(
        input_variables=["crop_type"],
        template="""
        Research recent market trends focusing on {crop_type} and identify 
        2 other crops that are currently trending for their market performance (with reasons why they're trending).
        For all 3 crops ({crop_type} plus 2 trending crops), provide analysis in EXACTLY this format nothing additional:
        
        - Trending Crops:
          - {crop_type}: 
            - Parameters: <example output exactly like this : Corn: Market_Price_per_ton (300), Demand_Index (150), Supply_Index (80), Competitor_Price_per_ton (280), Economic_Indicator (1.1), Weather_Impact_Score (50), Seasonal_Factor (Medium), Consumer_Trend_Index (120)>
            - Strength: <main market strength>
            - Rising percentage: <percentage rice than {crop_type}>
            - Source: <source mentioning this>
          - <Crop 1>:
            - Parameters: <example output exactly like this : Corn: Market_Price_per_ton (300), Demand_Index (150), Supply_Index (80), Competitor_Price_per_ton (280), Economic_Indicator (1.1), Weather_Impact_Score (50), Seasonal_Factor (Medium), Consumer_Trend_Index (120)>
            - Strength: <why trending just few words>
            - Rising percentage: <percentage rice than {crop_type}>
            - Source: <just name source mentioning this>
          - <Crop 2>:
            - Parameters: <Market_Price_per_ton, Demand_Index, Supply_Index>
            - Strength: <why trending just few words>
            - Rising percentage: <percentage rice than {crop_type}>
            - Source: <just name source mentioning this 1 line>
        """
    )

    def web_market_trends_analysis(crop_type):
        search_query = f"2024 market trends for {crop_type} compared to other crops site:.edu OR site:.gov OR site:.org"
        search_results = search_tool.run(search_query)
        
        prompt = web_market_trends_prompt.format(crop_type=crop_type)
        return llm.invoke(prompt + "\n\nRecent Reports:\n" + search_results[:2000])

    analysis_chain = RunnableParallel(
        market_analysis=market_analysis_chain,
        top3_market_comparison=top3_market_comparison_chain,
        web_market_trends=lambda x: web_market_trends_analysis(x["crop_type"])
    )

    analysis_result = analysis_chain.invoke({
        "crop_type": crop_type,
        "querycropstr": querycropstr.strip()  
    })


    store_crux("market_trend_agent_market_analysis", analysis_result["market_analysis"].content.strip(), update=True)
    store_crux("market_trend_agent_top3_comparison", analysis_result["top3_market_comparison"].content.strip(), update=True)
    store_crux("market_trend_agent_web_trends", analysis_result["web_market_trends"].content.strip(), update=True)

    print(analysis_result["market_analysis"].content.strip())
    print(analysis_result["top3_market_comparison"].content.strip())
    print(analysis_result["web_market_trends"].content.strip())

    return {
        "market_analysis": analysis_result["market_analysis"].content.strip(),
        "top3_market_comparison": analysis_result["top3_market_comparison"].content.strip(),
        "web_market_trends": analysis_result["web_market_trends"].content.strip()
    }
