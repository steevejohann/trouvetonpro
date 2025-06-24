import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:trouvetonpro/firebase_options.dart';

import 'tanos_animation.dart';
import 'inscription_page.dart';
import 'professionnels/electricien_page.dart';
import 'package:trouvetonpro/client_page.dart';

const d_red = Color(0xFFE9717D);
const d_backgroundTop = Color(0xFF1E2A38);
const d_backgroundBottom = Color(0xFFEEF1F5);

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({Key? key}) : super(key: key);

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
    scopes: ['email', 'profile'],
  );

  void _redirectUser(User user) {
    final email = user.email ?? "";
    if (email.contains("pro") || email.contains("artisan")) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfessionalPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClientPage()),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        _redirectUser(userCredential.user!);
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await _auth.signInWithCredential(credential);
        _redirectUser(userCredential.user!);
      }
    } catch (e) {
      debugPrint("❌ Erreur Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion Google: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [d_backgroundTop, d_backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Connexion',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              TanosAnimation(
                delay: 1500,
                child: SizedBox(
                  height: 500,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/charpentier_2.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              TanosAnimation(
                delay: 2500,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Column(
                    children: [
                      Text(
                        'Votre projet de construction en clic.',
                        style: GoogleFonts.poppins(
                          color: d_red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Connectez-vous à votre compte',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[300],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TanosAnimation(
                delay: 3500,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfessionalPage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: d_red,
                          padding: const EdgeInsets.all(13),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mail_outline_outlined),
                            const SizedBox(width: 10),
                            Text('EMAIL', style: GoogleFonts.poppins(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(13),
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FontAwesomeIcons.google, color: Colors.red),
                            const SizedBox(width: 10),
                            Text(
                              'GOOGLE',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InscriptionPage()),
                        ),
                        child: Text(
                          'Vous n\'avez pas de compte ? Inscrivez-vous',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: d_red,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
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
