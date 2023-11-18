import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';

class MainAppBar extends StatelessWidget {
  final Widget? leading;
  final Widget? action;
  final String title;
  MainAppBar({required this.title, this.leading, this.action, Key? key})
      : super(key: key);
  final Controller controller = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 100, child: leading),
                  Image.asset(
                    "asset/images/appbar_icon.png",
                    width: 40,
                  ),
                  SizedBox(width: 100, child: action),
                ],
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
