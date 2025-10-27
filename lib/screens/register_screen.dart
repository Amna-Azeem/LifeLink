import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();
  String? _selectedRole; // Donor or Recipient
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your role')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        // Create user in Firebase Authentication
        UserCredential userCred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCred.user!.updateDisplayName(
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
        );

        // Store additional data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'bloodGroup': _bloodGroupController.text.trim(),
          'city': _cityController.text.trim(),
          'contact': _contactController.text.trim(),
          'role': _selectedRole, // Donor or Recipient
          'lastDonation': null,
        });

        // ✅ Log out right after registration
        await FirebaseAuth.instance.signOut();

        // ✅ Show success message and redirect
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please log in.'),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.code} — ${e.message}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bloodGroupController.dispose();
    _cityController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFFFFF7F7),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFCEAEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Card(
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(Icons.bloodtype,
                            color: const Color(0xFFE53935), size: 60),
                      ),
                      const SizedBox(height: 10),


                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "Create Your Account",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE53935),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Join LifeLink and make a difference today.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                    
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'First Name',
                              ),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Enter name' : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration:
                                  inputDecoration.copyWith(labelText: 'Last Name'),
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Enter name' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _emailController,
                        decoration: inputDecoration.copyWith(labelText: 'Email'),
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Enter valid email'
                            : null,
                      ),
                      const SizedBox(height: 14),

                     
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            inputDecoration.copyWith(labelText: 'Password'),
                        obscureText: true,
                        validator: (val) => val == null || val.length < 6
                            ? 'Password too short'
                            : null,
                      ),
                      const SizedBox(height: 14),

                 
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: inputDecoration.copyWith(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Confirm your password';
                          } else if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _bloodGroupController,
                        decoration:
                            inputDecoration.copyWith(labelText: 'Blood Group'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter blood group' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _cityController,
                        decoration: inputDecoration.copyWith(labelText: 'City'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter city' : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: _contactController,
                        decoration:
                            inputDecoration.copyWith(labelText: 'Contact Number'),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter contact' : null,
                      ),
                      const SizedBox(height: 14),


                      Text(
                        "Register as",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: const [
                          DropdownMenuItem(
                              value: "Donor", child: Text("Donor")),
                          DropdownMenuItem(
                              value: "Recipient", child: Text("Recipient")),
                        ],
                        decoration:
                            inputDecoration.copyWith(hintText: "Select Role"),
                        onChanged: (value) =>
                            setState(() => _selectedRole = value),
                      ),
                      const SizedBox(height: 20),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                                ),
                                onPressed: _register,
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
