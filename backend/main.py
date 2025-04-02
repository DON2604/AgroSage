from agents.sustainability_agent import farm_advisor
from agents.weather_agent import w_agent

if __name__ == "__main__":
    location = "Kolkata"
    #print(w_agent(location))  
    sustainibility_agent_res=farm_advisor("Wheat")
    #print(sustainibility_agent_res)
