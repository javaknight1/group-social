import 'package:flutter/material.dart';
import '../services/social_media_service.dart';
import 'home_screen.dart';

enum ScreenMode {
  registration,
  settings
}

class SocialAccountsSetupScreen extends StatefulWidget {
  final ScreenMode mode;
  
  const SocialAccountsSetupScreen({
    Key? key, 
    this.mode = ScreenMode.registration
  }) : super(key: key);

  @override
  _SocialAccountsSetupScreenState createState() => _SocialAccountsSetupScreenState();
}

class _SocialAccountsSetupScreenState extends State<SocialAccountsSetupScreen> {
  final _socialMediaService = SocialMediaService();
  
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _snapchatController = TextEditingController();
  final _tiktokController = TextEditingController();
  
  bool _isLoading = false;
  bool _isInitializing = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadExistingAccounts();
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _facebookController.dispose();
    _snapchatController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

    Future<void> _loadExistingAccounts() async {
    try {
      setState(() {
        _isInitializing = true;
      });
      
      // Get the current user's profile
      final userProfile = await _socialMediaService.getUserProfile();
      
      if (userProfile != null && userProfile.socialAccounts.isNotEmpty) {
        // Populate text controllers with existing values
        for (var account in userProfile.socialAccounts) {
          switch (account.platform.toLowerCase()) {
            case 'instagram':
              _instagramController.text = account.username;
              break;
            case 'facebook':
              _facebookController.text = account.username;
              break;
            case 'snapchat':
              _snapchatController.text = account.username;
              break;
            case 'tiktok':
              _tiktokController.text = account.username;
              break;
          }
        }
        
        print('Loaded accounts: ${userProfile.socialAccounts.length}');
      }
    } catch (e) {
      print('Error loading social accounts: $e');
      // Don't show error to user, just log it
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Your Accounts'),
        // Show back button in settings mode, hide in registration mode
        automaticallyImplyLeading: widget.mode == ScreenMode.settings,
        // Show skip button in registration mode only
        actions: widget.mode == ScreenMode.registration ? [
          TextButton(
            onPressed: _navigateToHome,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ] : null,
      ),
      body: _isLoading || _isInitializing
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
                  // Only show Skip option in registration mode as text button at bottom
                  if (widget.mode == ScreenMode.registration) 
                    const SizedBox(height: 10),
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

  void _navigateToHome() {
    if (widget.mode == ScreenMode.registration) {
      // From registration: clear the entire navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,  // This predicate ensures all previous routes are removed
      );
    } else {
      // From settings: just go back
      Navigator.pop(context);
    }
  }

  Future<void> _saveAccounts() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Instagram
      if (_instagramController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'instagram',
          _instagramController.text.trim(),
        );
      } else {
        await _socialMediaService.disconnectSocialAccount('instagram');
      }
      
      // Facebook
      if (_facebookController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'facebook',
          _facebookController.text.trim(),
        );
      } else {
        await _socialMediaService.disconnectSocialAccount('facebook');
      }
      
      // Snapchat
      if (_snapchatController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'snapchat',
          _snapchatController.text.trim(),
        );
      } else {
        await _socialMediaService.disconnectSocialAccount('snapchat');
      }
      
      // TikTok
      if (_tiktokController.text.isNotEmpty) {
        await _socialMediaService.connectSocialAccount(
          'tiktok',
          _tiktokController.text.trim(),
        );
      } else {
        await _socialMediaService.disconnectSocialAccount('tiktok');
      }
      
      // Navigate based on mode
      if (mounted) {
        _navigateToHome();
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