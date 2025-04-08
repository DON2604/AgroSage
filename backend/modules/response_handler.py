import json
import os

def get_responses():
    # Correct the file path to point to the actual location of response.json
    file_path = os.path.join(os.path.dirname(__file__), '../db/response.json')
    if not os.path.exists(file_path):
        return None

    with open(file_path, 'r') as file:
        data = json.load(file)
        # Return all responses
        return data.get('responses', [])
