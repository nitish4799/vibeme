import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibeme/screens/tabs.dart';

class OTPDialog extends StatefulWidget {
  final String verificationId;
  const OTPDialog({super.key, required this.verificationId});

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final TextEditingController _otpController = TextEditingController();

  void verifyCode() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: _otpController.text,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return; // ✅ Check if widget is still mounted

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => Tabs(),
        ), // Replace with your actual widget
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return; // ✅ Prevent usage of context if unmounted

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to sign in: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter OTP'),
      content: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: '6-digit code'),
      ),
      actions: [TextButton(onPressed: verifyCode, child: Text('Verify'))],
    );
  }
}
