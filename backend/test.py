from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)

CORS(app) 

weather_data ={
    "conservation_insights": [
        {
            "crop_type": "Wheat",
            "estimated_savings": 14711.51,
            "farm_id": 1,
            "insights": "Implement drip irrigation to reduce water use by 30%"
        },
        {
            "crop_type": "Soybean",
            "estimated_savings": 4883.5,
            "farm_id": 2,
            "insights": "Use rainwater harvesting to supplement by 20%"
        },
        {
            "crop_type": "Corn",
            "estimated_savings": 4233.36,
            "farm_id": 3,
            "insights": "Implement drip irrigation to reduce water use by 30%"
        },
        {
            "crop_type": "Wheat",
            "estimated_savings": 4703.51,
            "farm_id": 4,
            "insights": "Implement drip irrigation to reduce water use by 30%"
        },
        {
            "crop_type": "Corn",
            "estimated_savings": 2339.52,
            "farm_id": 5,
            "insights": "Implement drip irrigation to reduce water use by 30%"
        }
    ],
    "farm_data": [
        {
            "crop_type": "Wheat",
            "farm_id": 1,
            "precipitation": 227.8909122156477,
            "soil_moisture": 49.14535876397696
        },
        {
            "crop_type": "Soybean",
            "farm_id": 2,
            "precipitation": 244.01749330098983,
            "soil_moisture": 21.49611538528016
        },
        {
            "crop_type": "Corn",
            "farm_id": 3,
            "precipitation": 141.11052082022786,
            "soil_moisture": 19.46904232943808
        },
        {
            "crop_type": "Wheat",
            "farm_id": 4,
            "precipitation": 156.78566341441285,
            "soil_moisture": 27.97423365959013
        },
        {
            "crop_type": "Corn",
            "farm_id": 5,
            "precipitation": 77.85936215956802,
            "soil_moisture": 33.63767886268485
        }
    ],
    "water_usage_calculation": {
        "farm_calculations": [
            {
                "adjusted_irrigation": 326.73,
                "crop_type": "Wheat",
                "farm_id": 1,
                "irrigation_needed": 272.11,
                "water_usage_liters": 3267300
            },
            {
                "adjusted_irrigation": 205.98,
                "crop_type": "Soybean",
                "farm_id": 2,
                "irrigation_needed": 205.98,
                "water_usage_liters": 2059800
            },
            {
                "adjusted_irrigation": 550.67,
                "crop_type": "Corn",
                "farm_id": 3,
                "irrigation_needed": 458.89,
                "water_usage_liters": 3546700
            },
            {
                "adjusted_irrigation": 411.85,
                "crop_type": "Wheat",
                "farm_id": 4,
                "irrigation_needed": 343.21,
                "water_usage_liters": 3438500
            },
            {
                "adjusted_irrigation": 522.14,
                "crop_type": "Corn",
                "farm_id": 5,
                "irrigation_needed": 522.14,
                "water_usage_liters": 2421400
            }
        ],
        "total_water_usage": 14701900
    },
    "web_water_trends": {
        "conservation_strategies": [
            {
                "description": "Precision Irrigation using Advanced Sensors",
                "savings_percentage": "20-30%",
                "source": "Phytech's platform"
            },
            {
                "description": "Water Reuse and Fit-for-Purpose Water Conservation",
                "savings_percentage": "15-25%",
                "source": "U.S. Department of Agriculture (USDA) and World Resources Institute (WRI) analysis"
            }
        ]
    }
}

@app.route('/sustainability', methods=['GET'])
def get_weather():
    return jsonify(weather_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)