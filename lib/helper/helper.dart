import 'dart:io';
import 'package:ai_chat/services/cloud_firestore_services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';

import '../controller/controller.dart';
import '../controller/message_controller.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';

class Helper {
  final controller = Get.put(Controller());

  final getIt = GetIt.instance;

  Future getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      controller.deviceId =
          iosDeviceInfo.identifierForVendor ?? "hata"; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      controller.deviceId = androidDeviceInfo.id; // unique ID on Android
    }
  }

  setUp() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // chatGptSetup();
    await GetStorage.init();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseCloudServices().updateTotalDownload();
    // await purchasesSetup();
    await getDeviceId();
    await messageLimitationsSetup();
    getIt.registerSingleton<FirebaseCloudServices>(FirebaseCloudServices());

    chatListSetup();

    //await hiveRegister();
    //await welcomeNotifSetup();
    //await notifLocal();
    //await shareUsRateUsCounter();
    await checkUserCredit();
  }

  checkUserCredit() async {
    MessageController messageController = Get.find<MessageController>();

    if (Platform.isIOS) {
      const storage = FlutterSecureStorage();

      var messageCreditIos = await storage.read(key: "messageCreditIos");
      if (messageCreditIos == null) {
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
        var lastLoginDate = await storage.read(key: "lastLoginIos");
        var user = UserModel(
            lastLoginDate: DateTime.parse(lastLoginDate!),
            messageCredit: int.parse(messageCreditIos));
        controller.user = user;
        controller.myMessageCredit.value =
            messageController.numberOfMessagePerDay;
        if (DateTime.now().difference(user.lastLoginDate).inHours <= 24) {
          controller.myMessageCredit.value = user.messageCredit;
        } else {
          await storage.write(
              key: "messageCreditIos",
              value: messageController.numberOfMessagePerDay.toString());
          await storage.write(
              key: "lastLoginIos", value: DateTime.now().toString());
          controller.myMessageCredit.value =
              messageController.numberOfMessagePerDay;
          controller.user.lastLoginDate = DateTime.now();
        }
      }
    } else {
      UserModel? user =
          await FirebaseCloudServices().getUser(controller.deviceId);

      if (user == null) {
        var userTemp =
            await FirebaseCloudServices().createUser(controller.deviceId);
        if (userTemp != null) {
          controller.user = userTemp;
          controller.myMessageCredit.value;
        }
      } else {
        controller.user = user;
        if (DateTime.now().difference(user.lastLoginDate).inHours <= 24) {
          controller.myMessageCredit.value = user.messageCredit;
        } else {
          //update date and fill credit

          controller.myMessageCredit.value =
              messageController.numberOfMessagePerDay;
          controller.user.lastLoginDate = DateTime.now();
          await FirebaseCloudServices()
              .updateUserLastLoginDateAndCredit(controller.deviceId);
        }
      }
    }
  }

  /* purchasesSetup() async {
    await Purchases.setLogLevel(LogLevel.debug);
    late PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration("goog_nEQzepKFJfuMJdITyWZFktQQcmy");
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration("");
    }
    await Purchases.configure(configuration);
  }*/

/*  wexlcomeNotifSetup() async {
    var firstDate = await getIt<Box>().get("firstDate");
    if (firstDate == null) {
      await getIt<Box>().put("firstDate", DateTime.now());
    }
    bool? isDeletedWelcomeNotif =
        await getIt<Box>().get("isDeletedWelcomeNotif");
    if (isDeletedWelcomeNotif == null) {
      await getIt<Box>().put("isDeletedWelcomeNotif", false);
    }
  }

  notifLocal() async {
    var numberOfNotif = await getIt<Box>().get("numberOfNotif");
    if (numberOfNotif == null) {
      await getIt<Box>().put("numberOfNotif", 1);
      controller.numberOfNotif.value = 1;
    } else {
      controller.numberOfNotif.value = await getIt<Box>().get("numberOfNotif");
    }
  }*/

  chatListSetup() {
    controller.chatList = List.generate(12, (index) => []);
  }

  messageLimitationsSetup() async {
    Map? temp = await FirebaseCloudServices().getMessageController();
    if (temp != null) {
      Get.lazyPut(() => MessageController.fromJson(temp));
    } else {
      Get.lazyPut(() => MessageController.forNoConnection());
    }
  }
}
