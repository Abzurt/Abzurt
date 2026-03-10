import 'package:cloud_firestore/cloud_firestore.dart';

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
  final String sourceUrl;
  final String category;
  final DateTime timestamp;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.sourceUrl,
    required this.category,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'sourceUrl': sourceUrl,
      'category': category,
      'timestamp': timestamp,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NewsModel(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      sourceUrl: map['sourceUrl'] ?? '',
      category: map['category'] ?? 'Genel',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
