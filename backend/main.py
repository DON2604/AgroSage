from flask import Flask, request, jsonify
from flask_cors import CORS  # Import CORS
from agents.sustainability_agent import farm_advisor
from agents.weather_agent import w_agent
from agents.market_trend_agent import market_trend_analyzer
from agents.carbon_footprint_agent import carbon_footprint_analyzer
from agents.water_usage import water_usage_tracker_agent
from agents.decision_agent import DecisionAgent
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Initialize DecisionAgent
db_path = os.path.join(os.path.dirname(__file__), 'db', 'memory.db')
decision_agent = DecisionAgent(db_path)

@app.route('/weather', methods=['GET'])
def weather():
    location = request.args.get('location', 'Kolkata')
    result = w_agent("Kolkata")
    cleaned_result = decision_agent.analyze_and_clean(result,"weather")
    if "error" in cleaned_result:
        print(f"Error in DecisionAgent: {cleaned_result['raw_response']}")
        return jsonify({"status": "error", "message": cleaned_result["error"], "details": cleaned_result["raw_response"]}), 500
    return jsonify(cleaned_result)

@app.route('/sustainability', methods=['GET'])
def sustainability():
    crop_type = request.args.get('crop_type', 'Wheat')
    result = farm_advisor(crop_type)
    cleaned_result = decision_agent.analyze_and_clean(result,"sustainability")
    return jsonify(cleaned_result)

@app.route('/market-trends', methods=['GET'])
def market_trends():
    crop_type = request.args.get('crop_type', 'Wheat')
    result = market_trend_analyzer(crop_type)
    cleaned_result = decision_agent.analyze_and_clean(result,"market")
    return jsonify(cleaned_result)

@app.route('/carbon-footprint', methods=['GET'])
def carbon_footprint():
    result = carbon_footprint_analyzer()
    cleaned_result = decision_agent.analyze_and_clean(result,"carbon")
    return jsonify(cleaned_result)

@app.route('/water-usage', methods=['GET'])
def water_usage():
    result = water_usage_tracker_agent()
    cleaned_result = decision_agent.analyze_and_clean(result,"water")
    return jsonify(cleaned_result)

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0')
