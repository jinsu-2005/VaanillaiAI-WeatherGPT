"""Conversational AI chat session and message database models."""
from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from app.core.database import Base


def utc_now():
    return datetime.now(timezone.utc)


class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    session_id = Column(String(64), unique=True, index=True, nullable=False)
    title = Column(String(200), default="Weather Query", nullable=False)
    language = Column(String(10), default="en", nullable=False)
    created_at = Column(DateTime, default=utc_now, nullable=False)
    updated_at = Column(DateTime, default=utc_now, onupdate=utc_now, nullable=False)

    # Relationships
    user = relationship("User", back_populates="conversations")
    messages = relationship("ChatMessage", back_populates="conversation", cascade="all, delete-orphan", order_by="ChatMessage.created_at")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False, index=True)
    role = Column(String(20), nullable=False)  # 'user', 'assistant', 'system', 'tool'
    content = Column(Text, nullable=False)
    language = Column(String(10), default="en", nullable=False)
    tool_calls = Column(JSON, nullable=True)          # List of tools invoked
    weather_context = Column(JSON, nullable=True)     # Snapshot of weather data fetched
    grounded_citations = Column(JSON, nullable=True)  # Official citations (e.g. IMD Bulletin, NWP ECMWF)
    created_at = Column(DateTime, default=utc_now, nullable=False)

    # Relationships
    conversation = relationship("Conversation", back_populates="messages")
