import sqlite3
import pandas as pd

conn = sqlite3.connect("db/farming_memory.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS farm_advisory (
    farm_id INTEGER PRIMARY KEY,
    soil_pH REAL,
    soil_moisture REAL,
    temperature REAL,
    rainfall REAL,
    crop_type TEXT,
    fertilizer_usage REAL,
    pesticide_usage REAL,
    crop_yield REAL,
    sustainability_score REAL
);
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS market_research (
    market_id INTEGER PRIMARY KEY,
    product TEXT,
    market_price REAL,
    demand_index REAL,
    supply_index REAL,
    competitor_price REAL,
    economic_indicator REAL,
    weather_impact REAL,
    seasonal_factor TEXT,
    consumer_trend REAL
);
""")

# Create users table for authentication
cursor.execute('''
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
''')

farmer_data = pd.read_csv("data/farmer_advisor_dataset.csv")
farmer_data.to_sql("farm_advisory", conn, if_exists="replace", index=False)

market_data = pd.read_csv("data/market_researcher_dataset.csv")
market_data.to_sql("market_research", conn, if_exists="replace", index=False)

conn.commit()
conn.close()




conn = sqlite3.connect("db/memory.db")
cursor = conn.cursor()

cursor.execute('''
        CREATE TABLE IF NOT EXISTS memory (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            agent_name TEXT NOT NULL UNIQUE,
            crux TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')

conn.commit()
conn.close()


print("Database initialized successfully! ✅")


