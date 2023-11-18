import 'package:cloud_firestore/cloud_firestore.dart';

class NotifModel {
  final String id;
  final String subtitle;
  final String title;
  final DateTime notifDate;

  NotifModel(
      {required this.id,
      required this.subtitle,
      required this.title,
      required this.notifDate});
  static NotifModel fromJson(Map json) {
    return NotifModel(
        id: json["id"],
        subtitle: json["subtitle"],
        title: json["title"],
        notifDate: DateTime.fromMillisecondsSinceEpoch(
            (json["datetime"] as Timestamp).millisecondsSinceEpoch));
  }

  Map toJSon() {
    final Map json = {};
    json["id"] = id;
    json["subtitle"] = subtitle;

    json["title"] = title;
    json["datetime"] = notifDate;
    return json;
  }
}
