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

  // ✅ Couleurs modifiées pour cohérence avec Welcome & Connexion
  final Color primaryColor = const Color.fromARGB(255, 83, 17, 190);
  final Color backgroundColor = const Color(0xFFEAF1F8); // Couleur de fond modifiée
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF343A40);
  final Color accentColor = const Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inscription',
          style: GoogleFonts.poppins(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TanosAnimation(
                  delay: 500,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/macon_3.jpeg'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TanosAnimation(
                  delay: 1000,
                  child: Text(
                    'Créer votre compte',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TanosAnimation(
                  delay: 1200,
                  child: Text(
                    'Rejoignez notre communauté de professionnels et clients',
                    style: GoogleFonts.poppins(
                      color: accentColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TanosAnimation(
                  delay: 1400,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: nomController,
                          label: 'Nom',
                          icon: Icons.person,
                          validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          controller: prenomController,
                          label: 'Prénom',
                          icon: Icons.person_outline,
                          validator: (value) => value!.isEmpty ? 'Prénom requis' : null,
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => 
                              value!.contains('@') ? null : 'Email invalide',
                        ),
                        const SizedBox(height: 15),
                        _buildInputField(
                          controller: usernameController,
                          label: 'Nom d\'utilisateur',
                          icon: Icons.account_circle,
                          validator: (value) => 
                              value!.isEmpty ? 'Nom d\'utilisateur requis' : null,
                        ),
                        const SizedBox(height: 15),
                        _buildRoleSelector(),
                        const SizedBox(height: 15),
                        _buildPasswordField(
                          controller: passwordController,
                          label: 'Mot de passe',
                          obscure: _obscurePassword,
                          toggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (value) => 
                              value!.length < 6 ? 'Minimum 6 caractères' : null,
                        ),
                        const SizedBox(height: 15),
                        _buildPasswordField(
                          controller: confirmPasswordController,
                          label: 'Confirmer le mot de passe',
                          obscure: _obscureConfirmPassword,
                          toggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          validator: (value) => 
                              value != passwordController.text ? 'Mots de passe différents' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TanosAnimation(
                  delay: 2200,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'S\'inscrire',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TanosAnimation(
                  delay: 2400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous avez déjà un compte ? ',
                        style: GoogleFonts.poppins(
                          color: accentColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Se connecter',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: accentColor),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: accentColor),
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: primaryColor,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: validator,
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        dropdownColor: cardColor,
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        decoration: InputDecoration(
          labelText: 'Rôle',
          labelStyle: GoogleFonts.poppins(color: accentColor),
          prefixIcon: Icon(Icons.work, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        style: GoogleFonts.poppins(color: textColor),
        items: [
          DropdownMenuItem(
            value: 'professionnel',
            child: Row(
              children: [
                Icon(Icons.build, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Text('Professionnel', style: GoogleFonts.poppins()),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'client',
            child: Row(
              children: [
                Icon(Icons.person, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Text('Client', style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ],
        onChanged: (value) => setState(() => selectedRole = value),
        validator: (value) => value == null ? 'Sélectionnez votre rôle' : null,
      ),
    );
  }

  Future<void> _submitForm() async {
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
              builder: (context) => const ProfessionalPage(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ClientPage(),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
