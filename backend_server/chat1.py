
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlalchemy.orm import Session
from database import SessionLocal, get_db
from models import Message, User
from fcm_utils import send_fcm_v1_notification
from datetime import datetime, timezone

chat_router = APIRouter()
connected_users = {}

# WebSocket for live chat
@chat_router.websocket("/ws/chat/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    await websocket.accept()
    connected_users[user_id] = websocket

    try:
        while True:
            data = await websocket.receive_json()
            receiver_id = data["receiver_id"]
            message = data["message"]

            # Save to database
            db = SessionLocal()
            new_message = Message(
                sender_id=user_id,
                receiver_id=receiver_id,
                message=message,
                timestamp=datetime.now(timezone.utc)
            )
            db.add(new_message)
            db.commit()

            # Forward message if receiver is online
            if receiver_id in connected_users:
                try:
                    await connected_users[receiver_id].send_json({
                        "sender_id": user_id,
                        "message": message
                    })
                except Exception:
                    # Remove user if their websocket is closed or errored
                    connected_users.pop(receiver_id, None)
            else:
                # Send FCM notification if receiver is offline
                receiver = db.query(User).filter(User.id == receiver_id).first()
                sender = db.query(User).filter(User.id == user_id).first()
                if receiver and receiver.fcm_token:
                    send_fcm_v1_notification(
                        receiver.fcm_token,
                        title=sender.full_name if sender else str(user_id),  # sender's name as title
                        body=message,
                        data={
                            "sender_id": user_id,
                            "sender_name": sender.full_name if sender else str(user_id),
                            "message": message
                        }
                    )
            db.close()

    except WebSocketDisconnect:
        connected_users.pop(user_id, None)

# HTTP GET for chat history
@chat_router.get("/chat-history/{user1_id}/{user2_id}")
def get_chat_history(user1_id: int, user2_id: int, db: Session = Depends(get_db)):
    messages = db.query(Message).filter(
        ((Message.sender_id == user1_id) & (Message.receiver_id == user2_id)) |
        ((Message.sender_id == user2_id) & (Message.receiver_id == user1_id))
    ).order_by(Message.timestamp).all()

    return [
        {
            "sender_id": msg.sender_id,
            "receiver_id": msg.receiver_id,
            "message": msg.message,
            "timestamp": msg.timestamp.isoformat()
        } for msg in messages
    ]
