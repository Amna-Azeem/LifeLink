import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'req_blood_screen.dart';
class FindDonorScreen extends StatefulWidget {
  const FindDonorScreen({super.key});
  

  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  final _cityController = TextEditingController();
  String? _selectedBloodGroup;
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = false;

Future<void> _searchDonors() async {
  if (_selectedBloodGroup == null || _cityController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter both blood group and city')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final enteredCity = _cityController.text.trim().toLowerCase();

    // 🔹 Only filter by blood group in Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('bloodGroup', isEqualTo: _selectedBloodGroup)
        .get();

    final allDonors =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    // 🔹 Filter by city and role in Dart
    final matchingDonors = allDonors.where((donor) {
      final donorCity = (donor['city'] ?? '').toString().toLowerCase();
      final donorRole = (donor['role'] ?? '').toString();
      return donorCity == enteredCity && donorRole == 'Donor';
    }).toList();

    setState(() => _donors = matchingDonors);
  } catch (e) {
    print('Firestore query error: $e'); // debug in console
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching donors: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE), // 🌸 soft pink background
      appBar: AppBar(
        title: const Text(
          'Find a Donor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        backgroundColor: const Color(0xFFE53935),
        elevation: 4,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shadowColor: Colors.redAccent.withOpacity(0.3),
            margin: const EdgeInsets.all(24),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔴 Heading
                  const Center(
                    child: Text(
                      'Search for Blood Donors',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🩸 Blood Group Selector
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Blood Group',
                      labelStyle:
                          const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                      ),
                    ),
                    value: _selectedBloodGroup,
                    items: [
                      'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                    ]
                        .map((bg) =>
                            DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 16))))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBloodGroup = value),
                  ),
                  const SizedBox(height: 16),

                  // 🏙️ City Input
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Enter City',
                      labelStyle:
                          const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE53935), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔍 Search Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _searchDonors,
                      icon: const Icon(Icons.search, color: Colors.white),
                      label: const Text(
                        'Search Donors',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🧭 Results
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
                      : _donors.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Text(
                                  'No donors found.\nTry another city or group.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _donors.length,
                              itemBuilder: (context, index) {
                                final donor = _donors[index];
                                final isAvailable = donor['available'] ?? true;

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.redAccent.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: const Offset(2, 3),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.2),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: const Icon(FontAwesomeIcons.user,
                                        color: Color(0xFFE53935), size: 30),
                                    title: Text(
                                      '${donor['firstName']} ${donor['lastName']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('🩸 Blood Group: ${donor['bloodGroup']}'),
                                          Text('🏙️ City: ${donor['city']}'),
                                          const SizedBox(height: 4),
                                          Text(
                                            isAvailable ? '🟢 Available' : '🔴 Unavailable',
                                            style: TextStyle(
                                              color: isAvailable ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: isAvailable
                                          ? () {
                                             Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RequestBloodScreen(donorData: donor),
  ),
);
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAvailable
                                            ? const Color(0xFFE53935)
                                            : Colors.grey,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                      ),
                                      child: const Text(
                                        'Request',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
