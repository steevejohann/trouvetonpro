import 'package:flutter/material.dart';
import  'welcome_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trouvetonpro/firebase_options.dart';
import 'tanos_animation.dart';

const d_red = Color(0xFFE9717D);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrouveTonPro',
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('TrouveTonPro'),
        backgroundColor: d_red,
      ),
      body: Center(
        child: TanosAnimation(
          delay: 1000, // 1 seconde
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo _1.jpeg', // 🖼️ Remplace par le nom de ton image si différent
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                'TrouveTonPro',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Un professionnel sur mesure',
                style: TextStyle(
                  fontSize: 16,
                  color: d_red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
