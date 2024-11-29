class PhoneDTO {
  String? value;
  String? callsign;

  PhoneDTO({
    this.value,
    this.callsign,
  });

  factory PhoneDTO.fromJson(Map<String, dynamic> json) {
    return PhoneDTO(
      value: json['value'],
      callsign: json['callsign'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'callsign': callsign,
    };
  }
}