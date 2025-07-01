import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:trouvetonpro/professionnels/electricien_page.dart';
import 'package:trouvetonpro/professionnels/maçon_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Couleurs principales de l'application
const Color primaryColor = Color(0xFF0D47A1); // Bleu profond
const Color secondaryColor = Color(0xFF64B5F6); // Bleu clair
const Color accentColor = Color(0xFFFFC107); // Jaune doré
const Color successColor = Color(0xFF4CAF50); // Vert
const Color dangerColor = Color(0xFFF44336); // Rouge

// NOUVELLES COULEURS DE FOND
const d_backgroundTop = Color(0xFFEAF1F8); // Bleu clair en haut
const d_backgroundBottom = Color(0xFFFFFFFF); // Blanc en bas

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  String selectedCategory = 'Tous';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String _name = 'Marie Koumba';
  String _about = "Vous cherchez des professionnels qualifiés pour vos travaux de maison (plomberie, électricité, peinture, etc.).";
  String? _profileImagePath;

  final List<String> categories = [
    'Tous',
    'Électricien',
    'Plombier',
    'Peintre',
    'Menuisier',
    'Maçon',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('client_name') ?? 'Marie Koumba';
      _about = prefs.getString('client_about') ?? "Vous cherchez des professionnels qualifiés pour vos travaux de maison (plomberie, électricité, peinture, etc.).";
      _profileImagePath = prefs.getString('client_profile_image_path');
    });

    if (_profileImagePath != null) {
      setState(() {
        _profileImage = File(_profileImagePath!);
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('client_name', _name);
    await prefs.setString('client_about', _about);
    
    if (_profileImage != null) {
      await prefs.setString('client_profile_image_path', _profileImage!.path);
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        _saveProfile();
      }
    } catch (e) {
      print("Erreur de sélection de photo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController(text: _name);
    TextEditingController aboutController = TextEditingController(text: _about);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier votre profil', 
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: secondaryColor.withOpacity(0.2),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/femme_1.jpeg') as ImageProvider,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30, color: primaryColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Cliquez pour changer la photo', 
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: aboutController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'À propos de vous',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
              style: TextButton.styleFrom(foregroundColor: dangerColor),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  _about = aboutController.text;
                });
                _saveProfile();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil mis à jour avec succès'),
                    backgroundColor: successColor,
                  ),
                );
              },
              child: const Text('Enregistrer'),
              style: ElevatedButton.styleFrom(backgroundColor: successColor),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    await _auth.signOut();
    if (mounted) Navigator.pop(context);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suppression du compte'),
        content: const Text('Cette action est irréversible. Êtes-vous sûr de vouloir supprimer votre compte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = _auth.currentUser;
              if (user != null) {
                await user.delete();
                if (mounted) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('client_name');
                  await prefs.remove('client_about');
                  await prefs.remove('client_profile_image_path');
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compte supprimé avec succès'),
                      backgroundColor: successColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9), // Fond blanc légèrement transparent
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.map, size: 40, color: primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Localisez les professionnels autour de vous (carte interactive à venir).',
                style: GoogleFonts.poppins(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalSuggestion() {
    if (selectedCategory == 'Tous') {
      return Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white, // Fond blanc
            child: ListTile(
              leading: Icon(FontAwesomeIcons.bolt, color: accentColor),
              title: Text('Électricien disponible', 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('Disponible près de chez vous', 
                style: GoogleFonts.poppins(color: Colors.grey[600])),
              trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfessionalPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white, // Fond blanc
            child: ListTile(
              leading: Icon(Icons.construction, color: Colors.brown),
              title: Text('Maçon disponible', 
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              subtitle: Text('Disponible près de chez vous', 
                style: GoogleFonts.poppins(color: Colors.grey[600])),
              trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MaconPage()),
                );
              },
            ),
          ),
        ],
      );
    } else if (selectedCategory == 'Électricien') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white, // Fond blanc
        child: ListTile(
          leading: Icon(FontAwesomeIcons.bolt, color: accentColor),
          title: Text('Électricien disponible', 
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          subtitle: Text('Disponible près de chez vous', 
            style: GoogleFonts.poppins(color: Colors.grey[600])),
          trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfessionalPage()),
            );
          },
        ),
      );
    } else if (selectedCategory == 'Maçon') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white, // Fond blanc
        child: ListTile(
          leading: Icon(Icons.construction, color: Colors.brown),
          title: Text('Maçon disponible', 
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          subtitle: Text('Disponible près de chez vous', 
            style: GoogleFonts.poppins(color: Colors.grey[600])),
          trailing: Icon(Icons.arrow_forward_ios, color: primaryColor),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MaconPage()),
            );
          },
        ),
      );
    } else {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white, // Fond blanc
        child: ListTile(
          leading: Icon(Icons.build_circle, color: Colors.grey),
          title: Text('$selectedCategory disponible',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          subtitle: const Text('Bientôt disponible'),
          trailing: Icon(Icons.lock, color: primaryColor),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$selectedCategory sera bientôt disponible !'),
                backgroundColor: accentColor,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenue, Client',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), 
            onPressed: _signOut,
            tooltip: 'Déconnexion',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white), 
            onPressed: _confirmDeleteAccount,
            tooltip: 'Supprimer le compte',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white), 
            onPressed: () => _showEditProfileDialog(context),
            tooltip: 'Modifier votre profil',
          ),
        ],
      ),
      body: Container(
        // AJOUT DU DÉGRADÉ DE FOND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [d_backgroundTop, d_backgroundBottom],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un professionnel...',
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  filled: true, // Fond blanc pour le champ
                  fillColor: Colors.white,
                ),
                onSubmitted: (query) {
                  if (query.toLowerCase().contains("électricien")) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfessionalPage()),
                    );
                  } else if (query.toLowerCase().contains("maçon") || query.toLowerCase().contains("macon")) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MaconPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Aucun professionnel trouvé pour "$query"'),
                        backgroundColor: dangerColor,
                        action: SnackBarAction(
                          label: 'Réessayer', 
                          onPressed: () {},
                          textColor: Colors.white,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white, // Fond blanc
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: secondaryColor.withOpacity(0.2),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage('assets/images/femme_1.jpeg') as ImageProvider,
                          child: _profileImage == null
                              ? const Icon(Icons.camera_alt, size: 24, color: primaryColor)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name, 
                              style: GoogleFonts.poppins(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              )),
                            Text('Client à la recherche de pros', 
                              style: GoogleFonts.poppins(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('À propos de vous', 
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                )),
              const SizedBox(height: 8),
              Text(
                _about,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String selectedPro = 'Électricien';
                      String message = '';
                      return AlertDialog(
                        title: Text('Demande de service rapide', 
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          )),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedPro,
                              items: categories
                                  .where((cat) => cat != 'Tous')
                                  .map((category) => DropdownMenuItem(
                                        value: category, 
                                        child: Text(category),
                                      ))
                                  .toList(),
                              onChanged: (val) => selectedPro = val!,
                              decoration: InputDecoration(
                                labelText: 'Catégorie',
                                labelStyle: TextStyle(color: primaryColor),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor, width: 2),
                                ),
                                filled: true, // Fond blanc
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Message au professionnel',
                                labelStyle: TextStyle(color: primaryColor),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor, width: 2),
                                ),
                                filled: true, // Fond blanc
                                fillColor: Colors.white,
                              ),
                              onChanged: (val) => message = val,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: const Text('Annuler'),
                            style: TextButton.styleFrom(foregroundColor: dangerColor),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Demande envoyée à un $selectedPro'),
                                  backgroundColor: successColor,
                                ),
                              );
                            },
                            child: const Text('Envoyer'),
                            style: ElevatedButton.styleFrom(backgroundColor: successColor),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Demande de service rapide'),
              ),
              const SizedBox(height: 24),
              Text('Catégorie de professionnels', 
                style: GoogleFonts.poppins(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                )),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white, // Fond blanc
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((category) => DropdownMenuItem(
                              value: category, 
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true, // Fond blanc
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildProfessionalSuggestion(),
              const SizedBox(height: 24),
              _buildMapCard(),
            ],
          ),
        ),
      ),
    );
  }
}