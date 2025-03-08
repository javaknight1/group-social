import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Account'),
            onTap: () {
              // Will navigate to account settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Connected Accounts'),
            onTap: () {
              // Will navigate to social media connections
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () {
              // Will sign out the user
            },
          ),
        ],
      ),
    );
  }
}