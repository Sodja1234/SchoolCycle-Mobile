import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:io';

import 'package:path/path.dart';

class CreateAnnouncementWidget {
  // Méthodes pour la gestion des images
  static Future<void> pickImage({
    required ImageSource source,
    required List<File> selectedImages,
    required StateSetter setState,
    int maxImages = 5,
  }) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null && selectedImages.length < maxImages) {
      setState(() {
        selectedImages.add(File(image.path));
      });
    }
  }

  static void removeImage(
    int index,
    List<File> selectedImages,
    StateSetter setState,
  ) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  static void showImagePicker({
    required BuildContext context,
    required List<File> selectedImages,
    required StateSetter setState,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(
                    source: ImageSource.gallery,
                    selectedImages: selectedImages,
                    setState: setState,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(
                    source: ImageSource.camera,
                    selectedImages: selectedImages,
                    setState: setState,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. Méthodes pour construire les widgets
  static Widget buildTypeSelector({
    required List<Map<String, dynamic>> announcementTypes,
    required String selectedType,
    required TextEditingController priceController,
    required void Function(String) onTypeSelected,
  }) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: announcementTypes.length,
        itemBuilder: (context, index) {
          final type = announcementTypes[index];
          final isSelected = selectedType == type['type'];

          return GestureDetector(
            onTap: () {
              onTypeSelected(type['type']);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: type['gradient'] as List<Color>,
                        )
                        : const LinearGradient(
                          colors: [Color(0xFFEEEEEE), Color(0xFFE0E0E0)],
                        ),
                borderRadius: BorderRadius.circular(20),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: (type['gradient'][0] as Color).withOpacity(
                              0.3,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ]
                        : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type['title'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type['subtitle'] as String,
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
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
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator:
            validator ??
            (required
                ? (v) => v!.isEmpty ? 'Ce champ est requis' : null
                : null),
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFFFF6B35), size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }



  static Widget buildMap({
    required LatLng selectedLocation,
    required Function(LatLng) onMapTap,
    required MapController mapController,
    required BuildContext context, // Ajout du contexte
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: selectedLocation,
            initialZoom: 13.0,
            crs: const Epsg3857(),
            onTap: (tapPosition, point) => onMapTap(point),
          ),
          children: [
            TileLayer(
              // Solution 1: OpenStreetMap France (sans authentification)
              urlTemplate:
                  'https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.app',

              // Solution alternative 2: Wikimedia Maps
              // urlTemplate: 'https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png',

              // Gestion des erreurs
              tileBuilder: (context, widget, tile) {
                // Vérification plus robuste des erreurs
                if (tile is TileMode && tile.loadError != null) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  );
                }
                return widget;
              },
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: selectedLocation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildDropdown<T>({
    required T? selectedValue,
    required List<Map<dynamic, dynamic>> items,
    required Function(T?) onChanged,
    required String labelText,
    required IconData prefixIcon,
    String valueKey = 'value',
    String labelKey = 'label',
    String iconKey = 'icon',
    Color primaryColor = const Color(0xFFFF6B35),
    bool isRequired = true,
    EdgeInsetsGeometry? margin,
    String? Function(T?)? validator,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText *' : labelText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(prefixIcon, color: primaryColor, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem<T>(
                value: item[valueKey] as T,
                child: Row(
                  children: [
                    if (item[iconKey] != null)
                      Icon(
                        item[iconKey] as IconData,
                        color: primaryColor,
                        size: 20,
                      ),
                    if (item[iconKey] != null) const SizedBox(width: 12),
                    Text(item[labelKey] as String),
                  ],
                ),
              );
            }).toList(),
        onChanged: onChanged,
        validator:
            validator ??
            (isRequired
                ? (v) => v == null ? 'Veuillez sélectionner $labelText' : null
                : null),
      ),
    );
  }

  static Widget buildLocationSection({
    required BuildContext context,
    required String address,
    required TextEditingController addressController,
    required bool showMap,
    required LatLng selectedLocation,
    required bool isLoadingLocation,
    required MapController mapController,
    required Function() onToggleMap,
    required Function() onGetCurrentLocation,
    required Function(String) onSearchAddress,
    required Function(LatLng) onMapTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Localisation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Bouton pour afficher/masquer la carte
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onToggleMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
                foregroundColor: const Color(0xFFFF6B35),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(showMap ? Icons.map_outlined : Icons.map),
              label: Text(
                showMap ? 'Masquer la carte' : 'Choisir sur la carte',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Carte interactive
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showMap ? 300 : 0,
            child:
                showMap
                    ? buildMap(
                      context: context,
                      selectedLocation: selectedLocation,
                      onMapTap: onMapTap,
                      mapController: mapController,
                    )
                    : const SizedBox.shrink(),
          ),

          if (showMap) const SizedBox(height: 16),

          // Champ adresse
          buildTextFormField(
            controller: addressController,
            label: 'Adresse',
            icon: Icons.location_on,
            validator: (value) {
              onSearchAddress(value ?? '');
              return null;
            },
          ),

          // Coordonnées
          Row(
            children: [
              Expanded(
                child: buildTextFormField(
                  controller: TextEditingController(
                    text: selectedLocation.latitude.toStringAsFixed(6),
                  ),
                  label: 'Latitude',
                  icon: Icons.my_location,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: buildTextFormField(
                  controller: TextEditingController(
                    text: selectedLocation.longitude.toStringAsFixed(6),
                  ),
                  label: 'Longitude',
                  icon: Icons.place,
                  readOnly: true,
                ),
              ),
            ],
          ),

          // Bouton localisation actuelle
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isLoadingLocation ? null : onGetCurrentLocation,
              icon:
                  isLoadingLocation
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF6B35),
                        ),
                      )
                      : const Icon(Icons.gps_fixed),
              label: Text(
                isLoadingLocation
                    ? 'Localisation en cours...'
                    : 'Utiliser ma position actuelle',
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF6B35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildImageSection({
    required List<File> selectedImages,
    required BuildContext context,
    required StateSetter setState,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photos (${selectedImages.length}/5) *',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Bouton d'ajout d'images
                GestureDetector(
                  onTap:
                      () => showImagePicker(
                        context: context,
                        selectedImages: selectedImages,
                        setState: setState,
                      ),
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color:
                          selectedImages.length < 5
                              ? const Color(0xFFFF6B35).withOpacity(0.1)
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color:
                            selectedImages.length < 5
                                ? const Color(0xFFFF6B35).withOpacity(0.3)
                                : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color:
                              selectedImages.length < 5
                                  ? const Color(0xFFFF6B35)
                                  : Colors.grey[400],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajouter',
                          style: TextStyle(
                            color:
                                selectedImages.length < 5
                                    ? const Color(0xFFFF6B35)
                                    : Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Images sélectionnées
                ...selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;

                  return Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap:
                                () => removeImage(
                                  index,
                                  selectedImages,
                                  setState,
                                ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSubmitButton({
    required bool isLoading,
    required VoidCallback onSubmit,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            alignment: Alignment.center,
            child:
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Publier l\'annonce',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  void showImagePickerDialog({
    required BuildContext context,
    required int currentImageCount,
    required void Function(ImageSource source) onPickImage,
    int maxImages = 5,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  if (currentImageCount < maxImages) {
                    onPickImage(ImageSource.gallery);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  if (currentImageCount < maxImages) {
                    onPickImage(ImageSource.camera);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
