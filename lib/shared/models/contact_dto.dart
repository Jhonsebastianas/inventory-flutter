import 'package:hola_mundo/shared/models/phone_dto.dart';

class ContactDTO {
  String? email;
  PhoneDTO? phone;
  PhoneDTO? cellular;

  ContactDTO({
    this.email,
    this.phone,
    this.cellular,
  });

  factory ContactDTO.fromJson(Map<String, dynamic> json) {
    return ContactDTO(
      email: json['email'],
      phone: json['phone'] != null
          ? PhoneDTO.fromJson(json['phone'])
          : null,
      cellular: json['cellular'] != null
          ? PhoneDTO.fromJson(json['cellular'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone?.toJson(),
      'cellular': cellular?.toJson(),
    };
  }
}