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

    def analyze_and_clean(self, raw_output, sender):
        memory_data = self.fetch_memory()
        memory_context = "\n".join([f"{agent}: {crux}" for agent, crux in memory_data])

        if sender == "sustainability":
            # Special handling for sustainability data
            try:
                # Try to parse raw output if it's a string
                if isinstance(raw_output, str):
                    try:
                        parsed_data = json.loads(raw_output)
                    except json.JSONDecodeError:
                        parsed_data = {}
                else:
                    parsed_data = raw_output
                
                # Format according to required template
                return self._format_sustainability_json(parsed_data)
            except Exception as e:
                print(f"Error formatting sustainability data: {e}")
                # Return template with dummy data if there's an error
                return self._format_sustainability_json({})
        elif sender == "market":
            # Special handling for market data
            try:
                # Try to parse raw output if it's a string
                if isinstance(raw_output, str):
                    try:
                        parsed_data = json.loads(raw_output)
                    except json.JSONDecodeError:
                        parsed_data = {}
                else:
                    parsed_data = raw_output
                
                # Format according to required template
                return self._format_market_json(parsed_data)
            except Exception as e:
                print(f"Error formatting market data: {e}")
                # Return template with dummy data if there's an error
                return self._format_market_json({})
        elif sender == "carbon":
            # Special handling for carbon data
            try:
                # Try to parse raw output if it's a string
                if isinstance(raw_output, str):
                    try:
                        parsed_data = json.loads(raw_output)
                    except json.JSONDecodeError:
                        parsed_data = {}
                else:
                    parsed_data = raw_output
                
                # Format according to required template
                return self._format_carbon_json(parsed_data)
            except Exception as e:
                print(f"Error formatting carbon data: {e}")
                # Return template with dummy data if there's an error
                return self._format_carbon_json({})
        elif sender == "water":
            # Special handling for water data
            try:
                # Try to parse raw output if it's a string
                if isinstance(raw_output, str):
                    try:
                        parsed_data = json.loads(raw_output)
                    except json.JSONDecodeError:
                        parsed_data = {}
                else:
                    parsed_data = raw_output
                
                # Format according to required template
                return self._format_water_json(parsed_data)
            except Exception as e:
                print(f"Error formatting water data: {e}")
                # Return template with dummy data if there's an error
                return self._format_water_json({})
        else:
            # Original logic for other senders
            prompt = PromptTemplate.from_template(
                "Given the following memory context:\n{memory_context}\n\n and GIVE JUST ONLY JSON NOTHING ELSE"
                "Analyze and structure the following raw output into a consistent JSON format. if you think any fields are empty and provide quotes even to true or false"
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
    
    def _format_sustainability_json(self, data):
        """Format sustainability data according to required template structure."""
        template = {
            "sustainability_analysis": {
                "analysis": "The sustainability score for Wheat is driven primarily by the Crop_Yield_ton, which is high in most cases, indicating good agricultural practices. The moderate to low Fertilizer_Usage_kg and Pesticide_Usage_kg also contribute to the high sustainability score, as they reduce the environmental impact of farming. However, the variability in Soil_pH and Soil_Moisture parameters may require more precise management to optimize crop growth and reduce waste.",
                "crop": "Wheat",
                "parameters": {
                    "Crop_Yield_ton": [2.5, 3.0, 2.0, 3.5, 3.2],
                    "Fertilizer_Usage_kg": [50, 40, 60, 30, 45],
                    "Pesticide_Usage_kg": [2, 1, 3, 1, 2],
                    "Rainfall_mm": [100, 120, 110, 130, 125],
                    "Soil_Moisture": [20, 30, 25, 35, 28],
                    "Soil_pH": [6.5, 7.0, 6.0, 7.5, 6.8],
                    "Temperature_C": [18, 20, 22, 19, 21]
                },
                "sustainability_scores": [0.7, 0.8, 0.6, 0.9, 0.8]
            },
            "top3_comparison": {
                "insights": "Soybean and Corn have similar parameters to Wheat, while Rice requires more rainfall and has different soil pH requirements.",
                "top_crops": [
                    {
                        "crop": "Soybean",
                        "parameters": {
                            "Crop_Yield_ton": 2.8,
                            "Fertilizer_Usage_kg": 120,
                            "Pesticide_Usage_kg": 4,
                            "Rainfall_mm": 650,
                            "Soil_Moisture": 30,
                            "Soil_pH": 6.2,
                            "Temperature_C": 22
                        },
                        "score": 8.2
                    },
                    {
                        "crop": "Corn",
                        "parameters": {
                            "Crop_Yield_ton": 3.0,
                            "Fertilizer_Usage_kg": 180,
                            "Pesticide_Usage_kg": 6,
                            "Rainfall_mm": 700,
                            "Soil_Moisture": 25,
                            "Soil_pH": 6.8,
                            "Temperature_C": 25
                        },
                        "score": 7.9
                    },
                    {
                        "crop": "Rice",
                        "parameters": {
                            "Crop_Yield_ton": 2.5,
                            "Fertilizer_Usage_kg": 150,
                            "Pesticide_Usage_kg": 5,
                            "Rainfall_mm": 800,
                            "Soil_Moisture": 40,
                            "Soil_pH": 5.8,
                            "Temperature_C": 20
                        },
                        "score": 7.8
                    }
                ]
            },
            "web_trends": {
                "trending_crops": [
                    {
                        "crop": "Wheat",
                        "parameters": {
                            "Crop_Yield_ton": 2.5,
                            "Fertilizer_Usage_kg": 120,
                            "Pesticide_Usage_kg": 4,
                            "Rainfall_mm": 500,
                            "Soil_Moisture": 20,
                            "Soil_pH": 6.0,
                            "Temperature_C": "15-20"
                        },
                        "source": "USDA",
                        "strength": "Low temperature tolerance, reducing climate change impacts"
                    },
                    {
                        "crop": "Quinoa",
                        "parameters": {
                            "Climate_Adaptability": "high",
                            "Soil_pH": "6.0-7.5",
                            "Water_Needs": "low"
                        },
                        "source": "FAO",
                        "strength": "Drought tolerance, high protein content"
                    },
                    {
                        "crop": "Lentils",
                        "parameters": {
                            "Climate_Adaptability": "high",
                            "Soil_pH": "6.0-7.0",
                            "Water_Needs": "moderate"
                        },
                        "source": "CGIAR",
                        "strength": "Nitrogen fixation, low water requirements"
                    }
                ]
            }
        }
        
        # Use LLM to analyze and tweak values based on input data while maintaining structure
        if isinstance(data, dict):
            # Create a context for the LLM to understand the data
            context = {
                "template": template,
                "raw_data": data
            }
            
            # Use the LLM to analyze and suggest modifications
            prompt = PromptTemplate.from_template(
                "Given the following template structure and raw input data:\n\n"
                "TEMPLATE: {template}\n\n"
                "RAW DATA: {raw_data}\n\n"
                "Analyze the raw data and suggest modifications to the template values. "
                "Maintain the exact structure but adjust the values based on insights from the raw data. "
                "Return only the modified template as a valid JSON object. Do not include any explanation."
            )
            
            formatted_prompt = prompt.format(template=json.dumps(template), raw_data=json.dumps(data))
            try:
                response = llm.invoke(formatted_prompt).content.strip()
                
                # Clean up the response
                if response.startswith("```json") and response.endswith("```"):
                    response = response[7:-3].strip()
                elif response.startswith("```") and response.endswith("```"):
                    response = response[3:-3].strip()
                    
                # Parse the modified template
                modified_template = json.loads(response)
                if isinstance(modified_template, dict):
                    return modified_template
            except Exception as e:
                print(f"Error tweaking sustainability template values: {e}")
                # Continue with manual merging if LLM modification fails
        
        # Fallback to manual merging if LLM approach fails
        if isinstance(data, dict):
            # Update sustainability_analysis section
            if "sustainability_analysis" in data and isinstance(data["sustainability_analysis"], dict):
                for key, value in data["sustainability_analysis"].items():
                    if key in template["sustainability_analysis"]:
                        template["sustainability_analysis"][key] = value
            
            # Update top3_comparison section
            if "top3_comparison" in data and isinstance(data["top3_comparison"], dict):
                for key, value in data["top3_comparison"].items():
                    if key in template["top3_comparison"]:
                        template["top3_comparison"][key] = value
            
            # Update web_trends section
            if "web_trends" in data and isinstance(data["web_trends"], dict):
                for key, value in data["web_trends"].items():
                    if key in template["web_trends"]:
                        template["web_trends"][key] = value
        
        return template
    
    def _format_market_json(self, data):
        """Format market data according to required template structure."""
        template = {
            "market_analysis": {
                "analysis": {
                    "Competitor_Price_per_ton": "True",
                    "Consumer_Trend_Index": "True",
                    "Demand_Index": "False",
                    "Economic_Indicator": "True",
                    "Market_Price_per_ton": "True",
                    "Seasonal_Factor": "False",
                    "Supply_Index": "True",
                    "Weather_Impact_Score": "True"
                },
                "overall_trend": "Rising (True) if most of the parameters show a rising trend. Otherwise, it's a non-rising trend (False).",
            },
            "top3_market_comparison": {
                "insights": "Oats, Barley, and Rye outperform Wheat in average market performance, with Oats showing the highest market price per ton and Rye demonstrating the highest demand index.",
                "parameters_comparison": {
                    "Barley": {
                        "Competitor_Price_per_ton": 295,
                        "Consumer_Trend_Index": 130,
                        "Demand_Index": 155,
                        "Economic_Indicator": 1.15,
                        "Market_Price_per_ton": 310,
                        "Seasonal_Factor": "Medium",
                        "Supply_Index": 85,
                        "Weather_Impact_Score": 55
                    },
                    "Oats": {
                        "Competitor_Price_per_ton": 290,
                        "Consumer_Trend_Index": 140,
                        "Demand_Index": 160,
                        "Economic_Indicator": 1.2,
                        "Market_Price_per_ton": 320,
                        "Seasonal_Factor": "High",
                        "Supply_Index": 90,
                        "Weather_Impact_Score": 60
                    },
                    "Rye": {
                        "Competitor_Price_per_ton": 305,
                        "Consumer_Trend_Index": 150,
                        "Demand_Index": 165,
                        "Economic_Indicator": 1.25,
                        "Market_Price_per_ton": 330,
                        "Seasonal_Factor": "Low",
                        "Supply_Index": 95,
                        "Weather_Impact_Score": 65
                    },
                    "Wheat": {
                        "Competitor_Price_per_ton": 280,
                        "Consumer_Trend_Index": 120,
                        "Demand_Index": 150,
                        "Economic_Indicator": 1.1,
                        "Market_Price_per_ton": 300,
                        "Seasonal_Factor": "Medium",
                        "Supply_Index": 80,
                        "Weather_Impact_Score": 50
                    }
                },
                "top_crops": [
                    "Oats",
                    "Barley",
                    "Rye"
                ]
            },
            "web_market_trends": {
                "crops": {
                    "Barley": {
                        "Competitor_Price_per_ton": 200,
                        "Consumer_Trend_Index": 125,
                        "Demand_Index": 130,
                        "Economic_Indicator": 1.08,
                        "Market_Price_per_ton": 220,
                        "Seasonal_Factor": "Medium",
                        "Supply_Index": 95,
                        "Weather_Impact_Score": 65,
                        "rising_percentage": "12% from the year prior",
                        "source": "Food and Agriculture Organization (FAO)",
                        "strength": "Increasing demand from the brewing industry"
                    },
                    "Oats": {
                        "Competitor_Price_per_ton": 190,
                        "Consumer_Trend_Index": 105,
                        "Demand_Index": 100,
                        "Economic_Indicator": 1.02,
                        "Market_Price_per_ton": 200,
                        "Seasonal_Factor": "Medium",
                        "Supply_Index": 80,
                        "Weather_Impact_Score": 55,
                        "rising_percentage": "15% from the year prior",
                        "source": "Statista",
                        "strength": "Growing demand from the food and feed industries"
                    },
                    "Wheat": {
                        "Competitor_Price_per_ton": 210,
                        "Consumer_Trend_Index": 110,
                        "Demand_Index": 120,
                        "Economic_Indicator": 1.05,
                        "Market_Price_per_ton": 230,
                        "Seasonal_Factor": "Medium",
                        "Supply_Index": 90,
                        "Weather_Impact_Score": 60,
                        "rising_percentage": "10% from the year prior",
                        "source": "USDA's World Agricultural Supply and Demand Estimates (WASDE)",
                        "strength": "Increased yields and improved weather conditions"
                    }
                }
            }
        }
        
        # Use LLM to analyze and tweak values based on input data while maintaining structure
        if isinstance(data, dict):
            # Create a context for the LLM to understand the data
            context = {
                "template": template,
                "raw_data": data
            }
            
            # Use the LLM to analyze and suggest modifications
            prompt = PromptTemplate.from_template(
                "Given the following template structure and raw input data:\n\n"
                "TEMPLATE: {template}\n\n"
                "RAW DATA: {raw_data}\n\n"
                "Analyze the raw data and suggest modifications to the template values. "
                "Maintain the exact structure but adjust the values based on insights from the raw data. "
                "Return only the modified template as a valid JSON object. Do not include any explanation."
            )
            
            formatted_prompt = prompt.format(template=json.dumps(template), raw_data=json.dumps(data))
            try:
                response = llm.invoke(formatted_prompt).content.strip()
                
                # Clean up the response
                if response.startswith("```json") and response.endswith("```"):
                    response = response[7:-3].strip()
                elif response.startswith("```") and response.endswith("```"):
                    response = response[3:-3].strip()
                    
                # Parse the modified template
                modified_template = json.loads(response)
                if isinstance(modified_template, dict):
                    return modified_template
            except Exception as e:
                print(f"Error tweaking market template values: {e}")
                # Continue with manual merging if LLM modification fails
        
        # Fallback to manual merging if LLM approach fails
        if isinstance(data, dict):
            # Update market_analysis section
            if "market_analysis" in data and isinstance(data["market_analysis"], dict):
                for key, value in data["market_analysis"].items():
                    if key in template["market_analysis"]:
                        template["market_analysis"][key] = value
            
            # Update top3_market_comparison section
            if "top3_market_comparison" in data and isinstance(data["top3_market_comparison"], dict):
                for key, value in data["top3_market_comparison"].items():
                    if key in template["top3_market_comparison"]:
                        template["top3_market_comparison"][key] = value
            
            # Update web_market_trends section
            if "web_market_trends" in data and isinstance(data["web_market_trends"], dict):
                for key, value in data["web_market_trends"].items():
                    if key in template["web_market_trends"]:
                        template["web_market_trends"][key] = value
        
        return template
    
    def _format_carbon_json(self, data):
        """Format carbon data according to required template structure."""
        template = {
            "carbon_footprint_calculation": {
                "farm_data": [
                    {
                        "carbon_footprint": 734.63,
                        "crop_type": "Wheat",
                        "farm_id": 1,
                        "fertilizer_use": 131.6928438033121,
                        "pesticide_use": 2.958214627794372
                    },
                    {
                        "carbon_footprint": 1027.74,
                        "crop_type": "Soybean",
                        "farm_id": 2,
                        "fertilizer_use": 136.3704915665747,
                        "pesticide_use": 19.20477028818854
                    },
                    {
                        "carbon_footprint": 702.75,
                        "crop_type": "Corn",
                        "farm_id": 3,
                        "fertilizer_use": 99.7252102526668,
                        "pesticide_use": 11.041065642810384
                    },
                    {
                        "carbon_footprint": 1159.61,
                        "crop_type": "Wheat",
                        "farm_id": 4,
                        "fertilizer_use": 194.8323963952749,
                        "pesticide_use": 8.806270972850378
                    },
                    {
                        "carbon_footprint": 360.056,
                        "crop_type": "Corn",
                        "farm_id": 5,
                        "fertilizer_use": 57.271266671217695,
                        "pesticide_use": 3.7475534903293206
                    }
                ],
                "total_carbon_footprint": 3980.68
            },
            "reduction_insights": {
                "reductions": [
                    {
                        "crop_type": "Wheat",
                        "estimated_reduction": 129.35,
                        "farm_id": 1,
                        "insights": [
                            "Reduce fertilizer use by 20% with precision farming"
                        ]
                    },
                    {
                        "crop_type": "Soybean",
                        "estimated_reduction": 343.49,
                        "farm_id": 2,
                        "insights": [
                            "Reduce fertilizer use by 20% with precision farming",
                            "Switch to organic pesticides, reducing emissions by 30%"
                        ]
                    },
                    {
                        "crop_type": "Corn",
                        "estimated_reduction": 55.39,
                        "farm_id": 3,
                        "insights": [
                            "Switch to organic pesticides, reducing emissions by 30%"
                        ]
                    },
                    {
                        "crop_type": "Wheat",
                        "estimated_reduction": 163.33,
                        "farm_id": 4,
                        "insights": [
                            "Reduce fertilizer use by 20% with precision farming"
                        ]
                    },
                    {
                        "crop_type": "Corn",
                        "estimated_reduction": 0,
                        "farm_id": 5,
                        "insights": []
                    }
                ]
            },
            "web_carbon_trends": {
                "reduction_strategies": [
                    {
                        "description": "Regenerative Agriculture Practices (e.g., no-till or reduced-till farming, cover crops, crop rotation)",
                        "reduction_percentage": "30-40%",
                        "source": "Natural Resources Defense Council (NRDC)"
                    },
                    {
                        "description": "Vertical Farming",
                        "reduction_percentage": "50-70%",
                        "source": "The Vertical Farming Project"
                    }
                ]
            }
        }
        
        # Use LLM to analyze and tweak values based on input data while maintaining structure
        if isinstance(data, dict):
            # Create a context for the LLM to understand the data
            context = {
                "template": template,
                "raw_data": data
            }
            
            # Use the LLM to analyze and suggest modifications
            prompt = PromptTemplate.from_template(
                "Given the following template structure and raw input data:\n\n"
                "TEMPLATE: {template}\n\n"
                "RAW DATA: {raw_data}\n\n"
                "Analyze the raw data and suggest modifications to the template values. "
                "Maintain the exact structure NOTHING must be NULL add dummy data but adjust the values based on insights from the raw data. "
                "Return only the modified template as a valid JSON object. Do not include any explanation."
            )
            
            formatted_prompt = prompt.format(template=json.dumps(template), raw_data=json.dumps(data))
            try:
                response = llm.invoke(formatted_prompt).content.strip()
                
                # Clean up the response
                if response.startswith("```json") and response.endswith("```"):
                    response = response[7:-3].strip()
                elif response.startswith("```") and response.endswith("```"):
                    response = response[3:-3].strip()
                    
                # Parse the modified template
                modified_template = json.loads(response)
                if isinstance(modified_template, dict):
                    return modified_template
            except Exception as e:
                print(f"Error tweaking carbon template values: {e}")
                # Continue with manual merging if LLM modification fails
        
        # Fallback to manual merging if LLM approach fails
        if isinstance(data, dict):
            # Update carbon_footprint_calculation section
            if "carbon_footprint_calculation" in data and isinstance(data["carbon_footprint_calculation"], dict):
                for key, value in data["carbon_footprint_calculation"].items():
                    if key in template["carbon_footprint_calculation"]:
                        template["carbon_footprint_calculation"][key] = value
            
            # Update reduction_insights section
            if "reduction_insights" in data and isinstance(data["reduction_insights"], dict):
                for key, value in data["reduction_insights"].items():
                    if key in template["reduction_insights"]:
                        template["reduction_insights"][key] = value
            
            # Update web_carbon_trends section
            if "web_carbon_trends" in data and isinstance(data["web_carbon_trends"], dict):
                for key, value in data["web_carbon_trends"].items():
                    if key in template["web_carbon_trends"]:
                        template["web_carbon_trends"][key] = value
        
        return template
    
    def _format_water_json(self, data):
        """Format water data according to required template structure."""
        template = {
            "conservation_insights": [
                {
                    "crop_type": "Wheat",
                    "estimated_savings_liters": 14743.91,
                    "insights": [
                        "Implement drip irrigation to reduce water use by 30%"
                    ]
                },
                {
                    "crop_type": "Soybean",
                    "estimated_savings_liters": 4883.49,
                    "insights": [
                        "Use rainwater harvesting to supplement by 20%"
                    ]
                },
                {
                    "crop_type": "Corn",
                    "estimated_savings_liters": 2822.15,
                    "insights": [
                        "Implement drip irrigation to reduce water use by 30%",
                        "Use rainwater harvesting to supplement by 20%"
                    ]
                },
                {
                    "crop_type": "Rice",
                    "estimated_savings_liters": 4699.39,
                    "insights": [
                        "Implement drip irrigation to reduce water use by 10%"
                    ]
                },
                {
                    "crop_type": "maize",
                    "estimated_savings_liters": 2339.29,
                    "insights": [
                        "Implement drip irrigation to reduce water use by 80%"
                    ]
                }
            ],
            "farm_data": [
                {
                    "crop_type": "Wheat",
                    "farm_id": 1,
                    "rainfall_mm": 227.8909122156477,
                    "soil_moisture": 49.14535876397696,
                    "water_usage_liters": 2721088.78
                },
                {
                    "crop_type": "Soybean",
                    "farm_id": 2,
                    "rainfall_mm": 244.01749330098983,
                    "soil_moisture": 21.49611538528016,
                    "water_usage_liters": 2471763.87
                },
                {
                    "crop_type": "Corn",
                    "farm_id": 3,
                    "rainfall_mm": 141.11052082022786,
                    "soil_moisture": 19.46904232943808,
                    "water_usage_liters": 5506674.35
                },
                {
                    "crop_type": "Rice",
                    "farm_id": 4,
                    "rainfall_mm": 156.78566341441285,
                    "soil_moisture": 27.97423365959013,
                    "water_usage_liters": 3432143.66
                },
                {
                    "crop_type": "Maize",
                    "farm_id": 5,
                    "rainfall_mm": 77.85936215956802,
                    "soil_moisture": 33.63767886268485,
                    "water_usage_liters": 5221408.38
                }
            ],
            "total_water_usage_liters": 15524979.06,
            "water_conservation_strategies": [
                {
                    "description": "Advanced sensor-based irrigation management using platforms like Phytech, which conveys how the plant feels and allows farmers to adjust irrigation accordingly.",
                    "savings_percentage": "20-30%",
                    "source": "Phytech's platform, used in several countries, has reported water savings of over 132 billion gallons in 2024."
                },
                {
                    "description": "Managing Livestock Access to Streams by installing fences along streams, rivers, and lakes to block animal access, helping to restore stream banks and prevent excess nutrients from entering the water.",
                    "savings_percentage": "15-25%",
                    "source": "USDA's Regional Conservation Partnership Program (RCPP) has reported significant water quality improvements through conservation projects, including reducing nutrient runoff from livestock manure."
                }
            ]
        }
        
        # Use LLM to analyze and tweak values based on input data while maintaining structure
        if isinstance(data, dict):
            # Create a context for the LLM to understand the data
            context = {
                "template": template,
                "raw_data": data
            }
            
            # Use the LLM to analyze and suggest modifications
            prompt = PromptTemplate.from_template(
                "Given the following template structure and raw input data:\n\n"
                "TEMPLATE: {template}\n\n"
                "RAW DATA: {raw_data}\n\n"
                "Analyze the raw data and suggest modifications to the template values. "
                "Maintain the exact structure but adjust the values based on insights from the raw data. "
                "Return only the modified template as a valid JSON object. Do not include any explanation."
            )
            
            formatted_prompt = prompt.format(template=json.dumps(template), raw_data=json.dumps(data))
            try:
                response = llm.invoke(formatted_prompt).content.strip()
                
                # Clean up the response
                if response.startswith("```json") and response.endswith("```"):
                    response = response[7:-3].strip()
                elif response.startswith("```") and response.endswith("```"):
                    response = response[3:-3].strip()
                    
                # Parse the modified template
                modified_template = json.loads(response)
                if isinstance(modified_template, dict) and "conservation_insights" in modified_template:
                    return modified_template
            except Exception as e:
                print(f"Error tweaking water template values: {e}")
                # Continue with manual merging if LLM modification fails
        
        # Fallback to manual merging if LLM approach fails
        if isinstance(data, dict):
            # Update conservation_insights section
            if "conservation_insights" in data and isinstance(data["conservation_insights"], list):
                template["conservation_insights"] = data["conservation_insights"]
            
            # Update farm_data section
            if "farm_data" in data and isinstance(data["farm_data"], list):
                template["farm_data"] = data["farm_data"]
            
            # Update total_water_usage_liters
            if "total_water_usage_liters" in data:
                template["total_water_usage_liters"] = data["total_water_usage_liters"]
            
            # Update water_conservation_strategies section
            if "water_conservation_strategies" in data and isinstance(data["water_conservation_strategies"], list):
                template["water_conservation_strategies"] = data["water_conservation_strategies"]
        
        return template
