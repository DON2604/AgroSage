from agents import market_trend_agent
from agents.sustainability_agent import farm_advisor
from agents.weather_agent import w_agent
from agents.market_trend_agent import market_trend_analyzer
from agents.carbon_footprint_agent import carbon_footprint_analyzer
from agents.water_usage import water_usage_tracker_agent

if __name__ == "__main__":
    location = "Kolkata"
    #print(w_agent(location))  
    #sustainibility_agent_res=farm_advisor("Wheat")
    #market_trend_analyzer("wheat")
    #print(sustainibility_agent_res)
    #carbon_footprint_analyzer()
    water_usage_tracker_agent()
