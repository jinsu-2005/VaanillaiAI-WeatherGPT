"""Pydantic schemas for Disaster and Severe Weather Warnings."""
from datetime import datetime
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict


class AlertSeverity(str, Enum):
    RED = "Red"          # Take Action (Warning)
    ORANGE = "Orange"    # Be Prepared (Alert)
    YELLOW = "Yellow"    # Be Updated (Watch)
    GREEN = "Green"      # No Warning


class DisasterAlertResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: Optional[int] = None
    alert_id: str
    source: str = Field(..., description="Issuing agency, e.g. IMD, NDMA, CWC")
    category: str = Field(..., description="Type of disaster, e.g. Heavy Rainfall, Cyclone, Lightning, Heatwave, Flood")
    severity: AlertSeverity
    urgency: str = "Immediate"
    headline: str
    description: str
    instruction: Optional[str] = None
    area_description: str
    district: Optional[str] = None
    state: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    effective_from: datetime
    expires_at: datetime
    is_active: bool = True
    color_hex: str = Field("#E53E3E", description="UI color code for severity")


class AlertSummary(BaseModel):
    total_active_alerts: int
    highest_severity: AlertSeverity
    alerts: List[DisasterAlertResponse]
