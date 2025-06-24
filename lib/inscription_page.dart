import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tanos_animation.dart';
import 'professionnels/electricien_page.dart';
import 'client_page.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? selectedRole;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inscription',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TanosAnimation(
                delay: 500,
                child: Image.asset(
                  'assets/images/macon_3.jpeg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              TanosAnimation(
                delay: 1000,
                child: TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom :'),
                  validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                ),
              ),
              TanosAnimation(
                delay: 1200,
                child: TextFormField(
                  controller: prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom :'),
                  validator: (value) => value!.isEmpty ? 'Prénom requis' : null,
                ),
              ),
              TanosAnimation(
                delay: 1400,
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email :'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.contains('@') ? null : 'Email invalide',
                ),
              ),
              TanosAnimation(
                delay: 1500,
                child: TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Nom d\'utilisateur :'),
                  validator: (value) => value!.isEmpty ? 'Nom d\'utilisateur requis' : null,
                ),
              ),
              TanosAnimation(
                delay: 1600,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Rôle :'),
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'professionnel', child: Text('Professionnel')),
                    DropdownMenuItem(value: 'client', child: Text('Client')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value),
                  validator: (value) => value == null ? 'Rôle requis' : null,
                ),
              ),
              TanosAnimation(
                delay: 1800,
                child: TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe :',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      value!.length < 6 ? 'Mot de passe trop court' : null,
                ),
              ),
              TanosAnimation(
                delay: 2000,
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe :',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (value) =>
                      value != passwordController.text ? 'Les mots de passe ne correspondent pas' : null,
                ),
              ),
              const SizedBox(height: 20),
              TanosAnimation(
                delay: 2200,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await _auth.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        // Redirection après inscription
                        if (selectedRole == 'professionnel') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfessionalPage()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ClientPage()),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur : ${e.message}')),
                        );
                      }
                    }
                  },
                  child: const Text('S\'inscrire'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



