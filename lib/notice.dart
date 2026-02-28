import "package:flutter/material.dart";
import 'package:donation_app/admin/event_management.dart';
import 'package:donation_app/admin/notice_manage.dart';
import 'package:donation_app/after_join_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  bool showClub = true; // default selected
  int _clubExpandedIndex = -1;
  int _memberExpandedIndex = -1;

  // Events loaded from Supabase
  List<Map<String, dynamic>> _events = [];
  // Admin-created notices from Supabase
  List<Map<String, dynamic>> _clubNotices = [];
  List<Map<String, dynamic>> _memberNotices = [];

  bool _loading = true;
  bool _isAdmin = false;

  // ---- "Seen" tracking (NEW badge) ----
  // We store IDs of notices the user has already seen in SharedPreferences.
  Set<String> _seenNoticeIds = {};
  // Snapshot of seen IDs BEFORE this visit (so NEW shows during current visit)
  Set<String> _previouslySeenIds = {};

  // Check if current user is logged in as a member (@lussc.local email)
  bool get isMember {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;
    final email = session.user.email ?? '';
    return email.endsWith('@lussc.local');
  }

  // Can access member notices if member or admin
  bool get canAccessMember => isMember || _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadSeenIds();
    _loadAll();
    _checkAdmin();
  }

  // Load seen notice IDs from local storage
  Future<void> _loadSeenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('seen_notice_ids') ?? [];
    setState(() {
      _seenNoticeIds = list.toSet();
      _previouslySeenIds = list.toSet(); // snapshot before this visit
    });
  }

  // Mark all currently visible notices + events as "seen" (for next visit)
  Future<void> _markAllCurrentAsSeen() async {
    bool changed = false;

    // Admin notices
    for (final n in _clubNotices) {
      final id = n['id']?.toString() ?? '';
      if (id.isNotEmpty && _seenNoticeIds.add(id)) changed = true;
    }
    for (final n in _memberNotices) {
      final id = n['id']?.toString() ?? '';
      if (id.isNotEmpty && _seenNoticeIds.add(id)) changed = true;
    }

    // Events (with 'event_' prefix to distinguish from admin notice IDs)
    for (final e in _events) {
      final id = 'event_${e['id']}';
      if (_seenNoticeIds.add(id)) changed = true;
    }

    if (changed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('seen_notice_ids', _seenNoticeIds.toList());
    }
  }

  Future<void> _checkAdmin() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;
    final email = session.user.email ?? '';
    try {
      final row = await Supabase.instance.client
          .from('admin_emails')
          .select()
          .eq('email', email)
          .maybeSingle();
      if (mounted) setState(() => _isAdmin = row != null);
    } catch (_) {}
  }

  // Load events AND admin-created notices together
  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      // Load events
      final events = await fetchActiveEvents();

      // Load admin-created notices
      final noticeRows = await Supabase.instance.client
          .from('notices')
          .select()
          .order('created_at', ascending: false);
      final notices = List<Map<String, dynamic>>.from(noticeRows as List);

      setState(() {
        _events = events;
        _clubNotices = notices.where((n) => n['audience'] == 'club').toList();
        _memberNotices = notices
            .where((n) => n['audience'] == 'member')
            .toList();
        _loading = false;
      });

      // Mark everything as seen so next visit won't show NEW
      _markAllCurrentAsSeen();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  // Open a link in the browser
  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Column(
            children: [
              // Appbar
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
                          'Notices',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sliding Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // Animated Slider
                      AnimatedAlign(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: showClub
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 32) / 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blue, Colors.blueAccent],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          // Club Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showClub = true;
                                });
                              },
                              child: Center(
                                child: Text(
                                  "Club Notices",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: showClub
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Member Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (canAccessMember) {
                                  setState(() {
                                    showClub = false;
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Members Notices"),
                                      content: const Text(
                                        "Please login as a member to access this section.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !showClub && canAccessMember
                                      ? Colors.blue
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!canAccessMember)
                                      const Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                    if (!canAccessMember)
                                      const SizedBox(width: 4),
                                    Text(
                                      "Members",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !showClub && canAccessMember
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //  Notices Content
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : showClub
                    ? clubNotices()
                    : memberNotices(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================== Club Notices ========================
  Widget clubNotices() {
    final events = _events;
    final adminNotices = _clubNotices;

    if (events.isEmpty && adminNotices.isEmpty) {
      return const Center(
        child: Text(
          'No notices yet.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    // Total items: admin notices first, then events
    final totalCount = adminNotices.length + events.length;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // Admin-created notices come first
        if (index < adminNotices.length) {
          final n = adminNotices[index];
          return _adminNoticeCard(notice: n, index: index, isClub: true);
        }

        // Then event-based notices
        final eventIndex = index - adminNotices.length;
        final event = events[eventIndex];
        final String title = event['title'] as String? ?? '';
        final String date = event['date'] as String? ?? '';
        final String time = event['timeDisplay'] as String? ?? '';
        final String description = event['description'] as String? ?? '';
        final String status = event['status'] as String? ?? 'Active';
        final String notice = event['notice'] as String? ?? '';

        final Color tagColor = status == 'Active' ? Colors.green : Colors.red;
        final String tag = status == 'Active' ? 'EVENT' : 'CLOSED';

        // Check if user has seen this event notice before
        final eventSeenKey = 'event_${event['id']}';
        final bool isNewEvent = !_previouslySeenIds.contains(eventSeenKey);

        return noticeCard(
          index: index,
          tag: tag,
          tagColor: tagColor,
          title: title,
          description: notice.isNotEmpty ? notice : description,
          fullDescription: description,
          date: date,
          time: time.isNotEmpty ? time : null,
          isNew: isNewEvent,
        );
      },
    );
  }

  // ======================== Members Notices ========================
  Widget memberNotices() {
    final events = _events;
    final adminNotices = _memberNotices;

    if (events.isEmpty && adminNotices.isEmpty) {
      return const Center(
        child: Text(
          'No member notices yet.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    final totalCount = adminNotices.length + events.length;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // Admin-created member notices first
        if (index < adminNotices.length) {
          final n = adminNotices[index];
          return _adminNoticeCard(notice: n, index: index, isClub: false);
        }

        // Then event-based notices
        final eventIndex = index - adminNotices.length;
        final event = events[eventIndex];
        final String title = event['title'] as String? ?? '';
        final String date = event['date'] as String? ?? '';
        final String time = event['timeDisplay'] as String? ?? '';
        final String description = event['description'] as String? ?? '';
        final String status = event['status'] as String? ?? 'Active';
        final String notice = event['notice'] as String? ?? '';

        final Color tagColor = status == 'Active' ? Colors.green : Colors.red;
        final String tag = status == 'Active' ? 'EVENT' : 'CLOSED';

        // Check if user has seen this event notice before
        final eventSeenKey = 'event_${event['id']}';
        final bool isNewEvent = !_previouslySeenIds.contains(eventSeenKey);

        return memberNoticeCard(
          event: event,
          index: index,
          tag: tag,
          tagColor: tagColor,
          title: title,
          description: notice.isNotEmpty ? notice : description,
          fullDescription: description,
          date: date,
          time: time.isNotEmpty ? time : null,
          isNew: isNewEvent,
        );
      },
    );
  }

  // ======================== Event Notice Card (club tab) ========================
  Widget noticeCard({
    required int index,
    required String tag,
    required Color tagColor,
    required String title,
    required String description,
    required String fullDescription,
    required String date,
    String? time,
    bool isNew = false,
  }) {
    bool isExpanded = _clubExpandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // ---- Description (truncated if long) ----
          Builder(
            builder: (_) {
              final fullText = fullDescription.isNotEmpty
                  ? fullDescription
                  : description;
              final isLong =
                  description.length > 100 ||
                  fullText.length > description.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpanded
                        ? fullText
                        : (description.length > 100
                              ? '${description.substring(0, 100)}...'
                              : description),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 6),
                          Text(time == null ? date : "$date · $time"),
                        ],
                      ),
                      if (isLong)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _clubExpandedIndex = isExpanded ? -1 : index;
                            });
                          },
                          child: Text(
                            isExpanded ? "Read less ←" : "Read more →",
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ======================== Event Notice Card (member tab) ========================
  Widget memberNoticeCard({
    required Map<String, dynamic> event,
    required int index,
    required String tag,
    required Color tagColor,
    required String title,
    required String description,
    required String fullDescription,
    required String date,
    String? time,
    bool isNew = false,
  }) {
    bool isExpanded = _memberExpandedIndex == index;
    final String status = event['status'] as String? ?? 'Active';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // ---- Description (truncated if long) ----
          Builder(
            builder: (_) {
              final fullText = fullDescription.isNotEmpty
                  ? fullDescription
                  : description;
              final isLong =
                  description.length > 100 ||
                  fullText.length > description.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExpanded
                        ? fullText
                        : (description.length > 100
                              ? '${description.substring(0, 100)}...'
                              : description),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(time == null ? date : "$date · $time"),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Read more
              Builder(
                builder: (_) {
                  final fullText = fullDescription.isNotEmpty
                      ? fullDescription
                      : description;
                  final isLong =
                      description.length > 100 ||
                      fullText.length > description.length;
                  if (!isLong) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _memberExpandedIndex = isExpanded ? -1 : index;
                      });
                    },
                    child: Text(
                      isExpanded ? "Read less ←" : "Read more →",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),

              // Join button — only for active events
              if (status == 'Active')
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AfterJoinEventPage(event: event),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Join'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _adminNoticeCard({
    required Map<String, dynamic> notice,
    required int index,
    required bool isClub,
  }) {
    final noticeId = notice['id'] as String? ?? '';
    final title = notice['title'] as String? ?? '';
    final body = notice['body'] as String? ?? '';
    final link = notice['link'] as String? ?? '';
    final location = notice['location'] as String? ?? '';
    final createdAt = notice['created_at'] as String? ?? '';
    final noticeDate = notice['notice_date'] as String? ?? '';
    final noticeTime = notice['notice_time'] as String? ?? '';

    // Get the notice type info (color, icon, label)
    final nType = getNoticeType(notice['notice_type'] as String?);

    // Use the correct expanded index based on tab
    final expandedIdx = isClub ? _clubExpandedIndex : _memberExpandedIndex;
    final isExpanded = expandedIdx == index;

    // Check if user has already seen this notice (before this visit)
    final bool isNew = !_previouslySeenIds.contains(noticeId);

    // Format date
    String dateText = '';
    if (createdAt.isNotEmpty) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        final local = dt.toLocal();
        dateText = '${local.day}/${local.month}/${local.year}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Tag row: notice type + NEW badge ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dynamic notice type tag (Meeting / Blood Urgent / etc.)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: nType.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(nType.icon, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      nType.label.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // NEW badge — only shows if user hasn't seen it yet
              if (isNew)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // ---- Title ----
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          // ---- Body (with Read more toggle) ----
          Text(
            isExpanded
                ? body
                : (body.length > 100 ? '${body.substring(0, 100)}...' : body),
            style: const TextStyle(color: Colors.black54),
          ),

          // ---- Location (if provided) ----
          if (location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],

          // ---- Link button ----
          if (link.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _openLink(link),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      link,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ---- Notice Date & Time (if set by admin) ----
          if (noticeDate.isNotEmpty || noticeTime.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.event, size: 16, color: Colors.indigo),
                const SizedBox(width: 4),
                Text(
                  [
                    noticeDate,
                    noticeTime,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // ---- Date + Read more ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 6),
                  Text(dateText),
                ],
              ),
              if (body.length > 100)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isClub) {
                        _clubExpandedIndex = isExpanded ? -1 : index;
                      } else {
                        _memberExpandedIndex = isExpanded ? -1 : index;
                      }
                    });
                  },
                  child: Text(
                    isExpanded ? "Read less ←" : "Read more →",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
