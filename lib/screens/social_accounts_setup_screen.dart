import 'package:flutter/material.dart';
import '../services/social_media_service.dart';
import 'home_screen.dart';

class SocialAccountsSetupScreen extends StatefulWidget {
  const SocialAccountsSetupScreen({Key? key}) : super(key: key);

  @override
  _SocialAccountsSetupScreenState createState() => _SocialAccountsSetupScreenState();
}

class _SocialAccountsSetupScreenState extends State<SocialAccountsSetupScreen> {
  final _socialMediaService = SocialMediaService();
  
  // For each platform, we need a controller for the username
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _snapchatController = TextEditingController();
  final _tiktokController = TextEditingController();
  
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _instagramController.dispose();
    _facebookController.dispose();
    _snapchatController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Your Accounts'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Connect your social media accounts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your username for each platform you want to connect',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSocialAccountInput(
                    'Instagram',
                    Icons.camera_alt,
                    Colors.pink,
                    _instagramController,
                    '@username',
                  ),
                  const SizedBox(height: 16),
                  _buildSocialAccountInput(
                    'Facebook',
                    Icons.facebook,
                    Colors.blue,
                    _facebookController,
                    'username or profile URL',
                  ),
                  const SizedBox(height: 16),
                  _buildSocialAccountInput(
                    'Snapchat',
                    Icons.crop_square,
                    Colors.yellow,
                    _snapchatController,
                    'username',
                  ),
                  const SizedBox(height: 16),
                  _buildSocialAccountInput(
                    'TikTok',
                    Icons.music_note,
                    Colors.black87,
                    _tiktokController,
                    '@username',
                  ),
                  if (_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveAccounts,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Save and Continue'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    },
                    child: const Text('Skip for now'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSocialAccountInput(
    String platform,
    IconData icon,
    Color color,
    TextEditingController controller,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                platform,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAccounts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Connect accounts that have usernames entered
      if (_instagramController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'instagram',
          _instagramController.text.trim(),
        );
      }
      
      if (_facebookController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'facebook',
          _facebookController.text.trim(),
        );
      }
      
      if (_snapchatController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'snapchat',
          _snapchatController.text.trim(),
        );
      }
      
      if (_tiktokController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'tiktok',
          _tiktokController.text.trim(),
        );
      }
      
      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}