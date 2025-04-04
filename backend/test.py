from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)

# Configure CORS to allow requests from your Flutter web app
# Replace 'http://localhost:port' with your actual Flutter web development server address
# You can find this when you run 'flutter run -d chrome'
CORS(app)  # Adjust port as needed

# Hardcoded JSON data
weather_data = {
    "crop_recommendation": {
        "harvest_crops": [
            "wheat",
            "barley",
            "oats",
            "rice",
            "soybeans"
        ],
        "plantation_crops": [
            "maize",
            "sorghum",
            "millet",
            "cowpea",
            "peanuts"
        ],
        "reason": "These crops are drought-tolerant and can thrive in hot and dry conditions, making them suitable for the given weather condition."
    },
    "query_data": [
        {
            "crop": "Rice",
            "value1": 9.999637660299218,
            "value2": 82.13945685862643
        },
        {
            "crop": "Wheat",
            "value1": 9.9994463792558,
            "value2": 67.11638483633713
        },
        {
            "crop": "Soybean",
            "value1": 9.999082131588938,
            "value2": 18.516091074481967
        },
        {
            "crop": "Wheat",
            "value1": 9.998343065447104,
            "value2": 23.967684266358116
        },
        {
            "crop": "Corn",
            "value1": 9.998171515081369,
            "value2": 83.09319372175138
        }
    ],
    "weather_condition": {
        "description": "Hot and Dry",
        "explanation": "The overall weather condition is hot and dry with high temperatures and minimal precipitation throughout the 10-day forecast."
    }
}

@app.route('/weather', methods=['GET'])
def get_weather():
    return jsonify(weather_data)

if __name__ == '__main__':
    # Run on 192.168.0.101:5000
    # Make sure this IP matches your machine's local network IP
    app.run(host='0.0.0.0', port=5000, debug=True)