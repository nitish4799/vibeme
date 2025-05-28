import 'package:flutter/material.dart';
import '../widgets/otp_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AuthScreen();
  }
}

class _AuthScreen extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  dynamic userPhone;

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

  void submitAuth() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$userPhone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _postSignInSetup(); // handle post-sign-in setup
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          showDialog(
            context: context,
            builder: (context) => OTPDialog(verificationId: verificationId),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
              width: 150,
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          validator: (value) {
                            if (value != null && value.length == 10) {
                              return null;
                            }
                            return 'galat hai bhai tera phone number';
                          },
                          onSaved: ((value) {
                            userPhone = value;
                          }),
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: submitAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 97, 157, 138),
                          ),
                          child: Text(
                            'Send OTP',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
