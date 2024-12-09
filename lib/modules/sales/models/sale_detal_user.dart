class SaleDetailUser {
  String id;
  String names;

  SaleDetailUser({
    required this.id,
    required this.names,
  });

  factory SaleDetailUser.fromJson(Map<String, dynamic> json) {
    return SaleDetailUser(
      id: json['id'] ?? '',
      names: json['names'] ?? '',
    );
  }

  factory SaleDetailUser.empty() {
    return SaleDetailUser(names: '', id: '');
  }
}
