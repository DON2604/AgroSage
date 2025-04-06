from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from langchain.schema.runnable import RunnableParallel
from langchain_community.utilities import SQLDatabase
from langchain_experimental.sql import SQLDatabaseChain 
from dotenv import load_dotenv
import os
import json
import sys
import os
from pathlib import Path

script_dir = Path(__file__).parent.absolute()
db_path = script_dir.parent / "db" / "farming_memory.db"
db = SQLDatabase.from_uri(f"sqlite:///{db_path}")


sys.path.append(str(Path(__file__).parent.parent))
from modules.query_extract_run import extract_sql_query, run_query
from modules.weather_fetcher import fetcher
from modules.memory_handler import store_crux  

load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")



llm = ChatGroq(
    model_name="llama-3.3-70b-versatile",
    temperature=0.7,
    groq_api_key=groq_api_key
)

def w_agent(location):
    weather_classification_prompt = PromptTemplate(
        input_variables=["weather_data"],
        template="""
        Analyze the following 10-day weather forecast data and determine the overall weather condition:
        {weather_data}
        
        Provide the analysis strictly in this format:
        - Weather condition: <condition> (e.g., Drought, Flood, Moderate, Extreme Cold, etc.)
        - One-line explanation of the weather condition.
        """
    )

    weather_classification_chain = weather_classification_prompt | llm

    crop_recommendation_prompt = PromptTemplate(
        input_variables=["weather_condition"],
        template="""
        Based on the given weather condition: "{weather_condition}", suggest the best crops to plant or harvest.
        
        Provide the response strictly in this format:
        - Plantation Crops: <comma-separated list of crops to plant>
        - Harvestation Crops: <comma-separated list of crops to harvest>
        - Short reason for the selection.
        """
    )

    crop_recommendation_chain = crop_recommendation_prompt | llm

    weather_to_crop_chain = RunnableParallel(
        weather_condition=weather_classification_chain
    )

    sample_weather_data = fetcher(location)

    weather_result = weather_to_crop_chain.invoke({"weather_data": json.dumps(sample_weather_data, indent=2)})

    weather_condition = weather_result["weather_condition"].content.strip()

    crop_result = crop_recommendation_chain.invoke({"weather_condition": weather_condition})

    db_chain = SQLDatabaseChain.from_llm(llm, db, verbose=True)
    qns1 = db_chain("Find the Crop_Type with respect to Crop_Yield_ton and Sustainability_Score in descending order")
    print(qns1["result"])
    gen_query = extract_sql_query(qns1["result"])
    querydata = run_query(gen_query)

    store_crux("weather_agent_weather_condition", weather_condition, update=True)
    store_crux("weather_agent_crop_recommendation", crop_result.content.strip(), update=True)

    print("weather_condition=", weather_condition, "crop_recommendation=", crop_result.content.strip(), "query_data=", querydata)

    return {
        "weather_condition": weather_condition,
        "crop_recommendation": crop_result.content.strip(),
        "query_data": querydata
    }
