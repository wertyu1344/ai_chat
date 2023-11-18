import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/ai_model.dart';
import 'chat_list_page.dart';

class AiCategories extends StatelessWidget {
  final int index;
  final String fortuneKey;
  final String imagePath;
  const AiCategories(
      {super.key,
      required this.index,
      required this.fortuneKey,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.to(ChatListPage(
              index: index,
              fortuneCategory: fortuneKey,
              appBarTitle: categories[fortuneKey]!,
            )),
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(230, 175, 47, 1),
                    borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    width: (MediaQuery.of(context).size.width / 1) - 16,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(230, 175, 47, 1),
              ),
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                categories[fortuneKey] ?? "",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
