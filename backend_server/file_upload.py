from fastapi import APIRouter, File, UploadFile, Query, HTTPException
from supabase import create_client, Client
from fastapi.responses import JSONResponse
# Replace with your actual credentials
SUPABASE_URL = "https://alxtxsmnyjkbjcjhgsqu.supabase.co"
SUPABASE_SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFseHR4c21ueWprYmpjamhnc3F1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTcxODM4MywiZXhwIjoyMDY3Mjk0MzgzfQ.qAx_tLPW0uNQPYDPkQinPnVPF3ZXl2NQ-fnISFGykZk"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

router = APIRouter()

@router.post("/upload/{user_id}/{ca_id}")
async def upload_file(
    user_id: int,
    ca_id: int,
    file: UploadFile = File(...),
    doc_type: str = Query(..., description="Document type: NID, TIN, Salary Certificate, Bank Statement, Audit Report")
):
    try:
        # Sanitize and format doc_type
        sanitized_doc_type = doc_type.strip().replace(" ", "_").lower()

        # Create file path
        file_path = f"client{user_id}/ca{ca_id}/{sanitized_doc_type}.pdf"

        # Read file content
        contents = await file.read()

        bucket = supabase.storage.from_("client-documents")

        # Try to delete existing file (if any)
        try:
            bucket.remove([file_path])
        except Exception as e:
            # It's okay if file doesn't exist
            pass

        # Upload new file
        bucket.upload(
            path=file_path,
            file=contents,
            file_options={"content-type": file.content_type}
        )

        return {
            "message": "File uploaded successfully",
            "file_path": file_path
        }

    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})
    
@router.get("/download-url/{user_id}/{ca_id}")
def generate_download_url(
    user_id: int,
    ca_id: int,
    doc_type: str = Query(...)
):
    # Mapping user input to actual file names
    mapping = {
        "nid": "nid",
        "tin": "tin",
        "tin certificate": "tin",
        "salary certificate": "salary_certificate",
        "bank statement": "bank_statement",
        "audit report": "audit_report",
    }
    key = doc_type.strip().lower()
    file_name = mapping.get(key)
    if not file_name:
        raise HTTPException(status_code=400, detail="Invalid doc_type")

    file_path = f"client{user_id}/ca{ca_id}/{file_name}.pdf"

    try:
        signed_url = supabase.storage.from_("client-documents").create_signed_url(
            file_path,
            expires_in=3600
        )
        return {"url": signed_url["signedURL"]}
    except Exception:
        raise HTTPException(status_code=404, detail=f"File not found at path: {file_path}")

@router.get("/check-file-exists/{client_id}/{ca_id}")
def check_audit_file_exists(client_id: int, ca_id: int):
    try:
        folder_path = f"client{client_id}/ca{ca_id}"
        result = supabase.storage.from_("client-documents").list(folder_path)

        for obj in result:
            if obj.get("name") == "audit_report.pdf":
                return {"exists": True}
        return {"exists": False}
    except Exception as e:
        return {"exists": False, "error": str(e)}

