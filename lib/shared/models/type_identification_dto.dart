class TypeIdentificationDTO {
  String? id;
  String? name;
  String? abbreviation;

  TypeIdentificationDTO({
    this.id,
    this.name,
    this.abbreviation,
  });

  factory TypeIdentificationDTO.fromJson(Map<String, dynamic> json) {
    return TypeIdentificationDTO(
      id: json['id'],
      name: json['name'],
      abbreviation: json['abbreviation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
    };
  }
}
