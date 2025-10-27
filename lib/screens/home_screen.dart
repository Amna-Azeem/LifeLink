import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "LifeLink Hero";

    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: AppBar(
        title: const Text(
          'LifeLink',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFFE53935),
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            tooltip: "Logout",
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 Hero Banner
            Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://static.vecteezy.com/system/resources/thumbnails/072/456/068/small/a-drop-of-blood-is-shown-on-a-dark-background-photo.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 260,
                  color: Colors.black.withOpacity(0.45),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome to LifeLink',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hello, $displayName 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // 🩸 Action Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildActionCard(
                      context, 'Find Donor', Icons.search, '/find-donor'),
                  
                  // 🧍‍♀️ Profile navigation (custom)
                  GestureDetector(
                    onTap: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.pushNamed(
                          context,
                          '/profile',
                          arguments: {'userId': user.uid},
                        );
                      }
                    },
                    child: _buildActionCard(
                        context, 'Profile', Icons.person, '/profile'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ❤️ Info Section (light cards)
            _buildInfoCard(
              title: "About Us",
              content:
                  "LifeLink is a community-driven platform connecting donors and recipients to ensure every drop counts. We make it simple, secure, and life-saving.",
            ),
            _buildInfoCard(
              title: "Our Mission & Vision",
              content:
                  "Our mission is to make blood donation accessible for everyone. We envision a world where every patient can find a life-saving donor instantly.",
            ),
            _buildInfoCard(
              title: "Contact Us",
              content:
                  "📍 Karachi, Pakistan\n📧 support@lifelink.org\n☎️ +92-300-1234567",
            ),

            const SizedBox(height: 30),

            // 🔻 Footer
            Container(
              width: double.infinity,
              color: const Color(0xFFFFCDD2),
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  '© 2025 LifeLink | Every Drop Counts ❤️',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🩸 Action Card (now tappable)
  Widget _buildActionCard(
      BuildContext context, String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () {
        if (route.isNotEmpty) {
          Navigator.pushNamed(context, route);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE53935), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(4, 6),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 10,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: const Color(0xFFE53935)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🧾 Info Section
  Widget _buildInfoCard({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.redAccent.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE53935),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
