"""Disaster Management and Severe Weather Warning Service."""
import logging
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.alert import DisasterAlert
from app.providers.imd_provider import IMDAlertProvider
from app.schemas.alert import (
    DisasterAlertResponse,
    AlertSummary,
    AlertSeverity,
    IMDWarningStage,
    HazardSOP,
    EmergencyContact,
    IMDSOPResponse,
)

logger = logging.getLogger(__name__)


class DisasterService:
    """Disaster warning aggregator and risk evaluator for MoES/IMD disaster management."""

    def __init__(self):
        self.imd_provider = IMDAlertProvider()

    async def get_active_alerts(
        self,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        district: Optional[str] = None,
        state: Optional[str] = None,
        db: Optional[AsyncSession] = None
    ) -> AlertSummary:
        """Fetch active alerts and compute regional severity."""
        alerts: List[DisasterAlertResponse] = []

        # 1. Fetch live CAP / IMD alerts
        live_alerts = await self.imd_provider.get_active_alerts(lat=lat, lon=lon, district=district, state=state)
        alerts.extend(live_alerts)

        # 2. Check DB for persisted emergency warnings if available
        if db is not None:
            try:
                stmt = select(DisasterAlert).where(DisasterAlert.is_active == True)
                if district:
                    stmt = stmt.where(DisasterAlert.district.ilike(f"%{district}%"))
                res = await db.execute(stmt)
                db_alerts = res.scalars().all()
                for dba in db_alerts:
                    # avoid duplicate alert_id
                    if not any(a.alert_id == dba.alert_id for a in alerts):
                        alerts.append(DisasterAlertResponse.model_validate(dba))
            except Exception as e:
                logger.warning(f"Error querying DB for alerts: {e}")

        # Compute highest severity
        highest_severity = AlertSeverity.GREEN
        for a in alerts:
            if a.severity == AlertSeverity.RED:
                highest_severity = AlertSeverity.RED
                break
            elif a.severity == AlertSeverity.ORANGE and highest_severity != AlertSeverity.RED:
                highest_severity = AlertSeverity.ORANGE
            elif a.severity == AlertSeverity.YELLOW and highest_severity not in (AlertSeverity.RED, AlertSeverity.ORANGE):
                highest_severity = AlertSeverity.YELLOW

        return AlertSummary(
            total_active_alerts=len(alerts),
            highest_severity=highest_severity,
            alerts=alerts
        )

    def get_imd_sop_matrix(
        self,
        hazard: Optional[str] = None,
        state: Optional[str] = None
    ) -> IMDSOPResponse:
        """Official IMD 4-Stage Warning Criteria & NDMA Disaster Standard Operating Procedures (SOPs)."""
        warning_stages = [
            IMDWarningStage(
                code="Green",
                name="No Warning (Normal)",
                action_required="No action required. General activities can proceed without disruption.",
                impact_summary="Weather is within climatological normals with no imminent severe threats.",
                color_hex="#2E7D32",
                precipitation_threshold="No rain or Light rain (< 15.5 mm / 24h)",
                wind_threshold="< 40 km/h (Normal breeze)",
                temperature_threshold="Normal range (-1.5°C to +1.5°C departure)",
            ),
            IMDWarningStage(
                code="Yellow",
                name="Watch (Be Updated)",
                action_required="Stay updated with local weather broadcasts. Keep emergency kit and battery radio ready.",
                impact_summary="Severe weather likely over next 24–48 hours; localized disruption possible.",
                color_hex="#F9A825",
                precipitation_threshold="Moderate to Heavy rain (64.5 – 115.5 mm / 24h)",
                wind_threshold="41 – 61 km/h (Strong breeze / Near gale)",
                temperature_threshold="Heatwave departure 3.0°C – 4.4°C above normal",
            ),
            IMDWarningStage(
                code="Orange",
                name="Alert (Be Prepared)",
                action_required="Be prepared for severe weather. Review evacuation plans, clear storm drains, secure crops.",
                impact_summary="High probability of severe weather causing power cuts, waterlogging, and travel delays.",
                color_hex="#E65100",
                precipitation_threshold="Very Heavy rain (115.6 – 204.4 mm / 24h)",
                wind_threshold="62 – 88 km/h (Gale force winds / Cyclonic storm)",
                temperature_threshold="Severe Heatwave departure >= 4.5°C for 2+ consecutive days",
            ),
            IMDWarningStage(
                code="Red",
                name="Warning (Take Action)",
                action_required="Take immediate protective action. Evacuate vulnerable low-lying zones, halt transit.",
                impact_summary="Extremely severe weather event with life-threatening flooding and infrastructure damage.",
                color_hex="#C62828",
                precipitation_threshold="Extremely Heavy rain (> 204.4 mm / 24h)",
                wind_threshold=">= 89 km/h (Severe / Very Severe Cyclonic Storm)",
                temperature_threshold="Extreme Heatwave departure >= 6.4°C or Max Temp >= 47°C",
            ),
        ]

        hazard_sops = [
            HazardSOP(
                hazard_id="cyclone",
                title="Tropical Cyclone & Coastal Storm Surge",
                severity_level="Orange to Red",
                lead_time_phase="Watch (48h) -> Warning (24h) -> Landfall",
                immediate_actions=[
                    "Secure loose corrugated tin sheets, solar panels, and outdoor furniture immediately.",
                    "Store 3 to 5 days of safe drinking water (3 liters/person/day) and dry non-perishable rations.",
                    "Charge mobile phones, power banks, and keep battery-powered radio tuned to official bulletins.",
                ],
                dos=[
                    "Keep essential documents, cash, and medical prescriptions in water-resistant ziplock bags.",
                    "Stay inside well-constructed pucca buildings away from large glass windows and towering trees.",
                    "Switch off electrical mains, LPG gas regulator valves, and circuit breakers before storm eye passage.",
                    "Heed local evacuation orders without hesitation when NDRF/SDRF personnel advise relocation.",
                ],
                donts=[
                    "Do NOT venture into the sea, beaches, or river mouths during coastal gale warnings.",
                    "Do NOT believe or forward unverified audio messages on social media; rely exclusively on IMD/NDMA.",
                    "Do NOT go outside when the wind suddenly stops during cyclone landfall; this is the storm eye and reverse winds follow.",
                    "Do NOT touch sagging or downed power lines, standing pools of water near utility poles, or transformers.",
                ],
                vulnerable_guidance="Relocate pregnant mothers, infants, dialysis patients, and livestock to designated cyclone shelters at least 12 hours prior to landfall.",
            ),
            HazardSOP(
                hazard_id="heavy_rainfall_flood",
                title="Torrential Heavy Rainfall & Urban Flash Flood",
                severity_level="Orange to Red",
                lead_time_phase="Onset -> Peak Inundation -> Drainage Recovery",
                immediate_actions=[
                    "Move electrical appliances, livestock, and valuables to upper floors or elevated plinths.",
                    "Never attempt to walk, wade, or drive two-wheelers/cars through flowing floodwater.",
                    "Shut off ground-level electrical circuit breakers if basement or plinth flooding begins.",
                ],
                dos=[
                    "Boil all drinking water or use chlorine purification tablets to prevent waterborne epidemics.",
                    "Clear rooftop gutter outlets and perimeter drain silt traps before deluge onset.",
                    "Keep emergency flotation aids, ropes, and a battery flashlight readily accessible.",
                    "Report inundated underpasses and breached canal embankments to DDMA helpline (1077).",
                ],
                donts=[
                    "Do NOT drive through flooded railway underpasses; water depth is deceptive and vehicle engines stall within 25 cm of water.",
                    "Do NOT allow children to swim or wade in stormwater drains, irrigation canals, or culverts.",
                    "Do NOT consume food that has come in contact with floodwater.",
                    "Do NOT turn on electrical switches with wet hands or while standing in moisture.",
                ],
                vulnerable_guidance="Ensure elderly family members have an elevated dry bed and a 7-day reserve of essential cardiovascular/diabetes medications.",
            ),
            HazardSOP(
                hazard_id="thunderstorm_lightning",
                title="Severe Thunderstorm, Squall & Lightning",
                severity_level="Yellow to Orange",
                lead_time_phase="Immediate Radar Echo (< 30 min)",
                immediate_actions=[
                    "Follow the 30-30 Rule: If time between lightning flash and thunder clap is under 30 seconds, seek substantial indoor shelter.",
                    "If caught in open agricultural fields with no shelter, assume the Lightning Crouch (squat on balls of feet with hands over ears).",
                    "Unplug computers, televisions, and sensitive high-voltage electronics from wall sockets.",
                ],
                dos=[
                    "Seek shelter inside an enclosed pucca building or an all-metal enclosed vehicle (Faraday cage).",
                    "Suspend all open-field agricultural activities, tractor operation, and open-water fishing immediately.",
                    "Stay indoors for at least 30 minutes after the last recorded thunder clap.",
                ],
                donts=[
                    "Do NOT take shelter under isolated tall trees, metal utility poles, or tin-roofed sheds in open ground.",
                    "Do NOT lie flat on the ground; doing so increases your contact surface area with fatal ground currents.",
                    "Do NOT use corded landline phones, take showers, or wash dishes during an active lightning storm.",
                    "Do NOT carry metal umbrellas, iron farm tools (sickles, spades), or golf clubs in the open.",
                ],
                vulnerable_guidance="Unhitch working bullocks and cattle from iron plows or metallic fences and herd them into enclosed barns.",
            ),
            HazardSOP(
                hazard_id="heatwave",
                title="Extreme Heatwave & Insolation Stress",
                severity_level="Orange to Red",
                lead_time_phase="Diurnal Peak (11:00 AM – 4:00 PM)",
                immediate_actions=[
                    "Drink plenty of water at regular intervals, even when not thirsty, supplemented with ORS, buttermilk, or lemon water.",
                    "Shift strenuous outdoor agricultural and construction labor to early morning (before 10 AM) or evening hours.",
                    "Move any heatstroke victim immediately to a cool shaded room, loosen clothes, and apply cold wet towels to neck, armpits, and groin.",
                ],
                dos=[
                    "Wear loose, lightweight, light-colored cotton clothing and cover head with a wet gamcha, towel, or wide-brim hat.",
                    "Carry a water bottle whenever leaving home and keep domestic pets in well-ventilated, shaded quarters with fresh water.",
                    "Keep curtains and blinds closed during daylight hours to insulate home interiors.",
                ],
                donts=[
                    "Do NOT leave children, infants, or pets unattended inside parked closed automobiles, even for a few minutes.",
                    "Do NOT consume alcohol, caffeinated fizzy drinks, or heavy high-protein meals that dehydrate the human body.",
                    "Do NOT engage in intense physical workouts during peak midday sun hours (12 PM – 3 PM).",
                ],
                vulnerable_guidance="Elderly persons, pregnant women, and patients with cardiac/renal conditions should remain strictly in ventilated or cooled indoor spaces.",
            ),
            HazardSOP(
                hazard_id="dense_fog_coldwave",
                title="Dense Fog & Severe Coldwave",
                severity_level="Yellow to Orange",
                lead_time_phase="Late Night to Morning Hours",
                immediate_actions=[
                    "Turn on vehicle yellow fog lights and low-beam headlamps; maintain double the normal following distance on highways.",
                    "Dress in multiple thin layers of warm woolens rather than a single heavy coat to trap insulating body air.",
                    "Ensure proper ventilation before lighting charcoal angithis or room gas heaters to prevent fatal carbon monoxide poisoning.",
                ],
                dos=[
                    "Check rail and flight departure schedules before traveling, as low Runway Visual Range (RVR < 50m) causes delays.",
                    "Consume warm liquids (ginger tea, soups) and vitamin-rich citrus fruits to bolster respiratory immunity.",
                    "Cover cattle with gunny bags at night and shield livestock sheds with straw thatch from northern winds.",
                ],
                donts=[
                    "Do NOT use high-beam headlights in dense fog; high beams reflect off water droplets and create blinding white glare.",
                    "Do NOT stop or park vehicles on expressways without turning on emergency four-way hazard flashers.",
                    "Do NOT sleep in a closed unventilated room with burning charcoal brazier (angithi).",
                ],
                vulnerable_guidance="Monitor infants and elderly for hypothermia (shivering, slurred speech, cold pale skin); seek medical help immediately.",
            ),
        ]

        if hazard:
            hazard_sops = [h for h in hazard_sops if h.hazard_id.lower() == hazard.lower()]

        emergency_contacts = [
            EmergencyContact(
                name="National Emergency Response Support",
                phone_number="112",
                agency="National Emergency (MHA)",
                category="National Emergency",
                availability="24x7 Toll-Free",
                toll_free=True,
            ),
            EmergencyContact(
                name="NDMA National Disaster Helpline",
                phone_number="1078",
                agency="National Disaster Management Authority",
                category="Disaster",
                availability="24x7 Toll-Free",
                toll_free=True,
            ),
            EmergencyContact(
                name="State Disaster Management Authority (SDMA)",
                phone_number="1070",
                agency="State Disaster Control Room",
                category="Disaster",
                availability="24x7 Toll-Free",
                toll_free=True,
            ),
            EmergencyContact(
                name="District Disaster Management Authority (DDMA)",
                phone_number="1077",
                agency="District Collectorate Disaster Cell",
                category="District",
                availability="24x7 Toll-Free",
                toll_free=True,
            ),
            EmergencyContact(
                name="Ambulance & Medical Emergency",
                phone_number="108",
                agency="National Health Mission",
                category="Medical",
                availability="24x7 Toll-Free",
                toll_free=True,
            ),
            EmergencyContact(
                name="Fire & Rescue Services",
                phone_number="101",
                agency="Fire & Emergency Services",
                category="Fire & Rescue",
                availability="24x7 Toll-Free",
                toll_free=True,
            ),
        ]

        return IMDSOPResponse(
            warning_stages=warning_stages,
            hazard_sops=hazard_sops,
            emergency_contacts=emergency_contacts,
        )


disaster_service = DisasterService()

