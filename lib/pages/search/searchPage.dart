import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';
import 'package:odc_mobile_template/pages/search/searchController.dart';
import 'package:odc_mobile_template/pages/search/searchState.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  var navigation = getIt<NavigationUtils>();

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        ref.read(searchControllerProvider.notifier).searchAnnouncement(query);
      } else {
        ref.read(searchControllerProvider.notifier).clearResults();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchControllerProvider.notifier).clearResults();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(249, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Recherche d'annonces",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildSearchResults(state)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.grey[200]!, // Bordure subtile
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Rechercher une annonce...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.orange),
              onPressed: _clearSearch,
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Erreur: ${state.error}'));
    }

    if (state.searchQuery.isEmpty) {
      return const Center(
        child: Text(
          'Entrez un terme de recherche',
          style: TextStyle(color: Colors.orange, fontSize: 17),
        ),
      );
    }

    if (state.searchResults?.isEmpty ?? true) {
      return Center(
        child: Text(
          'Aucun résultat pour "${state.searchQuery}"',
          style: const TextStyle(color: Colors.orange, fontSize: 17),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.searchResults!.length,
      itemBuilder: (context, index) {
        final announcement = state.searchResults![index];
        return announcementCard(
          announcement: announcement,
          onTap: () {
            if (announcement.id != null) {
              navigation.navigate(
                '/public/detail_announcement/${announcement.id}',
              );
            }
          },
          onFavoriteTap: () {},
        );
      },
    );
  }

  static Widget announcementCard({
    required Announcement announcement,
    required Function() onTap,
    required Function() onFavoriteTap,
  }) {
    // Gestion de l'URL de l'image
    final baseUrl = dotenv.env["BASE_URL"] ?? "";
    final imageUrl =
        baseUrl.endsWith("/api")
            ? baseUrl.replaceFirst("/api", "/storage/")
            : baseUrl;
    final imagePath =
        announcement.photos?.isNotEmpty == true
            ? announcement.photos?.first.url
            : null;
    final fullImageUrl = imagePath != null ? "$imageUrl$imagePath" : "";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          maxWidth: 500,
        ), // Empêche l'élargissement excessif
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[200]!, // Bordure subtile
            width: 2,
          ),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Partie Image (60% de la carte)
            SizedBox(
              height: 180, // Hauteur fixe pour l'image
              child: Stack(
                children: [
                  // Image principale
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildNetworkImage(fullImageUrl),
                  ),

                  // Badge de type
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildTypeBadge(announcement.operation_type),
                  ),

                  // Bouton favori
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _buildFavoriteButton(onFavoriteTap),
                  ),
                ],
              ),
            ),

            // Partie Texte (40% de la carte)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre (avec gestion du overflow)
                  Text(
                    announcement.title ?? "Titre indisponible",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Localisation
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          announcement.exchange_location_address ??
                              "Emplacement inconnu",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Prix
                  Text(
                    announcement.price != null
                        ? "${announcement.price}Fc"
                        : "Gratuit",
                    style: TextStyle(
                      color: const Color(0xFFFF6B35),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour l'image avec gestion d'erreur et loading
  static Widget _buildNetworkImage(String imageUrl) {
    return imageUrl.isNotEmpty
        ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder:
              (context, error, stackTrace) => _buildImageErrorWidget(),
          loadingBuilder:
              (context, child, loadingProgress) =>
                  loadingProgress == null ? child : _buildImageLoadingWidget(),
        )
        : _buildImageErrorWidget();
  }

  static Widget _buildImageErrorWidget() {
    return Container(
      color: const Color(0xFFFF6B35).withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          color: Color(0xFFFF6B35),
          size: 40,
        ),
      ),
    );
  }

  static Widget _buildImageLoadingWidget() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B35),
          strokeWidth: 2,
        ),
      ),
    );
  }

  // Widget pour le badge de type
  static Widget _buildTypeBadge(String? operationType) {
    final (text, color) = _getTypeInfo(operationType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Widget pour le bouton favori
  static Widget _buildFavoriteButton(Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.favorite_border, color: Colors.red, size: 18),
      ),
    );
  }

  // Helper pour les infos de type
  static (String text, Color color) _getTypeInfo(String? type) {
    return switch (type) {
      "sale" => ("Vente", Colors.orange),
      "exchange" => ("Échange", Colors.orange),
      "don" => ("Don", Colors.orange),
      _ => ("Autre", Colors.orange),
    };
  }
}
