import streamlit as st
import requests
import pandas as pd

# 1. SETUP: API Connection
API_URL = "http://127.0.0.1:8000"

st.set_page_config(page_title="OptiFlow Command Center", layout="wide")
st.title("OptiFlow Manager Dashboard - Team Nexus")

# --- SECTION 0: SYSTEM HEALTH CHECK ---
try:
    # Ping the API to make sure it's alive
    response = requests.get(f"{API_URL}/")
    st.sidebar.success(f"Backend: {response.json()['status']}") # Moved to sidebar for cleaner look
except:
    st.error("CRITICAL: Backend is OFFLINE. Run 'uvicorn main:app --reload' first.")
    st.stop()





    
col1, col2 = st.columns(2)

# --- LEFT COLUMN: UPDATE MACHINE STATUS ---
with col1:
    st.subheader("Post New Machine")
    
    machine_name = st.text_input("Machine Name", placeholder="e.g. Ultimaker")
    
    c1, c2 = st.columns(2)
    price_per_hour = c1.number_input("Price Per Hour (LKR)", min_value=0, step=500)
    status = c2.radio(
    "Machine Status",
    ["ACTIVE", "MAINTENANCE", "BROKEN"]
    )

    
    image_url = st.text_input("Image_url", value="OptiFlow.png")

    if image_url:
        try:
            st.image(image_url, width=300, caption="Preview")
        except:
            st.warning("Invalid Image URL. Please paste a valid link starting with http/https")
    
    if st.button("Post Machine to Board"):
        job_data = {
            "name": machine_name,
            "price_per_hour": int(price_per_hour),
            "status": status,
            "image_url": image_url
        }
        
        post_res = requests.post(f"{API_URL}/create_machine", json=job_data)
        
        if post_res.status_code == 200:
            st.balloons() 
            st.success("Job Posted Successfully!")
        else:
            st.error("Failed to post job.")
            st.code(post_res.text) # Show technical error for debugging

# --- RIGHT COLUMN: POST NEW JOB ---
with col2:
    st.subheader("Post New Work")
    
    job_title = st.text_input("Job Title", placeholder="e.g. Bind 50 Thesis Books")
    
    c1, c2 = st.columns(2)
    price = c1.number_input("Price (LKR)", min_value=0, step=500)
    hours = c2.number_input("Est. Hours", min_value=1, step=1)
    
    deadline = st.text_input("Deadline", value="2026-02-20 14:00:00")
    
    if st.button("Post Job to Board"):
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

st.divider()
st.header("Machine Fleet Status")

if st.button("Refresh Machines"):
    st.rerun()

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


# --- SECTION 2: LIVE JOB BOARD ---
st.divider()
st.header("Live Job Board")

if st.button("Refresh Jobs"):
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

