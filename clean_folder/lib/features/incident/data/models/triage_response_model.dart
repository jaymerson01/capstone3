class TriageResponseModel {
  final String urgency;
  final String justification;

  TriageResponseModel({
    required this.urgency,
    required this.justification,
  });

  factory TriageResponseModel.fromJson(Map<String, dynamic> json) {
    return TriageResponseModel(
      urgency: json['urgency'] as String,
      justification: json['justification'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urgency': urgency,
      'justification': justification,
    };
  }
}
