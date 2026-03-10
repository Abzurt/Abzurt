class SourceModel {
  final String id;
  final String url;
  final String category;
  final String addedBy;

  SourceModel({
    required this.id,
    required this.url,
    required this.category,
    required this.addedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'category': category,
      'addedBy': addedBy,
    };
  }

  factory SourceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SourceModel(
      id: documentId,
      url: map['url'] ?? '',
      category: map['category'] ?? '',
      addedBy: map['addedBy'] ?? '',
    );
  }
}
