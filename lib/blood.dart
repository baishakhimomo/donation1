import 'package:flutter/material.dart';

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

  // Local UI state
  bool _hasSubmitted = false;
  String _selectedBloodFilter = 'All';
  String _searchQuery = '';

  String _myEntryKey = '';

  // In-memory donor list (replace with backend later)
  final List<Map<String, String>> _donors = [];

  // Filter options
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

  Future<void> pickBloodGroup() async {
    // Bottom-sheet picker for blood group
    String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('A+'),
              onTap: () => Navigator.pop(context, 'A+'),
            ),
            ListTile(
              title: const Text('A-'),
              onTap: () => Navigator.pop(context, 'A-'),
            ),
            ListTile(
              title: const Text('B+'),
              onTap: () => Navigator.pop(context, 'B+'),
            ),
            ListTile(
              title: const Text('B-'),
              onTap: () => Navigator.pop(context, 'B-'),
            ),
            ListTile(
              title: const Text('O+'),
              onTap: () => Navigator.pop(context, 'O+'),
            ),
            ListTile(
              title: const Text('O-'),
              onTap: () => Navigator.pop(context, 'O-'),
            ),
            ListTile(
              title: const Text('AB+'),
              onTap: () => Navigator.pop(context, 'AB+'),
            ),
            ListTile(
              title: const Text('AB-'),
              onTap: () => Navigator.pop(context, 'AB-'),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      setState(() {
        _bloodController.text = selected;
      });
    }
  }

  void _handleRequest(String phone) {
    // Request action (call later via url_launcher)
    // TODO: Later
    // 1) Add url_launcher to pubspec.yaml
    // 2) import 'package:url_launcher/url_launcher.dart';
    // 3) call launchUrl(Uri.parse('tel:$phone')) here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Call $phone')));
  }

  void _submitDonor() {
    // Validate and add a donor entry
    if (_nameController.text.trim().isEmpty ||
        _bloodController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    if (_hasSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can register only once.')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final blood = _bloodController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final entryKey = '${name.toLowerCase()}|${phone.toLowerCase()}';

    setState(() {
      _donors.add({
        'name': name,
        'blood': blood,
        'address': address,
        'phone': phone,
      });
      _hasSubmitted = true;
      _myEntryKey = entryKey;
      _nameController.clear();
      _bloodController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  void _startEdit(Map<String, String> donor) {
    _nameController.text = donor['name'] ?? '';
    _bloodController.text = donor['blood'] ?? '';
    _phoneController.text = donor['phone'] ?? '';
    _addressController.text = donor['address'] ?? '';
  }

  void _updateMyEntry(Map<String, String> donor) {
    if (_nameController.text.trim().isEmpty ||
        _bloodController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    final name = _nameController.text.trim();
    final blood = _bloodController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    final newKey = '${name.toLowerCase()}|${phone.toLowerCase()}';

    setState(() {
      final index = _donors.indexOf(donor);
      if (index != -1) {
        _donors[index] = {
          'name': name,
          'blood': blood,
          'address': address,
          'phone': phone,
        };
        _myEntryKey = newKey;
      }
      _nameController.clear();
      _bloodController.clear();
      _phoneController.clear();
      _addressController.clear();
    });
  }

  void _deleteMyEntry(Map<String, String> donor) {
    setState(() {
      _donors.remove(donor);
      _hasSubmitted = false;
      _myEntryKey = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 720;
    final contentWidth = size.width > 900 ? 900.0 : size.width;
    final fieldWidth = isWide ? (contentWidth - 16) / 2 : contentWidth;
    // Sort + filter donors for display
    final donors = List<Map<String, String>>.from(_donors)
      ..sort((a, b) => a['name']!.compareTo(b['name']!));
    final filteredDonors = donors.where((donor) {
      final matchesBlood =
          _selectedBloodFilter == 'All' ||
          donor['blood'] == _selectedBloodFilter;
      final name = donor['name'] ?? '';
      final matchesSearch =
          _searchQuery.isEmpty || name.toLowerCase().contains(_searchQuery);
      return matchesBlood && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 15),
            Image.asset('assets/logo.jpeg', width: 30, height: 30),
            const SizedBox(width: 8),
            const Text(
              'DONATE BLOOD, SAVE LIVES',
              style: TextStyle(
                color: Color.fromARGB(255, 78, 91, 106),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Donor registration section
                    Container(
                      padding: const EdgeInsets.all(16),
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
                                width: 250,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section header
                              const Text(
                                'Register as a Blood Donor',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 72, 131, 198),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Fill the form below to help those in need.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(255, 120, 120, 120),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Form fields
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Full Name',
                                        hintText: 'Enter full name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: _bloodController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        labelText: 'Blood Group',
                                        hintText: 'Select blood group',
                                        suffixIcon: const Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onTap: pickBloodGroup,
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        hintText: 'Enter phone number',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: fieldWidth,
                                    child: TextField(
                                      controller: _addressController,
                                      decoration: InputDecoration(
                                        labelText: 'Address',
                                        hintText: 'Enter address',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Donor list section
                    const Text(
                      'Registered Blood Donors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 78, 91, 106),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
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
                              decoration: const InputDecoration(
                                hintText: 'Search by name',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.trim().toLowerCase();
                                });
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = _searchController.text
                                    .trim()
                                    .toLowerCase();
                              });
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Blood group filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _bloodGroups.map((group) {
                          final isSelected = _selectedBloodFilter == group;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(group),
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
                    const SizedBox(height: 12),
                    // Donor cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredDonors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final donor = filteredDonors[index];
                        final initials = donor['name']!
                            .split(' ')
                            .where((part) => part.isNotEmpty)
                            .take(2)
                            .map((part) => part[0])
                            .join();

                        final donorKey =
                            '${donor['name']!.toLowerCase()}|${donor['phone']!.toLowerCase()}';
                        final isMine = donorKey == _myEntryKey;

                        return Container(
                          padding: const EdgeInsets.all(12),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  200,
                                  220,
                                  245,
                                ),
                                child: Text(
                                  initials.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      donor['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              255,
                                              245,
                                              219,
                                              217,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            donor['blood']!,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                182,
                                                70,
                                                70,
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            donor['address']!,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                120,
                                                120,
                                                120,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      donor['phone']!,
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          95,
                                          128,
                                          178,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (isMine)
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _startEdit(donor),
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () => _updateMyEntry(donor),
                                      icon: const Icon(Icons.check_circle),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteMyEntry(donor),
                                      icon: const Icon(Icons.delete),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _handleRequest(donor['phone']!),
                                      icon: const Icon(Icons.call),
                                      label: const Text('Request'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          120,
                                          160,
                                          220,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _handleRequest(donor['phone']!),
                                  icon: const Icon(Icons.call),
                                  label: const Text('Request'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      120,
                                      160,
                                      220,
                                    ),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
