"""Conversational AI WeatherGPT Chat Endpoints."""
from typing import List
from fastapi import APIRouter, Depends, Path
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import get_db
from app.models.chat import Conversation, ChatMessage
from app.schemas.chat import ChatQueryRequest, ChatQueryResponse, ChatHistoryItem
from app.services.ai_agent import ai_agent

router = APIRouter()


@router.post("/message", response_model=ChatQueryResponse, summary="Send Message to WeatherGPT")
async def chat_message(
    payload: ChatQueryRequest,
    db: AsyncSession = Depends(get_db)
):
    """Send natural language question about weather, alerts, farm spraying, or travel.
    Supported in English, Tamil, and Hindi with Zero Hallucinations."""
    return await ai_agent.process_chat(payload, db=db)


@router.get("/history/{session_id}", response_model=List[ChatHistoryItem], summary="Get Conversation History")
async def get_history(
    session_id: str = Path(..., description="Conversation session UUID"),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve full conversation trajectory with tool calls and citations."""
    stmt = (
        select(ChatMessage)
        .join(Conversation)
        .where(Conversation.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
    )
    res = await db.execute(stmt)
    messages = res.scalars().all()
    return [ChatHistoryItem.model_validate(m) for m in messages]
