import 'package:hola_mundo/core/utils/numer_formatter.dart';

class InformationReductionInventoryDTO {
  final double previousStock;
  final double newStock;
  final bool isExistenceBelowLimit;
  final String productName;

  InformationReductionInventoryDTO({
    required this.previousStock,
    required this.newStock,
    required this.isExistenceBelowLimit,
    required this.productName,
  });

  factory InformationReductionInventoryDTO.fromJson(Map<String, dynamic> json) {
    return InformationReductionInventoryDTO(
      previousStock: NumberFormatter.parseDouble(json['previousStock']),
      newStock: NumberFormatter.parseDouble(json['newStock']),
      isExistenceBelowLimit: json['isExistenceBelowLimit'],
      productName: json['productName'],
    );
  }
}

class CreateSaleOutDTO {
  final String idSale;
  final List<InformationReductionInventoryDTO> informationReductionInventory;

  CreateSaleOutDTO({
    required this.idSale,
    required this.informationReductionInventory,
  });

  factory CreateSaleOutDTO.fromJson(Map<String, dynamic> json) {
    return CreateSaleOutDTO(
      idSale: json['idSale'],
      informationReductionInventory: (json['informationReductionInventory'] as List)
          .map((item) => InformationReductionInventoryDTO.fromJson(item))
          .toList(),
    );
  }
}
