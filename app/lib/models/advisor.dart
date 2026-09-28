/// One entry from backend's /advisors — currently a labeled placeholder
/// directory (see backend/app/services/advisor_service.py), not a real
/// AGRITEX officer list yet.
class Advisor {
  final String id;
  final String name;
  final String role;
  final String district;
  final String phone;

  const Advisor({
    required this.id,
    required this.name,
    required this.role,
    required this.district,
    required this.phone,
  });

  factory Advisor.fromJson(Map<String, dynamic> json) => Advisor(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        district: json['district'] as String,
        phone: json['phone'] as String? ?? '',
      );
}

enum AdvisorRequestType { farmVisit, diseaseEscalation, consultation }

extension AdvisorRequestTypeApi on AdvisorRequestType {
  String get apiValue => switch (this) {
        AdvisorRequestType.farmVisit => 'farm_visit',
        AdvisorRequestType.diseaseEscalation => 'disease_escalation',
        AdvisorRequestType.consultation => 'consultation',
      };

  String get label => switch (this) {
        AdvisorRequestType.farmVisit => 'Farm visit request',
        AdvisorRequestType.diseaseEscalation => 'Disease escalation',
        AdvisorRequestType.consultation => 'Agronomic consultation',
      };
}

class AdvisorRequestResult {
  final String ticket;
  final String status;

  const AdvisorRequestResult({required this.ticket, required this.status});

  factory AdvisorRequestResult.fromJson(Map<String, dynamic> json) => AdvisorRequestResult(
        ticket: json['ticket'] as String,
        status: json['status'] as String,
      );
}
