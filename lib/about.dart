import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  Widget simpleCard(
    BuildContext context,
    String title,
    IconData icon, {
    String? description,
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
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: Colors.blueGrey),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade800,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.asset('assets/logoremove.jpeg', width: 36),
                    const SizedBox(width: 10),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
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
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
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
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          simpleCard(context, "150+ Events", Icons.event),
                          simpleCard(
                            context,
                            "200+ Activities",
                            Icons.local_activity,
                          ),
                          simpleCard(context, "300+ Members", Icons.people),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Text(
                        "Main Events",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          simpleCard(
                            context,
                            "Iftar Sharing",
                            Icons.restaurant,
                          ),
                          simpleCard(context, "Film Festival", Icons.movie),
                          simpleCard(context, "Art Competition", Icons.brush),
                          simpleCard(context, "Food Stalls", Icons.fastfood),
                          simpleCard(
                            context,
                            "Blood & Vaccination Campaign",
                            Icons.bloodtype,
                          ),
                          simpleCard(
                            context,
                            "Winter Clothes Distribution",
                            Icons.ac_unit,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Text(
                        "Our Projects",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade800,
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
                            description:
                                "The Alo School Project works under the Social Services Club to support children living in orphanages. Its main goal is to provide educational assistance to these children, helping them bridge the knowledge gap between themselves and regular school students. Beyond academics, the project focuses on motivating and inspiring children to explore their potential and prepare them for a better life. Through personalized guidance and support, Alo School aims to create an environment where every child can grow confidently and achieve their dreams.",
                          ),
                          simpleCard(
                            context,
                            "Blood Wing",
                            Icons.favorite,
                            description:
                                "The Blood Wing Project is committed to saving lives and promoting public health through organized blood donation and vaccination campaigns. The project encourages community members to donate blood regularly, ensuring a steady and safe supply for patients in need. Alongside this, the project conducts vaccination drives to protect vulnerable populations from preventable diseases. By combining awareness, action, and community participation, the Blood Wing Project aims to build a healthier, stronger, and more resilient society.",
                          ),
                          simpleCard(
                            context,
                            "HashiMukh",
                            Icons.sentiment_satisfied,
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
                          color: Colors.blueGrey.shade800,
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
                                color: Colors.blueGrey.shade800,
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
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "facebook.com/lussc",
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade800,
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
                                    color: Colors.blueGrey.shade800,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "lussc@gmail.com",
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade800,
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
