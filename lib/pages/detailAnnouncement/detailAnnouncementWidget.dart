import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/pages/home/homeWidget.dart';
import 'package:path/path.dart';

class DetailAnnouncementWidget {



  static Widget imageGallery(
    Announcement announcement,
    int selectedImageIndex,
    Function(int) onImageSelected,
    bool isFavorite,
    Function() onFavoriteTap,
  ) {
    // URL de base pour les images, récupérée depuis les variables d'environnement
    var baseUrl = dotenv.env["BASE_URL"] ?? "";
    var imageUrl =
        baseUrl.endsWith("/api")
            ? baseUrl.replaceFirst("/api", "/storage/")
            : baseUrl;

    var imagesLength = announcement.photos!.length;

    return Container(
      height: 400,
      child: Column(
        children: [
          // Grande image principale
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        announcement.photos != null &&
                                announcement.photos!.isNotEmpty
                            ? Image.network(
                              "$imageUrl${announcement.photos![selectedImageIndex].url}",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Color(0xFFFF6B35).withOpacity(0.1),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_rounded,
                                      color: Color(0xFFFF6B35),
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.image, size: 50),
                            ),
                  ),
                  // Badge du type d'annonce
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9000),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Bouton favori
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        padding: EdgeInsets.all(10),
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
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Indicateur d'image
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '${selectedImageIndex + 1}/$imagesLength',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Miniatures
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: announcement.photos!.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedImageIndex;
                return GestureDetector(
                  onTap: () {
                    onImageSelected(index);
                    HapticFeedback.selectionClick();
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Color(0xFFFF6B35) : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Color(0xFFFF6B35).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ]
                              : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "$imageUrl${announcement.photos![index].url.startsWith('/') ? announcement.photos![index].url.substring(1) : announcement.photos![index].url}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la section d'informations principales de l'annonce contenant :
  /// - Titre
  /// - Prix/Type d'opération
  /// - Catégorie et date
  /// - Description
  static Widget infoSection(Announcement announcement) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et prix
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  announcement.title!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9B35), Color(0xFFFF9000)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  announcement.operation_type == 'sale'
                      ? '${announcement.price} Fc'
                      : announcement.operation_type == 'exchange'
                      ? 'Échange'
                      : 'Gratuit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Informations rapides
          Row(
            children: [
              // categorie
              Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${announcement.category?.name}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${announcement.created_at}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20,),

          Row(
            children:[
              Icon(Icons.location_on_outlined, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                // Prend tout l'espace disponible
                child: Text(
                  "${announcement.exchange_location_address}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  softWrap: true, // Retour à la ligne
                  maxLines: 3, // Limite optionnelle
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Description
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            announcement.description!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la section du propriétaire contenant :
  /// - Avatar
  /// - Nom
  /// - Bouton "Voir profil"
  static Widget ownerSection(Announcement announcement) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              ),
            ),
            child: ClipOval(
              child: Image.network(
                announcement.created_by!.name!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      announcement.created_by!.name!
                          .split(' ')
                          .map((e) => e[0])
                          .join(''),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(width: 16),

          // Informations du propriétaire
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.created_by!.name!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 4),
              ],
            ),
          ),

          // Bouton voir profil
          GestureDetector(
            onTap: () {
              print('Voir le profil');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Voir profil',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la section des boutons d'action contenant :
  /// - Bouton "Envoyer un message" (principal)
  /// - Bouton "Partager"
  /// - Bouton "Signaler cette annonce"
  static Widget buildActionButtons(
    BuildContext context,
    Function() onMessageTap,
    Function() onShareTap,
    Function() onReportTap,
  ) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          // Boutons principaux
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onMessageTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7300), Color(0xFFFF9000)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(vertical: 12),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Envoyer un message',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Bouton partager
              Container(
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
                child: IconButton(
                  onPressed: onShareTap,
                  icon: Icon(Icons.share_rounded, color: Color(0xFFFF9000)),
                  iconSize: 24,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Bouton signaler
          TextButton.icon(
            onPressed: onReportTap,
            icon: Icon(Icons.flag_rounded, color: const Color(0xFFFF9000), size: 20),
            label: Text(
              'Signaler cette annonce',
              style: TextStyle(
                color: const Color(0xFFFF9000),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // la section des annonces similaires
  static Widget buildSimilarAnnouncements(
    List<Announcement> similarAnnouncements,
    BuildContext context,
    Function(int) onAnnouncementTap,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Annonces similaires',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          // Condition pour afficher soit la liste soit un message
          if (similarAnnouncements.isEmpty)
            // Message quand aucune annonce similaire n'est trouvée
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Aucune annonce similaire trouvée',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            )
          else
            // Liste des annonces similaires (si non vide)
            Container(
              height: 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similarAnnouncements.length,
                itemBuilder: (context, index) {

                  double screenWidth = MediaQuery.of(context).size.width;
                  double cardWidth = screenWidth * 0.9;
                  double horizontalPadding = (screenWidth - cardWidth) / 2;

                  final announcement = similarAnnouncements[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: cardWidth,
                      margin: EdgeInsets.only(right: 5),
                      child: HomeWidgets.announcementCard(
                        announcement: announcement,
                        onTap: () {
                          onAnnouncementTap(
                            announcement.id,
                          );
                        },
                        onFavoriteTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // le message
  static void showMessageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Envoyer un message',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      decoration: InputDecoration(
                        hintText: 'Tapez votre message ici...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Color(0xFFFF6B35)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Message envoyé !'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDF6C0E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Envoyer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // message de signalement
  static void showReportDialog(BuildContext context) {
    final TextEditingController _reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Signaler cette annonce'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Merci de préciser la raison du signalement :'),
                SizedBox(height: 16),
                TextField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Décrivez le problème...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_reasonController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez saisir une raison')),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  _submitReport(context, _reasonController.text);
                },
                child: Text('Envoyer'),
              ),
            ],
          ),
    );
  }

  static void _submitReport(BuildContext context, String reason) {
    // Implémentez l'envoi du signalement ici
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Signalement envoyé avec succès')));
  }
}
