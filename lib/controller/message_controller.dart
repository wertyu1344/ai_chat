import 'package:get/get.dart';

class MessageController extends GetxController {
  int numberOfMessageForRateUs;
  int numberOfMessageForShare;
  int numberOfMessagePerDay;
  int totalRateUs;
  int totalShareUs;
  MessageController.forNoConnection()
      : numberOfMessageForRateUs = 3,
        numberOfMessageForShare = 3,
        totalShareUs = 3,
        totalRateUs = 3,
        numberOfMessagePerDay = 3;
  MessageController(
      {required this.numberOfMessageForRateUs,
      required this.numberOfMessageForShare,
      required this.numberOfMessagePerDay,
      required this.totalRateUs,
      required this.totalShareUs});
  MessageController.fromJson(Map json)
      : numberOfMessageForRateUs = json["numberOfMessageForRateUs"],
        numberOfMessageForShare = json["numberOfMessageForShare"],
        numberOfMessagePerDay = json["numberOfMessagePerDay"],
        totalRateUs = json["totalRateUs"],
        totalShareUs = json["totalShare"];
}
