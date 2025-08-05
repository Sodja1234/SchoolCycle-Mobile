import 'package:odc_mobile_template/business/models/announcement/announcement.dart';

class SearchState {
  final List<Announcement>? searchResults;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const SearchState({
    this.searchResults,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  SearchState copyWith({
    List<Announcement>? searchResults,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}