import streamlit as st
import requests
import pandas as pd

# 1. SETUP: API Connection
API_URL = "http://127.0.0.1:8000"

st.set_page_config(page_title="OptiFlow Command Center", layout="wide")
st.title("🖨️ OptiFlow Manager Dashboard - Team Nexus")

# --- SECTION 0: SYSTEM HEALTH CHECK ---
try:
    # Ping the API to make sure it's alive
    response = requests.get(f"{API_URL}/")
    st.sidebar.success(f"Backend: {response.json()['status']}") # Moved to sidebar for cleaner look
except:
    st.error("🚨 CRITICAL: Backend is OFFLINE. Run 'uvicorn main:app --reload' first.")
    st.stop()


# --- SECTION 1: MACHINE FLEET STATUS ---
st.header("1. Machine Fleet Status")

# A. Fetch the list of machines from the API
# (This requires the new @app.get("/machines") endpoint in main.py)
res = requests.get(f"{API_URL}/machines")

if res.status_code == 200:
    machines_data = res.json()['machines']
    
    # B. Display the Live Table
    # We use Pandas to create a clean view of the fleet
    if machines_data:
        df_machines = pd.DataFrame(machines_data)
        # Show name, status, and ID (hidden index)
        st.dataframe(
            df_machines[['name', 'status', 'id']], 
            use_container_width=True,
            hide_index=True
        )

    # --- CONTROL PANEL (Split into two columns) ---
    st.divider()
    col1, col2 = st.columns(2)

    # --- LEFT COLUMN: UPDATE MACHINE STATUS ---
    with col1:
        st.subheader("🔧 Maintenance Switch")
        
        if machines_data:
            # 1. Create a Dictionary map: {"Ultimaker S5": "550e84...", "Formlabs": "a1b2..."}
            # This lets us show the Name but use the ID in the background.
            machine_options = {m['name']: m['id'] for m in machines_data}
            
            # 2. The Dropdown (Selectbox)
            selected_name = st.selectbox("Select Machine:", list(machine_options.keys()))
            
            # 3. Retrieve the ID based on the selection
            selected_id = machine_options[selected_name]
            
            # 4. Status Selector
            status_choice = st.selectbox("Set Status:", ["ACTIVE", "MAINTENANCE", "BROKEN"])

            if st.button("Update Machine Status"):
                # Call the API with the specific ID
                payload = {"status": status_choice}
                patch_res = requests.patch(f"{API_URL}/machines/{selected_id}", json=payload)

                if patch_res.status_code == 200:
                    st.toast(f"✅ {selected_name} updated to {status_choice}!")
                    st.rerun() # Refresh the page instantly to show the change in the table
                else:
                    st.error(f"Error: {patch_res.text}")
        else:
            st.warning("No machines found in database.")

    # --- RIGHT COLUMN: POST NEW JOB ---
    with col2:
        st.subheader("📢 Post New Work")
        
        job_title = st.text_input("Job Title", placeholder="e.g. Bind 50 Thesis Books")
        
        c1, c2 = st.columns(2)
        price = c1.number_input("Price (LKR)", min_value=0, step=500)
        hours = c2.number_input("Est. Hours", min_value=1, step=1)
        
        deadline = st.text_input("Deadline", value="2026-02-20 14:00:00")
        
        if st.button("🚀 Post Job to Board"):
            job_data = {
                "title": job_title,
                "price": int(price),
                "estimated_hours": int(hours),
                "deadline": deadline
            }
            
            post_res = requests.post(f"{API_URL}/create_job", json=job_data)
            
            if post_res.status_code == 200:
                st.balloons() 
                st.success("Job Posted Successfully!")
            else:
                st.error("Failed to post job.")
                st.code(post_res.text) # Show technical error for debugging

else:
    st.error("⚠️ Could not load machines. Did you add the '/machines' endpoint to main.py?")


# --- SECTION 2: LIVE JOB BOARD ---
st.divider()
st.header("📋 Live Job Board")

if st.button("Refresh Board"):
    st.rerun()

# Fetch jobs from API
jobs_res = requests.get(f"{API_URL}/jobs")

if jobs_res.status_code == 200:
    jobs_data = jobs_res.json()['jobs']
    
    if jobs_data:
        df = pd.DataFrame(jobs_data)
        # Select clean columns
        clean_table = df[['title', 'price', 'status', 'deadline', 'estimated_hours']]
        st.dataframe(clean_table, use_container_width=True)
    else:
        st.info("No open jobs right now. The board is empty.")