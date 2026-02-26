import "package:flutter/material.dart";
import 'package:donation_app/admin/event_management.dart';
import 'package:donation_app/after_join_event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Notice extends StatefulWidget {
  const Notice({super.key});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  bool showClub = true; // default selected
  int expandedIndex = -1;

  // Check if current user is logged in as a member (@lussc.local email)
  bool get isMember {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return false;
    final email = session.user.email ?? '';
    return email.endsWith('@lussc.local');
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
              Container(
                margin: const EdgeInsets.only(top: 40, left: 16, right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset('assets/logo.png', width: 36),
                    const SizedBox(width: 10),
                    const Text(
                      'Notices',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                  ],
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
                                if (isMember) {
                                  setState(() {
                                    showClub = false; // Member active
                                  });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Members Notices"),
                                      content: const Text(
                                        "Please login as a member to access this section.",
                                      ), //member na hole ei option dekhabe
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
                                  color: !showClub && isMember
                                      ? Colors
                                            .blue // Active hole blue dekhabe
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!isMember)
                                      const Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                    if (!isMember) const SizedBox(width: 4),
                                    Text(
                                      "Members",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: !showClub && isMember
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
              Expanded(child: showClub ? clubNotices() : memberNotices()),
            ],
          ),
        ],
      ),
    );
  }

  // Club Notices — show events from eventStore as simple notices
  Widget clubNotices() {
    final events = eventStore.where((e) => e['status'] == 'Active').toList();

    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No notices yet.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final String title = event['title'] as String? ?? '';
        final String date = event['date'] as String? ?? '';
        final String time = event['timeDisplay'] as String? ?? '';
        final String location = event['location'] as String? ?? '';
        final String description = event['description'] as String? ?? '';
        final String status = event['status'] as String? ?? 'Active';
        final String notice = event['notice'] as String? ?? '';

        // Tag color based on status
        final Color tagColor = status == 'Active' ? Colors.green : Colors.red;
        final String tag = status == 'Active' ? 'EVENT' : 'CLOSED';

        return noticeCard(
          index: index,
          tag: tag,
          tagColor: tagColor,
          title: title,
          description: notice.isNotEmpty ? notice : description,
          fullDescription: description,
          date: date,
          time: time.isNotEmpty ? time : null,
          isNew: status == 'Active',
        );
      },
    );
  }

  // Members Notices — show events with Join button, only for members
  Widget memberNotices() {
    final events = eventStore.where((e) => e['status'] == 'Active').toList();

    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No member notices yet.',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final String title = event['title'] as String? ?? '';
        final String date = event['date'] as String? ?? '';
        final String time = event['timeDisplay'] as String? ?? '';
        final String description = event['description'] as String? ?? '';
        final String status = event['status'] as String? ?? 'Active';
        final String notice = event['notice'] as String? ?? '';

        final Color tagColor = status == 'Active' ? Colors.green : Colors.red;
        final String tag = status == 'Active' ? 'EVENT' : 'CLOSED';

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
          isNew: status == 'Active',
        );
      },
    );
  }

  // Reusable Notice Card
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
    bool isExpanded = expandedIndex == index;

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

          Text(
            isExpanded && fullDescription.isNotEmpty
                ? fullDescription
                : description,
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
                  Text(time == null ? date : "$date . $time"),
                ],
              ),

              // CLICKABLE READ MORE
              if (fullDescription.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedIndex = -1;
                      } else {
                        expandedIndex = index;
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

  // Member Notice Card — same as noticeCard but with a Join button
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
    bool isExpanded = expandedIndex == index;
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

          Text(
            isExpanded && fullDescription.isNotEmpty
                ? fullDescription
                : description,
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 6),
              Text(time == null ? date : "$date . $time"),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Read more
              if (fullDescription.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        expandedIndex = -1;
                      } else {
                        expandedIndex = index;
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
}
