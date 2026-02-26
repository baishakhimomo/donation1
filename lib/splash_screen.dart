import 'package:donation_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:donation_app/mem_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset("assets/backg.png", fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/logobackremove.png", width: 300),
                const SizedBox(height: 20),
                Text(
                  "LUSSC",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 55, 71, 79),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Leading University\nSocial Services Club",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: 0.2,
                    color: const Color.fromARGB(255, 38, 50, 56),
                    shadows: [
                      Shadow(
                        color: Colors.white.withAlpha(160),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Serving Humanity Through\nStudent-Led Initiatives",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    letterSpacing: 0.15,
                    color: const Color.fromARGB(255, 55, 71, 79),
                    shadows: [
                      Shadow(
                        color: Colors.white.withAlpha(150),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
