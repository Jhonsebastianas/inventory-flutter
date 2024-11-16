class SalesConsultation {
  DateTime? startDate;
  DateTime? endDate;

  SalesConsultation({
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }
}