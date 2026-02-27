import 'package:donation_app/home_page.dart';
import 'package:donation_app/mem_login.dart';
import 'package:flutter/material.dart';
import 'package:donation_app/authentication/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

class MembershipFeePaymentPage extends StatefulWidget {
  final String studentId;
  const MembershipFeePaymentPage({super.key, required this.studentId});

  @override
  State<MembershipFeePaymentPage> createState() =>
      _MembershipFeePaymentPageState();
}

class _MembershipFeePaymentPageState extends State<MembershipFeePaymentPage> {
  final _trxIdController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  // Numbers fetched from Supabase
  String _bkashNumber = '';
  String _nagadNumber = '';
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
          .eq('context', 'membership');
      final list = List<Map<String, dynamic>>.from(rows as List);
      for (final r in list) {
        final type = r['payment_type'] ?? '';
        final num = (r['phone_number'] ?? '').toString();
        if (type == 'bkash') _bkashNumber = num;
        if (type == 'nagad') _nagadNumber = num;
      }
      setState(() {});
    } catch (e) {
      debugPrint('load membership numbers error: $e');
    }
  }

  void submitPayment() async {
    if (_paymentMethodController.text.isEmpty ||
        _trxIdController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      await Auth().submitMemberPayment(
        studentId: widget.studentId,
        paymentMethod: _paymentMethodController.text.trim(),
        trxId: _trxIdController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment submitted. Wait for admin approval."),
        ),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> pickPaymentMethod() async {
    String? selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("bKash"),
              onTap: () => Navigator.pop(context, "bKash"),
            ),
            ListTile(
              title: Text("Nagad"),
              onTap: () => Navigator.pop(context, "Nagad"),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Membership Fee Payment",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 78, 91, 106),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Pay via bKash or Nagad and submit TrxID",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 130, 130, 130),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(25, height * 0.15, 25, 100),
              padding: EdgeInsets.all(16),
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
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pay Membership Fee",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 90, 70),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text("Amount", style: TextStyle(fontSize: 13)),
                        SizedBox(height: 2),
                        Text(
                          "100 BDT",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 20, 110, 200),
                          ),
                        ),
                        SizedBox(height: 18),
                        TextField(
                          controller: _paymentMethodController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Payment Method",
                            hintText: "Select (bKash/Nagad)",
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onTap: pickPaymentMethod,
                        ),
                        SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color.fromARGB(255, 220, 230, 240),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Send payment to this number:",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 6),
                              Text(
                                _displayNumber.isEmpty
                                    ? "Select payment method"
                                    : _displayNumber,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: _displayNumber.isEmpty
                                      ? Colors.grey
                                      : Color.fromARGB(255, 255, 90, 70),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
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

                        SizedBox(height: 22),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 90, 70),
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: submitPayment,
                          child: Text(
                            "Submit Payment",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color.fromARGB(255, 220, 230, 240),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Activation",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "• Payment submitted → Admin verifies TrxID",
                              ),
                              Text(
                                "• After verification → Your membership will be approved",
                              ),

                              Text("• Then you can Login as Member"),
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
          Positioned(
            left: 25,
            right: 25,
            bottom: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 30, 120, 210),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
              child: Text("Go to Home →", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
