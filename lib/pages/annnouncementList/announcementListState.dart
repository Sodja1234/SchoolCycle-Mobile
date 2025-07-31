import 'package:odc_mobile_template/business/models/announcement/announcement.dart';

class AnnoucementListState{
  final List<Announcement>? announcements;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  AnnoucementListState({
    this.announcements,
    this.isLoading = false,
    this.error,
    this.page = 0,
    this.hasMore = true
  });

  AnnoucementListState copyWith({
    List<Announcement>? announcements,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return AnnoucementListState(
      announcements: announcements ?? this.announcements,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}