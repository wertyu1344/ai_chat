import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../controller/controller.dart';
import '../models/notif_model.dart';
import 'notif_widget.dart';
import 'notif_widget_select_model.dart';

class NotificationContent extends StatefulWidget {
  final List<NotifModel> notifications;
  final Function onDelete;
  final bool isDeleteWelcome;
  const NotificationContent({
    super.key,
    required this.notifications,
    required this.onDelete,
    required this.isDeleteWelcome,
  });

  @override
  State<NotificationContent> createState() => _NotificationContentState();
}

class _NotificationContentState extends State<NotificationContent> {
  late List buttonValues;
  final Controller controller = Get.find<Controller>();
  GetIt getIt = GetIt.I;
  bool welcomeNotifButtonValue = false;

  @override
  void initState() {
    buttonValues = List.generate(widget.notifications.length, (index) => false);
    super.initState();
  }

  bool selectAll = false;

  @override
  Widget build(BuildContext context) {
    bool isSelectedAll = !buttonValues.any((element) => element == false) &&
        welcomeNotifButtonValue;
    void fillIsSelected() {
      if (isSelectedAll) {
        buttonValues.fillRange(0, buttonValues.length, false);
        welcomeNotifButtonValue = false;
      } else {
        buttonValues.fillRange(0, buttonValues.length, true);
        welcomeNotifButtonValue = true;
      }
    }

    return Obx(
      () {
        if (!controller.inDeleteModeNotifPage.value) {
          return ListView.builder(
            itemCount: widget.notifications.length + 1,
            padding: const EdgeInsets.only(top: 30),
            itemBuilder: (context, index) {
              if (index == 0) {
                if (!widget.isDeleteWelcome) {
                  return const NotificationWidget(
                      title: "Fallasana'ya Hoşgeldin!",
                      content:
                          "Yapay zeka falcılar seni çok şaşırtacak ve etkileyecek. Hemen istediğin türde falına baktır.",
                      date: "");
                } else {
                  return const SizedBox();
                }
              }
              return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: NotificationWidget(
                      title: widget.notifications[index - 1].title,
                      content: widget.notifications[index - 1].subtitle,
                      date: formatDate(
                          widget.notifications[index - 1].notifDate,
                          [dd, '.', mm, '.', yyyy, ' ', hh, ':', nn])));
            },
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                            onPressed: () {
                              fillIsSelected();

                              setState(() {});
                            },
                            child: Row(
                              children: [
                                const Text(
                                  "Tümünü seç",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  color: Colors.black,
                                  child: Transform.scale(
                                    scale: 1.3,
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: Colors.white, width: 1),
                                      ),
                                      child: Checkbox(
                                        tristate: false,
                                        fillColor:
                                            const MaterialStatePropertyAll(
                                                Colors.transparent),
                                        overlayColor: MaterialStatePropertyAll(
                                            isSelectedAll
                                                ? Colors.white
                                                : Colors.transparent),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        value: isSelectedAll,
                                        onChanged: (value) {
                                          fillIsSelected();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (welcomeNotifButtonValue) {
                              await getIt<Box>()
                                  .put("isDeletedWelcomeNotif", true);
                              welcomeNotifButtonValue = true;
                            }
                            List<String> unwantedNotifs = [];

                            for (var i = 0;
                                i < widget.notifications.length;
                                i++) {
                              if (buttonValues[i]) {
                                unwantedNotifs.add(widget.notifications[i].id);
                              }
                            }
                            List<String>? unwantedNotifications =
                                getIt<Box>().get("unwantedNotifications");

                            if (unwantedNotifications == null) {
                              await getIt<Box>()
                                  .put("unwantedNotifications", unwantedNotifs);
                            } else {
                              unwantedNotifications
                                  .addAll(unwantedNotifs.toSet().toList());
                              await getIt<Box>().put("unwantedNotifications",
                                  unwantedNotifications);
                            }
                            widget.onDelete();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Sil",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.notifications.length + 1,
                  padding: const EdgeInsets.only(top: 30),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      if (!widget.isDeleteWelcome) {
                        return NotificationWidgetSelectModel(
                          index: index,
                          title: "Hoş geldin",
                          content: "Falına bakmaya hemen başla",
                          buttonValue: welcomeNotifButtonValue,
                          onTap: (index) {
                            welcomeNotifButtonValue = !welcomeNotifButtonValue;
                            setState(() {});
                          },
                          date: "",
                        );
                      } else {
                        return SizedBox();
                      }
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: NotificationWidgetSelectModel(
                        index: index - 1,
                        title: widget.notifications[index - 1].title,
                        content: widget.notifications[index - 1].subtitle,
                        date: formatDate(
                            widget.notifications[index - 1].notifDate,
                            [dd, '.', mm, '.', yyyy, ' ', hh, ':', nn]),
                        buttonValue: buttonValues[index - 1],
                        onTap: (gelen) {
                          buttonValues[gelen] = !buttonValues[gelen];
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
