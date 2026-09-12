import 'package:flutter/material.dart';

class IMDWarningStageModel {
  final String code;
  final String name;
  final String actionRequired;
  final String impactSummary;
  final String colorHex;
  final String precipitationThreshold;
  final String windThreshold;
  final String temperatureThreshold;

  IMDWarningStageModel({
    required this.code,
    required this.name,
    required this.actionRequired,
    required this.impactSummary,
    required this.colorHex,
    required this.precipitationThreshold,
    required this.windThreshold,
    required this.temperatureThreshold,
  });

  Color get color {
    switch (code.toLowerCase()) {
      case 'red':
        return const Color(0xFFC62828);
      case 'orange':
        return const Color(0xFFE65100);
      case 'yellow':
        return const Color(0xFFF9A825);
      case 'green':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  factory IMDWarningStageModel.fromJson(Map<String, dynamic> json) {
    return IMDWarningStageModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      actionRequired: json['action_required'] ?? '',
      impactSummary: json['impact_summary'] ?? '',
      colorHex: json['color_hex'] ?? '#2E7D32',
      precipitationThreshold: json['precipitation_threshold'] ?? '',
      windThreshold: json['wind_threshold'] ?? '',
      temperatureThreshold: json['temperature_threshold'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'action_required': actionRequired,
      'impact_summary': impactSummary,
      'color_hex': colorHex,
      'precipitation_threshold': precipitationThreshold,
      'wind_threshold': windThreshold,
      'temperature_threshold': temperatureThreshold,
    };
  }
}

class HazardSOPModel {
  final String hazardId;
  final String title;
  final String severityLevel;
  final String leadTimePhase;
  final List<String> immediateActions;
  final List<String> dos;
  final List<String> donts;
  final String vulnerableGuidance;

  HazardSOPModel({
    required this.hazardId,
    required this.title,
    required this.severityLevel,
    required this.leadTimePhase,
    required this.immediateActions,
    required this.dos,
    required this.donts,
    required this.vulnerableGuidance,
  });

  IconData get icon {
    switch (hazardId.toLowerCase()) {
      case 'cyclone':
        return Icons.cyclone_rounded;
      case 'heavy_rainfall_flood':
        return Icons.water_drop_rounded;
      case 'thunderstorm_lightning':
        return Icons.flash_on_rounded;
      case 'heatwave':
        return Icons.wb_sunny_rounded;
      case 'dense_fog_coldwave':
      default:
        return Icons.cloud_rounded;
    }
  }

  factory HazardSOPModel.fromJson(Map<String, dynamic> json) {
    return HazardSOPModel(
      hazardId: json['hazard_id'] ?? '',
      title: json['title'] ?? '',
      severityLevel: json['severity_level'] ?? '',
      leadTimePhase: json['lead_time_phase'] ?? '',
      immediateActions: (json['immediate_actions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dos: (json['dos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      donts: (json['donts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      vulnerableGuidance: json['vulnerable_guidance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hazard_id': hazardId,
      'title': title,
      'severity_level': severityLevel,
      'lead_time_phase': leadTimePhase,
      'immediate_actions': immediateActions,
      'dos': dos,
      'donts': donts,
      'vulnerable_guidance': vulnerableGuidance,
    };
  }
}

class EmergencyContactModel {
  final String name;
  final String phoneNumber;
  final String agency;
  final String category;
  final String availability;
  final bool tollFree;

  EmergencyContactModel({
    required this.name,
    required this.phoneNumber,
    required this.agency,
    required this.category,
    this.availability = '24x7 Toll-Free',
    this.tollFree = true,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      agency: json['agency'] ?? '',
      category: json['category'] ?? 'Emergency',
      availability: json['availability'] ?? '24x7 Toll-Free',
      tollFree: json['toll_free'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
      'agency': agency,
      'category': category,
      'availability': availability,
      'toll_free': tollFree,
    };
  }
}

class IMDSOPResponseModel {
  final List<IMDWarningStageModel> warningStages;
  final List<HazardSOPModel> hazardSops;
  final List<EmergencyContactModel> emergencyContacts;
  final String source;
  final String disclaimer;
  final String generatedAt;
  final bool isOfflineCached;

  IMDSOPResponseModel({
    required this.warningStages,
    required this.hazardSops,
    required this.emergencyContacts,
    required this.source,
    required this.disclaimer,
    required this.generatedAt,
    this.isOfflineCached = false,
  });

  factory IMDSOPResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    return IMDSOPResponseModel(
      warningStages: (json['warning_stages'] as List<dynamic>?)
              ?.map((e) => IMDWarningStageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hazardSops: (json['hazard_sops'] as List<dynamic>?)
              ?.map((e) => HazardSOPModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      emergencyContacts: (json['emergency_contacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContactModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      source: json['source'] ?? 'IMD National Weather Forecasting Centre & NDMA SOP Guidelines',
      disclaimer: json['disclaimer'] ?? 'Official disaster mitigation operating procedures.',
      generatedAt: json['generated_at'] ?? DateTime.now().toIso8601String(),
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warning_stages': warningStages.map((e) => e.toJson()).toList(),
      'hazard_sops': hazardSops.map((e) => e.toJson()).toList(),
      'emergency_contacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'source': source,
      'disclaimer': disclaimer,
      'generated_at': generatedAt,
    };
  }

  static IMDSOPResponseModel defaultFallback() {
    return IMDSOPResponseModel(
      isOfflineCached: true,
      source: 'Official IMD & NDMA Disaster Standard Operating Procedures (Embedded Offline)',
      disclaimer: 'Official disaster mitigation procedures. Obey directives from local SDMA/NDRF authorities.',
      generatedAt: DateTime.now().toIso8601String(),
      warningStages: [
        IMDWarningStageModel(
          code: 'Green',
          name: 'No Warning (Normal)',
          actionRequired: 'No action required. General activities can proceed without disruption.',
          impactSummary: 'Weather is within climatological normals with no imminent severe threats.',
          colorHex: '#2E7D32',
          precipitationThreshold: 'No rain or Light rain (< 15.5 mm / 24h)',
          windThreshold: '< 40 km/h (Normal breeze)',
          temperatureThreshold: 'Normal range (-1.5°C to +1.5°C departure)',
        ),
        IMDWarningStageModel(
          code: 'Yellow',
          name: 'Watch (Be Updated)',
          actionRequired: 'Stay updated with local broadcasts. Keep emergency kit and battery radio ready.',
          impactSummary: 'Severe weather likely over next 24–48 hours; localized disruption possible.',
          colorHex: '#F9A825',
          precipitationThreshold: 'Moderate to Heavy rain (64.5 – 115.5 mm / 24h)',
          windThreshold: '41 – 61 km/h (Strong breeze / Near gale)',
          temperatureThreshold: 'Heatwave departure 3.0°C – 4.4°C above normal',
        ),
        IMDWarningStageModel(
          code: 'Orange',
          name: 'Alert (Be Prepared)',
          actionRequired: 'Be prepared for severe weather. Review evacuation plans, clear storm drains, protect crops.',
          impactSummary: 'High probability of severe weather causing power cuts, waterlogging, and travel delays.',
          colorHex: '#E65100',
          precipitationThreshold: 'Very Heavy rain (115.6 – 204.4 mm / 24h)',
          windThreshold: '62 – 88 km/h (Gale force winds / Cyclonic storm)',
          temperatureThreshold: 'Severe Heatwave departure >= 4.5°C for 2+ consecutive days',
        ),
        IMDWarningStageModel(
          code: 'Red',
          name: 'Warning (Take Action)',
          actionRequired: 'Take immediate protective action. Evacuate vulnerable low-lying zones, halt transit.',
          impactSummary: 'Extremely severe weather event with life-threatening flooding and infrastructure damage.',
          colorHex: '#C62828',
          precipitationThreshold: 'Extremely Heavy rain (> 204.4 mm / 24h)',
          windThreshold: '>= 89 km/h (Severe / Very Severe Cyclonic Storm)',
          temperatureThreshold: 'Extreme Heatwave departure >= 6.4°C or Max Temp >= 47°C',
        ),
      ],
      hazardSops: [
        HazardSOPModel(
          hazardId: 'cyclone',
          title: 'Tropical Cyclone & Coastal Storm Surge',
          severityLevel: 'Orange to Red',
          leadTimePhase: 'Watch (48h) -> Warning (24h) -> Landfall',
          immediateActions: [
            'Secure loose corrugated tin sheets, solar panels, and outdoor furniture immediately.',
            'Store 3 to 5 days of safe drinking water (3 liters/person/day) and dry non-perishable rations.',
            'Charge mobile phones, power banks, and keep battery-powered radio tuned to official bulletins.',
          ],
          dos: [
            'Keep essential documents, cash, and medical prescriptions in water-resistant ziplock bags.',
            'Stay inside well-constructed pucca buildings away from large glass windows and towering trees.',
            'Switch off electrical mains, LPG gas regulator valves, and circuit breakers before storm eye passage.',
            'Heed local evacuation orders without hesitation when NDRF/SDRF personnel advise relocation.',
          ],
          donts: [
            'Do NOT venture into the sea, beaches, or river mouths during coastal gale warnings.',
            'Do NOT believe or forward unverified audio messages on social media; rely exclusively on IMD/NDMA.',
            'Do NOT go outside when the wind suddenly stops during cyclone landfall; this is the storm eye and reverse winds follow.',
            'Do NOT touch sagging or downed power lines, standing pools of water near utility poles, or transformers.',
          ],
          vulnerableGuidance: 'Relocate pregnant mothers, infants, dialysis patients, and livestock to designated cyclone shelters at least 12 hours prior to landfall.',
        ),
        HazardSOPModel(
          hazardId: 'heavy_rainfall_flood',
          title: 'Torrential Heavy Rainfall & Urban Flash Flood',
          severityLevel: 'Orange to Red',
          leadTimePhase: 'Onset -> Peak Inundation -> Drainage Recovery',
          immediateActions: [
            'Move electrical appliances, livestock, and valuables to upper floors or elevated plinths.',
            'Never attempt to walk, wade, or drive two-wheelers/cars through flowing floodwater.',
            'Shut off ground-level electrical circuit breakers if basement or plinth flooding begins.',
          ],
          dos: [
            'Boil all drinking water or use chlorine purification tablets to prevent waterborne epidemics.',
            'Clear rooftop gutter outlets and perimeter drain silt traps before deluge onset.',
            'Keep emergency flotation aids, ropes, and a battery flashlight readily accessible.',
            'Report inundated underpasses and breached canal embankments to DDMA helpline (1077).',
          ],
          donts: [
            'Do NOT drive through flooded railway underpasses; water depth is deceptive and vehicle engines stall within 25 cm of water.',
            'Do NOT allow children to swim or wade in stormwater drains, irrigation canals, or culverts.',
            'Do NOT consume food that has come in contact with floodwater.',
            'Do NOT turn on electrical switches with wet hands or while standing in moisture.',
          ],
          vulnerableGuidance: 'Ensure elderly family members have an elevated dry bed and a 7-day reserve of essential cardiovascular/diabetes medications.',
        ),
        HazardSOPModel(
          hazardId: 'thunderstorm_lightning',
          title: 'Severe Thunderstorm, Squall & Lightning',
          severityLevel: 'Yellow to Orange',
          leadTimePhase: 'Immediate Radar Echo (< 30 min)',
          immediateActions: [
            'Follow the 30-30 Rule: If time between lightning flash and thunder clap is under 30 seconds, seek substantial indoor shelter.',
            'If caught in open agricultural fields with no shelter, assume the Lightning Crouch (squat on balls of feet with hands over ears).',
            'Unplug computers, televisions, and sensitive high-voltage electronics from wall sockets.',
          ],
          dos: [
            'Seek shelter inside an enclosed pucca building or an all-metal enclosed vehicle (Faraday cage).',
            'Suspend all open-field agricultural activities, tractor operation, and open-water fishing immediately.',
            'Stay indoors for at least 30 minutes after the last recorded thunder clap.',
          ],
          donts: [
            'Do NOT take shelter under isolated tall trees, metal utility poles, or tin-roofed sheds in open ground.',
            'Do NOT lie flat on the ground; doing so increases your contact surface area with fatal ground currents.',
            'Do NOT use corded landline phones, take showers, or wash dishes during an active lightning storm.',
            'Do NOT carry metal umbrellas, iron farm tools (sickles, spades), or golf clubs in the open.',
          ],
          vulnerableGuidance: 'Unhitch working bullocks and cattle from iron plows or metallic fences and herd them into enclosed barns.',
        ),
        HazardSOPModel(
          hazardId: 'heatwave',
          title: 'Extreme Heatwave & Insolation Stress',
          severityLevel: 'Orange to Red',
          leadTimePhase: 'Diurnal Peak (11:00 AM – 4:00 PM)',
          immediateActions: [
            'Drink plenty of water at regular intervals, even when not thirsty, supplemented with ORS, buttermilk, or lemon water.',
            'Shift strenuous outdoor agricultural and construction labor to early morning (before 10 AM) or evening hours.',
            'Move any heatstroke victim immediately to a cool shaded room, loosen clothes, and apply cold wet towels to neck, armpits, and groin.',
          ],
          dos: [
            'Wear loose, lightweight, light-colored cotton clothing and cover head with a wet gamcha, towel, or wide-brim hat.',
            'Carry a water bottle whenever leaving home and keep domestic pets in well-ventilated, shaded quarters with fresh water.',
            'Keep curtains and blinds closed during daylight hours to insulate home interiors.',
          ],
          donts: [
            'Do NOT leave children, infants, or pets unattended inside parked closed automobiles, even for a few minutes.',
            'Do NOT consume alcohol, caffeinated fizzy drinks, or heavy high-protein meals that dehydrate the human body.',
            'Do NOT engage in intense physical workouts during peak midday sun hours (12 PM – 3 PM).',
          ],
          vulnerableGuidance: 'Elderly persons, pregnant women, and patients with cardiac/renal conditions should remain strictly in ventilated or cooled indoor spaces.',
        ),
        HazardSOPModel(
          hazardId: 'dense_fog_coldwave',
          title: 'Dense Fog & Severe Coldwave',
          severityLevel: 'Yellow to Orange',
          leadTimePhase: 'Late Night to Morning Hours',
          immediateActions: [
            'Turn on vehicle yellow fog lights and low-beam headlamps; maintain double the normal following distance on highways.',
            'Dress in multiple thin layers of warm woolens rather than a single heavy coat to trap insulating body air.',
            'Ensure proper ventilation before lighting charcoal angithis or room gas heaters to prevent fatal carbon monoxide poisoning.',
          ],
          dos: [
            'Check rail and flight departure schedules before traveling, as low Runway Visual Range (RVR < 50m) causes delays.',
            'Consume warm liquids (ginger tea, soups) and vitamin-rich citrus fruits to bolster respiratory immunity.',
            'Cover cattle with gunny bags at night and shield livestock sheds with straw thatch from northern winds.',
          ],
          donts: [
            'Do NOT use high-beam headlights in dense fog; high beams reflect off water droplets and create blinding white glare.',
            'Do NOT stop or park vehicles on expressways without turning on emergency four-way hazard flashers.',
            'Do NOT sleep in a closed unventilated room with burning charcoal brazier (angithi).',
          ],
          vulnerableGuidance: 'Monitor infants and elderly for hypothermia (shivering, slurred speech, cold pale skin); seek medical help immediately.',
        ),
      ],
      emergencyContacts: [
        EmergencyContactModel(
          name: 'National Emergency Response Support',
          phoneNumber: '112',
          agency: 'National Emergency (MHA)',
          category: 'National Emergency',
          availability: '24x7 Toll-Free',
          tollFree: true,
        ),
        EmergencyContactModel(
          name: 'NDMA National Disaster Helpline',
          phoneNumber: '1078',
          agency: 'National Disaster Management Authority',
          category: 'Disaster',
          availability: '24x7 Toll-Free',
          tollFree: true,
        ),
        EmergencyContactModel(
          name: 'State Disaster Management Authority (SDMA)',
          phoneNumber: '1070',
          agency: 'State Disaster Control Room',
          category: 'Disaster',
          availability: '24x7 Toll-Free',
          tollFree: true,
        ),
        EmergencyContactModel(
          name: 'District Disaster Management Authority (DDMA)',
          phoneNumber: '1077',
          agency: 'District Collectorate Disaster Cell',
          category: 'District',
          availability: '24x7 Toll-Free',
          tollFree: true,
        ),
        EmergencyContactModel(
          name: 'Ambulance & Medical Emergency',
          phoneNumber: '108',
          agency: 'National Health Mission',
          category: 'Medical',
          availability: '24x7 Toll-Free',
          tollFree: true,
        ),
        EmergencyContactModel(
          name: 'Fire & Rescue Services',
          phoneNumber: '101',
          agency: 'Fire & Emergency Services',
          category: 'Fire & Rescue',
          availability: '24x7 Toll-Free',
          tollFree: true,
        ),
      ],
    );
  }
}
