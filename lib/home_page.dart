import 'dart:async';
import 'package:donation_app/about.dart';
import 'package:donation_app/admin/event_management.dart';
import 'package:donation_app/after_join_event.dart';
import 'package:donation_app/authentication/auth.dart';
import 'package:donation_app/blood.dart';
import 'package:donation_app/cloth_page.dart';
import 'package:donation_app/food_page.dart';
import 'package:donation_app/logOut.dart';
import 'package:donation_app/mem_login.dart';
import 'package:donation_app/money_don.dart';
import 'package:donation_app/notice.dart';
import 'package:donation_app/notification_page.dart';
import 'package:donation_app/profile.dart';
import 'package:donation_app/sponsor_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _pageIndex = 0;

  bool showAll = false;

  final List<String> slides = [
    'assets/homepic2.jpeg',
    'assets/homepic1.jpeg',
    'assets/stallgrouppic.jpeg',
    'assets/bloodpic.jpeg',
    'assets/winterpic.jpeg',
  ];

  // Events loaded from Supabase
  List<Map<String, dynamic>> _activeEvents = [];

  // Bell icon: true when there are unread notifications
  bool _hasUnreadNotifs = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _checkUnreadNotifs();

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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Load active events from Supabase
  Future<void> _loadEvents() async {
    try {
      final events = await fetchActiveEvents();
      setState(() => _activeEvents = events);
    } catch (_) {}
  }

  void mainWorkClick(String name) {
    if (name == 'Blood') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodPage()),
      );
      return;
    }

    // For Clothes, Food, Money — require login
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text('Login Required'),
          content: const Text(
            'Please log in as a donor or member to access this section.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6FA8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (name == 'Clothes') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ClothDonation()),
      );
    } else if (name == 'Money') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MoneyDonationPage()),
      );
    } else if (name == 'Food') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FoodPage()),
      );
    }
  }

  void logOut() async {
    await Auth().signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogOutPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final double pagePad = width * 0.04;
    final double titleSize = width * 0.09;
    final double sectionSize = width * 0.055;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),

          // ================= HEADER =================
          SafeArea(
            child: Column(
              children: [
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
                        if (Navigator.canPop(context))
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
                          'HOME',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),

                        // Bell icon for notices
                        _buildBellIcon(context),
                        const SizedBox(width: 4),

                        //Menu Bar
                        buildMenu(context),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: pagePad,
                      vertical: pagePad * 0.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ================= SLIDER =================
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: SizedBox(
                            height: width * 0.58,
                            child: PageView(
                              controller: _pageController,
                              children: slides.map((img) {
                                return Image.asset(img, fit: BoxFit.cover);
                              }).toList(),
                              onPageChanged: (i) {
                                _pageIndex = i;
                                setState(() {});
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: pagePad * 0.6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < slides.length; i++)
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: pagePad * 0.25,
                                ),
                                height: width * 0.02,
                                width: _pageIndex == i
                                    ? width * 0.045
                                    : width * 0.02,
                                decoration: BoxDecoration(
                                  color: _pageIndex == i
                                      ? Colors.blue
                                      : const Color.fromARGB(
                                          255,
                                          151,
                                          144,
                                          144,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: pagePad * 1.2),

                        // ================= MAIN WORK =================
                        Text(
                          'Our Main Work',
                          style: TextStyle(
                            fontSize: titleSize * 0.62,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,

                            color: const Color.fromARGB(255, 24, 75, 106),
                          ),
                        ),

                        SizedBox(height: pagePad * 0.8),

                        Row(
                          children: [
                            mainWorkCard(
                              'Clothes',
                              Icons.checkroom,
                              const Color.fromARGB(255, 144, 202, 249),
                            ),
                            SizedBox(width: pagePad * 0.8),
                            mainWorkCard(
                              'Food',
                              Icons.restaurant,
                              const Color.fromARGB(255, 129, 199, 132),
                            ),
                          ],
                        ),

                        SizedBox(height: pagePad * 0.8),

                        Row(
                          children: [
                            mainWorkCard(
                              'Blood',
                              Icons.bloodtype,
                              const Color.fromARGB(255, 239, 154, 154),
                            ),
                            SizedBox(width: pagePad * 0.8),
                            mainWorkCard(
                              'Money',
                              Icons.monetization_on,
                              const Color.fromARGB(255, 250, 236, 112),
                            ),
                          ],
                        ),

                        SizedBox(height: pagePad * 1.6),

                        // ================= ACTIVE EVENTS =================
                        Text(
                          'Active Events',
                          style: TextStyle(
                            fontSize: titleSize * 0.62,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,

                            color: const Color.fromARGB(255, 24, 75, 106),
                          ),
                        ),

                        SizedBox(height: pagePad * 0.8),

                        _activeEvents.isEmpty
                            ? Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(pagePad * 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(180),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  'No active events right now.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: sectionSize * 0.8,
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: width * 0.50,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _activeEvents.map((event) {
                                    final Color baseColor =
                                        event['cardColor'] as Color;
                                    final IconData iconData =
                                        event['icon'] as IconData;

                                    return Container(
                                      width: width * 0.56,
                                      margin: EdgeInsets.only(
                                        right: pagePad * 0.8,
                                      ),
                                      padding: EdgeInsets.all(pagePad * 0.9),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.topRight,
                                          colors: [
                                            baseColor.withAlpha(80),
                                            baseColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(30),
                                            blurRadius: 10,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: baseColor,
                                            child: Icon(
                                              iconData,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: pagePad * 0.8),
                                          Text(
                                            event['title'] as String,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: sectionSize * 0.8,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: pagePad * 0.4),
                                          Text(
                                            event['date'] as String,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: sectionSize * 0.7,
                                            ),
                                          ),
                                          const Spacer(),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                // Check if user is logged in
                                                final session = Supabase
                                                    .instance
                                                    .client
                                                    .auth
                                                    .currentSession;
                                                if (session == null) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                      ),
                                                      title: const Text(
                                                        'Login Required',
                                                      ),
                                                      content: const Text(
                                                        'Please login as a donor or member to join this event.',
                                                      ),
                                                      actions: [
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color.fromARGB(
                                                                  255,
                                                                  30,
                                                                  111,
                                                                  168,
                                                                ),
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                ctx,
                                                              ),
                                                          child: const Text(
                                                            'OK',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                  return;
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AfterJoinEventPage(
                                                          event: event,
                                                        ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: baseColor
                                                    .withAlpha(230),
                                              ),
                                              child: const Text(
                                                'Join',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                        SizedBox(height: pagePad * 1.6),

                        // ================= SPONSOR =================
                        Container(
                          margin: EdgeInsets.only(bottom: pagePad),
                          padding: EdgeInsets.all(pagePad * 1.1),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(220),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sponsor Now',
                                      style: TextStyle(
                                        fontSize: titleSize * 0.62,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.normal,

                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: pagePad * 0.4),
                                    Text(
                                      'Support our activities and help us grow.',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: sectionSize * 0.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SponsorPage(),
                                    ),
                                  );
                                },
                                child: const Text('Sponsor'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: pagePad * 1.2),
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

  Widget mainWorkCard(String title, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => mainWorkClick(title),
        child: Container(
          height: MediaQuery.sizeOf(context).width * 0.28,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(220),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 0.13,
                height: MediaQuery.sizeOf(context).width * 0.13,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: MediaQuery.sizeOf(context).width * 0.055,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 24, 75, 106),
                  fontSize: MediaQuery.sizeOf(context).width * 0.045,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if there are unread notifications for the current user
  Future<void> _checkUnreadNotifs() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) {
        if (mounted) setState(() => _hasUnreadNotifs = false);
        return;
      }

      final rows = await Supabase.instance.client
          .from('user_notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('is_read', false);

      final hasUnread = (rows as List).isNotEmpty;
      if (mounted) {
        setState(() => _hasUnreadNotifs = hasUnread);
      }
    } catch (_) {}
  }

  // Bell icon widget with red dot for unread notifications
  Widget _buildBellIcon(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            );
            // After coming back, re-check unread
            _checkUnreadNotifs();
          },
        ),
        // Red dot — only visible when there are unread notifications
        if (_hasUnreadNotifs)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu),
      offset: const Offset(0, 40),
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'Notice':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notice()),
            );
            break;

          case 'About Us':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutPage()),
            );
            break;

          case 'Profile':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyProfile()),
            );
            break;

          case 'Login':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
            break;

          case 'Logout':
            logOut();

            break;

          // Subpages example under Home
          // case 'Blood Donation':
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => BloodPage()),
          //   );
          //   break;
          // case 'Cloth Donation':
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => ClothDonPage()),
          //   );
          //   break;
          // case 'Money Donation':
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => MoneyDonationPage()),
          //   );
          //   break;
          // case 'Food Donation':
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => FoodPage()),
          //   );
          //   break;
        }
      },
      itemBuilder: (context) {
        final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
        return [
          const PopupMenuItem(value: 'Notice', child: Text('Notice')),
          const PopupMenuItem(value: 'About Us', child: Text('About Us')),
          if (isLoggedIn)
            const PopupMenuItem(value: 'Profile', child: Text('Profile')),
          const PopupMenuItem(value: 'Login', child: Text('Login')),
          if (isLoggedIn)
            const PopupMenuItem(value: 'Logout', child: Text('Logout')),
        ];
      },
    );
  }
}
