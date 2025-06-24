import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trouvetonpro/professionnels/electricien_page.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  String selectedCategory = 'Tous';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> categories = [
    'Tous',
    'Électricien',
    'Plombier',
    'Peintre',
    'Menuisier',
    'Maçon',
  ];

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String name = 'Marie Koumba';
        return AlertDialog(
          title: Text('Modifier le profil', style: GoogleFonts.poppins()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nom'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Statut'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profil mis à jour pour $name')),
                );
              },
              child: const Text('Enregistrer'),
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

  void _deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte supprimé avec succès')),
        );
      }
    }
  }

  Widget _buildMapCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.map, size: 40, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Localisez les professionnels autour de vous (carte interactive à venir).',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalSuggestion() {
    if (selectedCategory == 'Électricien' || selectedCategory == 'Tous') {
      return ListTile(
        leading: const Icon(FontAwesomeIcons.bolt, color: Colors.orange),
        title: const Text('Électricien disponible'),
        subtitle: const Text('Disponible près de chez vous'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfessionalPage()),
          );
        },
      );
    } else {
      return ListTile(
        leading: const Icon(Icons.build_circle, color: Colors.grey),
        title: Text('$selectedCategory disponible'),
        subtitle: const Text('Bientôt disponible'),
        trailing: const Icon(Icons.lock),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$selectedCategory sera bientôt disponible !')),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenue, Client',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteAccount),
          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditProfileDialog(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un professionnel...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (query) {
                if (query.toLowerCase().contains("électricien")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfessionalPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Aucun professionnel trouvé pour "$query"'),
                      action: SnackBarAction(label: 'Réessayer', onPressed: () {}),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/femme_1.jpeg'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Marie Koumba', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Client à la recherche de pros', style: GoogleFonts.poppins()),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('À propos de vous', style: GoogleFonts.alikeAngular()),
            const SizedBox(height: 8),
            Text(
              "Vous cherchez des professionnels qualifiés pour vos travaux de maison (plomberie, électricité, peinture, etc.).",
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
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
                      title: Text('Demande de service rapide', style: GoogleFonts.poppins()),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: selectedPro,
                            items: categories
                                .where((cat) => cat != 'Tous')
                                .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                                .toList(),
                            onChanged: (val) => selectedPro = val!,
                            decoration: const InputDecoration(labelText: 'Catégorie'),
                          ),
                          TextField(
                            decoration: const InputDecoration(labelText: 'Message au professionnel'),
                            onChanged: (val) => message = val,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Demande envoyée à un $selectedPro')),
                            );
                          },
                          child: const Text('Envoyer'),
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
            Text('Catégorie de professionnels', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategory = value!),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 24),
            _buildProfessionalSuggestion(),
            const SizedBox(height: 24),
            _buildMapCard(),
          ],
        ),
      ),
    );
  }
}
