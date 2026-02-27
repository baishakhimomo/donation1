import 'package:donation_app/admin/admin_approval.dart';
import 'package:donation_app/cloth_page.dart';
import 'package:donation_app/food_page.dart';
import 'package:donation_app/mem_login.dart';
import 'package:donation_app/profile.dart';
import 'package:donation_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://ylyyyvresgnacchzesub.supabase.co",
    anonKey: "sb_publishable_vS6E7TGfUbt1nZZHTbjCJw_X6kcHlBX",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
