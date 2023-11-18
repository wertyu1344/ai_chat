import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  DateTime lastLoginDate;
  int messageCredit;
  UserModel({
    required this.lastLoginDate,
    required this.messageCredit,
  });
  UserModel.fromJson(Map json)
      : lastLoginDate = DateTime.fromMillisecondsSinceEpoch(
            (json["lastLoginDate"] as Timestamp).millisecondsSinceEpoch),
        messageCredit = json["messageCredit"];
}
