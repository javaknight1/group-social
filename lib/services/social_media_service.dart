import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

class SocialMediaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  // Collection reference
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');
  
  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      return null;
    }
    
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    
    return UserProfile.fromFirestore(doc);
  }
  
  // Create or update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final userRef = _usersCollection.doc(userId);
    final userDoc = await userRef.get();
    
    if (userDoc.exists) {
      // Update existing profile
      await userRef.update({
        'displayName': displayName,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new profile
      final currentUser = _authService.currentUser;
      await userRef.set({
        'email': currentUser?.email ?? '',
        'displayName': displayName ?? currentUser?.displayName ?? '',
        'photoUrl': photoUrl ?? currentUser?.photoURL,
        'socialAccounts': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Mock method for connecting social media account (in real app, use OAuth)
  Future<void> connectSocialAccount(
    String platform,
    String username,
    {String? accessToken}
  ) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final userRef = _usersCollection.doc(userId);
    final userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      await updateUserProfile();
    }
    
    // Get existing accounts or create empty list
    List<SocialMediaAccount> accounts = [];
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      if (userData['socialAccounts'] != null) {
        accounts = (userData['socialAccounts'] as List)
            .map((account) => SocialMediaAccount.fromMap(account))
            .toList();
      }
    }
    
    // Check if the platform already exists and update or add
    int existingIndex = accounts.indexWhere((a) => a.platform == platform);
    if (existingIndex >= 0) {
      accounts[existingIndex] = SocialMediaAccount(
        platform: platform,
        username: username,
        isConnected: true,
        accessToken: accessToken,
      );
    } else {
      accounts.add(SocialMediaAccount(
        platform: platform,
        username: username,
        isConnected: true,
        accessToken: accessToken,
      ));
    }
    
    // Update the social accounts array
    await userRef.update({
      'socialAccounts': accounts.map((account) => account.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Mock method for disconnecting social media account
  Future<void> disconnectSocialAccount(String platform) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final userRef = _usersCollection.doc(userId);
    final userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      return;
    }
    
    final userData = userDoc.data() as Map<String, dynamic>;
    if (userData['socialAccounts'] == null) {
      return;
    }
    
    List<SocialMediaAccount> accounts = (userData['socialAccounts'] as List)
        .map((account) => SocialMediaAccount.fromMap(account))
        .toList();
    
    accounts.removeWhere((account) => account.platform == platform);
    
    await userRef.update({
      'socialAccounts': accounts.map((account) => account.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get all users in a group with their social media accounts
  Future<List<UserProfile>> getGroupMemberProfiles(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }
    
    final userDocs = await _usersCollection
        .where(FieldPath.documentId, whereIn: userIds)
        .get();
    
    return userDocs.docs
        .map((doc) => UserProfile.fromFirestore(doc))
        .toList();
  }
  
  // Mock method for following users on a platform
  Future<void> followUsersOnPlatform(
    String platform,
    List<String> usersToFollow
  ) async {
    // In a real app, you would use the platform's API to follow users
    // For now, just simulate success
    await Future.delayed(const Duration(seconds: 1));
    
    // Return success or throw an error for failure
    return;
  }
}