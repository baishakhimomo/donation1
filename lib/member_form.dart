import 'package:donation_app/membership_fee_payment_page.dart';
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
        contactEmail: _emailController.text.trim(), // THIS replaces email usage
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

  //Gender Select Method
  Future<void> pickGender() async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Column(
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
        );
      },
    );

    if (selected != null) {
      setState(() {
        _genderController.text = selected;
      });
    }
  }

  //Blood group select method
  Future<void> pickBloodGroup() async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("A+"),
              onTap: () => Navigator.pop(context, "A+"),
            ),
            ListTile(
              title: Text("A-"),
              onTap: () => Navigator.pop(context, "A-"),
            ),
            ListTile(
              title: Text("B+"),
              onTap: () => Navigator.pop(context, "B+"),
            ),
            ListTile(
              title: Text("B-"),
              onTap: () => Navigator.pop(context, "B-"),
            ),
            ListTile(
              title: Text("O+"),
              onTap: () => Navigator.pop(context, "O+"),
            ),
            ListTile(
              title: Text("O-"),
              onTap: () => Navigator.pop(context, "O-"),
            ),
            ListTile(
              title: Text("AB+"),
              onTap: () => Navigator.pop(context, "AB+"),
            ),
            ListTile(
              title: Text("AB-"),
              onTap: () => Navigator.pop(context, "AB-"),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            SizedBox(width: 15),
            Image.asset('assets/logo.jpeg', width: 30, height: 30),
            SizedBox(width: 8),
            Text(
              "LUSSC",
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
          Positioned.fill(
            child: Image.asset("assets/backg.png", fit: BoxFit.cover),
          ),
          Positioned(
            top: 15,
            left: 22,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Join the LUSSC Family!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 78, 91, 106),
                  ),
                ),
                SizedBox(height: 8),

                Text(
                  "Fill out the form below to become a member of the Leading Umiversity Social Service Club and make a positive impact.",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 78, 91, 106),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(25, height * 0.15, 25, 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(220),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset("assets/logo.jpeg", width: 400),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Membership Registration Form",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 72, 131, 198),
                        ),
                      ),
                      SizedBox(height: 6),

                      Row(
                        children: [
                          Text(
                            "Step 1: Fill the form",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 72, 131, 198),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: const Color.fromARGB(255, 182, 179, 179),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Step 2: Pay fee",
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color.fromARGB(255, 182, 179, 179),
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: const Color.fromARGB(255, 182, 179, 179),
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Step 3: Wait for admin verify",
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color.fromARGB(255, 182, 179, 179),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 10),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "Enter your full name",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _studentIdController,
                                decoration: InputDecoration(
                                  labelText: "Student ID",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "Enter your student ID",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _deptController,
                                decoration: InputDecoration(
                                  labelText: "Department",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "e.g., CSE",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _batchController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Batch",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "e.g., 56",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "Enter your email address",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: "Phone Number",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "e.g., 01XXXXXXXXX",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              TextField(
                                controller: _genderController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Gender",
                                  hintText: "Select Gender",
                                  suffixIcon: Icon(Icons.arrow_drop_down),

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 182, 179, 179),
                                      width: 0.9,
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onTap: pickGender,
                              ),
                              SizedBox(height: 20),

                              TextField(
                                controller: _bloodController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Blood Group (Optional)",
                                  hintText: "Select Blood Group",
                                  suffixIcon: const Icon(Icons.arrow_drop_down),

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

                                onTap: pickBloodGroup,
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: "Address",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "Enter your present address",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "Enter password",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _confirmPassController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: "Confirm Password",
                                  labelStyle: TextStyle(
                                    color: Color.fromARGB(255, 78, 91, 106),
                                  ),
                                  hintText: "Re-enter password",
                                  hintStyle: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                        255,
                                        182,
                                        179,
                                        179,
                                      ),
                                      width: 0.9,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 91, 106),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 35),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    72,
                                    131,
                                    198,
                                  ),
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(400, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: submitForm,
                                child: Text(
                                  "Continue to Payment →",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
