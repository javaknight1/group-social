import 'package:flutter/material.dart';
import 'home_screen.dart';

class SocialAccountsSetupScreen extends StatefulWidget {
  const SocialAccountsSetupScreen({Key? key}) : super(key: key);

  @override
  _SocialAccountsSetupScreenState createState() => _SocialAccountsSetupScreenState();
}

class _SocialAccountsSetupScreenState extends State<SocialAccountsSetupScreen> {
  // For demonstration, we'll just track which accounts are connected
  bool _isInstagramConnected = false;
  bool _isFacebookConnected = false;
  bool _isSnapchatConnected = false;
  bool _isTikTokConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Your Accounts'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
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
            const SizedBox(height: 20),
            _buildSocialButton(
              'Instagram',
              Icons.camera_alt,
              Colors.pink,
              _isInstagramConnected,
              () {
                // Here you would handle Instagram OAuth
                setState(() {
                  _isInstagramConnected = !_isInstagramConnected;
                });
              },
            ),
            const SizedBox(height: 10),
            _buildSocialButton(
              'Facebook',
              Icons.facebook,
              Colors.blue,
              _isFacebookConnected,
              () {
                // Here you would handle Facebook OAuth
                setState(() {
                  _isFacebookConnected = !_isFacebookConnected;
                });
              },
            ),
            const SizedBox(height: 10),
            _buildSocialButton(
              'Snapchat',
              Icons.crop_square,
              Colors.yellow,
              _isSnapchatConnected,
              () {
                // Here you would handle Snapchat OAuth
                setState(() {
                  _isSnapchatConnected = !_isSnapchatConnected;
                });
              },
            ),
            const SizedBox(height: 10),
            _buildSocialButton(
              'TikTok',
              Icons.music_note,
              Colors.black87,
              _isTikTokConnected,
              () {
                // Here you would handle TikTok OAuth
                setState(() {
                  _isTikTokConnected = !_isTikTokConnected;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // For now, just proceed to home screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Continue'),
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

  Widget _buildSocialButton(
    String platform,
    IconData icon,
    Color color,
    bool isConnected,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(isConnected ? '$platform Connected' : 'Connect $platform'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? Colors.green : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: onPressed,
    );
  }
}