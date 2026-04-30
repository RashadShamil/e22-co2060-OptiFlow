import os
from supabase import create_client, Client
from dotenv import load_dotenv

# =====================================================================
# DATABASE CONNECTION MANAGER
# =====================================================================

# 1. Load the environment variables from the .env / .env.local file.
# This keeps your secret keys safe and out of the public codebase.
load_dotenv()

# 2. Extract the URL and API Key
url: str = os.environ.get("SUPABASE_URL")
key: str = os.environ.get("SUPABASE_KEY")

# 3. Create the single, centralized Supabase client.cd

# By doing this here, every other file in the project (like routes.py 
# and optimizer.py) can just import this one 'supabase' variable 
# instead of creating a new connection every time.
supabase: Client = create_client(url, key)