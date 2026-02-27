import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supa = Supabase.instance.client;

// ── Helper: send a notification to a user ──
Future<void> _sendNotification({
  required String userId,
  required String title,
  required String body,
  required String type,
}) async {
  try {
    await _supa.from('user_notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
    });
  } catch (e) {
    debugPrint('send notification error: $e');
  }
}

// ─────────────────────────────────────────────────────────
//  ADMIN SETTINGS PAGE  (Numbers · Pickups · Money · Sponsors)
// ─────────────────────────────────────────────────────────
class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 30, 111, 168),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.phone_android), text: "Numbers"),
            Tab(icon: Icon(Icons.local_shipping), text: "Pickups"),
            Tab(icon: Icon(Icons.attach_money), text: "Money"),
            Tab(icon: Icon(Icons.handshake), text: "Sponsors"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _PaymentNumbersTab(),
          _PickupRequestsTab(),
          _MoneyDonationsTab(),
          _SponsorRequestsTab(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 1 — PAYMENT NUMBERS
// ═══════════════════════════════════════════════════════════
class _PaymentNumbersTab extends StatefulWidget {
  const _PaymentNumbersTab();

  @override
  State<_PaymentNumbersTab> createState() => _PaymentNumbersTabState();
}

class _PaymentNumbersTabState extends State<_PaymentNumbersTab> {
  bool _loading = true;

  // money donation numbers
  final _mdBkash = TextEditingController();
  final _mdNagad = TextEditingController();
  final _mdCall = TextEditingController();

  // membership numbers
  final _memBkash = TextEditingController();
  final _memNagad = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNumbers();
  }

  @override
  void dispose() {
    _mdBkash.dispose();
    _mdNagad.dispose();
    _mdCall.dispose();
    _memBkash.dispose();
    _memNagad.dispose();
    super.dispose();
  }

  Future<void> _loadNumbers() async {
    setState(() => _loading = true);
    try {
      final rows = await _supa.from('payment_contacts').select();
      final list = List<Map<String, dynamic>>.from(rows as List);

      for (final r in list) {
        final ctx = r['context'] ?? '';
        final type = r['payment_type'] ?? '';
        final num = (r['phone_number'] ?? '').toString();

        if (ctx == 'money_donation') {
          if (type == 'bkash') _mdBkash.text = num;
          if (type == 'nagad') _mdNagad.text = num;
          if (type == 'admin_call') _mdCall.text = num;
        } else if (ctx == 'membership') {
          if (type == 'bkash') _memBkash.text = num;
          if (type == 'nagad') _memNagad.text = num;
        }
      }
    } catch (e) {
      debugPrint('load numbers error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    try {
      final updates = [
        {
          'context': 'money_donation',
          'payment_type': 'bkash',
          'phone_number': _mdBkash.text.trim(),
        },
        {
          'context': 'money_donation',
          'payment_type': 'nagad',
          'phone_number': _mdNagad.text.trim(),
        },
        {
          'context': 'money_donation',
          'payment_type': 'admin_call',
          'phone_number': _mdCall.text.trim(),
        },
        {
          'context': 'membership',
          'payment_type': 'bkash',
          'phone_number': _memBkash.text.trim(),
        },
        {
          'context': 'membership',
          'payment_type': 'nagad',
          'phone_number': _memNagad.text.trim(),
        },
      ];

      for (final u in updates) {
        await _supa
            .from('payment_contacts')
            .update({
              'phone_number': u['phone_number'],
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('context', u['context']!)
            .eq('payment_type', u['payment_type']!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Numbers saved!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Money Donation Section ──
          const Text(
            "Money Donation Numbers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _numField("bKash Number", Icons.phone_android, _mdBkash),
          const SizedBox(height: 10),
          _numField("Nagad Number", Icons.phone_android, _mdNagad),
          const SizedBox(height: 10),
          _numField("Admin Call Number", Icons.call, _mdCall),

          const Divider(height: 36),

          // ── Membership Section ──
          const Text(
            "Membership Payment Numbers",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _numField("bKash Number", Icons.phone_android, _memBkash),
          const SizedBox(height: 10),
          _numField("Nagad Number", Icons.phone_android, _memNagad),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 111, 168),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text(
                "Save All Numbers",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(String label, IconData icon, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 2 — PICKUP REQUESTS
// ═══════════════════════════════════════════════════════════
class _PickupRequestsTab extends StatefulWidget {
  const _PickupRequestsTab();

  @override
  State<_PickupRequestsTab> createState() => _PickupRequestsTabState();
}

class _PickupRequestsTabState extends State<_PickupRequestsTab> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String _filter = 'pending'; // pending | approved | rejected

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _supa
          .from('pickup_requests')
          .select()
          .eq('status', _filter)
          .order('created_at', ascending: false);
      _requests = List<Map<String, dynamic>>.from(rows as List);
    } catch (e) {
      debugPrint('pickup load error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _updateStatus(String id, String status, {String? reason}) async {
    try {
      // Find the request to get user_id and type
      final req = _requests.firstWhere(
        (r) => r['id'].toString() == id,
        orElse: () => {},
      );
      final userId = (req['user_id'] ?? '').toString();
      final donationType = (req['donation_type'] ?? '').toString();

      final data = <String, dynamic>{
        'status': status,
        'approved_by': _supa.auth.currentUser?.id,
      };
      if (status == 'approved') {
        data['approved_at'] = DateTime.now().toIso8601String();
      }
      if (reason != null) data['rejection_reason'] = reason;

      await _supa.from('pickup_requests').update(data).eq('id', id);

      // Send notification to the user
      if (userId.isNotEmpty) {
        final typeLabel = donationType == 'food' ? 'Food' : 'Cloth';
        if (status == 'approved') {
          await _sendNotification(
            userId: userId,
            title: '$typeLabel Pickup Approved',
            body: 'Your $typeLabel pickup request has been approved!',
            type: 'pickup_approved',
          );
        } else if (status == 'rejected') {
          await _sendNotification(
            userId: userId,
            title: '$typeLabel Pickup Rejected',
            body: reason != null && reason.isNotEmpty
                ? 'Your $typeLabel pickup was rejected. Reason: $reason'
                : 'Your $typeLabel pickup request was rejected.',
            type: 'pickup_rejected',
          );
        }
      }

      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _reject(String id) async {
    String reason = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text("Rejection Reason"),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: "Enter reason (optional)",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                reason = ctrl.text.trim();
                Navigator.pop(ctx);
              },
              child: const Text("Reject"),
            ),
          ],
        );
      },
    );
    // If dialog was cancelled with no action, still reject if user tapped Reject
    _updateStatus(id, 'rejected', reason: reason.isEmpty ? null : reason);
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Request?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _supa.from('pickup_requests').delete().eq('id', id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Filter chips ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _chip("Pending", 'pending'),
              const SizedBox(width: 8),
              _chip("Approved", 'approved'),
              const SizedBox(width: 8),
              _chip("Rejected", 'rejected'),
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? Center(
                  child: Text(
                    "No $_filter requests",
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (_, i) => _pickupCard(_requests[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color.fromARGB(255, 30, 111, 168),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      onSelected: (_) {
        _filter = value;
        _load();
      },
    );
  }

  Widget _pickupCard(Map<String, dynamic> r) {
    final type = (r['donation_type'] ?? '').toString();
    final name = (r['full_name'] ?? '').toString();
    final phone = (r['phone'] ?? '').toString();
    final addr = (r['pickup_address'] ?? '').toString();
    final date = (r['preferred_pickup_date'] ?? '').toString();
    final notes = (r['notes'] ?? '').toString();
    final status = (r['status'] ?? 'pending').toString();
    final id = r['id'].toString();

    Color badge = Colors.orange;
    if (status == 'approved') badge = Colors.green;
    if (status == 'rejected') badge = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  type == 'food' ? Icons.fastfood : Icons.checkroom,
                  color: const Color.fromARGB(255, 30, 111, 168),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badge.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("Type: ${type == 'food' ? 'Food' : 'Cloth'}"),
            Text("Phone: $phone"),
            Text("Address: $addr"),
            if (date.isNotEmpty) Text("Pickup Date: $date"),
            if (notes.isNotEmpty) Text("Notes: $notes"),

            if (status == 'pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _updateStatus(id, 'approved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _reject(id),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _delete(id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],

            if (status != 'pending') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _delete(id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 3 — MONEY DONATIONS
// ═══════════════════════════════════════════════════════════
class _MoneyDonationsTab extends StatefulWidget {
  const _MoneyDonationsTab();

  @override
  State<_MoneyDonationsTab> createState() => _MoneyDonationsTabState();
}

class _MoneyDonationsTabState extends State<_MoneyDonationsTab> {
  List<Map<String, dynamic>> _donations = [];
  bool _loading = true;
  String _filter = 'pending'; // pending | received | not_received

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _supa
          .from('money_donations')
          .select()
          .eq('status', _filter)
          .order('created_at', ascending: false);
      _donations = List<Map<String, dynamic>>.from(rows as List);
    } catch (e) {
      debugPrint('money donations load error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _markStatus(String id, String status) async {
    try {
      // Find the donation to get user_id
      final don = _donations.firstWhere(
        (d) => d['id'].toString() == id,
        orElse: () => {},
      );
      final userId = (don['user_id'] ?? '').toString();
      final trxId = (don['trx_id'] ?? '').toString();
      final amount = (don['amount'] ?? '').toString();

      await _supa
          .from('money_donations')
          .update({
            'status': status,
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': _supa.auth.currentUser?.id,
          })
          .eq('id', id);

      // Send notification to user
      if (userId.isNotEmpty) {
        if (status == 'received') {
          await _sendNotification(
            userId: userId,
            title: 'Payment Received',
            body:
                'Your donation of $amount BDT (TrxID: $trxId) has been received. Thank you!',
            type: 'payment_received',
          );
        } else if (status == 'not_received') {
          await _sendNotification(
            userId: userId,
            title: 'Payment Not Received',
            body:
                'We could not verify your donation of $amount BDT (TrxID: $trxId). Please contact admin.',
            type: 'payment_failed',
          );
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Marked as $status")));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Donation?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _supa.from('money_donations').delete().eq('id', id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Filter chips ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _chip("Pending", 'pending'),
              const SizedBox(width: 8),
              _chip("Received", 'received'),
              const SizedBox(width: 8),
              _chip("Not Received", 'not_received'),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _donations.isEmpty
              ? Center(
                  child: Text(
                    "No $_filter donations",
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _donations.length,
                  itemBuilder: (_, i) => _donationCard(_donations[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color.fromARGB(255, 30, 111, 168),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      onSelected: (_) {
        _filter = value;
        _load();
      },
    );
  }

  Widget _donationCard(Map<String, dynamic> d) {
    final amount = (d['amount'] ?? '').toString();
    final method = (d['payment_method'] ?? '').toString();
    final trxId = (d['trx_id'] ?? '').toString();
    final status = (d['status'] ?? 'pending').toString();
    final id = d['id'].toString();
    final createdAt = (d['created_at'] ?? '').toString();

    // Date
    String dateStr = '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      dateStr =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    Color badge = Colors.orange;
    if (status == 'received') badge = Colors.green;
    if (status == 'not_received') badge = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  color: Color.fromARGB(255, 30, 111, 168),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "$amount BDT",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badge.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("Method: $method"),
            Text("TrxID: $trxId"),
            if (dateStr.isNotEmpty) Text("Date: $dateStr"),

            if (status == 'pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _markStatus(id, 'received'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Received"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _markStatus(id, 'not_received'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Not Received"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _delete(id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],

            if (status != 'pending') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _delete(id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 4 — SPONSOR REQUESTS
// ═══════════════════════════════════════════════════════════
class _SponsorRequestsTab extends StatefulWidget {
  const _SponsorRequestsTab();

  @override
  State<_SponsorRequestsTab> createState() => _SponsorRequestsTabState();
}

class _SponsorRequestsTabState extends State<_SponsorRequestsTab> {
  List<Map<String, dynamic>> _requests = [];
  bool _loading = true;
  String _filter = 'pending';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await _supa
          .from('sponsor_requests')
          .select()
          .eq('status', _filter)
          .order('created_at', ascending: false);
      _requests = List<Map<String, dynamic>>.from(rows as List);
    } catch (e) {
      debugPrint('sponsor load error: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await _supa
          .from('sponsor_requests')
          .update({
            'status': status,
            'reviewed_at': DateTime.now().toIso8601String(),
            'reviewed_by': _supa.auth.currentUser?.id,
          })
          .eq('id', id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Sponsor Request?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await _supa.from('sponsor_requests').delete().eq('id', id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _chip("Pending", 'pending'),
              const SizedBox(width: 8),
              _chip("Approved", 'approved'),
              const SizedBox(width: 8),
              _chip("Rejected", 'rejected'),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? Center(
                  child: Text(
                    "No $_filter sponsor requests",
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (_, i) => _sponsorCard(_requests[i]),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color.fromARGB(255, 30, 111, 168),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      onSelected: (_) {
        _filter = value;
        _load();
      },
    );
  }

  Widget _sponsorCard(Map<String, dynamic> r) {
    final name = (r['name'] ?? '').toString();
    final email = (r['email'] ?? '').toString();
    final phone = (r['phone'] ?? '').toString();
    final company = (r['company_name'] ?? '').toString();
    final message = (r['message'] ?? '').toString();
    final status = (r['status'] ?? 'pending').toString();
    final id = r['id'].toString();

    Color badge = Colors.orange;
    if (status == 'approved') badge = Colors.green;
    if (status == 'rejected') badge = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.handshake,
                  color: Color.fromARGB(255, 30, 111, 168),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badge.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (company.isNotEmpty) Text("Company: $company"),
            if (email.isNotEmpty) Text("Email: $email"),
            if (phone.isNotEmpty) Text("Phone: $phone"),
            if (message.isNotEmpty) Text("Message: $message"),

            if (status == 'pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _updateStatus(id, 'approved'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _updateStatus(id, 'rejected'),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text("Reject"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _delete(id),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              ),
            ],

            if (status != 'pending') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => _delete(id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete",
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
