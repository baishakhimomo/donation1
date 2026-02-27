import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:donation_app/validators.dart';

class BloodPage extends StatefulWidget {
  const BloodPage({super.key});

  @override
  State<BloodPage> createState() => _BloodPageState();
}

class _BloodPageState extends State<BloodPage> {
  // Form controllers
  final _nameController = TextEditingController();
  final _bloodController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _searchController = TextEditingController();

  // State
  String _selectedBloodFilter = 'All';
  String _searchQuery = '';
  bool _loading = true;
  bool _isAdmin = false;

  // Donors loaded from Supabase
  List<Map<String, dynamic>> _donors = [];

  // Current user id (null if not logged in)
  String? _userId;

  final List<String> _bloodGroups = [
    'All',
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    _initUser();
    _loadDonors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Get logged-in user info and check admin
  void _initUser() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _userId = session.user.id;
      _checkAdmin(session.user.email ?? '');
    }
  }

  Future<void> _checkAdmin(String email) async {
    try {
      final row = await Supabase.instance.client
          .from('admin_emails')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (mounted) setState(() => _isAdmin = row != null);
    } catch (_) {}
  }

  // Load all donors from Supabase
  Future<void> _loadDonors() async {
    setState(() => _loading = true);
    try {
      final rows = await Supabase.instance.client
          .from('blood_donors')
          .select()
          .order('name', ascending: true);
      setState(() {
        _donors = List<Map<String, dynamic>>.from(rows as List);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // Check if current user already has a registration
  bool get _hasMyEntry {
    if (_userId == null) return false;
    return _donors.any((d) => d['user_id'] == _userId);
  }

  // Blood group picker bottom sheet
  Future<void> _pickBloodGroup() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((
              g,
            ) {
              return ListTile(
                title: Text(g),
                onTap: () => Navigator.pop(context, g),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _bloodController.text = selected);
    }
  }

  // Submit new donor registration
  Future<void> _submitDonor() async {
    // Must be logged in
    if (_userId == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Login Required'),
          content: const Text(
            'Please log in as a donor or member to register.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6FA8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Validate fields
    final errors = <String>[
      validateName(_nameController.text) ?? '',
      validateRequired(_bloodController.text, 'Blood Group') ?? '',
      validatePhone(_phoneController.text) ?? '',
      validateAddress(_addressController.text) ?? '',
    ];
    errors.removeWhere((e) => e.isEmpty);

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errors.first)));
      return;
    }

    // One registration per account (admin can add more)
    if (!_isAdmin && _hasMyEntry) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can register only once.')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('blood_donors').insert({
        'user_id': _userId,
        'name': _nameController.text.trim(),
        'blood_group': _bloodController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      _nameController.clear();
      _bloodController.clear();
      _phoneController.clear();
      _addressController.clear();

      await _loadDonors();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Edit donor entry via dialog
  Future<void> _editEntry(Map<String, dynamic> donor) async {
    final nameCtrl = TextEditingController(text: donor['name'] ?? '');
    final bloodCtrl = TextEditingController(text: donor['blood_group'] ?? '');
    final phoneCtrl = TextEditingController(text: donor['phone'] ?? '');
    final addressCtrl = TextEditingController(text: donor['address'] ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: bloodCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Blood Group'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // Capture values before disposing
    final updatedName = nameCtrl.text.trim();
    final updatedBlood = bloodCtrl.text.trim();
    final updatedPhone = phoneCtrl.text.trim();
    final updatedAddress = addressCtrl.text.trim();

    nameCtrl.dispose();
    bloodCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();

    if (saved != true) return;

    final id = donor['id'] as String?;
    if (id == null) return;

    try {
      await Supabase.instance.client
          .from('blood_donors')
          .update({
            'name': updatedName,
            'blood_group': updatedBlood,
            'phone': updatedPhone,
            'address': updatedAddress,
          })
          .eq('id', id);
      await _loadDonors();
    } catch (_) {}
  }

  // Delete a donor entry
  Future<void> _deleteEntry(Map<String, dynamic> donor) async {
    final id = donor['id'] as String?;
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Entry?'),
        content: Text('Remove ${donor['name']}?'),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client.from('blood_donors').delete().eq('id', id);
      await _loadDonors();
    } catch (_) {}
  }

  Future<void> _handleRequest(String phone) async {
    // Build a tel: URI and launch the phone dialer
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not call $phone')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ===== Responsive sizes (same pattern as other pages) ==s===
    final width = MediaQuery.sizeOf(context).width;
    final double pagePad = width * 0.04;
    final double titleSize = width * 0.055;
    final double bodySize = width * 0.037;
    final double smallSize = width * 0.032;

    // Filter donors for display
    final filtered = _donors.where((d) {
      final matchBlood =
          _selectedBloodFilter == 'All' ||
          d['blood_group'] == _selectedBloodFilter;
      final name = (d['name'] ?? '').toString().toLowerCase();
      final matchSearch = _searchQuery.isEmpty || name.contains(_searchQuery);
      return matchBlood && matchSearch;
    }).toList();

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
                // ===== HEADER — same as login page =====
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
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new),
                        ),
                        Image.asset(
                          'assets/logo.jpeg',
                          height: 34,
                          width: 34,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Donate Blood",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== BODY =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(pagePad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ===== REGISTRATION FORM =====
                        Container(
                          padding: EdgeInsets.all(pagePad),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Logo watermark
                              Center(
                                child: Opacity(
                                  opacity: 0.08,
                                  child: Image.asset(
                                    'assets/logo.jpeg',
                                    width: width * 0.5,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Register as a Blood Donor',
                                    style: TextStyle(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        72,
                                        131,
                                        198,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad * 0.4),
                                  Text(
                                    'Fill the form below to help those in need.',
                                    style: TextStyle(
                                      fontSize: smallSize,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: pagePad),

                                  // Form fields
                                  _buildField(
                                    _nameController,
                                    'Full Name',
                                    'Enter full name',
                                    bodySize,
                                  ),
                                  SizedBox(height: pagePad * 0.7),
                                  _buildField(
                                    _bloodController,
                                    'Blood Group',
                                    'Select blood group',
                                    bodySize,
                                    readOnly: true,
                                    onTap: _pickBloodGroup,
                                    suffixIcon: Icons.arrow_drop_down,
                                  ),
                                  SizedBox(height: pagePad * 0.7),
                                  _buildField(
                                    _phoneController,
                                    'Phone Number',
                                    'Enter phone number',
                                    bodySize,
                                    keyboard: TextInputType.phone,
                                  ),
                                  SizedBox(height: pagePad * 0.7),
                                  _buildField(
                                    _addressController,
                                    'Address',
                                    'Enter address',
                                    bodySize,
                                  ),
                                  SizedBox(height: pagePad),

                                  // Submit button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _submitDonor,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          224,
                                          79,
                                          69,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: pagePad * 0.8,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(fontSize: bodySize),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: pagePad * 1.2),

                        // ===== REGISTERED DONORS =====
                        Text(
                          'Registered Blood Donors',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 78, 91, 106),
                          ),
                        ),
                        SizedBox(height: pagePad * 0.7),

                        // Search bar
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: pagePad * 0.6,
                            vertical: pagePad * 0.3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: TextStyle(fontSize: bodySize),
                                  decoration: InputDecoration(
                                    hintText: 'Search by name',
                                    hintStyle: TextStyle(fontSize: bodySize),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (v) {
                                    setState(() {
                                      _searchQuery = v.trim().toLowerCase();
                                    });
                                  },
                                ),
                              ),
                              Icon(Icons.search, size: width * 0.06),
                            ],
                          ),
                        ),
                        SizedBox(height: pagePad * 0.7),

                        // Blood group filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _bloodGroups.map((group) {
                              final isSelected = _selectedBloodFilter == group;
                              return Padding(
                                padding: EdgeInsets.only(right: pagePad * 0.5),
                                child: ChoiceChip(
                                  label: Text(
                                    group,
                                    style: TextStyle(fontSize: smallSize),
                                  ),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedBloodFilter = group;
                                    });
                                  },
                                  selectedColor: const Color.fromARGB(
                                    255,
                                    120,
                                    160,
                                    220,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: pagePad * 0.7),

                        // Donor cards
                        if (_loading)
                          const Center(child: CircularProgressIndicator())
                        else if (filtered.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(pagePad * 2),
                              child: Text(
                                'No donors found.',
                                style: TextStyle(
                                  fontSize: bodySize,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (donor) => _donorCard(
                              donor,
                              width,
                              pagePad,
                              bodySize,
                              smallSize,
                            ),
                          ),

                        SizedBox(height: pagePad),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== Reusable responsive text field =====
  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    double fontSize, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboard,
      style: TextStyle(fontSize: fontSize),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: fontSize),
        hintStyle: TextStyle(fontSize: fontSize * 0.9),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: fontSize * 0.8,
          vertical: fontSize * 0.7,
        ),
      ),
    );
  }

  // ===== Donor card =====
  Widget _donorCard(
    Map<String, dynamic> donor,
    double width,
    double pagePad,
    double bodySize,
    double smallSize,
  ) {
    final name = (donor['name'] ?? '') as String;
    final blood = (donor['blood_group'] ?? '') as String;
    final phone = (donor['phone'] ?? '') as String;
    final address = (donor['address'] ?? '') as String;
    final donorUserId = donor['user_id'] as String?;

    // User can manage their own entry; admin can manage all
    final isMine = _userId != null && donorUserId == _userId;
    final canManage = isMine || _isAdmin;

    // Initials from name
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      margin: EdgeInsets.only(bottom: pagePad * 0.7),
      padding: EdgeInsets.all(pagePad * 0.7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: width * 0.06,
            backgroundColor: const Color.fromARGB(255, 200, 220, 245),
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: bodySize,
                color: const Color.fromARGB(255, 78, 91, 106),
              ),
            ),
          ),
          SizedBox(width: pagePad * 0.6),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: bodySize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: pagePad * 0.2),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: pagePad * 0.4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 219, 217),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        blood,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 182, 70, 70),
                          fontWeight: FontWeight.bold,
                          fontSize: smallSize,
                        ),
                      ),
                    ),
                    SizedBox(width: pagePad * 0.4),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: smallSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: pagePad * 0.2),
                Text(
                  phone,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 95, 128, 178),
                    fontSize: smallSize,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Request / Call button
              ElevatedButton(
                onPressed: () => _handleRequest(phone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 120, 160, 220),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: pagePad * 0.6,
                    vertical: pagePad * 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.call, size: width * 0.04),
                    SizedBox(width: pagePad * 0.2),
                    Text('Request', style: TextStyle(fontSize: smallSize)),
                  ],
                ),
              ),

              // Edit / Delete — own entry or admin
              if (canManage)
                Padding(
                  padding: EdgeInsets.only(top: pagePad * 0.3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editEntry(donor),
                        icon: Icon(Icons.edit, size: width * 0.045),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: pagePad * 0.3),
                      IconButton(
                        onPressed: () => _deleteEntry(donor),
                        icon: Icon(
                          Icons.delete,
                          size: width * 0.045,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
