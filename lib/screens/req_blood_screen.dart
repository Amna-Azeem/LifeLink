import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class RequestBloodScreen extends StatefulWidget {
  final Map<String, dynamic> donorData; // donor info passed from Find Donor page

  const RequestBloodScreen({super.key, required this.donorData});

  @override
  State<RequestBloodScreen> createState() => _RequestBloodScreenState();
}

class _RequestBloodScreenState extends State<RequestBloodScreen>
    with SingleTickerProviderStateMixin {
  bool _isSending = false;
  bool _isSent = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
  // Example: Add some basic validation if you have text fields
  // if (_nameController.text.isEmpty || _bloodGroupController.text.isEmpty) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Please fill all fields")),
  //   );
  //   return;
  // }

  setState(() {
    _isSending = true;
  });

  try {
    // Save request to Firestore (change collection name as needed)
    await FirebaseFirestore.instance.collection('bloodRequests').add({
      'bloodGroup': 'A+', // replace with your controller values
      'location': 'Lahore', // or form fields
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Blood request sent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Failed to send request: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

      

     

  @override
  Widget build(BuildContext context) {
    final donor = widget.donorData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Blood', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: _isSent
              ? FadeTransition(
                  opacity: _controller,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 90),
                      const SizedBox(height: 20),
                      const Text(
                        "Request Sent Successfully!",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your blood request has been sent to ${donor['firstName']} ${donor['lastName']}.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Back to Donors"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              "You are about to send a blood request to:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.red.shade100,
                              child: Text(
                                donor['firstName'][0],
                                style: const TextStyle(
                                    fontSize: 32, color: Colors.redAccent),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${donor['firstName']} ${donor['lastName']}",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text("Blood Group: ${donor['bloodGroup']}"),
                            Text("City: ${donor['city']}"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _isSending
    ? const CircularProgressIndicator(color: Colors.redAccent)
    : ElevatedButton.icon(
        onPressed: _sendRequest, // ✅ calls the real backend function
        icon: const Icon(Icons.send),
        label: const Text(
          "Send Blood Request",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
        

                  ],
                ),
        ),
      ),
    );
  }
}
