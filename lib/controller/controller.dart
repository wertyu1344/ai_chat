import 'dart:async';

import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  var isWriting = false.obs;
  var message = "".obs;
  StreamSubscription<CompletionResponse>? streamSubscription;
  StreamSubscription<StreamCompletionResponse>? chatStreamSubscription;
  var showIcon = false.obs;
}
