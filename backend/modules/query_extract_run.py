from pathlib import Path
import sqlite3

def extract_sql_query(input_string):
    start_keyword = "SQLQuery:"
    start_index = input_string.find(start_keyword)
    
    if start_index == -1:
        return None
    sql_query = input_string[start_index + len(start_keyword):]
    sql_query = sql_query.strip()
    
    return sql_query

def run_query(sent_query):
    script_dir = Path(__file__).parent.absolute()
    db_path = script_dir.parent / "db" / "farming_memory.db"
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute(sent_query)
    result = cursor.fetchall()
    conn.close()
    return(result)