import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MoneyDonationPage extends StatefulWidget {
  const MoneyDonationPage({super.key});

  @override
  State<MoneyDonationPage> createState() => _MoneyDonationPageState();
}

class _MoneyDonationPageState extends State<MoneyDonationPage> {
  final _trxIdController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _amountController = TextEditingController();

  //Replace with your real admin number
  static const String adminPhoneNumber = "017XXXXXXXX";

  Future<void> pickPaymentMethod() async {
    final String? selected = await showModalBottomSheet<String>(
      context: context,
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
      setState(() => _paymentMethodController.text = selected);
    }
  }

  Future<void> _callAdmin() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: adminPhoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot launch phone dialer')),
      );
    }
  }

  void _submitDonation() {
    final amount = _amountController.text.trim();
    final method = _paymentMethodController.text.trim();
    final trx = _trxIdController.text.trim();

    if (amount.isEmpty || method.isEmpty || trx.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    // UI-only for now. Later you will insert into Supabase.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Donation submitted! Awaiting confirmation."),
      ),
    );
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
    final height = MediaQuery.of(context).size.height;

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

          // PAGE TITLE
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Money Donation",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 78, 91, 106),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Pay via bKash/Nagad and submit TrxID",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 130, 130, 130),
                  ),
                ),
              ],
            ),
          ),

          // MAIN CARD
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(25, height * 0.15, 25, 25),
              padding: const EdgeInsets.all(16),
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
                  Center(
                    child: Opacity(
                      opacity: 0.07,
                      child: Image.asset("assets/logo.jpeg", width: 420),
                    ),
                  ),

                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Donate Money",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 20, 110, 200),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Amount
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Amount (BDT)",
                            hintText: "Enter amount you want to donate",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Payment method
                        TextField(
                          controller: _paymentMethodController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Payment Method",
                            hintText: "Select (Bkash/Nagad)",
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: pickPaymentMethod,
                        ),

                        const SizedBox(height: 16),

                        // Send number display
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color.fromARGB(255, 220, 230, 240),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Send payment to this number:",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 6),
                              Text(
                                adminPhoneNumber,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 90, 70),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

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

                        const SizedBox(height: 18),

                        // Submit donation
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              90,
                              70,
                            ),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submitDonation,
                          child: const Text(
                            "Submit Donation",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Info box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color.fromARGB(255, 220, 230, 240),
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Confirmation",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "• Confirmation will be given within 24 hours.",
                              ),
                              Text(
                                "• If you don’t get confirmation within 1 day, contact the club.",
                              ),
                              Text("• Contact time: 7 PM - 10 PM"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Contact admin full button with call icon
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              30,
                              120,
                              210,
                            ),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _callAdmin,
                          icon: const Icon(Icons.call),
                          label: const Text(
                            "Contact Admin (7 PM - 10 PM)",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
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
