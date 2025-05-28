import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibeme/screens/tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPDialog extends StatefulWidget {
  final String verificationId;
  const OTPDialog({super.key, required this.verificationId});

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _postSignInSetup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final doc = await userDocRef.get();

    if (!doc.exists) {
      await userDocRef.set({
        'phone': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'profileImageUrl': null, // or set to a default image URL
      });
    }
  }

  void verifyCode() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: _otpController.text,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _postSignInSetup();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Tabs()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
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
