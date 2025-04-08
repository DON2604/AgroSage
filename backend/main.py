from flask import Flask, request, jsonify
from flask_cors import CORS
from agents.sustainability_agent import farm_advisor
from agents.weather_agent import w_agent
from agents.market_trend_agent import market_trend_analyzer
from agents.carbon_footprint_agent import carbon_footprint_analyzer
from agents.water_usage import water_usage_tracker_agent
from agents.decision_agent import DecisionAgent
from modules.auth_handler import register_user, login_user
from modules.ticket_handler import create_ticket, get_all_tickets  # Import ticket handling functions
from modules.response_handler import get_responses  # Import response handler
import os
import threading
import time
import json

app = Flask(__name__)
CORS(app) 

db_path = os.path.join(os.path.dirname(__file__), 'db', 'memory.db')
decision_agent = DecisionAgent(db_path)

# Cache for response.json
response_cache = {}

def refresh_cache():
    """Background thread to refresh the response cache every 5 seconds."""
    global response_cache
    file_path = os.path.join(os.path.dirname(__file__), 'db', 'response.json')  # Corrected file path
    while True:
        try:
            with open(file_path, 'r') as file:
                response_cache = json.load(file)
        except Exception as e:
            print(f"Error refreshing cache: {e}")
        time.sleep(5)

# Start the background thread
cache_thread = threading.Thread(target=refresh_cache, daemon=True)
cache_thread.start()

@app.route('/', methods=['GET'])
def health_check():
    return jsonify({"status": "alive", "message": "Service is running"}), 200

@app.route('/cached-response', methods=['GET'])
def get_cached_response():
    """Endpoint to fetch the cached response."""
    if response_cache:
        return jsonify({"success": True, "data": response_cache}), 200
    else:
        return jsonify({"success": False, "message": "Cache is empty"}), 500

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

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    name = data.get('name', '')
    email = data.get('email', '')
    password = data.get('password', '')
    
    if not all([name, email, password]):
        return jsonify({"success": False, "message": "All fields are required"}), 400
    
    result = register_user(name, email, password)
    
    if result["success"]:
        return jsonify(result), 201
    else:
        return jsonify(result), 400

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email', '')
    password = data.get('password', '')
    
    if not all([email, password]):
        return jsonify({"success": False, "message": "Email and password are required"}), 400
    
    result = login_user(email, password)
    
    if result["success"]:
        return jsonify(result), 200
    else:
        return jsonify(result), 401

@app.route('/api/tickets', methods=['POST', 'GET'])
def tickets():
    if request.method == 'POST':
        # Create a new ticket
        data = request.get_json()
        user_id = data.get('user_id', '')
        title = data.get('title', '')
        description = data.get('description', '')

        if not all([user_id, title, description]):
            return jsonify({"success": False, "message": "All fields are required"}), 400

        result = create_ticket(user_id, title, description)
        if result["success"]:
            return jsonify(result), 201
        else:
            return jsonify(result), 400

    elif request.method == 'GET':
        # Retrieve all tickets with responses
        tickets = get_all_tickets()
        return jsonify({"success": True, "tickets": tickets}), 200

@app.route('/api/responses', methods=['GET'])
def responses():
    print("Fetching all responses")  # Debug log
    responses = get_responses()
    if responses:
        return jsonify({"success": True, "responses": responses}), 200
    else:
        return jsonify({"success": False, "message": "No responses found"}), 404

if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0')
