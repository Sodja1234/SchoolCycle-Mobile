import 'package:odc_mobile_template/business/models/announcement/announcement.dart';
import 'package:odc_mobile_template/business/models/user/user.dart';

class Report{
  final int user_id;
  final int announcement_id;
  final String motif;
  final String detail;

  Report({
    required this.announcement_id,
    required this.user_id,
    required this.detail,
    required this.motif,
  });

  factory Report.fromJson(json) => Report(
    user_id: json['user_id'],
    announcement_id: json['announcement_id'],
    detail: json['detail'],
    motif: json['motif'],

  );

  Map<String, dynamic> toJson() => {
    'user_id' : user_id,
    'announcement_id' :announcement_id,
    'motif' : motif,
    'detail' : detail,
  };
}