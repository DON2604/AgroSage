from langchain_groq import ChatGroq
from langchain.prompts import PromptTemplate
from dotenv import load_dotenv
import os
import json

load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

llm = ChatGroq(
    model_name="llama3-70b-8192",
    temperature=0.7,
    groq_api_key=groq_api_key
)

def feedback_agent(query):

    prompt_template = PromptTemplate(
        input_variables=["query"],
        template="""
        Generate 8 concise, actionable feedback points for a farmer based on this query: "{query}"
        
        Each point should:
        1. Start with "Point X: " (where X is the point number 1-8)
        2. Be relevant to sustainable farming, agricultural techniques, or market insights
        3. Provide practical advice
        4. Be concise (one line per point)
        
        Format your response as a JSON array of exactly 8 string items, with no additional commentary.
        Example format: ["Point 1: First point", "Point 2: Second point", ...]
        """
    )
    
    prompt = prompt_template.format(query=query)
   
    llm_response = llm.invoke(prompt)

    try:
 
        content = llm_response.content
        start_idx = content.find('[')
        end_idx = content.rfind(']') + 1
        
        if start_idx != -1 and end_idx != -1:
            json_str = content[start_idx:end_idx]
            feedback_points = json.loads(json_str)
        else:
            feedback_points = [
                f"Point 1: Addressing '{query}' requires careful consideration",
                "Point 2: Consider sustainable farming practices",
                "Point 3: Water conservation is critical for agricultural success",
                "Point 4: Crop rotation improves soil health and yield",
                "Point 5: Modern agricultural technology can improve efficiency",
                "Point 6: Climate-resistant crop varieties may help future-proof your farm",
                "Point 7: Local market trends should inform planting decisions",
                "Point 8: Community knowledge sharing is valuable for innovation"
            ]
    except Exception:
        feedback_points = [
            f"Point 1: Addressing '{query}' requires careful consideration",
            "Point 2: Consider sustainable farming practices",
            "Point 3: Water conservation is critical for agricultural success",
            "Point 4: Crop rotation improves soil health and yield",
            "Point 5: Modern agricultural technology can improve efficiency",
            "Point 6: Climate-resistant crop varieties may help future-proof your farm",
            "Point 7: Local market trends should inform planting decisions",
            "Point 8: Community knowledge sharing is valuable for innovation"
        ]

    response = {
        "data": {
            "query": query,
            "feedback": feedback_points,
            "timestamp": "Generated pointwise feedback for query"
        },
        "success": True
    }
    
    return response