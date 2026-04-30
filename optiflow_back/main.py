# =====================================================================
# IMPORTS: The core building blocks of our web server
# =====================================================================
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import traceback

# Here we import the "router" object we just built in routes.py.
# Think of the router as a giant power strip that holds all our endpoints.
from app.routes import router 

# =====================================================================
# 1. APPLICATION BOOTSTRAP
# =====================================================================
# This line creates the actual web server. When uvicorn runs, it looks 
# specifically for this 'app' variable.
app = FastAPI(
    title="OptiFlow Enterprise API",
    description="The centralized backend for the OptiFlow Print Shop Scheduler.",
    version="2.0.0"
)

# =====================================================================
# 2. CORS MIDDLEWARE (The Security Guard)
# =====================================================================
# "Middleware" is code that runs before your actual API endpoints do.
# CORS (Cross-Origin Resource Sharing) is a browser security feature.
# By default, a web browser (or Flutter web app) running on localhost:3000 
# is mathematically forbidden from talking to an API on localhost:8000.
app.add_middleware(
    CORSMiddleware,
    # allow_origins=["*"] means "Let ANY website or app talk to this API." 
    # For production, you would change this to your specific Flutter web URL.
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"], # Allow GET, POST, PUT, PATCH, DELETE
    allow_headers=["*"], # Allow all types of data headers
)

# =====================================================================
# 3. GLOBAL EXCEPTION HANDLER (The Safety Net)
# =====================================================================
# If your C++ engine crashes, or a database query fails, Python usually 
# panics and stops the server. This decorator catches ANY completely 
# unhandled error before it kills the server.
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # traceback.format_exc() gets the exact line number and error message
    error_detail = traceback.format_exc()
    
    # Print it to the terminal so YOU (the developer) can fix it
    print("CRITICAL SERVER ERROR:\n", error_detail)
    
    # Send a clean 500 error code back to the Flutter app so it doesn't 
    # freeze, but instead shows a "Server Offline" message to the user.
    return JSONResponse(status_code=500, content={"detail": "Internal Server Error. The engineering team has been notified."})

# =====================================================================
# 4. ROUTER INCLUSION (The Traffic Director)
# =====================================================================
# Instead of writing all 50 of our API endpoints in this one file (which 
# would be a nightmare to read), we wrote them in routes.py. 
# This line plugs that "power strip" into the main server.
# The prefix="/api" means every route automatically gets /api added to it.
# (e.g., "/resources" becomes "/api/resources")
app.include_router(router, prefix="/api")

# =====================================================================
# 5. ROOT ENDPOINT (The Pulse Check)
# =====================================================================
# A very simple route just to check if the server is awake.
@app.get("/")
def root():
    return {"message": "OptiFlow Enterprise Engine is Online and Ready. ✅"}