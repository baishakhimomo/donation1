import 'dart:async';
import 'package:donation_app/mem_login.dart';
import 'package:donation_app/member_form.dart';
import 'package:flutter/material.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  //  SLIDER
  final PageController _pageController = PageController();
  Timer? _timer;
  int _pageIndex = 0;

  final List<String> slides = [
    'image/food1.jpeg',
    'image/food2.jpeg',
    'image/food3.jpeg',
    'image/food4.jpeg',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _pageIndex++;
        if (_pageIndex == slides.length) {
          _pageIndex = 0;
        }

        _pageController.animateToPage(
          _pageIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        setState(() {});
      }
    });
  }

  //CONTROLLERS
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  final _phoneCtrl = TextEditingController();
  final _pickupAddressCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();

    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();

    _phoneCtrl.dispose();
    _pickupAddressCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();

    super.dispose();
  }

  static const primaryBlue = Color.fromARGB(255, 30, 95, 168);
  static const deepBlue = Color.fromARGB(255, 14, 63, 122);

  //  MENU
  Widget buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Color.fromARGB(255, 30, 95, 168)),
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'Login':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
            break;

          case 'Logout':
            debugPrint("Logged out");
            break;

          case 'Blood Donation':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MemberForm()),
            );
            break;

          case 'Cloth Donation':
            // Already on this page
            break;
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'About Us', child: Text('About Us')),
          PopupMenuItem(value: 'Profile', child: Text('Profile')),

          PopupMenuItem(value: 'Login', child: Text('Login')),
          PopupMenuItem(value: 'Logout', child: Text('Logout')),
          PopupMenuDivider(),
          PopupMenuItem(value: 'Blood Donation', child: Text('Blood Donation')),
          PopupMenuItem(value: 'Cloth Donation', child: Text('Cloth Donation')),
          PopupMenuItem(value: 'Money Donation', child: Text('Money Donation')),
          PopupMenuItem(value: 'Food Donation', child: Text('Food Donation')),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // responsive
    final width = MediaQuery.sizeOf(context).width;

    final double pagePad = width * 0.04;
    final double titleSize = width * 0.09;
    final double sectionSize = width * 0.055;

    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND =====
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),

          Positioned.fill(child: Container(color: Colors.white.withAlpha(64))),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pagePad),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    children: [
                      //  TOP BAR
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(217), // 85% opacity
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            Image.asset('assets/logoremove.jpeg', height: 28),
                            const SizedBox(width: 10),
                            const Text(
                              "LUSSC",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const Spacer(),
                            buildMenu(context),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Food Donation",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          color: const Color.fromRGBO(14, 63, 122, 1),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= SLIDER =================
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(204), // 80% opacity
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: width < 380 ? 4 / 3 : 16 / 9,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: slides.length,
                                  onPageChanged: (i) =>
                                      setState(() => _pageIndex = i),
                                  itemBuilder: (_, i) =>
                                      Image.asset(slides[i], fit: BoxFit.cover),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(slides.length, (i) {
                                      final active = i == _pageIndex;
                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: active ? 16 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: active
                                              ? Colors.white
                                              : Colors.white.withAlpha(128),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DONATION GUIDELINES
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Accepted Food",
                          style: TextStyle(
                            fontSize: sectionSize,
                            fontWeight: FontWeight.w900,
                            color: deepBlue,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(204), // 80% opacity
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CheckLine(text: " All Homemade Food"),
                            SizedBox(height: 10),
                            _CheckLine(
                              text:
                                  "Grocery Items (Rice, pulses, flour, pasta, etc.)",
                            ),
                            SizedBox(height: 10),
                            _CheckLine(
                              text: "Not Accepted: Expired or Spoiled Food",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      //  PICKUP BOX (UPDATED: watermark logo inside)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(204), // 80% opacity
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Stack(
                            children: [
                              // ===== WATERMARK =====
                              Positioned.fill(
                                child: Center(
                                  child: IgnorePointer(
                                    child: Opacity(
                                      opacity: 0.18,
                                      child: Image.asset(
                                        'assets/logo.jpeg',
                                        width: 250,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ===== CONTENT =====
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 44,
                                          width: 44,
                                          decoration: BoxDecoration(
                                            color: primaryBlue.withAlpha(
                                              31,
                                            ), // 12% opacity
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.local_shipping_outlined,
                                            color: primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Request Pickup",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w900,
                                                  color: deepBlue,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                "We will pick up food from your location.",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Divider(color: Colors.black.withAlpha(20)),
                                    const SizedBox(height: 12),

                                    _softField(
                                      hint: "Full Name",
                                      icon: Icons.person_outline,
                                      controller: _nameCtrl,
                                    ),
                                    const SizedBox(height: 10),

                                    _softField(
                                      hint: "Phone Number",
                                      icon: Icons.phone_android_outlined,
                                      controller: _phoneCtrl,
                                      prefixText: "+1  |  ",
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 10),

                                    _softField(
                                      hint: "Pickup Address",
                                      icon: Icons.location_on_outlined,
                                      controller: _pickupAddressCtrl,
                                    ),
                                    const SizedBox(height: 10),

                                    _softDateField(
                                      hint: "Preferred Pickup Date",
                                      icon: Icons.calendar_month_outlined,
                                      controller: _dateCtrl,
                                    ),
                                    const SizedBox(height: 10),

                                    _softField(
                                      hint: "Notes (Optional)",
                                      icon: Icons.notes_outlined,
                                      controller: _notesCtrl,
                                    ),

                                    const SizedBox(height: 16),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              26,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          // TODO submit pickup request
                                        },
                                        child: const Text(
                                          "Request Pickup",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DROP OFF
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Drop-off Location",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: deepBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Come drop off foods at our location.",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black.withAlpha(15),
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color.fromARGB(
                                          255,
                                          45,
                                          190,
                                          127,
                                        ),
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "10 AM — 4 PM",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: primaryBlue,
                                        size: 22,
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Leading University Student Service Club (LUSSC)\nRAB-Ground Floor, Leading University, Sylhet",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // guidlines testfield
  Widget _inputField(String hint, IconData icon, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.white.withAlpha(179), // 70% opacity
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // softfield
  Widget _softField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue.withAlpha(191)),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black54,
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(140),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withAlpha(15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryBlue.withAlpha(90)),
        ),
      ),
    );
  }

  // date field
  Widget _softDateField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: now,
          lastDate: DateTime(now.year + 1),
        );

        if (picked != null) {
          controller.text =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryBlue.withAlpha(191)),
        filled: true,
        fillColor: Colors.white.withAlpha(140),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withAlpha(15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryBlue.withAlpha(90)),
        ),
      ),
    );
  }
}

// CHECK LINE
class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF2DBE7F), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
