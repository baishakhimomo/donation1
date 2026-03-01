import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool showAll = false;

  Widget simpleCard(
    BuildContext context,
    String title,
    IconData icon, {
    String? description,
    Color iconColor = const Color.fromARGB(255, 84, 110, 122),
  }) {
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w >= 700 ? 300.0 : (w >= 420 ? (w / 2) - 24 : w - 40);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      width: cardWidth,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(66, 0, 0, 0),
            blurRadius: 4,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: iconColor),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 24, 75, 106),
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: const Color.fromARGB(255, 84, 110, 122),
              ),
            ),
          ],
        ],
      ),
    );
  }

  final List<Map<String, Object>> allEvents = [
    {
      'icon': Icons.food_bank,
      'title': 'Iftar Sharing',
      'iconColor': Color.fromARGB(255, 144, 202, 249),
      'details':
          'The Iftar Sharing event is organized every Ramadan to bring the community together. '
          'Volunteers prepare and distribute iftar meals to people in need, including street vendors, '
          'day laborers, and underprivileged families. The event promotes the spirit of sharing and '
          'compassion during the holy month, ensuring no one breaks their fast on an empty stomach.',
    },
    {
      'icon': Icons.ac_unit,
      'title': 'Winter Clothes Drive',
      'iconColor': Color.fromARGB(255, 129, 199, 132),
      'details':
          'The Winter Clothes Drive collects warm clothing such as sweaters, blankets, jackets, '
          'and shawls from generous donors and distributes them to people living in cold-affected areas. '
          'Every winter, thousands of underprivileged families struggle to stay warm, and this event aims '
          'to provide them with essential winter wear to survive the harsh cold season.',
    },
    {
      'icon': Icons.brush,
      'title': 'Art Competition',
      'iconColor': Color.fromARGB(255, 248, 165, 140),
      'details':
          'The Art Competition is a creative event that encourages students and young artists to '
          'showcase their talents through painting, drawing, and other art forms. Participants compete in '
          'various categories, and the event aims to foster creativity, cultural expression, and artistic '
          'skills among the youth while also raising awareness about social issues through art.',
    },
    {
      'icon': Icons.restaurant,
      'title': 'Food Stalls',
      'iconColor': Color.fromARGB(255, 186, 104, 200),
      'details':
          'The Food Stalls event is a fun-filled fundraiser where members set up stalls offering '
          'delicious homemade food items. All the proceeds from the stalls go towards supporting the '
          'club\'s charitable activities. It is a great opportunity for members to bond, develop '
          'entrepreneurial skills, and raise funds for a good cause in a festive atmosphere.',
    },
    {
      'icon': Icons.water_damage,
      'title': 'Flood Relief Program',
      'iconColor': Color.fromARGB(255, 79, 195, 247),
      'details':
          'The Flood Relief Program is an emergency response initiative that provides essential '
          'supplies such as food, clean water, medicine, and clothing to flood-affected communities. '
          'Volunteers work tirelessly to reach remote areas and help displaced families rebuild their '
          'lives. The program also includes awareness campaigns on flood preparedness and safety measures.',
    },
    {
      'icon': Icons.directions_bike,
      'title': 'Raincoat for Rickshaw Heroes',
      'iconColor': Color.fromARGB(255, 144, 164, 174),
      'details':
          'The Raincoat for Rickshaw Heroes event provides free raincoats to rickshaw pullers '
          'who brave the rain every day to earn their livelihood. These hardworking individuals often '
          'lack basic rain protection, putting their health at risk. By distributing raincoats, the '
          'club ensures they can continue working safely during the monsoon season with dignity.',
    },
    {
      'icon': Icons.local_hospital,
      'title': 'Health Support for Major Diseases',
      'iconColor': Color.fromARGB(255, 223, 78, 78),
      'details':
          'This program provides financial and medical support to patients suffering from major '
          'diseases such as cancer, kidney failure, and heart conditions. The club raises funds to help '
          'cover treatment costs for families who cannot afford expensive medical care. The initiative '
          'also organizes free health checkup camps and awareness sessions on disease prevention.',
    },
    {
      'icon': Icons.movie,
      'title': 'Film Festival',
      'iconColor': Color.fromARGB(255, 239, 154, 154),
      'details':
          'The Film Festival is a cultural event that screens short films, documentaries, and '
          'student-made movies focused on social issues and community development. It provides a '
          'platform for aspiring filmmakers to share their stories while raising awareness about '
          'important topics like poverty, education, and environmental conservation through cinema.',
    },
    {
      'icon': Icons.park,
      'title': 'Tree Plantation',
      'iconColor': Color.fromARGB(255, 102, 187, 106),
      'details':
          'The Tree Plantation drive is an environmental initiative where volunteers plant '
          'hundreds of saplings across campuses, parks, and public spaces. The program educates '
          'participants about the importance of greenery, combating climate change, and preserving '
          'biodiversity. Each planting event is accompanied by workshops on sustainable living and '
          'environmental stewardship.',
    },
  ];

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final double pagePad = width * 0.04;
    final double titleSize = width * 0.09;
    final double sectionSize = width * 0.055;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
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
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset("assets/club_image.jpeg"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "Mission",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color.fromARGB(255, 24, 75, 106),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "To make a positive impact in our community and beyond by organizing charitable events and promoting volunteering among students.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          simpleCard(
                            context,
                            "150+ Events",
                            Icons.event,
                            iconColor: Colors.orange,
                          ),
                          simpleCard(
                            context,
                            "200+ Activities",
                            Icons.local_activity,
                            iconColor: Colors.teal,
                          ),
                          simpleCard(
                            context,
                            "300+ Members",
                            Icons.people,
                            iconColor: Colors.indigo,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // ================= ALL EVENTS =================
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Our All Events',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 24, 75, 106),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showAll = !showAll;
                                });
                              },
                              child: Text(
                                showAll ? 'Show Less' : 'View All',
                                style: TextStyle(fontSize: sectionSize * 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: pagePad * 0.8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: (showAll ? allEvents : allEvents.take(3))
                              .map((event) {
                                final color = event['iconColor'] as Color;
                                final IconData iconData =
                                    event['icon'] as IconData;

                                return Container(
                                  margin: EdgeInsets.only(
                                    bottom: pagePad * 0.8,
                                  ),
                                  padding: EdgeInsets.all(pagePad * 0.9),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(220),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: width * 0.13,
                                        height: width * 0.13,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          iconData,
                                          color: Colors.white,
                                          size: sectionSize,
                                        ),
                                      ),
                                      SizedBox(width: pagePad * 0.8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event['title'] as String,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: sectionSize * 0.75,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    iconData,
                                                    color: color,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      event['title'] as String,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromARGB(
                                                          255,
                                                          24,
                                                          75,
                                                          106,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Text(
                                                event['details'] as String,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  height: 1.5,
                                                  color:
                                                      Colors.blueGrey.shade700,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    'Close',
                                                    style: TextStyle(
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: color,
                                        ),
                                        child: Text(
                                          'Details',
                                          style: TextStyle(
                                            fontSize: sectionSize * 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        "Our Projects",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 24, 75, 106),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          simpleCard(
                            context,
                            "Alo School",
                            Icons.school,
                            iconColor: Colors.green,
                            description:
                                "The Alo School Project works under the Social Services Club to support children living in orphanages. Its main goal is to provide educational assistance to these children, helping them bridge the knowledge gap between themselves and regular school students. Beyond academics, the project focuses on motivating and inspiring children to explore their potential and prepare them for a better life. Through personalized guidance and support, Alo School aims to create an environment where every child can grow confidently and achieve their dreams.",
                          ),
                          simpleCard(
                            context,
                            "Blood Wing",
                            Icons.favorite,
                            iconColor: Colors.red,
                            description:
                                "The Blood Wing Project is committed to saving lives and promoting public health through organized blood donation and vaccination campaigns. The project encourages community members to donate blood regularly, ensuring a steady and safe supply for patients in need. Alongside this, the project conducts vaccination drives to protect vulnerable populations from preventable diseases. By combining awareness, action, and community participation, the Blood Wing Project aims to build a healthier, stronger, and more resilient society.",
                          ),
                          simpleCard(
                            context,
                            "HashiMukh",
                            Icons.sentiment_satisfied,
                            iconColor: Colors.amber,
                            description:
                                "The Hashi Mukh Project is dedicated to empowering underprivileged families and improving their quality of life. The project helps families become self-reliant by providing opportunities to earn their own income while offering financial support for essential needs, particularly medical care. By supporting families both financially and socially, Hashi Mukh strives to create a community where every member has a chance to live with dignity, health, and hope.",
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      Text(
                        "Previous Programmes",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 24, 75, 106),
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 11,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  "images/pic${index + 1}.jpeg",
                                  height: 220,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        color: Colors.blueGrey.withAlpha(140),
                        child: Column(
                          children: [
                            Text(
                              "Contact Us",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 24, 75, 106),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            GestureDetector(
                              onTap: () {
                                openLink(
                                  "https://www.facebook.com/share/1Az13H6ACL/",
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.facebook,
                                    color: const Color.fromARGB(
                                      255,
                                      55,
                                      71,
                                      79,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "facebook.com/lussc",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        55,
                                        71,
                                        79,
                                      ),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            GestureDetector(
                              onTap: () {
                                openLink("mailto:lussc@lus.ac.bd");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: const Color.fromARGB(
                                      255,
                                      55,
                                      71,
                                      79,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "lussc@gmail.com",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        55,
                                        71,
                                        79,
                                      ),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 15),

                            Text(
                              "© 2026 LUSSC. All Rights Reserved.",
                              style: TextStyle(
                                color: Colors.blueGrey.shade800,
                                fontSize: 12,
                              ),
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
        ),
      ),
    );
  }
}
