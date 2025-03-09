import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/user_profile.dart';
import '../services/group_service.dart';
import '../services/social_media_service.dart';
import '../services/auth_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  
  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  final SocialMediaService _socialMediaService = SocialMediaService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _isFollowingAll = false;
  Group? _group;
  String _error = '';
  List<UserProfile> _memberProfiles = [];

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    try {
      final group = await _groupService.getGroup(widget.groupId);
      setState(() {
        _group = group;
        _isLoading = false;
      });
      
      // Also load member profiles when available
      _loadMemberProfiles();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadMemberProfiles() async {
    try {
      final members = await _groupService.getGroupMembers(widget.groupId).first;
      final userIds = members.map((member) => member.userId).toList();
      
      final profiles = await _socialMediaService.getGroupMemberProfiles(userIds);
      
      setState(() {
        _memberProfiles = profiles;
      });
    } catch (e) {
      // Handle error silently, we'll still show the group without profile details
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Details')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final group = _group!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildActionButtons(),
          Expanded(
            child: StreamBuilder<List<GroupMember>>(
              stream: _groupService.getGroupMembers(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final members = snapshot.data ?? [];
                
                if (members.isEmpty) {
                  return const Center(child: Text('No members in this group yet'));
                }
                
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    
                    // Find corresponding user profile if available
                    final profile = _memberProfiles.firstWhere(
                      (p) => p.id == member.userId,
                      orElse: () => UserProfile(
                        id: member.userId,
                        email: 'no email',
                        socialAccounts: [],
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    profile.displayName?.substring(0, 1).toUpperCase() ?? 
                                    profile.email.substring(0, 1).toUpperCase(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.displayName ?? profile.email,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        member.isAdmin ? 'Admin' : 'Member',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (profile.socialAccounts.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: profile.socialAccounts.map((account) {
                                  return Chip(
                                    avatar: Icon(_getSocialIcon(account.platform), size: 16),
                                    label: Text(account.username),
                                    backgroundColor: _getSocialColor(account.platform).withOpacity(0.2),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      case 'snapchat':
        return Icons.crop_square;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.link;
    }
  }
  
  Color _getSocialColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return Colors.pink;
      case 'facebook':
        return Colors.blue;
      case 'snapchat':
        return Colors.yellow;
      case 'tiktok':
        return Colors.black87;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle),
            label: _isFollowingAll 
                ? const Text('Following Everyone...') 
                : const Text('Follow Everyone'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: _isFollowingAll ? Colors.green : null,
            ),
            onPressed: _isFollowingAll ? null : _followEveryone,
          ),
          const SizedBox(height: 8),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Group Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _followEveryone() async {
    // Get the current user's profile to know which platforms they're on
    try {
      setState(() {
        _isFollowingAll = true;
      });
      
      final currentUserProfile = await _socialMediaService.getUserProfile();
      if (currentUserProfile == null) {
        throw Exception('User profile not found');
      }
      
      // Get all connected platforms from current user
      final connectedPlatforms = currentUserProfile.socialAccounts
          .where((account) => account.isConnected)
          .map((account) => account.platform)
          .toList();
      
      if (connectedPlatforms.isEmpty) {
        throw Exception('No connected social media accounts found');
      }
      
      // For each platform the current user is on, follow all other members who are on it
      for (var platform in connectedPlatforms) {
        // Get usernames to follow on this platform
        final usersToFollow = _memberProfiles
            .where((profile) => profile.id != _authService.getCurrentUserId())
            .map((profile) => profile.socialAccounts
                .firstWhere(
                  (account) => account.platform == platform && account.isConnected,
                  orElse: () => SocialMediaAccount(
                    platform: platform,
                    username: '',
                    isConnected: false,
                  ),
                )
            )
            .where((account) => account.isConnected && account.username.isNotEmpty)
            .map((account) => account.username)
            .toList();
        
        if (usersToFollow.isNotEmpty) {
          await _socialMediaService.followUsersOnPlatform(platform, usersToFollow);
        }
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully followed everyone!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFollowingAll = false;
        });
      }
    }
  }

  void _showShareDialog() {
    final String joinUrl = 'socialconnector://join/${widget.groupId}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this QR code or link to invite others:'),
            // const SizedBox(height: 20),
            // QrImageView(
            //   data: joinUrl,
            //   version: QrVersions.auto,
            //   size: 200.0,
            // ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    joinUrl,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: joinUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _debugPrintMemberProfiles() {
    print('-------------- MEMBER PROFILES (${_memberProfiles.length}) --------------');
    for (int i = 0; i < _memberProfiles.length; i++) {
      final profile = _memberProfiles[i];
      print('Profile #$i:');
      print('  ID: ${profile.id}');
      print('  Email: ${profile.email}');
      print('  Display Name: ${profile.displayName ?? "N/A"}');
      print('  Created: ${profile.createdAt}');
      
      // Print social accounts
      print('  Social Accounts (${profile.socialAccounts.length}):');
      for (var account in profile.socialAccounts) {
        print('    - ${account.platform}: ${account.username} (Connected: ${account.isConnected})');
      }
      print('----------------------------------------');
    }
  }
}