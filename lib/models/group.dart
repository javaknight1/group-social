import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Group(
      id: doc.id,
      name: data['name'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'active': active,
    };
  }
}