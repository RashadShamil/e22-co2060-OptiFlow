import os
from supabase import create_client, Client
from datetime import datetime, timedelta

# --- 1. CONFIGURATION (Paste your keys here) ---
url = "https://rtqgwssnrqjjmgpnttgq.supabase.co"  
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0cWd3c3NucnFqam1ncG50dGdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2MTg2MDMsImV4cCI6MjA4NTE5NDYwM30.9xXUA7MxrLgPMi2P9GmcyAnbU242xRgvbmenNLg8iE4"     
supabase: Client = create_client(url, key)

# --- 2. THE BOUNCER LOGIC ---
def check_availability(machine_id, new_start_str, new_end_str):
    """
    Checks if a machine is free during the requested slot.
    Returns: True (Available), False (Conflict)
    """
    print(f"\n Checking availability for Machine...")
    machine_info = supabase.table('machine').select("status").eq("id",machine_id),execute()
    if machine_info.data and machine_info.data[0]['status'] != 'ACTIVE':
        print(f"MACHINE DOWN Status is: {machine_info.data[0]['status']}")
        return False
    
    # A. Fetch all EXISTING bookings for this machine
    response = supabase.table('bookings').select("*").eq("machine_id", machine_id).execute()
    existing_bookings = response.data
    
    # B. Convert string inputs to computer time objects
    #    Format expected: "2026-01-30 14:00:00"
    new_start = datetime.strptime(new_start_str, "%Y-%m-%d %H:%M:%S")
    new_end = datetime.strptime(new_end_str, "%Y-%m-%d %H:%M:%S")

    # C. The "Overlap" Algorithm
    for booking in existing_bookings:
        # Clean up Supabase time format (remove the 'T' and timezone)
        clean_start = booking['start_time'].split('+')[0].replace('T', ' ')
        clean_end = booking['end_time'].split('+')[0].replace('T', ' ')
        
        existing_start = datetime.strptime(clean_start, "%Y-%m-%d %H:%M:%S")
        existing_end = datetime.strptime(clean_end, "%Y-%m-%d %H:%M:%S")
        
        # THE MATH: A conflict happens if:
        # (New Start is BEFORE Existing End) AND (New End is AFTER Existing Start)
        if new_start < existing_end and new_end > existing_start:
            print(f"❌ CONFLICT! Overlaps with booking: {clean_start} to {clean_end}")
            return False # Block the booking

    print("✅ Slot is Clear! Booking allowed.")
    return True

def create_booking(machine_id, user_name, start_time, end_time):
    """
    Tries to save a booking ONLY if the slot is clear.
    """
    # 1. Ask the 'Bouncer' if we can enter
    is_available = check_availability(machine_id, start_time, end_time)
    
    if is_available:
        # 2. If yes, insert the data
        data = {
            "machine_id": machine_id,
            "user_name": user_name,
            "start_time": start_time,
            "end_time": end_time
        }
        supabase.table('bookings').insert(data).execute()
        print("🎉 Booking Successfully Saved to Database!")
    else:
        print("⛔ Booking Rejected: Slot is busy.")

# --- 3. TEST ZONE ---
if __name__ == "__main__":
    # We need a valid Machine ID to test. 
    # I've put a placeholder here. You need to replace it with a real ID.
    
    TEST_MACHINE_ID = "1754f1fd-6225-4b11-927b-dec5e7f66eb6" 
    
    # Scenario:
    # Rashad books 2:00 PM - 3:00 PM. (Should Work)
    # Sulakshan tries to book 2:30 PM - 3:30 PM. (Should Fail)
    
    print("--- Test 1: Rashad books the slot ---")
    create_booking(TEST_MACHINE_ID, "Rashad", "2026-02-15 14:00:00", "2026-02-15 15:00:00")
    
    print("\n--- Test 2: Sulakshan tries to steal the slot ---")
    create_booking(TEST_MACHINE_ID, "Sulakshan", "2026-02-15 12:01:00", "2026-02-15 11:00:00")