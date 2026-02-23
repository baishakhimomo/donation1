import 'dart:async';
import 'package:donation_app/about.dart';
import 'package:donation_app/blood.dart';
import 'package:donation_app/cloth_page.dart';
import 'package:donation_app/food_page.dart';
import 'package:donation_app/mem_login.dart';
import 'package:donation_app/member_form.dart';
import 'package:donation_app/money_don.dart';
import 'package:donation_app/notice.dart';
import 'package:donation_app/profile.dart';
import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> activeEvents = [
    {
      'icon': Icons.food_bank,
      'title': 'Iftar Sharing',
      'time': 'Feb 12 · 5:30 PM',
      'cta': 'Join',
      'cardColor': Color.fromARGB(255, 164, 73, 160),
      'iconColor': Color.fromARGB(255, 164, 73, 160),
    },
    {
      'icon': Icons.set_meal,
      'title': 'Food Stalls',
      'time': 'Feb 15 · 11:00 AM',
      'cta': 'Join',
      'cardColor': Color.fromARGB(255, 113, 212, 116),
      'iconColor': Color.fromARGB(255, 113, 212, 116),
    },
    {
      'icon': Icons.bloodtype,
      'title': 'Blood Donation',
      'time': 'Feb 22 · 9:00 AM',
      'cta': 'Join',
      'cardColor': Color.fromARGB(255, 224, 79, 69),
      'iconColor': Color.fromARGB(255, 224, 79, 69),
    },
  ];

  final List<Map<String, Object>> allEvents = [
    {
      'icon': Icons.food_bank,
      'title': 'Iftar Sharing',
      'time': '5:30 PM - 7:30 PM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 144, 202, 249),
    },
    {
      'icon': Icons.emoji_people,
      'title': 'Winter Clothes Drive',
      'time': '',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 129, 199, 132),
    },
    {
      'icon': Icons.brush,
      'title': 'Art Competition',
      'time': '10:00 AM - 3:00 PM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 248, 165, 140),
    },
    {
      'icon': Icons.restaurant,
      'title': 'Food Stalls',
      'time': '11:00 AM - 5:00 PM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 186, 104, 200),
    },
    {
      'icon': Icons.water_damage,
      'title': 'Flood Relief Program',
      'time': '',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 79, 195, 247),
    },
    {
      'icon': Icons.directions_bike,
      'title': 'Raincoat for Rickshaw Heroes',
      'time': '9:00 AM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 144, 164, 174),
    },
    {
      'icon': Icons.local_hospital,
      'title': 'Health Support for Major Diseases',
      'time': '9:00 AM - 2:00 PM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 223, 78, 78),
    },
    {
      'icon': Icons.movie,
      'title': 'Film Festival',
      'time': '6:00 PM - 10:00 PM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 239, 154, 154),
    },
    {
      'icon': Icons.park,
      'title': 'Tree Plantation',
      'time': '7:00 AM - 12:00 PM',
      'cta': 'Join',
      'iconColor': Color.fromARGB(255, 102, 187, 106),
    },
  ];

  @override
  void initState() {
    super.initState();

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

  void mainWorkClick(String name) {
    if (name == 'Blood') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BloodPage()),
      );
    } else if (name == 'Clothes') {
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backg.png', fit: BoxFit.cover),
          ),

          // ================= HEADER =================
          SafeArea(
            child: Container(
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                  Image.asset('assets/logo.jpeg', width: 36),
                  const SizedBox(width: 10),
                  const Text(
                    'HOME',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),

                  //Menu Bar
                  buildMenu(context),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              top: 80,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: SingleChildScrollView(
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

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < slides.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _pageIndex == i ? 18 : 8,
                          decoration: BoxDecoration(
                            color: _pageIndex == i
                                ? Colors.blue
                                : const Color.fromARGB(255, 151, 144, 144),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= MAIN WORK =================
                  const Text(
                    'Our Main Work',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      mainWorkCard(
                        'Clothes',
                        Icons.checkroom,
                        const Color.fromARGB(255, 144, 202, 249),
                      ),
                      const SizedBox(width: 12),
                      mainWorkCard(
                        'Food',
                        Icons.restaurant,
                        const Color.fromARGB(255, 129, 199, 132),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      mainWorkCard(
                        'Blood',
                        Icons.bloodtype,
                        const Color.fromARGB(255, 239, 154, 154),
                      ),
                      const SizedBox(width: 12),
                      mainWorkCard(
                        'Money',
                        Icons.monetization_on,
                        const Color.fromARGB(255, 250, 236, 112),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ================= ACTIVE EVENTS =================
                  const Text(
                    'Active Events',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: activeEvents.map((event) {
                        final Color baseColor = event['cardColor'] as Color;
                        final IconData iconData = event['icon'] as IconData;

                        return Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [baseColor.withAlpha(80), baseColor],
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: baseColor,
                                child: Icon(iconData, color: Colors.white),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                event['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                event['time'] as String,
                                style: const TextStyle(color: Colors.white),
                              ),

                              const Spacer(),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: baseColor.withAlpha(230),
                                  ),
                                  child: Text(
                                    event['cta'] as String,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= ALL EVENTS =================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'All Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showAll = !showAll;
                          });
                        },
                        child: Text(showAll ? 'Show Less' : 'View All'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Column(
                    children: (showAll ? allEvents : allEvents.take(3)).map((
                      event,
                    ) {
                      final color = event['iconColor'] as Color;
                      final IconData iconData = event['icon'] as IconData;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(iconData, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(event['time'] as String),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: color,
                              ),
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ================= SPONSOR =================
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sponsor Now',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Support our activities and help us grow.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: const Text('Sponsor'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
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
          height: 110,
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
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
          // case 'Profile':
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => MyProfile()),
          //   );
          //   break;

          case 'Login':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
            break;
          // case 'Logout':
          //   print("Logged out");
          //   break;

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
        // Customize menu items per page if needed
        return [
          const PopupMenuItem(value: 'Notice', child: Text('Notice')),
          const PopupMenuItem(value: 'About Us', child: Text('About Us')),

          // const PopupMenuItem(value: 'Profile', child: Text('Profile')),
          const PopupMenuItem(value: 'Login', child: Text('Login')),
          // const PopupMenuItem(value: 'Logout', child: Text('Logout')),
        ];
      },
    );
  }
}
