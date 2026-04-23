from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.routes import router
import traceback

app = FastAPI(title="OptiFlow Slice 4 - Resource Management API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    error_detail = traceback.format_exc()
    print("🔴 ERROR:", error_detail)
    return JSONResponse(status_code=500, content={"detail": error_detail})

app.include_router(router, prefix="/api")

@app.get("/")
def root():
    return {"message": "OptiFlow Slice 4 API is running ✅"}