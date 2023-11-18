import 'dart:async';
import 'dart:io';

import 'package:ai_chat/views/subject_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';
import '../controller/message_controller.dart';
import '../models/user_model.dart';
import '../services/cloud_firestore_services.dart';
import '../widgets/bot_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List pageList = [
    const SubjectPage(),
    const SubjectPage(),
    const SubjectPage(),
  ];
  Timer? timer;
  final storage = FlutterSecureStorage();
  late Duration duration;
  @override
  void initState() {
    //initPlatformState();
    duration = controller.user.lastLoginDate
        .add(const Duration(days: 1))
        .difference(DateTime.now());

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await fill();
      duration = controller.user.lastLoginDate
          .add(const Duration(days: 1))
          .difference(DateTime.now());
    });
    super.initState();
  }

  fill() async {
    MessageController messageController = Get.find<MessageController>();

    if (duration.isNegative || duration.inSeconds == 0) {
      controller.user.lastLoginDate = DateTime.now();
      if (Platform.isIOS) {
        await storage.write(
            key: "messageCreditIos",
            value: messageController.numberOfMessagePerDay.toString());
        await storage.write(
            key: "lastLoginIos", value: DateTime.now().toString());
        controller.user = UserModel(
            lastLoginDate: DateTime.now(),
            messageCredit: messageController.numberOfMessagePerDay);
        controller.myMessageCredit.value =
            messageController.numberOfMessagePerDay;
      } else {
        await FirebaseCloudServices()
            .updateUserLastLoginDateAndCredit(controller.deviceId);
        controller.myMessageCredit.value =
            messageController.numberOfMessagePerDay;
        controller.user.lastLoginDate = DateTime.now();
      }
    } else {}
  }

  /*Future<void> initPlatformState() async {
    appData.appUserID = await Purchases.appUserID;
    controller.userId.value = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      appData.appUserID = await Purchases.appUserID;
      controller.userId.value = await Purchases.appUserID;

      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementID];
      appData.entitlementIsActive = entitlement?.isActive ?? false;
      controller.isPremiumActive.value = entitlement?.isActive ?? false;
      setState(() {});
    });
  }*/

  final Controller controller = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: const Text(
              "Elevanlabs | Chat Gbt",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: pageList[controller.botNavBarIndex.value],
          bottomNavigationBar: const MyBotNavBar()),
    );
  }
}
