import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/models/category/category.dart';

class Homestate {
  final bool isLoading;
  final String? errorMessage;
  final List<Announcement>? announcements;
  final List<Announcement>? salesAnnouncements;
  final List<Announcement>? exchangeAnnouncements;
  final List<Announcement>? donationAnnouncements;
  final List<Category>? categories;

  Homestate({
    this.isLoading = false,
    this.errorMessage,
    this.announcements,
    this.categories,
    this.donationAnnouncements,
    this.exchangeAnnouncements,
    this.salesAnnouncements
  });
  
  Homestate copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Announcement>? announcements,
    List<Category>? categories,
    List<Announcement>? salesAnnouncements,
    List<Announcement>? exchangeAnnouncements,
    List<Announcement>? donationAnnouncements
  }) {
    return Homestate(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      announcements: announcements ?? this.announcements,
      salesAnnouncements: salesAnnouncements ?? this.salesAnnouncements,
      donationAnnouncements: donationAnnouncements ?? this.donationAnnouncements,
      exchangeAnnouncements: exchangeAnnouncements ?? this.exchangeAnnouncements,
      categories: categories ?? this.categories,
    );
  }
}