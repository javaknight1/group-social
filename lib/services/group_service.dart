import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import 'auth_service.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Collection references
  final CollectionReference _groupsCollection = 
      FirebaseFirestore.instance.collection('groups');
  
  // Create a new group
  Future<DocumentReference> createGroup(String name) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Create group
    final groupRef = await _groupsCollection.add({
      'name': name,
      'createdBy': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'active': true,
    });
    
    // Add creator as a member
    await groupRef.collection('members').add({
      'userId': userId,
      'joinedAt': FieldValue.serverTimestamp(),
      'isAdmin': true,
    });
    
    return groupRef;
  }
  
  // Get all groups for current user
  Stream<List<Group>> getUserGroups() {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
      .collectionGroup('members')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .asyncMap((memberSnapshot) async {
        List<Group> groups = [];
        
        for (var doc in memberSnapshot.docs) {
          final groupId = doc.reference.parent.parent!.id;
          
          final groupDoc = await _groupsCollection.doc(groupId).get();
          if (groupDoc.exists && groupDoc.data() != null) {
            groups.add(Group.fromFirestore(groupDoc));
          }
        }
        
        return groups;
      });
  }
  
  // Get group by ID
  Future<Group> getGroup(String groupId) async {
    final doc = await _groupsCollection.doc(groupId).get();
    if (!doc.exists) {
      throw Exception('Group not found');
    }
    return Group.fromFirestore(doc);
  }
  
  // Join a group
  Future<void> joinGroup(String groupId) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    // Check if already a member
    final memberQuery = await _groupsCollection
        .doc(groupId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();
    
    if (memberQuery.docs.isEmpty) {
      // Add as new member
      await _groupsCollection.doc(groupId).collection('members').add({
        'userId': userId,
        'joinedAt': FieldValue.serverTimestamp(),
        'isAdmin': false,
      });
    }
  }
  
  // Get all members of a group
  Stream<List<GroupMember>> getGroupMembers(String groupId) {
    return _groupsCollection
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => GroupMember.fromFirestore(doc)).toList());
  }
  
  // Leave a group
  Future<void> leaveGroup(String groupId) async {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final memberQuery = await _groupsCollection
        .doc(groupId)
        .collection('members')
        .where('userId', isEqualTo: userId)
        .get();
    
    for (var doc in memberQuery.docs) {
      await doc.reference.delete();
    }
  }
}