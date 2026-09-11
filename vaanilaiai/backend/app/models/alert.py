"""Disaster and weather alert database model."""
from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, Float
from app.core.database import Base


def utc_now():
    return datetime.now(timezone.utc)


class DisasterAlert(Base):
    __tablename__ = "disaster_alerts"

    id = Column(Integer, primary_key=True, index=True)
    alert_id = Column(String(100), unique=True, index=True, nullable=False)
    source = Column(String(50), default="IMD", nullable=False)
    category = Column(String(50), nullable=False)
    severity = Column(String(20), nullable=False)
    urgency = Column(String(20), default="Immediate", nullable=False)
    headline = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    instruction = Column(Text, nullable=True)
    area_description = Column(String(255), nullable=False)
    district = Column(String(100), nullable=True, index=True)
    state = Column(String(100), nullable=True, index=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    effective_from = Column(DateTime, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False, index=True)
    created_at = Column(DateTime, default=utc_now, nullable=False)
