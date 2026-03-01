import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

class SponsorPage extends StatefulWidget {
  const SponsorPage({super.key});

  @override
  State<SponsorPage> createState() => _SponsorPageState();
}

class _SponsorPageState extends State<SponsorPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Email are required")),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final session = _supa.auth.currentSession;
      await _supa.from('sponsor_requests').insert({
        'user_id': session?.user.id,
        'name': name,
        'email': email,
        'phone': _phoneCtrl.text.trim(),
        'company_name': _companyCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sponsorship request submitted!")),
      );

      _nameCtrl.clear();
      _emailCtrl.clear();
      _phoneCtrl.clear();
      _companyCtrl.clear();
      _messageCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/backg.png", fit: BoxFit.cover),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
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
                          'Sponsor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// BODY
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        "Become a Sponsor",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 24, 75, 106),
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// EVENT SPONSOR CARD
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.handshake_outlined,
                              size: 50,
                              color: Color.fromARGB(255, 24, 75, 106),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Event Sponsor",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 24, 75, 106),
                              ),
                            ),
                            const Text("Support a specific event"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// WHY SPONSOR CARD
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "LUSSC is a 100% non-profit student organization",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "All funds are used for Social Welfare",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Sponsor names or logos will be\ndisplayed on event materials\nand digital platforms",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// OUR PREVIOUS SPONSORS
                      const Text(
                        "Our Previous Sponsors",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color.fromARGB(255, 24, 75, 106),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          _sponsorChip(
                            "Shapnik Consultancy",
                            Icons.business,
                            Colors.indigo,
                          ),
                          _sponsorChip(
                            "ARZ International",
                            Icons.public,
                            Colors.teal,
                          ),
                          _sponsorChip(
                            "Gaming Station",
                            Icons.sports_esports,
                            Colors.deepOrange,
                          ),
                          _sponsorChip(
                            "Insaaf Clothing",
                            Icons.checkroom,
                            Colors.purple,
                          ),
                          _sponsorChip(
                            "Crystal Rose Hotel",
                            Icons.room_service,
                            Colors.brown,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "...and many more",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// FORM FIELDS
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          children: [
                            // Watermark in center
                            Positioned.fill(
                              child: Center(
                                child: Icon(
                                  Icons.volunteer_activism,
                                  size: 120,
                                  color: Colors.blueGrey.withAlpha(30),
                                ),
                              ),
                            ),
                            // Form fields on top
                            Column(
                              children: [
                                _field(
                                  "Name / Organization",
                                  Icons.person_outline,
                                  _nameCtrl,
                                ),
                                const SizedBox(height: 10),
                                _field(
                                  "Email",
                                  Icons.email_outlined,
                                  _emailCtrl,
                                  keyboard: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 10),
                                _field(
                                  "Phone (Optional)",
                                  Icons.phone_outlined,
                                  _phoneCtrl,
                                  keyboard: TextInputType.phone,
                                ),
                                const SizedBox(height: 10),
                                _field(
                                  "Company Name (Optional)",
                                  Icons.business_outlined,
                                  _companyCtrl,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _messageCtrl,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: "Message (Optional)",
                                    prefixIcon: const Icon(
                                      Icons.message_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// SUBMIT
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 24, 75, 106),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _submitting
                                ? "Submitting..."
                                : "Submit Sponsorship",
                            style: const TextStyle(fontSize: 16),
                          ),
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
    );
  }

  Widget _field(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _sponsorChip(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(120), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
