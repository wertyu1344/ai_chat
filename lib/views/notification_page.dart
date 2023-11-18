import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../controller/controller.dart';
import '../models/notif_model.dart';
import '../services/cloud_firestore_services.dart';
import '../widgets/bot_nav_bar.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/notif_content.dart';
import 'empty_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GetIt get = GetIt.I;

  final Controller controller = Get.find<Controller>();
  @override
  void initState() {
    controller.inDeleteModeNotifPage.value = false;

    numberOfNotifReset();
    super.initState();
  }

  bool isDeleteWelcome = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const MyBotNavBar(),
      body: Column(
        children: [
          MainAppBar(
              title: "Bildirimler",
              action: SizedBox(
                height: 18,
                child: InkWell(
                    onTap: () {
                      controller.inDeleteModeNotifPage.value =
                          !controller.inDeleteModeNotifPage.value;
                    },
                    child: Obx(() => Image.asset(
                        "asset/images/trash_can${controller.inDeleteModeNotifPage.value ? "_red" : ""}.png",
                        width: 18))),
              )),
          Expanded(
            child: FutureBuilder(
                future: getNotifs(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("eror"),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      if (!isDeleteWelcome) {
                        snapshot.data!.sort(
                          (a, b) => a.notifDate.isAfter(b.notifDate) ? 0 : 1,
                        );
                        return NotificationContent(
                            isDeleteWelcome: isDeleteWelcome,
                            onDelete: () {
                              controller.inDeleteModeNotifPage.value = false;
                              setState(() {});
                            },
                            notifications: snapshot.data!);
                      }
                      if (snapshot.data!.isEmpty) {
                        return const EmptyPage();
                      }
                      snapshot.data!.sort(
                        (a, b) => a.notifDate.isAfter(b.notifDate) ? 0 : 1,
                      );
                      return NotificationContent(
                          isDeleteWelcome: isDeleteWelcome,
                          onDelete: () {
                            controller.inDeleteModeNotifPage.value = false;
                            setState(() {});
                          },
                          notifications: snapshot.data!);
                    } else {
                      return const Center(
                        child: Text("Null"),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  Future<List<NotifModel>?> getNotifs() async {
    List<NotifModel>? notifs =
        await get<FirebaseCloudServices>().getNotifications();
    List<String>? filter = await get<Box>().get("unwantedNotifications");
    DateTime firstDate = await get<Box>().get("firstDate");
    isDeleteWelcome = await get<Box>().get("isDeletedWelcomeNotif");

    List<NotifModel> temp = [];
    if (notifs != null) {
      temp.addAll(
          notifs.where((element) => element.notifDate.isAfter(firstDate)));
      if (filter != null) {
        var filtered = temp
            .where((NotifModel element) => !filter.contains(element.id))
            .toList();
        return filtered;
      } else {
        return temp;
      }
    }

    return null;
  }

  numberOfNotifReset() async {
    await GetIt.I<Box>().put("numberOfNotif", 0);
  }
}
