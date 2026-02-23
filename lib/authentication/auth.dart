import 'package:supabase_flutter/supabase_flutter.dart';

class Auth {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ================= MEMBER SIGNUP =================
  Future<void> memberSignUp({
    required String studentId,
    required String name,
    required String department,
    required int batch,
    required String contactEmail, // optional: real email for notifications
    required String password,
  }) async {
    final email = "$studentId@lussc.local"; // fake internal email

    // 1️⃣ CREATE AUTH USER
    final authRes = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = authRes.user;
    if (user == null) throw Exception("Signup failed");

    // 2️⃣ SAVE MEMBER INFO
    await _supabase.from('members').insert({
      'id': user.id,
      'student_id': studentId,
      'name': name,
      'department': department,
      'batch': batch,
      'contact_email': contactEmail,
      'is_approved': false, // admin approval pending
    });
  }

  // ================= MEMBER LOGIN =================
  Future<void> memberLogin({
    required String studentId,
    required String password,
  }) async {
    // Get internal email from student_id
    final row = await _supabase
        .from('members')
        .select('id')
        .eq('student_id', studentId)
        .maybeSingle();

    if (row == null) throw Exception("Student ID not found");

    final email = "$studentId@lussc.local";

    // Sign in
    await _supabase.auth.signInWithPassword(email: email, password: password);

    // Check approval
    final approvedRow = await _supabase
        .from('members')
        .select('is_approved')
        .eq('student_id', studentId)
        .maybeSingle();

    if (approvedRow == null || approvedRow['is_approved'] == false) {
      throw Exception("Your account is not approved by admin yet.");
    }
  }

  // ================= SUBMIT PAYMENT =================
  Future<void> submitMemberPayment({
    required String studentId,
    required String paymentMethod,
    required String trxId,
  }) async {
    await _supabase.from('member_payments').insert({
      'student_id': studentId,
      'payment_method': paymentMethod,
      'trx_id': trxId,
      'is_verified': false, // admin will verify
    });
  }

  // ================= DONOR SIGNUP =================
  Future<void> signUpDonor({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String reference,
  }) async {
    // 1) Create auth user
    final res = await _supabase.auth.signUp(email: email, password: password);

    // 2) Ensure session exists
    if (_supabase.auth.currentSession == null) {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    }

    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Donor signup failed');

    // 3) Insert donor data into donors table
    await _supabase.from('Donors').insert({
      'id': user.id,
      'name': name,
      'phone': phone,
      'email': email,
      'reference': reference,
    });
  }

  // ================= DONOR LOGIN =================
  Future<void> signInDonor({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // ================= ADMIN METHODS =================
  Future<List<Map<String, dynamic>>> getPendingMembers() async {
    final res = await _supabase
        .from('members')
        .select()
        .eq('is_approved', false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> approveMember(String studentId) async {
    await _supabase
        .from('members')
        .update({'is_approved': true})
        .eq('student_id', studentId);
  }

  Future<List<Map<String, dynamic>>> getPendingPayments() async {
    final res = await _supabase
        .from('member_payments')
        .select()
        .eq('is_verified', false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> verifyPayment(String trxId) async {
    await _supabase
        .from('member_payments')
        .update({'is_verified': true})
        .eq('trx_id', trxId);
  }

  // ================= LOGOUT =================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ================= CURRENT USER =================
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    return session?.user.email;
  }

  String? getCurrentUserId() {
    final session = _supabase.auth.currentSession;
    return session?.user.id;
  }
}
