import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';
import '../views/notification_page.dart';

class AppBarNotifButton extends StatelessWidget {
  final Controller controller = Get.find<Controller>();
  AppBarNotifButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          IconButton(
            onPressed: () async {
              controller.numberOfNotif.value = 0;
              if (Platform.isAndroid) {
                FlutterAppBadgeControl.removeBadge();
              } else {
                FlutterAppBadger.removeBadge();
              }
              Get.to(() => const NotificationPage());
            },
            icon: Image.asset(
              "asset/images/notif_icon.png",
              height: 30,
            ),
          ),
          Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Obx(
                    () => Text(
                      controller.numberOfNotif.string,
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))),
        ],
      ),
    );
  }
}
