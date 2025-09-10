class SheetRow {
  final String customerName;
  final String ipAddress;
  final String location;
  final String vendor;
  final String contactField;

  SheetRow({
    required this.customerName,
    required this.ipAddress,
    required this.location,
    required this.vendor,
    required this.contactField,
  });

  factory SheetRow.fromJson(Map<String, dynamic> json) {
    return SheetRow(
      customerName: json["Customer Name"] ?? "",
      ipAddress: json["IP Address"] ?? "",
      location: json["Location"] ?? "",
      vendor: json["Vendor"] ?? "",
      contactField: json["Contact Name & Number"] ?? "",
    );
  }
}
