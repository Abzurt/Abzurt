class UserModel {
  final String id;
  final String email;
  final String displayName;
  final List<String> readNewsIds;
  final List<String> savedNewsIds;
  final List<String> sharedNewsIds;
  final List<String> categories;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.readNewsIds = const [],
    this.savedNewsIds = const [],
    this.sharedNewsIds = const [],
    this.categories = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'readNewsIds': readNewsIds,
      'savedNewsIds': savedNewsIds,
      'sharedNewsIds': sharedNewsIds,
      'categories': categories,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      readNewsIds: List<String>.from(map['readNewsIds'] ?? []),
      savedNewsIds: List<String>.from(map['savedNewsIds'] ?? []),
      sharedNewsIds: List<String>.from(map['sharedNewsIds'] ?? []),
      categories: List<String>.from(map['categories'] ?? []),
    );
  }
}
