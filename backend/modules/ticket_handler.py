import os
import json

TICKETS_FILE = os.path.join(os.path.dirname(__file__), '../db/tickets.json')

def load_tickets():
    if not os.path.exists(TICKETS_FILE):
        return []
    with open(TICKETS_FILE, 'r') as file:
        return json.load(file)

def save_tickets(tickets):
    with open(TICKETS_FILE, 'w') as file:
        json.dump(tickets, file, indent=4)

def create_ticket(user_id, title, description):
    # Clear all previous tickets
    tickets = []
    ticket_id = 1
    new_ticket = {
        "id": ticket_id,
        "user_id": user_id,
        "title": title,
        "description": description,
        "responses": []
    }
    tickets.append(new_ticket)
    save_tickets(tickets)
    return {"success": True, "message": "Ticket created successfully", "ticket": new_ticket}

def get_all_tickets():
    return load_tickets()

def get_responses(ticket_id):
    tickets = load_tickets()
    for ticket in tickets:
        if ticket["id"] == ticket_id:
            return {"success": True, "responses": ticket["responses"]}
    return {"success": False, "message": "Ticket not found"}
