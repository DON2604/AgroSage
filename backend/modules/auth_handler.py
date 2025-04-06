import sqlite3
import os
import hashlib
from pathlib import Path

def hash_password(password):
    """Hash a password for storing."""
    return hashlib.sha256(password.encode()).hexdigest()

def register_user(name, email, password):
    """Register a new user in the database."""
    try:
        script_dir = Path(__file__).parent.absolute()
        db_path = script_dir.parent / "db" / "farming_memory.db"
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Check if email already exists
        cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
        if cursor.fetchone():
            conn.close()
            return {"success": False, "message": "Email already registered"}
        
        # Hash the password before storing
        hashed_password = hash_password(password)
        
        # Insert new user
        cursor.execute(
            "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
            (name, email, hashed_password)
        )
        conn.commit()
        conn.close()
        return {"success": True, "message": "Registration successful"}
    except Exception as e:
        return {"success": False, "message": f"Registration failed: {str(e)}"}

def login_user(email, password):
    """Authenticate a user."""
    try:
        script_dir = Path(__file__).parent.absolute()
        db_path = script_dir.parent / "db" / "farming_memory.db"
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Hash the password for comparison
        hashed_password = hash_password(password)
        
        # Check credentials
        cursor.execute("SELECT id, name FROM users WHERE email = ? AND password = ?", 
                      (email, hashed_password))
        user = cursor.fetchone()
        conn.close()
        
        if user:
            return {"success": True, "message": "Login successful", "user_id": user[0], "name": user[1]}
        else:
            return {"success": False, "message": "Invalid email or password"}
    except Exception as e:
        return {"success": False, "message": f"Login failed: {str(e)}"}
