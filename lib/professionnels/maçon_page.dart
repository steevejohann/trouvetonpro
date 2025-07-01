import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart' as io;
import 'package:intl/intl.dart';

// Couleurs principales de l'application
const Color primaryColor = Color(0xFF0D47A1); // Bleu profond
const Color secondaryColor = Color(0xFF64B5F6); // Bleu clair
const Color accentColor = Color(0xFFFFC107); // Jaune doré
const Color successColor = Color(0xFF4CAF50); // Vert
const Color dangerColor = Color(0xFFF44336); // Rouge

// NOUVELLES COULEURS DE FOND
const d_backgroundTop = Color(0xFFEAF1F8); // Bleu clair en haut
const d_backgroundBottom = Color(0xFFFFFFFF); // Blanc en bas

class MaconPage extends StatefulWidget {
  const MaconPage({super.key});

  @override
  State<MaconPage> createState() => _ProfessionalPageState();
}

class _ProfessionalPageState extends State<MaconPage> {
  List<String> imageList = [
    'assets/images/batiplus_1.jpeg',
    'assets/images/sogametec_1.jpeg',
    'assets/images/entreprise_1.jpeg',
    'assets/images/sogametec_2.jpeg',
  ];

  List<File> realisations = [];
  final picker = ImagePicker();
  File? profileImage; // Pour stocker la nouvelle photo de profil

  String name = 'john Snow | N°066955335 ';
  String status = 'Maçon | occupé aujourd\'hui | localisation: Akanda';
  String service1 = 'Constrution complète de vos projets immobiliers';
  String price1 = '400 000 FCFA';
  String service2 = 'Crépissage';
  String price2 = '100 000 FCFA';
  double rating = 0;
  double averageRating = 3.7;
  List<double> allRatings = [];
  Position? currentPosition;
  String commentaire = '';

  // Variables pour la demande de devis
  List<Map<String, dynamic>> devisRequests = [];
  final GlobalKey<FormState> _devisFormKey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedService;
  double superficie = 100.0;
  int nombrePieces = 3;
  DateTime dateChantier = DateTime.now().add(const Duration(days: 7));

