import 'package:ai_chat/widgets/ripple_effect.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';

class TalkWaitWidget extends StatefulWidget {
  @override
  State<TalkWaitWidget> createState() => _TalkWaitWidgetState();
}

class _TalkWaitWidgetState extends State<TalkWaitWidget> {
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
    return Obx(() => controller.isTalking.value
        ? const TalkingAnimation(color: Colors.deepPurpleAccent)
        : const SpinKitThreeInOut(
            color: Colors.white,
            size: 40.0,
          ));
  }
}
