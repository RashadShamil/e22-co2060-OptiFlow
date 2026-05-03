import os
import uuid
from supabase import create_client
from dotenv import load_dotenv

def seed_database():
    load_dotenv(".env.local")
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_KEY")
    
    if not url or not key:
        print("Missing Supabase credentials in .env.local")
        return
        
    client = create_client(url, key)
    
    print("Seeding database...")
    
    # 1. Check existing resources
    existing_humans = client.table("resources").select("*").eq("type", "HUMAN").execute()
    
    if len(existing_humans.data) == 0:
        print("Inserting team members (HUMAN resources)...")
        team_members = [
            {"id": str(uuid.uuid4()), "name": "Alex Carter", "type": "HUMAN", "status": "ACTIVE"},
            {"id": str(uuid.uuid4()), "name": "Sarah Jenkins", "type": "HUMAN", "status": "IDLE"},
            {"id": str(uuid.uuid4()), "name": "Mike Ross", "type": "HUMAN", "status": "OFFLINE"},
            {"id": str(uuid.uuid4()), "name": "Emily Davis", "type": "HUMAN", "status": "ACTIVE"},
            {"id": str(uuid.uuid4()), "name": "David Wilson", "type": "HUMAN", "status": "OFFLINE"},
            {"id": str(uuid.uuid4()), "name": "Jessica Taylor", "type": "HUMAN", "status": "ACTIVE"},
        ]
        client.table("resources").insert(team_members).execute()
        print(f"Inserted {len(team_members)} team members.")
    else:
        print(f"Found {len(existing_humans.data)} existing team members. Skipping insertion.")

    print("Database seeding check complete.")

if __name__ == "__main__":
    seed_database()
