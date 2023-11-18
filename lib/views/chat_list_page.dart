import 'dart:async';

import 'package:ai_chat/models/ai_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';
import '../services/cloud_firestore_services.dart';
import '../widgets/app_bar_notif_button.dart';
import '../widgets/bot_nav_bar.dart';
import '../widgets/chat_tile.dart';
import '../widgets/main_app_bar.dart';

class ChatListPage extends StatelessWidget {
  final String appBarTitle;
  final String fortuneCategory;
  final int index;
  ChatListPage(
      {required this.appBarTitle,
      Key? key,
      required this.fortuneCategory,
      required this.index})
      : super(key: key);
  final Controller controller = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const MyBotNavBar(),
      body: Column(
        children: [
          MainAppBar(
            title: appBarTitle,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child: Image.asset(
                    "asset/images/diamond.png",
                    width: 50,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.myMessageCredit.string,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
            action: AppBarNotifButton(),
          ),
          Expanded(
              child: FutureBuilder(
                  future: getData(fortuneCategory),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text("Eror"),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (controller.chatList[index] != null) {
                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 16),
                          itemCount: controller.chatList[index]!.length,
                          itemBuilder: (context, i) {
                            return Column(
                              children: [
                                ChatTile(
                                    chatListIndex: index,
                                    listViewIndex: i,
                                    aiModel: controller.chatList[index]![i],
                                    haveLock:
                                        false /*appData.entitlementIsActive == true
                                      ? false
                                      : i == 0
                                          ? false
                                          : true,*/
                                    ),
                              ],
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("Eror"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }
                  }))
        ],
      ),
    );
  }

  Future<List<AiModel?>?> getData(String fortuneCategory) async {
    if (controller.chatList[index]!.isEmpty) {
      print("ai model boş");
      controller.chatList[index] =
          await FirebaseCloudServices().getFortuneTellers(fortuneCategory);
    }

    return controller.chatList[index];
  }
}
