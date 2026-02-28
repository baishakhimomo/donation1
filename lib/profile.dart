import 'package:donation_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool _loading = true;
  String _role = ''; // 'Donor' or 'Member'
  Map<String, dynamic> _info = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);

    try {
      final user = _supa.auth.currentUser;
      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      final email = user.email ?? '';

      // Member emails end with @lussc.local
      if (email.endsWith('@lussc.local')) {
        // Fetch from members table
        final row = await _supa
            .from('members')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (row != null) {
          _role = 'Member';
          _info = row;
        }
      } else {
        // Fetch from Donors table
        final row = await _supa
            .from('Donors')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (row != null) {
          _role = 'Donor';
          _info = row;
        }
      }
    } catch (e) {
      debugPrint('profile load error: $e');
    }

    setState(() => _loading = false);
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pagePad = width * 0.04;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar — same as login page ──
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(235),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Image.asset(
                          'assets/logo.jpeg',
                          height: 34,
                          width: 34,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Body ──
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _supa.auth.currentUser == null
                      ? const Center(
                          child: Text(
                            'Please login first',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      : _role.isEmpty
                      ? const Center(
                          child: Text(
                            'Profile not found',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: pagePad),
                          child: _buildProfileContent(width),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(double width) {
    final name = (_info['name'] ?? '').toString();

    return Column(
      children: [
        const SizedBox(height: 10),

        // Avatar
        CircleAvatar(
          radius: width * 0.14,
          backgroundColor: Colors.white70,
          child: Text(
            _getInitials(name),
            style: TextStyle(
              fontSize: width * 0.09,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 30, 111, 168),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Name
        Text(
          name,
          style: TextStyle(
            fontSize: width * 0.065,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _role == 'Member' ? Colors.blue : Colors.teal,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            _role,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Center(
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset('assets/logo.jpeg', width: width * 0.5),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Color.fromARGB(255, 24, 75, 106),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show fields based on role
                  if (_role == 'Member') ...[
                    _infoRow(Icons.badge, 'Student ID', _info['student_id']),
                    _infoRow(Icons.person, 'Name', _info['name']),
                    _infoRow(Icons.school, 'Department', _info['department']),
                    _infoRow(
                      Icons.numbers,
                      'Batch',
                      _info['batch']?.toString(),
                    ),
                    _infoRow(
                      Icons.email,
                      'Contact Email',
                      _info['contact_email'],
                    ),
                  ],

                  if (_role == 'Donor') ...[
                    _infoRow(Icons.person, 'Name', _info['name']),
                    _infoRow(Icons.phone, 'Phone', _info['phone']),
                    _infoRow(Icons.email, 'Email', _info['email']),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Home button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 30, 111, 168),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.home),
            label: const Text('Go to Home', style: TextStyle(fontSize: 16)),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // Single info row
  Widget _infoRow(IconData icon, String label, dynamic value) {
    final text = (value ?? '—').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color.fromARGB(255, 30, 111, 168)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
