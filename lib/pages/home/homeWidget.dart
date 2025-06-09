import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:path/path.dart';

class HomeWidgets {
  // Widget d’un élément de la barre de navigation inférieure
  static Widget navbarItem({
    required int index,
    required int selectedIndex,
    required Map<String, dynamic> item,
    required Function(int) onTap,
  }) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: double.infinity,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Color(0xFFFF6B35).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item['icon'],
                  color: isSelected ? Color(0xFFFF6B35) : Colors.grey[600],
                  size: 24,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item['label'],
                style: TextStyle(
                  color: isSelected ? Color(0xFFFF6B35) : Colors.grey[600],
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construit la section principale du carrousel (bannières)
  static Widget buildHeroSection({
    required List<Map<String, dynamic>> slides,
    required PageController pageController,
    required Function(int) onPageChanged,
  }) {
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PageView.builder(
        controller: pageController,
        itemCount: slides.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          final slide = slides[index];
          return _buildSlide(slide);
        },
      ),
    );
  }

  // Construit chaque diapositive du carrousel
  static Widget _buildSlide(Map<String, dynamic> slide) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: slide['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: slide['gradient'][0].withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        // Cercle décoratif en arrière-plan
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
           // Contenu principal de la diapositive
          Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(slide['icon'], color: Colors.white, size: 40),
                SizedBox(height: 16),
                Text(
                  slide['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  slide['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Petits points pour indiquer la position actuelle dans le carrousel
  static Widget buildSliderIndicator({
    required int currentPage,
    required int slideCount,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          slideCount,
          (index) => Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  currentPage == index
                      ? Color(0xFFFF6B35)
                      : Color(0xFFFF6B35).withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  // Barre de recherche avec champ de texte, icône de recherche et filtre
  static Widget buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.search_outlined,
              color: Color(0xFFFF6B35),
              size: 24,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher des fournitures...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune_rounded, color: Color(0xFFFF6B35), size: 20),
          ),
        ],
      ),
    );
  }

  // Carte affichant une catégorie (ex: Livres, Stylos, etc.)
  static Widget categoryCard({
    required Map<String, dynamic> category,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: category['gradient'],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: category['gradient'][0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(category['icon'], color: Colors.white, size: 32),
            ),
            SizedBox(height: 8),
            Text(
              category['label'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carte affichant une annonce
  static Widget announcementCard({
    required Announcement announcement,
    required Function() onTap,
    required Function() onFavoriteTap,
  }) {
    // URL de base pour les images, récupérée depuis les variables d'environnement
    var baseUrl = dotenv.env["BASE_URL"] ?? "";
    // Supprimer /api et le remplacer par /storage/
    var imageUrl = baseUrl.endsWith("/api") ? baseUrl.replaceFirst("/api", "/storage/") : baseUrl;
    // recuperer la première image
    String? imagePath = announcement.photos?.first['url'];
    String fullImageUrl = imagePath != null ? "$imageUrl$imagePath" : "";
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFFFF6B35).withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Color(0xFFFF6B35),
                                size: 40,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF6B35),
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(announcement.operation_type),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        announcement.operation_type == "sale"
                            ? "Vente"
                            : announcement.operation_type == "exchange"
                            ? "Échange"
                            : announcement.operation_type == "don"
                            ? "Don"
                            : "Autre",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.red[400],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      announcement.title != null
                          ? (announcement.title!.length > 17
                              ? '${announcement.title!.substring(0, 15)}...'
                              : announcement.title!)
                          : "Titre indisponible",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.grey[500],
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Rue de l'école",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      announcement.price != null
                          ? "${announcement.price}Fc"
                          : "Gratuit",
                      style: TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // La methode pour afficher les couleurs de type d'operation
  static Color _getTypeColor(String? type) {
    switch (type) {
      case "sale":
        return Color(0xFF4CAF50);
      case "exchange":
        return Color(0xFF2196F3);
      case "donation":
        return Color(0xFFFF9800);
      default:
        return Color(0xFF9E9E9E);
    }
  }

  // le des sections  qui prend en parametre le titre, le sous-titre et
  static Widget titreSection({
    required String title,
    required String subtitle,
    Function()? onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