  Future<void> _pickImage() async {
    print("Début de _pickImage");
    try {
      // Gestion spécifique pour le web
      if (kIsWeb) {
        print("Plateforme Web: Accès direct à la galerie");
        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            realisations.add(File(pickedFile.path));
          });
        }
        return;
      }

      PermissionStatus status;
      if (io.Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else if (io.Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plateforme non supportée')),
        );
        return;
      }

      if (status.isGranted) {
        print("Permission accordée");
        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
        print("Fichier sélectionné: ${pickedFile?.path}");

        if (pickedFile != null) {
          print("Ajout du fichier: ${pickedFile.path}");
          setState(() {
            realisations.add(File(pickedFile.path));
          });
        } else {
          print("Aucun fichier sélectionné");
        }
      } else {
        print("Permission refusée: $status");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission refusée pour accéder aux fichiers')),
        );
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
      }
    } catch (e, stack) {
      print("ERREUR: $e");
      print("STACK TRACE: $stack");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Erreur de sélection de photo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  void _editField(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Fond blanc pour la boîte de dialogue
        title: Text('Modifier $title', 
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            filled: true,
            fillColor: Colors.white,
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
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
          ),
        ],
      ),
    );
  }

  void _repondreClient(String demande, String client) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Fond blanc pour la boîte de dialogue
        title: Text("Répondre à $client", 
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Message de réponse",
            hintText: "Votre message...",
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Annuler'),
            style: TextButton.styleFrom(foregroundColor: dangerColor),
          ),
          ElevatedButton(
            onPressed: () {
              String message = controller.text.trim();
              Navigator.pop(context);
              if (message.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message envoyé à $client : "$message"'),
                    backgroundColor: successColor,
                  ),
                );
              }
            },
            child: const Text('Envoyer'),
            style: ElevatedButton.styleFrom(backgroundColor: successColor),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void _updateRating(double newRating) {
    setState(() {
      rating = newRating;
      allRatings.add(newRating);
      averageRating = allRatings.isEmpty ? 0 : allRatings.reduce((a, b) => a + b) / allRatings.length;
    });
  }

  Widget _buildRatingBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
              onPressed: () {
                _updateRating(index + 1.0);
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Note moyenne: ${averageRating.toStringAsFixed(1)}/5 (${allRatings.length} avis)',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildCommentBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commentaire', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Écrivez votre avis ici...',
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) => setState(() => commentaire = val),
        ),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Fond blanc pour la boîte de dialogue
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Déconnexion réussie'),
                  backgroundColor: successColor,
                ),
              );
            },
            child: const Text('Déconnexion'),
            style: ElevatedButton.styleFrom(backgroundColor: accentColor),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Fond blanc pour la boîte de dialogue
        title: const Text('Suppression du compte'),
        content: const Text('Cette action est irréversible. Êtes-vous sûr de vouloir supprimer votre compte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compte supprimé avec succès'),
                  backgroundColor: Color.fromARGB(255, 33, 24, 161),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: dangerColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(File file) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: secondaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: secondaryColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 30, color: primaryColor),
            const SizedBox(height: 8),
            Text('Ajouter', style: TextStyle(color: primaryColor)),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour afficher le formulaire de devis
  void _showDevisForm(String service) {
    selectedService = service;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white, // Fond blanc pour la boîte de dialogue
            title: Text('Demande de devis pour $service', 
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _devisFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom complet',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telephoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse du chantier',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer l\'adresse';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Champs spécifiques pour l'installation électrique
                    if (service.contains('Montage des briques'))
                      Column(
                        children: [
                          Text('Superficie: ${superficie.toInt()} m²',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: superficie,
                            min: 50,
                            max: 500,
                            divisions: 18,
                            label: superficie.toInt().toString(),
                            onChanged: (value) => setState(() => superficie = value),
                          ),
                          const SizedBox(height: 12),
                          Text('Nombre de pièces: $nombrePieces',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: nombrePieces.toDouble(),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            label: nombrePieces.toString(),
                            onChanged: (value) => setState(() => nombrePieces = value.toInt()),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description des travaux',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez décrire les travaux';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Date prévue: ',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () async {
                            final selected = await showDatePicker(
                              context: context,
                              initialDate: dateChantier,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (selected != null) {
                              setState(() => dateChantier = selected);
                            }
                          },
                          child: Text(
                            '${dateChantier.day}/${dateChantier.month}/${dateChantier.year}',
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                  if (_devisFormKey.currentState!.validate()) {
                    final newDevis = {
                      'service': selectedService,
                      'client': nomController.text,
                      'email': emailController.text,
                      'telephone': telephoneController.text,
                      'adresse': adresseController.text,
                      'date': dateChantier,
                      'status': 'En attente',
                      'details': {
                        'superficie': superficie,
                        'pieces': nombrePieces,
                        'description': descriptionController.text,
                      },
                    };
                    
                    setState(() {
                      devisRequests.add(newDevis);
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Devis demandé pour $selectedService'),
                        backgroundColor: successColor,
                      ),
                    );
                    
                    // Réinitialiser les champs
                    nomController.clear();
                    emailController.clear();
                    telephoneController.clear();
                    adresseController.clear();
                    descriptionController.clear();
                  }
                },
                child: const Text('Demander devis'),
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
              ),
            ],
          );
        },
      ),
    );
  }

  // Nouvelle méthode pour construire les cartes de service
  Widget _buildServiceCard(String service, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: Colors.white, // Fond blanc
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(service,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(price,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: primaryColor),
                  onPressed: () => _editField('service', service, (val) {
                    if (service == service1) {
                      setState(() => service1 = val);
                    } else {
                      setState(() => service2 = val);
                    }
                  }),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showDevisForm(service),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Demander devis'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour construire les cartes de devis
  Widget _buildDevisCard(Map<String, dynamic> devis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(devis['service']!,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(devis['status']!),
                  backgroundColor: devis['status'] == 'En attente' 
                    ? Colors.orange[100] 
                    : Colors.green[100],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client: ${devis['client']}'),
            Text('Email: ${devis['email']}'),
            Text('Téléphone: ${devis['telephone']}'),
            Text('Adresse: ${devis['adresse']}'),
            Text('Date prévue: ${DateFormat('dd/MM/yyyy').format(devis['date'])}'),
            
            if (devis['details'] != null) ...[
              const SizedBox(height: 8),
              Text('Détails:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              if (devis['details']['superficie'] != null)
                Text('- Superficie: ${devis['details']['superficie']} m²'),
              if (devis['details']['pieces'] != null)
                Text('- Nombre de pièces: ${devis['details']['pieces']}'),
              if (devis['details']['description'] != null)
                Text('- Description: ${devis['details']['description']}'),
            ],
            
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      devisRequests.remove(devis);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Devis supprimé')),
                    );
                  },
                  child: const Text('Supprimer'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Logique pour envoyer le devis au client
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Devis envoyé à ${devis['client']}'),
                        backgroundColor: successColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Envoyer devis', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    allRatings = [4, 5, 3, 4, 2, 5].map((e) => e.toDouble()).toList();
    averageRating = allRatings.reduce((a, b) => a + b) / allRatings.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tableau de bord du professionnel',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _confirmDeleteAccount,
            tooltip: 'Supprimer le compte',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _confirmLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Container(
        // DÉGRADÉ DE FOND
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
              Text('Bienvenue, M. $name',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),

              if (currentPosition != null)
                Text(
                  'Position actuelle: (${currentPosition!.latitude}, ${currentPosition!.longitude})',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: secondaryColor, width: 1),
                ),
                color: Colors.white, // Fond blanc
                child: ListTile(
                  leading: GestureDetector(
                    onTap: _pickProfileImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: secondaryColor.withOpacity(0.2),
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : const AssetImage('assets/images/electricien_1.jpg') as ImageProvider,
                      child: profileImage == null
                          ? const Icon(Icons.person, size: 30, color: primaryColor)
                          : null,
                    ),
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    status,
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Color(0xFF0D47A1)),
                    onPressed: () => _editField('nom', name, (val) => setState(() => name = val)),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section des photos supplémentaires
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: secondaryColor.withOpacity(0.3)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    Container(
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/macon_3.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/chantier_1.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Mes réalisations', 
                style: GoogleFonts.poppins(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: realisations.isEmpty 
                    ? _buildAddPhotoButton()
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...realisations.map((file) => _buildImageItem(file)),
                          _buildAddPhotoButton(),
                        ],
                      ),
              ),

              const SizedBox(height: 24),
              Text('Mes services', style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: primaryColor,
              )),
              const SizedBox(height: 8),
              _buildServiceCard(service1, price1),
              _buildServiceCard(service2, price2),

              // Nouvelle section pour les demandes de devis
              if (devisRequests.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Demandes de devis', 
                  style: GoogleFonts.poppins(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                ...devisRequests.map((devis) => _buildDevisCard(devis)).toList(),
              ],
              
              const SizedBox(height: 24),
              Text('Noter ce professionnel', 
                style: GoogleFonts.poppins(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              _buildRatingBar(),
              const SizedBox(height: 12),
              _buildCommentBox(),

              const SizedBox(height: 24),
              Text('Demandes récentes', 
                style: GoogleFonts.poppins(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text('constrution de chateaux', 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('Client: marie Koumba | Libreville', 
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
                trailing: ElevatedButton(
                  onPressed: () => _repondreClient('crépissage', 'Paul Bongo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Répondre'),
                ),
              ),
              ListTile(
                title: Text('fouille', 
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                subtitle: Text('Client: Alice Nguema | Akanda', 
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
                trailing: ElevatedButton(
                  onPressed: () => _repondreClient('Pose de prises électriques', 'Alice Nguema'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Répondre'),
                ),
              ),

              const SizedBox(height: 24),
              Text('Évaluations clients', style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: primaryColor,
              )),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text('$rating / 5', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  commentaire.isNotEmpty ? commentaire : 'Laisser votre avis sur ce professionnel.',
                  style: GoogleFonts.poppins(),
                ),
              ),

              // Bouton de soumission d'avis
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (commentaire.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Avis soumis avec succès'),
                          backgroundColor: successColor,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez écrire un commentaire'),
                          backgroundColor: dangerColor,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.send),
                  label: const Text('Soumettre mon avis'),
                ),
              ),

              const SizedBox(height: 24),
              Text('Publicité', style: GoogleFonts.poppins(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: primaryColor,
              )),
              const SizedBox(height: 8),
              CarouselSlider(
                options: CarouselOptions(height: 180, autoPlay: true, enlargeCenterPage: true),
                items: imageList.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(item),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}