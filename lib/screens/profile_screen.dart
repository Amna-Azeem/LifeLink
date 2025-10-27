import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'edit_profile_screen.dart';
import 'find_donor_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;
  Map<String, dynamic>? userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      // 🔹 Try fetching by UID
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          _loading = false;
        });
      } else {
        // 🔹 If no UID doc found, try by email
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            userData = snapshot.docs.first.data();
            _loading = false;
          });
        } else {
          // 🔹 Default fallback values
          setState(() {
            userData = {
              'firstName': 'Unknown',
              'lastName': '',
              'email': user.email ?? '',
              'bloodGroup': 'N/A',
              'contact': 'N/A',
              'city': 'N/A',
            };
            _loading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFE53935),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: _imageBytes != null
                  ? MemoryImage(_imageBytes!)
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: pickImage,
              child: const Text(
                "Change Photo",
                style: TextStyle(
                    color: Color(0xFFE53935),
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Blood Donor | Life Saver',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 25),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    InfoRow(
                      label: 'Full Name',
                      value:
                          '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}',
                    ),
                    const Divider(),
                    InfoRow(
                        label: 'Email',
                        value: userData?['email'] ?? 'Not available'),
                    const Divider(),
                    InfoRow(
                        label: 'Blood Group',
                        value: userData?['bloodGroup'] ?? 'N/A'),
                    const Divider(),
                    InfoRow(
                        label: 'Contact',
                        value: userData?['contact'] ?? 'N/A'),
                    const Divider(),
                    InfoRow(label: 'City', value: userData?['city'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit Profile',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    minimumSize: const Size(150, 45),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FindDonorScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text('Search Donor',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    minimumSize: const Size(150, 45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black87)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w400, color: Colors.black54)),
        ],
      ),
    );
  }
}
