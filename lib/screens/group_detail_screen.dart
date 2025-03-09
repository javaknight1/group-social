import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:qr_flutter/qr_flutter.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../services/group_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;
  
  const GroupDetailScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupService _groupService = GroupService();
  bool _isLoading = true;
  Group? _group;
  String _error = '';

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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(member.userId.substring(0, 1).toUpperCase()),
                      ),
                      title: Text(member.userId),
                      subtitle: Text(member.isAdmin ? 'Admin' : 'Member'),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle),
            label: const Text('Follow Everyone'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              // In a real app, this would trigger the social media following process
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Following everyone in this group!')),
              );
            },
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
            const SizedBox(height: 20),
            // QrImageView(
            //   data: joinUrl,
            //   version: QrVersions.auto,
            //   size: 200.0,
            // ),
            // const SizedBox(height: 20),
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
}