import sqlite3
connection = sqlite3.connect('./farming_memory.db') 

cursor = connection.cursor()

query = """SELECT "Crop_Type", "Crop_Yield_ton", "Sustainability_Score" FROM farm_advisory ORDER BY "Crop_Yield_ton" DESC, "Sustainability_Score" DESC LIMIT 5;"""  # Replace with your desired SQL query

try:
    cursor.execute(query)
    rows = cursor.fetchall()
    for row in rows:
        print(row)
except sqlite3.Error as e:
    print(f"Error executing query: {e}")
finally:
    connection.close()
