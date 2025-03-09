import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMember {
  final String id;
  final String userId;
  final DateTime joinedAt;
  final bool isAdmin;

  GroupMember({
    required this.id,
    required this.userId,
    required this.joinedAt,
    required this.isAdmin,
  });

  factory GroupMember.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return GroupMember(
      id: doc.id,
      userId: data['userId'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isAdmin': isAdmin,
    };
  }
}