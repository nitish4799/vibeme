import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final imagePicker = ImagePicker();

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _pickerImageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // print("No user is currently signed in.");
        return;
      }

      final uid = user.uid;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();

      if (data != null && data.containsKey('profileImageUrl')) {
        setState(() {
          _profileImageUrl = data['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Failed to load profile image: $e');
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // print("No user is currently signed in.");
        return;
      }

      final uid = user.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$uid.jpg');

      await storageRef.putFile(imageFile);

      final downloadURL = await storageRef.getDownloadURL();
      // print('Image uploaded! URL: $downloadURL');

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profileImageUrl': downloadURL,
      }, SetOptions(merge: true));

      await user.updatePhotoURL(downloadURL);

      setState(() {
        _pickerImageFile = imageFile;
        _profileImageUrl = downloadURL;
      });
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  void _onAvatarTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Picture'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 50,
                      maxWidth: 150,
                    );
                    if (image == null) return;
                    final file = File(image.path);
                    setState(() {
                      _pickerImageFile = file;
                    });
                    await _uploadImageToFirebase(file);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Upload a Picture'),
                  onTap: () async {
                    Navigator.pop(context);
                    final image = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                      maxWidth: 150,
                    );
                    if (image == null) return;
                    final file = File(image.path);
                    setState(() {
                      _pickerImageFile = file;
                    });
                    await _uploadImageToFirebase(file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_pickerImageFile != null) {
      imageProvider = FileImage(_pickerImageFile!);
    } else if (_profileImageUrl != null) {
      imageProvider = NetworkImage(_profileImageUrl!);
    }

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => _onAvatarTap(context),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.manage_accounts, size: 40)
                : null,
          ),
        ),
      ),
    );
  }
}