import sqlite3
import os
from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from dotenv import load_dotenv

load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

llm = ChatGroq(
    model_name="qwen-2.5-32b",
    temperature=0.7,
    groq_api_key=groq_api_key
)

def store_crux(agent_name, crux, update=False):
    prompt = PromptTemplate.from_template("Summarize this in one to two sentences keeping the most important context that can be used to reference later: {text}")
    formatted_prompt = prompt.format(text=crux) 
    short_crux = llm.invoke(formatted_prompt).content.strip()  
    db_path = os.path.join(os.path.dirname(__file__), '..', 'db', 'memory.db')
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    if update:
        cursor.execute('''
            INSERT INTO memory (agent_name, crux)
            VALUES (?, ?)
            ON CONFLICT(agent_name) DO UPDATE SET crux=excluded.crux, timestamp=CURRENT_TIMESTAMP
        ''', (agent_name, short_crux))
    else:
        cursor.execute('''
            INSERT INTO memory (agent_name, crux)
            VALUES (?, ?)
        ''', (agent_name, short_crux))

    conn.commit()
    conn.close()
