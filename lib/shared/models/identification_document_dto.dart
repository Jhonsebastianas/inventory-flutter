import 'package:hola_mundo/shared/models/type_identification_dto.dart';

class IdentificationDocumentDTO {
  String? value;
  TypeIdentificationDTO? type;

  IdentificationDocumentDTO({
    this.value,
    this.type,
  });

  factory IdentificationDocumentDTO.fromJson(Map<String, dynamic> json) {
    return IdentificationDocumentDTO(
      value: json['value'],
      type: json['type'] != null
          ? TypeIdentificationDTO.fromJson(json['type'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'type': type?.toJson(),
    };
  }
}
