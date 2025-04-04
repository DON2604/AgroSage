from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from dotenv import load_dotenv
import sqlite3
import os
import json

# Load environment variables
load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

# Initialize the LLM
llm = ChatGroq(
    model_name="qwen-2.5-coder-32b",
    temperature=0.7,
    groq_api_key=groq_api_key
)

class DecisionAgent:
    def __init__(self, db_path):
        self.db_path = db_path

    def fetch_memory(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("SELECT agent_name, crux FROM memory")
        memory_data = cursor.fetchall()
        conn.close()
        return memory_data

    def analyze_and_clean(self, raw_output):
        memory_data = self.fetch_memory()
        memory_context = "\n".join([f"{agent}: {crux}" for agent, crux in memory_data])

        prompt = PromptTemplate.from_template(
            "Given the following memory context:\n{memory_context}\n\n and GIVE JUST ONLY JSON NOTHING ELSE"
            "Analyze and structure the following raw output into a consistent JSON format. if you think any fields are empty"
            "Ensure the JSON is clean and well-structured:\n\n{raw_output}\n\n"
            "Return the structured JSON:"
        )
        formatted_prompt = prompt.format(memory_context=memory_context, raw_output=raw_output)
        response = llm.invoke(formatted_prompt).content.strip()

        # ✅ Strip markdown code block if it exists
        if response.startswith("```json") and response.endswith("```"):
            response = response[7:-3].strip()
        elif response.startswith("```") and response.endswith("```"):
            response = response[3:-3].strip()

        try:
            structured_json = json.loads(response)
            return structured_json
        except json.JSONDecodeError:
            print(f"LLM returned invalid JSON. Raw response: {response}")
            return {
                "error": "Invalid JSON returned by LLM",
                "raw_response": response
            }
