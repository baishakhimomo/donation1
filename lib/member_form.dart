import 'package:donation_app/membership_fee_payment_page.dart';
import 'package:donation_app/validators.dart';
import 'package:flutter/material.dart';
import 'package:donation_app/authentication/auth.dart';

class MemberForm extends StatefulWidget {
  const MemberForm({super.key});

  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _deptController = TextEditingController();
  final _batchController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _bloodController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  void submitForm() async {
    // --- Regex validation ---
    final errors = <String>[
      validateName(_nameController.text) ?? '',
      validateStudentId(_studentIdController.text) ?? '',
      validateDepartment(_deptController.text) ?? '',
      validateBatch(_batchController.text) ?? '',
      validateEmail(_emailController.text) ?? '',
      validatePhone(_phoneController.text) ?? '',
      validateRequired(_genderController.text, 'Gender') ?? '',
      validateAddress(_addressController.text) ?? '',
      validatePassword(_passwordController.text) ?? '',
    ];
    errors.removeWhere((e) => e.isEmpty);

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errors.first)));
      return;
    }

    if (_passwordController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      await Auth().memberSignUp(
        studentId: _studentIdController.text.trim(),
        name: _nameController.text.trim(),
        department: _deptController.text.trim(),
        batch: int.parse(_batchController.text.trim()),
        contactEmail: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MembershipFeePaymentPage(
            studentId: _studentIdController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Gender Select
  Future<void> pickGender() async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Male"),
                onTap: () => Navigator.pop(context, "Male"),
              ),
              ListTile(
                title: const Text("Female"),
                onTap: () => Navigator.pop(context, "Female"),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _genderController.text = selected);
    }
  }

  // Blood group select
  Future<void> pickBloodGroup() async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("A+"),
                onTap: () => Navigator.pop(context, "A+"),
              ),
              ListTile(
                title: const Text("A-"),
                onTap: () => Navigator.pop(context, "A-"),
              ),
              ListTile(
                title: const Text("B+"),
                onTap: () => Navigator.pop(context, "B+"),
              ),
              ListTile(
                title: const Text("B-"),
                onTap: () => Navigator.pop(context, "B-"),
              ),
              ListTile(
                title: const Text("O+"),
                onTap: () => Navigator.pop(context, "O+"),
              ),
              ListTile(
                title: const Text("O-"),
                onTap: () => Navigator.pop(context, "O-"),
              ),
              ListTile(
                title: const Text("AB+"),
                onTap: () => Navigator.pop(context, "AB+"),
              ),
              ListTile(
                title: const Text("AB-"),
                onTap: () => Navigator.pop(context, "AB-"),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _bloodController.text = selected);
    }
  }

  // Reusable text field
  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    double pagePad, {
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    TextInputType? keyboard,
    bool obscure = false,
  }) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboard,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 78, 91, 106)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 182, 179, 179)),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 182, 179, 179),
            width: 0.9,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 78, 91, 106),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double pagePad = width * 0.04;
    final double sectionSize = width * 0.055;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/backg.png", fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.white.withAlpha(89))),
          SafeArea(
            child: Column(
              children: [
                // HEADER — same style as login page
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
                          "LUSSC",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: pagePad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: pagePad),

                        // Title — same font as login page
                        const Text(
                          "Join the LUSSC\nFamily!",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: Color.fromARGB(255, 24, 75, 106),
                          ),
                        ),

                        SizedBox(height: pagePad),

                        // Registration form card
                        Container(
                          padding: EdgeInsets.all(pagePad),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Center(
                                  child: Opacity(
                                    opacity: 0.08,
                                    child: Image.asset(
                                      "assets/logo.jpeg",
                                      width: width * 0.85,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Membership Registration Form",
                                    style: TextStyle(
                                      fontSize: sectionSize,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        255,
                                        24,
                                        75,
                                        106,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad * 0.4),

                                  // Steps
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Text(
                                          "Step 1: Fill the form",
                                          style: TextStyle(
                                            fontSize: sectionSize * 0.65,
                                            color: const Color.fromARGB(
                                              255,
                                              72,
                                              131,
                                              198,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: pagePad * 0.4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: sectionSize * 0.7,
                                          color: const Color.fromARGB(
                                            255,
                                            182,
                                            179,
                                            179,
                                          ),
                                        ),
                                        SizedBox(width: pagePad * 0.4),
                                        Text(
                                          "Step 2: Pay fee",
                                          style: TextStyle(
                                            fontSize: sectionSize * 0.65,
                                            color: const Color.fromARGB(
                                              255,
                                              182,
                                              179,
                                              179,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: pagePad * 0.4),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: sectionSize * 0.7,
                                          color: const Color.fromARGB(
                                            255,
                                            182,
                                            179,
                                            179,
                                          ),
                                        ),
                                        SizedBox(width: pagePad * 0.4),
                                        Text(
                                          "Step 3: Wait for admin verify",
                                          style: TextStyle(
                                            fontSize: sectionSize * 0.65,
                                            color: const Color.fromARGB(
                                              255,
                                              182,
                                              179,
                                              179,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: pagePad),

                                  // Form fields
                                  _buildField(
                                    _nameController,
                                    "Full Name",
                                    "Enter your full name",
                                    pagePad,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _studentIdController,
                                    "Student ID",
                                    "Enter your student ID",
                                    pagePad,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _deptController,
                                    "Department",
                                    "e.g., CSE",
                                    pagePad,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _batchController,
                                    "Batch",
                                    "e.g., 56",
                                    pagePad,
                                    keyboard: TextInputType.number,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _emailController,
                                    "Email",
                                    "Enter your email address",
                                    pagePad,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _phoneController,
                                    "Phone Number",
                                    "e.g., 01XXXXXXXXX",
                                    pagePad,
                                    keyboard: TextInputType.phone,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _genderController,
                                    "Gender",
                                    "Select Gender",
                                    pagePad,
                                    readOnly: true,
                                    onTap: pickGender,
                                    suffixIcon: Icons.arrow_drop_down,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _bloodController,
                                    "Blood Group (Optional)",
                                    "Select Blood Group",
                                    pagePad,
                                    readOnly: true,
                                    onTap: pickBloodGroup,
                                    suffixIcon: Icons.arrow_drop_down,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _addressController,
                                    "Address",
                                    "Enter your present address",
                                    pagePad,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _passwordController,
                                    "Password",
                                    "Enter password",
                                    pagePad,
                                    obscure: true,
                                  ),
                                  SizedBox(height: pagePad * 1.4),
                                  _buildField(
                                    _confirmPassController,
                                    "Confirm Password",
                                    "Re-enter password",
                                    pagePad,
                                    obscure: true,
                                  ),
                                  SizedBox(height: pagePad * 2.4),

                                  // Submit button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        72,
                                        131,
                                        198,
                                      ),
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(
                                        double.infinity,
                                        (width * 0.13).clamp(46.0, 56.0),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: submitForm,
                                    child: Text(
                                      "Continue to Payment →",
                                      style: TextStyle(fontSize: sectionSize),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: pagePad * 2),
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
}
