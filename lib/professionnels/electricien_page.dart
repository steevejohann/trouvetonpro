import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import pour détecter la plateforme web
import 'package:universal_io/io.dart' as io; // Import multiplateforme

class ProfessionalPage extends StatefulWidget {
  const ProfessionalPage({super.key});

  @override
  State<ProfessionalPage> createState() => _ProfessionalPageState();
}

class _ProfessionalPageState extends State<ProfessionalPage> {
  List<String> imageList = [
    'assets/images/batiplus_1.jpeg',
    'assets/images/sogametec_1.jpeg',
    'assets/images/entreprise_1.jpeg',
    'assets/images/sogametec_2.jpeg',
  ];

  List<File> realisations = [];
  final picker = ImagePicker();

  String name = 'Jean Dupont | N°074481520 ';
  String status = 'Électricien | Libre aujourd\'hui | localisation: Akanda';
  String service1 = 'Installation électrique complète';
  String price1 = '80 000 FCFA';
  String service2 = 'Réparation d\'urgence';
  String price2 = '30 000 FCFA';
  double rating = 0;
  double averageRating = 3.7;
  List<double> allRatings = [];
  Position? currentPosition;
  String commentaire = '';

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

  void _editField(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
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
        title: Text("Répondre à $client"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Message de réponse",
            hintText: "Votre message...",
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              String message = controller.text.trim();
              Navigator.pop(context);
              if (message.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message envoyé à $client : "$message"')),
                );
              }
            },
            child: const Text('Envoyer'),
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
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
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
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnexion réussie')),
              );
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
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
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compte supprimé avec succès')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes réalisations', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
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
      ],
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
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 30, color: Colors.black54),
            SizedBox(height: 8),
            Text('Ajouter', style: TextStyle(color: Colors.black54)),
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDeleteAccount,
            tooltip: 'Supprimer le compte',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bienvenue, M. $name',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (currentPosition != null)
              Text(
                'Position actuelle: (${currentPosition!.latitude}, ${currentPosition!.longitude})',
                style: GoogleFonts.poppins(fontSize: 14, fontStyle: FontStyle.italic),
              ),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/electricien_ 1.jpg'),
                ),
                title: Text(name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text(status, style: GoogleFonts.poppins()),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editField('nom', name, (val) => setState(() => name = val)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section des réalisations avec la nouvelle structure
            _buildRealisationsSection(),

            const SizedBox(height: 24),
            Text('Mes services', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: Text(service1, style: GoogleFonts.poppins()),
              subtitle: Text('Prix : $price1', style: GoogleFonts.poppins()),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editField('service', service1, (val) => setState(() => service1 = val)),
              ),
            ),
            ListTile(
              title: Text(service2, style: GoogleFonts.poppins()),
              subtitle: Text('Prix : $price2', style: GoogleFonts.poppins()),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editField('service', service2, (val) => setState(() => service2 = val)),
              ),
            ),

            const SizedBox(height: 24),
            Text('Noter ce professionnel', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildRatingBar(),
            const SizedBox(height: 12),
            _buildCommentBox(),

            const SizedBox(height: 24),
            Text('Demandes récentes', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: Text('Branchement défectueux à réparer', style: GoogleFonts.poppins()),
              subtitle: Text('Client: Paul Bongo | Libreville', style: GoogleFonts.poppins()),
              trailing: ElevatedButton(
                onPressed: () => _repondreClient('Branchement défectueux', 'Paul Bongo'),
                child: const Text('Répondre'),
              ),
            ),
            ListTile(
              title: Text('Pose de prises électriques', style: GoogleFonts.poppins()),
              subtitle: Text('Client: Alice Nguema | Akanda', style: GoogleFonts.poppins()),
              trailing: ElevatedButton(
                onPressed: () => _repondreClient('Pose de prises électriques', 'Alice Nguema'),
                child: const Text('Répondre'),
              ),
            ),

            const SizedBox(height: 24),
            Text('Évaluations clients', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text('$rating / 5', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              subtitle: Text(
                commentaire.isNotEmpty ? commentaire : 'Laisser votre avis sur ce professionnel.',
                style: GoogleFonts.poppins(),
              ),
            ),

            const SizedBox(height: 24),
            Text('Publicité', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
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
    );
  }
}