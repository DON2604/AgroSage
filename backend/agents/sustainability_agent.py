from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from langchain.schema.runnable import RunnableParallel
from langchain.sql_database import SQLDatabase
from langchain_experimental.sql import SQLDatabaseChain 
from dotenv import load_dotenv
import os
import sys
from pathlib import Path


script_dir = Path(__file__).parent.absolute()
db_path = script_dir.parent / "db" / "farming_memory.db"
db = SQLDatabase.from_uri(f"sqlite:///{db_path}")


sys.path.append(str(Path(__file__).parent.parent))
from modules.query_extract_run import extract_sql_query, run_query


load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

# Initialize Groq LLM
llm = ChatGroq(
    model_name="llama-3.3-70b-versatile",
    temperature=0.7,
    groq_api_key=groq_api_key
)

def farm_advisor(crop_type):
    querycropstr = ""
    db_chain = SQLDatabaseChain.from_llm(llm, db, verbose=True)
    qns1 = db_chain("Find the Crop_Type with respect to Crop_Yield_ton and Sustainability_Score in descending order")
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
        - Parameters Comparison: <parameters for top 3 crops and the given crop>
        - Insights: <short comparison summary>
        """
    )

    top3_comparison_chain = top3_comparison_prompt | llm

    analysis_chain = RunnableParallel(
        sustainability=sustainability_analysis_chain,
        top3_comparison=top3_comparison_chain
    )

    analysis_result = analysis_chain.invoke({
        "crop_type": crop_type,
        "querycropstr": querycropstr.strip()  
    })

    sustainability_result = analysis_result["sustainability"].content.strip()
    top3_result = analysis_result["top3_comparison"].content.strip()

    return {
        "sustainability_analysis": sustainability_result,
        "top3_comparison": top3_result,
    }


