import 'package:hola_mundo/modules/clients/models/client_dto.dart';
import 'package:hola_mundo/modules/sales/models/sale_detal_user.dart';
import 'package:hola_mundo/shared/models/sale.dart';

class SaleDetailDTO {
  String id;
  String idUser;
  SaleDetailUser userSold;
  String businessId;
  String clientId;
  ClientDTO? client;
  String invoiceIdentifier;
  DateTime createdAt;
  List<SaleProduct> products;
  List<PaymentMethod> paymentMethods;
  double totalInvoiced;
  int totalProducts;
  String proofPayment;
  bool? isRecent; // Campo opcional

  SaleDetailDTO({
    required this.id,
    required this.idUser,
    required this.userSold,
    required this.businessId,
    required this.clientId,
    this.client,
    required this.invoiceIdentifier,
    required this.createdAt,
    required this.products,
    required this.paymentMethods,
    required this.totalInvoiced,
    required this.totalProducts,
    required this.proofPayment,
    this.isRecent,
  });

  factory SaleDetailDTO.fromJson(Map<String, dynamic> json) {
  return SaleDetailDTO(
    id: json['id'] ?? '',
    idUser: json['idUser'] ?? '',
    userSold: json['userSold'] != null 
        ? SaleDetailUser.fromJson(json['userSold']) 
        : SaleDetailUser.empty(), // Maneja casos nulos con un objeto vacío
    businessId: json['businessId'] ?? '',
    clientId: json['clientId'] ?? '',
    client: json['client'] != null
        ? ClientDTO.fromJson(json['client'])
        : null, // Maneja casos nulos con un objeto vacío
    invoiceIdentifier: json['invoiceIdentifier'] ?? '', // Usa un valor predeterminado
    createdAt: json['createdAt'] != null 
        ? DateTime.tryParse(json['createdAt']) ?? DateTime(1970, 1, 1) // Maneja errores de formato
        : DateTime(1970, 1, 1),
    products: (json['products'] as List?)?.map((product) => SaleProduct.fromJson(product)).toList() ?? [],
    paymentMethods: (json['paymentMethods'] as List?)?.map((method) => PaymentMethod.fromJson(method)).toList() ?? [],
    totalInvoiced: (json['totalInvoiced'] as num?)?.toDouble() ?? 0.0, // Maneja valores nulos y conversiones seguras
    totalProducts: json['totalProducts'] ?? 0,
    proofPayment: json['proofPayment'] ?? '', // Usa un valor predeterminado
    isRecent: json['isRecent'] ?? false, // Asume falso si no está definido
  );
}

}
