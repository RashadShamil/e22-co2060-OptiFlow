import os 
from supabase import create_client, Client

url = "https://rtqgwssnrqjjmgpnttgq.supabase.co"  
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ0cWd3c3NucnFqam1ncG50dGdxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2MTg2MDMsImV4cCI6MjA4NTE5NDYwM30.9xXUA7MxrLgPMi2P9GmcyAnbU242xRgvbmenNLg8iE4"     

def test_the_brain():

    print("Connecting to Supabase.")
    supabase: Client = create_client(url,key)

    print("Connected. Time for Data.")
    response = supabase.table('machines').select("*").execute()
    data = response.data

    if len(data)>0:
        print("Getting Data")
        for machines in data:
            print(f" - {machines['name']} (Status: {machines['status']})")
    else:
        print("Not Connected")

if __name__ == "__main__":
    test_the_brain()

            