import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_app/validators.dart';

final _supa = Supabase.instance.client;

class RegistrationFeePage extends StatefulWidget {
  const RegistrationFeePage({super.key});

  @override
  State<RegistrationFeePage> createState() => _RegistrationFeePageState();
}

class _RegistrationFeePageState extends State<RegistrationFeePage> {
  final _trxIdController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _amountController = TextEditingController();

  // Numbers fetched from Supabase
  String _bkashNumber = '';
  String _nagadNumber = '';
  String _adminCallNumber = '';

  // The number shown to user (changes when they pick bKash / Nagad)
  String _displayNumber = '';

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  Future<void> _loadNumbers() async {
    try {
      final rows = await _supa
          .from('payment_contacts')
          .select()
          .eq('context', 'money_donation');
      final list = List<Map<String, dynamic>>.from(rows as List);
      for (final r in list) {
        final type = r['payment_type'] ?? '';
        final num = (r['phone_number'] ?? '').toString();
        if (type == 'bkash') _bkashNumber = num;
        if (type == 'nagad') _nagadNumber = num;
        if (type == 'admin_call') _adminCallNumber = num;
      }
      setState(() {});
    } catch (e) {
      debugPrint('load money numbers error: $e');
    }
  }

  Future<void> pickPaymentMethod() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("bKash"),
                onTap: () => Navigator.pop(context, "bKash"),
              ),
              ListTile(
                title: const Text("Nagad"),
                onTap: () => Navigator.pop(context, "Nagad"),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _paymentMethodController.text = selected;
        if (selected == 'bKash') {
          _displayNumber = _bkashNumber;
        } else if (selected == 'Nagad') {
          _displayNumber = _nagadNumber;
        }
      });
    }
  }

  Future<void> _callAdmin() async {
    if (_adminCallNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin call number not set yet')),
      );
      return;
    }
    final Uri phoneUri = Uri(scheme: 'tel', path: _adminCallNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch phone dialer')),
      );
    }
  }

  void _submitDonation() async {
    final amount = _amountController.text.trim();
    final method = _paymentMethodController.text.trim();
    final trx = _trxIdController.text.trim();

    if (amount.isEmpty || method.isEmpty || trx.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    // Regex validation
    final errors = <String>[
      validateAmount(amount) ?? '',
      validateRequired(method, 'Payment Method') ?? '',
      validateTrxId(trx) ?? '',
    ];
    errors.removeWhere((e) => e.isEmpty);

    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errors.first)));
      return;
    }

    final session = _supa.auth.currentSession;
    if (session == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please login first.")));
      return;
    }

    try {
      await _supa.from('money_donations').insert({
        'user_id': session.user.id,
        'amount': amount,
        'payment_method': method,
        'trx_id': trx,
        'purpose': 'registration_fee',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration fee submitted! Awaiting confirmation."),
        ),
      );

      _amountController.clear();
      _paymentMethodController.clear();
      _trxIdController.clear();
      setState(() => _displayNumber = '');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    _trxIdController.dispose();
    _paymentMethodController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final double pagePad = width * 0.04;

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
                // HEADER — same as login page
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
                          "Registration Fee",
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

                        // MAIN CARD
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
                              // watermark logo
                              Positioned.fill(
                                child: Center(
                                  child: Opacity(
                                    opacity: 0.07,
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
                                    "Pay via bKash/Nagad and submit TrxID",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: const Color.fromARGB(
                                        255,
                                        24,
                                        75,
                                        106,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad * 0.6),
                                  // Amount
                                  TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Amount (BDT)",
                                      hintText:
                                          "Enter amount you want to donate",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad),

                                  // Payment method
                                  TextField(
                                    controller: _paymentMethodController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "Payment Method",
                                      hintText: "Select (Bkash/Nagad)",
                                      suffixIcon: const Icon(
                                        Icons.arrow_drop_down,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onTap: pickPaymentMethod,
                                  ),
                                  SizedBox(height: pagePad),

                                  // Send number display
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(pagePad * 0.8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          220,
                                          230,
                                          240,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Send payment to this number:",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _displayNumber.isEmpty
                                              ? "Select payment method"
                                              : _displayNumber,
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: _displayNumber.isEmpty
                                                ? Colors.grey
                                                : const Color.fromARGB(
                                                    255,
                                                    255,
                                                    90,
                                                    70,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: pagePad),

                                  // TrxID
                                  TextField(
                                    controller: _trxIdController,
                                    decoration: InputDecoration(
                                      labelText: "Transaction ID (TrxID)",
                                      hintText: "Enter TrxID from SMS",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad * 1.2),

                                  // Submit donation
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          255,
                                          90,
                                          70,
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
                                      onPressed: _submitDonation,
                                      child: const Text(
                                        "Submit Donation",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad),

                                  // Info box
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(pagePad * 0.8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          220,
                                          230,
                                          240,
                                        ),
                                      ),
                                    ),
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Confirmation",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            color: Color.fromARGB(
                                              255,
                                              24,
                                              75,
                                              106,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "• Confirmation will be given within 24 hours.",
                                        ),
                                        Text(
                                          "• If you don't get confirmation within 1 day, contact the club.",
                                        ),
                                        Text("• Contact time: 7 PM - 10 PM"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: pagePad),

                                  // Contact button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          30,
                                          120,
                                          210,
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
                                      onPressed: _callAdmin,
                                      icon: const Icon(Icons.call),
                                      label: const Text(
                                        "Contact Admin (7 PM - 10 PM)",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: pagePad * 0.5),
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
