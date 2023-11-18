import 'dart:async';

import 'package:ai_chat/elevanlabs.dart';
import 'package:ai_chat/views/talk_ai_page.dart';
import 'package:ai_chat/main.dart';
import 'package:ai_chat/models/ai_model.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../controller/controller.dart';
import '../services/cloud_firestore_services.dart';
import '../services/storage_services.dart';
import '../views/talk_ai_page2.dart';
import '../views/talk_ai_page3.dart';

class ChatTile extends StatefulWidget {
  final AiModel aiModel;
  final bool haveLock;
  final int chatListIndex;
  final int listViewIndex;

  final Controller controller = Get.find<Controller>();

  ChatTile(
      {required this.haveLock,
      Key? key,
      required this.aiModel,
      required this.chatListIndex,
      required this.listViewIndex})
      : super(key: key);

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  late bool isLiked;

  @override
  void initState() {
    var isLikedStorage = box.read("${widget.aiModel.id}_isLiked") ?? false;
    isLiked = isLikedStorage;
    super.initState();
  }

  GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16, bottom: 16),
      child: Row(
        children: [
          Stack(alignment: Alignment.topRight, children: [
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(230, 175, 47, 1),
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Ink(
                  child: InkWell(
                    onTap: () async {
                      Get.to(() => Elevanlabs(
                            aiModel: widget.aiModel,
                          ));

                      /*  if (!widget.haveLock) {
                        Get.to(() => ChatPage(
                          fortuneTeller: widget.fortuneTeller,
                        ));
                      } else {
                        Offerings? offerings;
                        try {
                          offerings = await Purchases.getOfferings();
                        } on PlatformException {}

                        setState(() {});

                        if (offerings == null || offerings.current == null) {
                          // offerings are empty, show a message to your user
                        } else {
                          // current offering is available, show paywall
                          Get.to(() =>
                              PremiumBuyPage(isComingFromLockedFortuneTeller: true, offering: offerings!.current!));
                        }
                      }*/
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget
                                  .controller
                                  .chatList[widget.chatListIndex]![
                                      widget.listViewIndex]
                                  .image ==
                              null
                          ? FutureBuilder(
                              future: getFortuneTellerImage(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Image.asset(
                                    "asset/images/test.webp",
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.data != null) {
                                    return Image.memory(
                                      widget
                                          .controller
                                          .chatList[widget.chatListIndex]![
                                              widget.listViewIndex]
                                          .image!,
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Image.asset(
                                      "asset/images/test.webp",
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                } else {
                                  return Container(
                                    color: Colors.grey,
                                    width: 110,
                                    height: 110,
                                    child: const Align(
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            )
                          : Image.memory(
                              widget
                                  .controller
                                  .chatList[widget.chatListIndex]![
                                      widget.listViewIndex]
                                  .image!,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            widget.haveLock
                ? Image.asset("asset/images/lock.png", width: 34, height: 31)
                : const SizedBox()
          ]),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Container(
                    height: 20,
                    width: 80,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(13, 128, 11, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("asset/images/active_gif.gif", width: 10),
                          const SizedBox(width: 8),
                          const Text(
                            "Çevrimiçi",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(230, 175, 47, 1),
                    ),
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.aiModel.name,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () async {
                                  if (isLiked) {
                                    await box.write(
                                        "${widget.aiModel.id}_isLiked", false);
                                    isLiked = false;
                                    FirebaseCloudServices()
                                        .deleteFortuneLike(widget.aiModel.id);
                                    int value = int.parse(
                                        widget.aiModel.firstFavoriteLength);
                                    value--;
                                    widget.aiModel.firstFavoriteLength =
                                        value.toString();
                                    setState(() {});
                                  } else {
                                    await box.write(
                                        "${widget.aiModel.id}_isLiked", true);

                                    isLiked = true;
                                    FirebaseCloudServices()
                                        .increaseFortuneLike(widget.aiModel.id);
                                    int value = int.parse(
                                        widget.aiModel.firstFavoriteLength);
                                    value++;
                                    widget.aiModel.firstFavoriteLength =
                                        value.toString();
                                    setState(() {});
                                  }
                                },
                                child: isLiked
                                    ? Image.asset(
                                        "asset/images/like.png",
                                        width: 20,
                                      )
                                    : Image.asset(
                                        "asset/images/unlike.png",
                                        width: 20,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatLike(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(230, 175, 47, 1),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          /*    Get.to(() => TalkAiPage(
                                aiModel: widget.aiModel,
                                chatGpt: ChatGpt(apiKey: apiKey),
                              ));*/
                          /*
                          if (!widget.haveLock) {
                            Get.to(() => ChatPage(
                                  fortuneTeller: widget.fortuneTeller,
                                ));
                          } else {
                            Offerings? offerings;
                            try {
                              offerings = await Purchases.getOfferings();
                            } on PlatformException {}

                            setState(() {});

                            if (offerings == null ||
                                offerings.current == null) {
                              // offerings are empty, show a message to your user
                            } else {
                              // current offering is available, show paywall
                              Get.to(() => PremiumBuyPage(
                                  isComingFromLockedFortuneTeller: true,
                                  offering: offerings!.current!));
                            }
                          }*/
                        },
                        child: Image.asset("asset/images/chat_icon.png",
                            width: 46),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 26,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatLike() {
    final numberFormat = NumberFormat.decimalPattern('tr_TR');
    final formattedLength =
        numberFormat.format(int.parse(widget.aiModel.firstFavoriteLength));
    return formattedLength;
  }

  Future<bool?> getFortuneTellerImage() async {
    var image = await FirebaseStorageServices()
        .getFortuneTellersImage(widget.aiModel.id);
    if (image != null) {
      widget.controller.chatList[widget.chatListIndex]![widget.listViewIndex]
          .image = image;
      return true;
    }
    return null;
  }
}
