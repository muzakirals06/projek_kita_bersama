class PdfFile {
  final String id;
  final String fdt;
  final String name;
  final String url;
  final String
      status; // Status persetujuan (misalnya, 'pending', 'approved', 'rejected')

  PdfFile({
    required this.id,
    required this.fdt,
    required this.name,
    required this.url,
    required this.status,
  });

  factory PdfFile.fromJson(Map<String, dynamic> json) {
    return PdfFile(
      id: json['id'],
      fdt: json['fdt'],
      name: json['name'],
      url: json['url'],
      status: json['status'],
    );
  }
}
