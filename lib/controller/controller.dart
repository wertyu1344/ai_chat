import 'dart:async';
import 'dart:typed_data';

import 'package:ai_chat/models/ai_model.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/io.dart';

import '../models/user_model.dart';

class Controller extends GetxController {
  var isWriting = false.obs;
  var message = "".obs;
  StreamSubscription<CompletionResponse>? streamSubscription;
  StreamSubscription<StreamCompletionResponse>? chatStreamSubscription;
  var showIcon = false.obs;
  //Elmaslar Canım Elmaslar
  RxInt myMessageCredit = 0.obs;
  int shareMessageCounter = 5;
  int rateUsCounter = 5;
  int totalShareUs = 5;
  int totalRateUs = 5;

  late UserModel user;
  Map<String, Uint8List?> pastFortunesImagesCache = {};
  late List<List<AiModel>?> chatList;
  var botNavBarIndex = 0.obs;
  int rating = 5;
  String deviceId = "";

  var inDeleteModeNotifPage = false.obs;
  var inDeleteModePastPage = false.obs;

  var isSelectedAll = false.obs;

  //Premium
  var userId = "".obs;
  var isPremiumActive = false.obs;

  //Chat page
  //Notif
  var numberOfNotif = 0.obs;

  //Audio an stt controller
  late AudioPlayer audioPlayer;
  late IOWebSocketChannel socket;
  List<List<int>> bufferedAudioDataList = [];
  var lastWords = "".obs;
  var isListening = false.obs;
  var isTalking = false.obs;
  SpeechToText speechToText = SpeechToText();
  StreamController<dynamic> audioStreamController =
      StreamController<dynamic>(); // late eklendi
}
