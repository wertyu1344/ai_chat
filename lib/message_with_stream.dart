import 'dart:math';

import 'package:ai_chat/ripple_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';

import 'controller/controller.dart';

class MessageWithStream extends StatefulWidget {
  @override
  State<MessageWithStream> createState() => _MessageWithStreamState();
}

class _MessageWithStreamState extends State<MessageWithStream> {
  Controller controller = Get.find<Controller>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.showIcon.value
        ? TalkingAnimation(color: Colors.deepPurpleAccent)
        : const SpinKitPulsingGrid(
            color: Colors.white,
            size: 80.0,
          ));
  }
}
