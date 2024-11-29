import 'package:hola_mundo/shared/models/contact_dto.dart';
import 'package:hola_mundo/shared/models/identification_document_dto.dart';

class RegisterClient {
  String? names;
  String? lastnames;
  IdentificationDocumentDTO? identification;
  ContactDTO? contact;

  RegisterClient({
    this.names,
    this.lastnames,
    this.identification,
    this.contact,
  });

  factory RegisterClient.fromJson(Map<String, dynamic> json) {
    return RegisterClient(
      names: json['names'],
      lastnames: json['lastnames'],
      identification: json['identification'] != null
          ? IdentificationDocumentDTO.fromJson(json['identification'])
          : null,
      contact:
          json['contact'] != null ? ContactDTO.fromJson(json['contact']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'names': names,
      'lastnames': lastnames,
      'identification': identification?.toJson(),
      'contact': contact?.toJson(),
    };
  }
}
