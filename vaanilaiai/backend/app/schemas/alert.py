"""Pydantic schemas for Disaster and Severe Weather Warnings."""
from datetime import datetime, timezone
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
    cap_identifier: Optional[str] = Field(None, description="NDMA Sachet OASIS CAP-XML Identifier")
    polygon_url: Optional[str] = Field(None, description="Sachet NDMA CAP Polygon XML endpoint")
    vernacular_headline: Optional[str] = Field(None, description="Vernacular / regional language headline (e.g. Hindi, Tamil)")
    vernacular_language: Optional[str] = Field(None, description="ISO code or name of regional language")
    sender_org: Optional[str] = Field(None, description="Originating SDMA or central issuing authority")


class AlertSummary(BaseModel):
    total_active_alerts: int
    highest_severity: AlertSeverity
    alerts: List[DisasterAlertResponse]


class IMDWarningStage(BaseModel):
    code: str = Field(..., description="Green, Yellow, Orange, Red")
    name: str = Field(..., description="Stage name (e.g. Warning / Take Action)")
    action_required: str = Field(..., description="Official directive to public and administrators")
    impact_summary: str = Field(..., description="Expected physical severity and disruption")
    color_hex: str = Field(..., description="Official hex color code")
    precipitation_threshold: str = Field(..., description="Rainfall threshold in 24h")
    wind_threshold: str = Field(..., description="Sustained wind speed threshold")
    temperature_threshold: str = Field(..., description="Temperature departure threshold")


class HazardSOP(BaseModel):
    hazard_id: str = Field(..., description="Unique hazard slug (e.g. cyclone, heavy_rainfall)")
    title: str = Field(..., description="Display title of hazard")
    severity_level: str = Field(..., description="Standard trigger level (e.g. Orange / Red)")
    lead_time_phase: str = Field(..., description="Phase: Watch, Warning, Landfall, Recovery")
    immediate_actions: List[str] = Field(..., description="Top 3 urgent actions to execute immediately")
    dos: List[str] = Field(..., description="NDMA approved Do's")
    donts: List[str] = Field(..., description="NDMA approved Don'ts")
    vulnerable_guidance: str = Field(..., description="Special guidance for children, elderly, and livestock")


class EmergencyContact(BaseModel):
    name: str = Field(..., description="Service or authority name")
    phone_number: str = Field(..., description="Telephone number or shortcode")
    agency: str = Field(..., description="Agency acronym e.g. NDMA, SDMA, MoHFW")
    category: str = Field(..., description="Category: National, Disaster, Medical, Fire, District")
    availability: str = Field(default="24x7 Toll-Free")
    toll_free: bool = Field(default=True)


class IMDSOPResponse(BaseModel):
    warning_stages: List[IMDWarningStage]
    hazard_sops: List[HazardSOP]
    emergency_contacts: List[EmergencyContact]
    source: str = Field(default="IMD National Weather Forecasting Centre & NDMA SOP Guidelines")
    disclaimer: str = Field(
        default="Official standard operating procedures for disaster mitigation. In an active emergency, obey instructions from local district administration, NDRF, and SDMA."
    )
    generated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
