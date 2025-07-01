import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'connexion_page.dart';
import 'tanos_animation.dart';

const d_red = Color(0xFFE9717D);
// 🎨 Nouvelle couleur de fond adaptée au design
const d_backgroundTop = Color(0xFFEAF1F8); // Bleu très clair
const d_backgroundBottom = Color(0xFFFFFFFF); // Blanc

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [d_backgroundTop, d_backgroundBottom],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TanosAnimation(
                  delay: 1500,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/logo _1.jpeg', // Remplace avec ton chemin local
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TanosAnimation(
                  delay: 2500,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 400,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/maison_1.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                TanosAnimation(
                  delay: 3000,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      'TrouveTonPro est une application qui connecte les clients avec les meilleurs artisans et professionnels du bâtiment à proximité. Trouvez rapidement un électricien, un plombier, un maçon ou tout autre expert qualifié pour vos travaux !',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                TanosAnimation(
                  delay: 3500,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(
                      'Connectez-vous aux meilleurs professionnels près de chez vous !',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                TanosAnimation(
                  delay: 4500,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 18, 4, 99),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.all(13),
                      ),
                      child: const Text('LANCEZ-VOUS!'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConnexionPage()),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
