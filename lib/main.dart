import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SocialConnectorApp());
}

class SocialConnectorApp extends StatelessWidget {
  const SocialConnectorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Connector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}