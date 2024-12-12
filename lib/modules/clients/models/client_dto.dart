import 'package:hola_mundo/shared/models/contact_dto.dart';
import 'package:hola_mundo/shared/models/identification_document_dto.dart';

class ClientDTO {
  String id;
  String businessId;
  String names;
  String lastnames;
  IdentificationDocumentDTO identification;
  ContactDTO contact;
  bool active;

  ClientDTO({
    required this.id,
    required this.businessId,
    required this.names,
    required this.lastnames,
    required this.identification,
    required this.contact,
    required this.active,
  });

  factory ClientDTO.fromJson(Map<String, dynamic> json) {
    return ClientDTO(
      id: json['id'],
      businessId: json['businessId'],
      names: json['names'],
      lastnames: json['lastnames'],
      identification: IdentificationDocumentDTO.fromJson(json['identification']),
      contact: ContactDTO.fromJson(json['contact']),
      active: json['active'],
    );
  }
}
