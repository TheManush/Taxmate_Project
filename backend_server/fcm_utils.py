import json
import requests
from google.oauth2 import service_account
from google.auth.transport.requests import Request

def send_fcm_v1_notification(token, title, body, data=None):
    
    SERVICE_ACCOUNT_FILE = r"C:\Users\hp\Desktop\FlutterMane\Taxmate_Project\Taxmate_Project\backend_server\test-f21bc-firebase-adminsdk-fbsvc-ac09f2676f.json"
    PROJECT_ID = "test-f21bc"

    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_FILE,
        scopes=["https://www.googleapis.com/auth/firebase.messaging"],
    )
    credentials.refresh(Request())
    access_token = credentials.token

    url = f"https://fcm.googleapis.com/v1/projects/{PROJECT_ID}/messages:send"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json; UTF-8",
    }
    # Ensure all data values are strings
    data_str = {k: str(v) for k, v in (data or {}).items()}
    message = {
        "message": {
            "token": token,
            "notification": {
                "title": title,
                "body": body,
            },
            "data": data_str,
        }
    }
    print("Sending to FCM token:", token)
    response = requests.post(url, headers=headers, data=json.dumps(message))
    print("FCM response:", response.status_code, response.text)
    return response.json()
