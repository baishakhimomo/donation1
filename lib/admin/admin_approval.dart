import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Make sure you already initialized Supabase in main.dart
final supabase = Supabase.instance.client;

class AdminApprovalPage extends StatefulWidget {
  const AdminApprovalPage({super.key});

  @override
  State<AdminApprovalPage> createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  List<Map<String, dynamic>> pendingRequests = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  // Fetch all pending requests (member + their payment trx id)
  Future<void> fetchPendingRequests() async {
    setState(() => loading = true);

    try {
      // 1) Get all unverified payments
      final paymentsRes = await supabase
          .from('member_payments')
          .select()
          .eq('is_verified', false);

      final payments = List<Map<String, dynamic>>.from(paymentsRes as List);

      if (payments.isEmpty) {
        setState(() {
          pendingRequests = [];
          loading = false;
        });
        return;
      }

      // 2) Fetch member info for those payments
      final studentIds = payments
          .map((p) => (p['student_id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final membersRes = await supabase
          .from('members')
          .select()
          .inFilter('student_id', studentIds);

      final members = List<Map<String, dynamic>>.from(membersRes as List);
      final memberByStudentId = <String, Map<String, dynamic>>{};
      for (final m in members) {
        final sid = (m['student_id'] ?? '').toString();
        if (sid.isNotEmpty) memberByStudentId[sid] = m;
      }

      // 3) Combine into a single list for UI
      final combined = <Map<String, dynamic>>[];
      for (final payment in payments) {
        final sid = (payment['student_id'] ?? '').toString();
        final member = memberByStudentId[sid];

        // If the member is already approved, don't show it here.
        if (member != null && member['is_approved'] == true) {
          continue;
        }

        combined.add({'member': member, 'payment': payment});
      }

      setState(() {
        pendingRequests = combined;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error fetching members')));
    } finally {
      setState(() => loading = false);
    }
  }

  // Approve member
  Future<void> approveRequest(Map<String, dynamic> request) async {
    final member = (request['member'] as Map<String, dynamic>?) ?? {};
    final payment = (request['payment'] as Map<String, dynamic>?) ?? {};
    final studentId = (member['student_id'] ?? payment['student_id'] ?? '')
        .toString();
    final trxId = (payment['trx_id'] ?? '').toString();

    if (studentId.isEmpty) return;

    // Update member as approved AND verify their payment
    await supabase
        .from('members')
        .update({'is_approved': true, 'rejection_reason': null})
        .eq('student_id', studentId);

    if (trxId.isNotEmpty) {
      await supabase
          .from('member_payments')
          .update({'is_verified': true})
          .eq('trx_id', trxId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${member['name'] ?? studentId} approved")),
    );

    fetchPendingRequests(); // Refresh list
  }

  // Reject member with reason
  Future<void> rejectRequest(Map<String, dynamic> request) async {
    final member = (request['member'] as Map<String, dynamic>?) ?? {};
    final payment = (request['payment'] as Map<String, dynamic>?) ?? {};
    final studentId = (member['student_id'] ?? payment['student_id'] ?? '')
        .toString();
    final trxId = (payment['trx_id'] ?? '').toString();

    if (studentId.isEmpty) return;

    String reason = '';
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Reason for Rejection"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Payment not received / Student not verified",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                reason = controller.text.trim();
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );

    if (reason.isEmpty) return;

    // Update member as rejected and save reason
    await supabase
        .from('members')
        .update({'is_approved': false, 'rejection_reason': reason})
        .eq('student_id', studentId);

    // Mark payment as verified so it disappears from the pending list
    // (Payment is now "processed" even though the member is rejected)
    if (trxId.isNotEmpty) {
      await supabase
          .from('member_payments')
          .update({'is_verified': true})
          .eq('trx_id', trxId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${member['name'] ?? studentId} rejected")),
    );

    fetchPendingRequests(); // Refresh list
  }

  Future<void> deleteRequest(Map<String, dynamic> request) async {
    final member = (request['member'] as Map<String, dynamic>?) ?? {};
    final payment = (request['payment'] as Map<String, dynamic>?) ?? {};
    final studentId = (member['student_id'] ?? payment['student_id'] ?? '')
        .toString();
    final trxId = (payment['trx_id'] ?? '').toString();
    final name = (member['name'] ?? studentId).toString();

    if (studentId.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Request?'),
          content: Text('Do you want to delete $name?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    // Delete payment row (if exists)
    if (trxId.isNotEmpty) {
      await supabase.from('member_payments').delete().eq('trx_id', trxId);
    } else {
      await supabase
          .from('member_payments')
          .delete()
          .eq('student_id', studentId);
    }

    // Delete member row
    await supabase.from('members').delete().eq('student_id', studentId);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$name deleted")));

    fetchPendingRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Approval"),
        backgroundColor: const Color(0xFF1E6FA8),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
          ? const Center(child: Text("No pending members"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pendingRequests.length,
              itemBuilder: (context, index) {
                final request = pendingRequests[index];
                final member =
                    (request['member'] as Map<String, dynamic>?) ?? {};
                final payment =
                    (request['payment'] as Map<String, dynamic>?) ?? {};
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (member['name'] ?? 'Unknown').toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => deleteRequest(request),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                        Text(
                          "Student ID: ${(member['student_id'] ?? payment['student_id'] ?? 'N/A').toString()}",
                        ),
                        Text(
                          "Department: ${(member['department'] ?? 'N/A').toString()}",
                        ),
                        Text("Batch: ${(member['batch'] ?? 'N/A').toString()}"),
                        Text(
                          "Transaction ID: ${(payment['trx_id'] ?? 'N/A').toString()}",
                        ),
                        Text(
                          "Email: ${(member['contact_email'] ?? 'N/A').toString()}",
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => approveRequest(request),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Approve"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => rejectRequest(request),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Reject"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
