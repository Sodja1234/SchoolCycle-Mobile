import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/annnouncementList/announcementListController.dart';
import 'package:odc_mobile_template/pages/annnouncementList/announcementListState.dart';
import 'package:odc_mobile_template/utils/navigationUtils.dart';

class AnnouncementListPage extends ConsumerStatefulWidget {
  final String? operation_type;

  const AnnouncementListPage({
    Key? key,
    this.operation_type,
  }) : super(key: key);

  @override
  ConsumerState<AnnouncementListPage> createState() => _AnnouncementListPageState();
}

class _AnnouncementListPageState extends ConsumerState<AnnouncementListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'all';
  String _selectedCondition = 'all';
  bool _showFilters = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.operation_type ?? 'all';
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(announcementListControllerProvider.notifier).loadInitialAnnouncements(
        operationTypes: _selectedType != 'all' ? [_selectedType] : null,
        states: _selectedCondition != 'all' ? [_selectedCondition] : null,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final state = ref.read(announcementListControllerProvider);
    if (!state.isLoading && state.hasMore) {
      await ref.read(announcementListControllerProvider.notifier).loadMoreAnnouncements(
        operationTypes: _selectedType != 'all' ? [_selectedType] : null,
        states: _selectedCondition != 'all' ? [_selectedCondition] : null,
      );
    }
  }

  void _onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      ref.read(announcementListControllerProvider.notifier).loadInitialAnnouncements(
        operationTypes: _selectedType != 'all' ? [_selectedType] : null,
        states: _selectedCondition != 'all' ? [_selectedCondition] : null,
      );
    });
  }

  void _refreshData() {
    ref.read(announcementListControllerProvider.notifier).loadInitialAnnouncements(
      operationTypes: _selectedType != 'all' ? [_selectedType] : null,
      states: _selectedCondition != 'all' ? [_selectedCondition] : null,
    );
  }

  var navigation = getIt<NavigationUtils>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementListControllerProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(249, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Liste d'annonces", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => navigation.navigate("/app/home"),
          icon: Icon(Icons.arrow_back),
          color: Colors.orange,
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFiltersPanel(),
          Expanded(
            child: _buildAnnouncementList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementList(AnnoucementListState state) {
    if (state.isLoading && (state.announcements == null || state.announcements!.isEmpty)) {
      return Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    if (state.announcements == null || state.announcements!.isEmpty) {
      return Center(child: Text('Aucune annonce trouvée'));
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.announcements!.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.announcements!.length) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final announcement = state.announcements![index];
          if (announcement == null) {
            return SizedBox(); // Ou un widget vide si l'annonce est null
          }

          return _buildAnnouncementCard(
            announcement: announcement,
            onTap: () {
              if (announcement.id != null) {
                navigation.navigate('/public/detail_announcement/${announcement.id}');
              }
            },
            onFavoriteTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required Announcement announcement,
    required Function() onTap,
    required Function() onFavoriteTap,
  }) {
    var baseUrl = dotenv.env["BASE_URL"] ?? "";
    var imageUrl = baseUrl.endsWith("/api") ? baseUrl.replaceFirst("/api", "/storage/") : baseUrl;
    String? imagePath = announcement.photos?.isNotEmpty == true ? announcement.photos?.first.url : null;
    String fullImageUrl = imagePath != null ? "$imageUrl$imagePath" : "";

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.photos?.isNotEmpty == true)
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        fullImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, size: 50),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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

            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          announcement.title ?? "Titre indisponible",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          announcement.exchange_location_address?.isNotEmpty == true
                              ? (announcement.exchange_location_address!.length > 30
                              ? '${announcement.exchange_location_address!.substring(0, 29)}...'
                              : announcement.exchange_location_address!)
                              : 'Adresse non disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          softWrap: true,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          announcement.price != null
                              ? '${announcement.price} Fc'
                              : 'Gratuit',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          Icon(Icons.search),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.orange),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(horizontal: 10),
      duration: Duration(milliseconds: 300),
      padding: _showFilters ? EdgeInsets.all(16) : EdgeInsets.zero,
      height: _showFilters ? null : 0,
      child: _showFilters ? SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filtrer par:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('all', 'Tous', _selectedType, (v) {
                      setState(() => _selectedType = v);
                      _refreshData();
                    }),
                    _buildFilterChip('sale', 'Vente', _selectedType, (v) {
                      setState(() => _selectedType = v);
                      _refreshData();
                    }),
                    _buildFilterChip('exchange', 'Échange', _selectedType, (v) {
                      setState(() => _selectedType = v);
                      _refreshData();
                    }),
                    _buildFilterChip('don', 'Don', _selectedType, (v) {
                      setState(() => _selectedType = v);
                      _refreshData();
                    }),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('all', 'Tous', _selectedCondition, (v) {
                      setState(() => _selectedCondition = v);
                      _refreshData();
                    }),
                    _buildFilterChip('new', 'Neuf', _selectedCondition, (v) {
                      setState(() => _selectedCondition = v);
                      _refreshData();
                    }),
                    _buildFilterChip('like_new', 'Comme neuf', _selectedCondition, (v) {
                      setState(() => _selectedCondition = v);
                      _refreshData();
                    }),
                    _buildFilterChip('good', 'Bon état', _selectedCondition, (v) {
                      setState(() => _selectedCondition = v);
                      _refreshData();
                    }),
                    _buildFilterChip('damaged', 'Abîmé', _selectedCondition, (v) {
                      setState(() => _selectedCondition = v);
                      _refreshData();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ) : SizedBox(),
    );
  }

  Widget _buildFilterChip(String value, String label, String currentFilter, Function(String) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selectedColor: Colors.orange,
      backgroundColor: Colors.grey[200],
      selected: currentFilter == value,
      onSelected: (_) => onSelected(value),
      labelStyle: TextStyle(
        color: currentFilter == value ? Colors.white : Colors.grey[700],
      ),
    );
  }
}