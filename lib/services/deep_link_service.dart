import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../screens/group_detail_screen.dart';
import 'group_service.dart';

class DeepLinkService {
  final GroupService _groupService = GroupService();
  
  // Scan QR code and join group
  Future<void> scanQRCode(BuildContext context) async {
    try {
      String barcodeScanRes = '1234567890'; // await FlutterBarcodeScanner.scanBarcode(
      // String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //   '#ff6666',
      //   'Cancel',
      //   true,
      //   ScanMode.QR,
      // );
      
      if (barcodeScanRes != '-1') {
        // Check if it's a valid group join URL
        final uri = Uri.parse(barcodeScanRes);
        if (uri.scheme == 'socialconnector' && uri.path.startsWith('/join/')) {
          final groupId = uri.path.replaceFirst('/join/', '');
          await _joinGroupAndNavigate(context, groupId);
        } else {
          // Invalid QR code
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid QR code format')),
            );
          }
        }
      }
    } on PlatformException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to scan QR code')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  // Join a group from a shared link
  Future<void> handleDeepLink(BuildContext context, String link) async {
    try {
      final uri = Uri.parse(link);
      if (uri.scheme == 'socialconnector' && uri.path.startsWith('/join/')) {
        final groupId = uri.path.replaceFirst('/join/', '');
        await _joinGroupAndNavigate(context, groupId);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error handling link: ${e.toString()}')),
        );
      }
    }
  }
  
  // Join group and navigate to its screen
  Future<void> _joinGroupAndNavigate(BuildContext context, String groupId) async {
    try {
      await _groupService.joinGroup(groupId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined group!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetailScreen(groupId: groupId),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining group: ${e.toString()}')),
        );
      }
    }
  }
}