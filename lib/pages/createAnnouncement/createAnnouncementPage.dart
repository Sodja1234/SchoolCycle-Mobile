import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:odc_mobile_template/business/models/announcement/createAnnouncement.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/login/loginCtrl.dart';
import 'package:odc_mobile_template/pages/createAnnouncement/createAnnouncementController.dart';

import 'package:odc_mobile_template/pages/createAnnouncement/createAnnouncementWidget.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';

class CreateAnnouncementPage extends ConsumerStatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState
    extends ConsumerState<CreateAnnouncementPage> {
  late MapController _mapController;
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  // Variables d'état
  String _selectedType =
      'sale'; // Type d'annonce sélectionné (vente, échange, don)
  String? _selectedCategory; // Catégorie sélectionnée
  List<File> _selectedImages = []; // Liste des images sélectionnées
  final ImagePicker _picker = ImagePicker(); // Pour la sélection d'images
  bool _isLoading = false; // Indicateur de chargement global
  bool _showMap = false; // Affichage de la carte
  String? _selectedState;
  // Variables pour la carte
  LatLng _selectedLocation = LatLng(
    -2.8797,
    23.6560,
  ); // Position par défaut (Kinshasa)
  LatLng _currentLocation = LatLng(
    -2.8797,
    -23.6560,
  ); // Position actuelle de l'utilisateur
  bool _isLoadingLocation =
      false; // Indicateur de chargement pour la localisation

  // Types d'annonces disponibles
  final List<Map<String, dynamic>> _announcementTypes = [
    {
      'type': 'sale',
      'title': 'Vente',
      'subtitle': 'Vendez vos fournitures',
      'icon': Icons.sell_rounded,
      'gradient': [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    },
    {
      'type': 'exchange',
      'title': 'Échange',
      'subtitle': 'Échangez sans argent',
      'icon': Icons.swap_horiz_rounded,
      'gradient': [Color(0xFF2196F3), Color(0xFF42A5F5)],
    },
    {
      'type': 'don',
      'title': 'Don',
      'subtitle': 'Offrez gratuitement',
      'icon': Icons.favorite_rounded,
      'gradient': [Color(0xFFFF9800), Color(0xFFFFB74D)],
    },
  ];

  static final List<Map<String, dynamic>> states = [
    {'value': 'new', 'label': 'Neuf', 'icon': Icons.new_releases_rounded},
    {'value': 'like new', 'label': 'Comme neuf', 'icon': Icons.star_rounded},
    {'value': 'good', 'label': 'Bon état', 'icon': Icons.thumb_up_rounded},
    {'value': 'damaged', 'label': 'Abîmé', 'icon': Icons.warning_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Initialisation du contrôleur de carte

    // Initialiser avec Kinshasa par défaut
    Future.delayed(Duration(milliseconds: 100), () {
      _initializeKinshasaLocation();
    });
  }

  void _initializeKinshasaLocation() {
    // Définir les coordonnées de Kinshasa
    setState(() {
      _selectedLocation = LatLng(-2.8797, 23.6560);
      _latitudeController.text = "-4.3252";
      _longitudeController.text = "15.3303";
    });

    // Rechercher l'adresse pour ces coordonnées
  }

  @override
  void dispose() {
    // Nettoyage des contrôleurs et animations
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        // Construction de l'adresse à partir des composants
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          if (address.isNotEmpty) address += ' ';
          address += place.postalCode!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      print('Erreur géocodage inverse: $e');
    }
  }

  /**
   * Construit le sélecteur de catégorie
   * @return Un widget DropdownButtonFormField personnalisé
   */
  Widget _buildCategorySelector({
    required List<Map<dynamic, dynamic>> categories,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Catégorie *',
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.category_rounded,
              color: Color(0xFFFF6B35),
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items:
            categories.map<DropdownMenuItem<String>>((category) {
              return DropdownMenuItem<String>(
                value: category['id']?.toString() ?? '', // Gestion du null
                child: Text(
                  category['name'] ?? 'Catégorie inconnue',
                ), // Gestion du null
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Veuillez sélectionner une catégorie'
                    : null,
      ),
    );
  }

  /**
   * Affiche un message d'erreur sous forme de SnackBar
   * @param message Le message d'erreur à afficher
   */
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleMapVisibility() {
    setState(() => _showMap = !_showMap);
  }

  var navigation = getIt<NavigationUtils>();

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(createAnnouncementProvider);
    var ctrl = ref.read(createAnnouncementProvider.notifier);
    var userLocal = ref.watch(LoginCtrlProvider);

    var categories = state.categories;
    var categoriesJson =
        categories?.map((category) => category.toJson()).toList();
    // print(categoriesJson);

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: Color(0xFFFF6B35)),
        ),
        title: Text(
          'Créer une annonce',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFFFF6B35),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),

              // Section titre
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type d\'annonce',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Choisissez le type d\'annonce que vous souhaitez créer',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // choix du type d'annonce
              CreateAnnouncementWidget.buildTypeSelector(
                announcementTypes: _announcementTypes,
                selectedType: _selectedType,
                priceController: _priceController,
                onTypeSelected: (type) {
                  setState(() {
                    _selectedType = type;
                    if (_selectedType != 'sale') {
                      _priceController.clear();
                    }
                  });
                },
              ),

              SizedBox(height: 32),

              // Section informations
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Informations',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: 16),

              CreateAnnouncementWidget.buildTextFormField(
                controller: _titleController,
                label: 'Titre',
                icon: Icons.title_rounded,
                hint: 'Ex: Pack de stylos neufs',
                validator:
                    (v) => v!.isEmpty ? 'Le titre est obligatoire' : null,
              ),

              CreateAnnouncementWidget.buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description_rounded,
                hint: 'Décrivez votre article en détail...',
                maxLines: 4,
                validator:
                    (v) => v!.isEmpty ? 'La description est obligatoire' : null,
              ),

              // Champ prix conditionnel
              if (_selectedType == 'sale')
                CreateAnnouncementWidget.buildTextFormField(
                  controller: _priceController,
                  label: 'Prix',
                  icon: Icons.euro_rounded,
                  hint: 'Ex: 15.50',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator:
                      (v) => v!.isEmpty ? 'Le prix est obligatoire' : null,
                ),
              _buildCategorySelector(categories: categoriesJson ?? []),
              SizedBox(height: 16),

              CreateAnnouncementWidget.buildDropdown(
                selectedValue: _selectedState,
                items: states,
                onChanged: (v) => setState(() => _selectedState = v),
                labelText: 'État de la fourniture',
                prefixIcon: Icons.category,
              ),

              SizedBox(height: 32),

              // Section localisation avec carte
              CreateAnnouncementWidget.buildLocationSection(
                context: context,
                showMap: _showMap,
                selectedLocation: _selectedLocation,
                addressController: _addressController,
                mapController: _mapController,
                isLoadingLocation: _isLoadingLocation,
                address: _addressController.text,
                onToggleMap: _toggleMapVisibility,
                onSearchAddress: ctrl.searchAddress,
                onGetCurrentLocation: ctrl.getCurrentLocation,
                onMapTap: (point) {
                  setState(() {
                    _selectedLocation = point;
                    _latitudeController.text = point.latitude.toStringAsFixed(
                      6,
                    );
                    _longitudeController.text = point.longitude.toStringAsFixed(
                      6,
                    );
                  });
                  _getAddressFromCoordinates(point);
                },
              ),

              SizedBox(height: 32),

              // Section photos
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              SizedBox(height: 16),
              // les images sélectionnées
              CreateAnnouncementWidget.buildImageSection(
                context: context,
                selectedImages: _selectedImages,
                setState: setState,
              ),

              SizedBox(height: 32),

              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 56,
                child:
                    (state.isLoading ?? false)
                        ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                        : ElevatedButton(
                          onPressed: () async {

                            if (_formKey.currentState!.validate()) {
                              var ctrl = ref.read(
                                createAnnouncementProvider.notifier,
                              );

                              if (_selectedImages.isEmpty) {
                                _showErrorSnackBar(
                                  'Veuillez ajouter au moins une photo',
                                );
                                return;
                              }

                              print(_selectedState);

                              var data = CreateAnnouncement(
                                title: _titleController.text,
                                description: _descriptionController.text,
                                operationType: _selectedType,
                                state: _selectedState ?? '',
                                exchangeLocationAddress:
                                    _addressController.text,
                                price:
                                    _priceController.text.isNotEmpty
                                        ? int.tryParse(_priceController.text)
                                        : null,
                                exchangeLocationLat: double.parse(
                                  _latitudeController.text,
                                ),
                                exchangeLocationLng: double.parse(
                                  _longitudeController.text,
                                ),
                                categoryId:
                                    int.tryParse(_selectedCategory!) ?? 0,
                                created_by: userLocal.user!.id ?? 0,
                                photos:
                                    _selectedImages
                                        .map((file) => file.path)
                                        .toList(),
                              );
                              var res = await ctrl.createAnnouncement(
                                data,
                                userLocal.user != null
                                    ? userLocal.user!.token!
                                    : '',
                              );
                              if (res) {
                                _showSuccessSnackBar(
                                  'Annonce publiée avec succès !',
                                );
                                Future.delayed(Duration(seconds: 3));
                                navigation.replace("/public/announcementList");
                              } else {
                                _showErrorSnackBar(
                                  "Annonce non publié, une erreur est survenue",
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFFF6B35,
                            ), // Couleur de base
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text('Publier l\'annonce'),
                        ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
