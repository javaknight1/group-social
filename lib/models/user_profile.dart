import 'package:cloud_firestore/cloud_firestore.dart';

class SocialMediaAccount {
  final String platform;
  final String username;
  final bool isConnected;
  final String? accessToken;

  SocialMediaAccount({
    required this.platform,
    required this.username,
    required this.isConnected,
    this.accessToken,
  });

  factory SocialMediaAccount.fromMap(Map<String, dynamic> data) {
    return SocialMediaAccount(
      platform: data['platform'] ?? '',
      username: data['username'] ?? '',
      isConnected: data['isConnected'] ?? false,
      accessToken: data['accessToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'username': username,
      'isConnected': isConnected,
      'accessToken': accessToken,
    };
  }
}

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<SocialMediaAccount> socialAccounts;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.socialAccounts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    List<SocialMediaAccount> accounts = [];
    if (data['socialAccounts'] != null) {
      accounts = (data['socialAccounts'] as List)
          .map((account) => SocialMediaAccount.fromMap(account))
          .toList();
    }
    
    return UserProfile(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      socialAccounts: accounts,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'socialAccounts': socialAccounts.map((account) => account.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}