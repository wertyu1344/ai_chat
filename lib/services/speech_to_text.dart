import 'package:ai_chat/controller/controller.dart';
import 'package:ai_chat/services/text_to_speech.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/message_model.dart';

class SpeechToTextService {
  bool _speechEnabled = false;
  final List<MessageModel> messageList = [];

  Controller controller = Get.put(Controller());

  void errorListener(SpeechRecognitionError error) {
    print("dinleme hatasu var ${error.errorMsg}");
    startListening();
  }

  Future<void> initSpeech() async {
    _speechEnabled = await controller.speechToText
        .initialize(onStatus: statusListener, onError: errorListener);
    if (_speechEnabled == false) {
      print("speech enabled edilmedi");
      initSpeech();
    } else {
      print("speech enablet edildi");
      controller.isListening.value = true;
      print("isListening güncelledim ${controller.isListening.value}");
    }
    await startListening();
  }

  stopListening() async {
    print("stop listening çalıştı");
    await controller.speechToText.stop();
    controller.isListening.value = false;
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.finalResult) {
      // Stop listening
      await stopListening();
      print("şu kelimeleri tespit ettim");
      print(result.recognizedWords);
      messageList.add(MessageModel(
          text: result.recognizedWords, isMe: true, isPrompt: false));
      controller.lastWords.value = "";
      controller.isListening.value = false;
      await TextToSpeechServices().chatCompletion(result.recognizedWords);

      // Print the recognized words to the terminal
    } else {
      print("dinleme durumu devam ediyor");
    }
    controller.lastWords.value = result.recognizedWords;
  }

  Future<void> startListening() async {
    print("dinleyecem");
    controller.lastWords.value = "";

    try {
      print("deniyourm");
      controller.isListening.value = true;
      await controller.speechToText.listen(
        localeId: "tr-TR",
        onResult: (result) async {
          await _onSpeechResult(result);
        },
        pauseFor: const Duration(seconds: 2),
      );
    } catch (e) {
      controller.isListening.value = false;

      print("dinleme hatası");
      print(e);
    }
  }

  statusListener(String status) async {
    print("statüsü dinliyourm");
    controller.isListening.value = true;
    print("şu an last word ${controller.lastWords.value}");

    if (controller.speechToText.isListening == false &&
        controller.audioPlayer.playing == false &&
        controller.lastWords.value == "") {
      print("durdu ve bişey demedi");
      await Future.delayed(Duration(seconds: 1));
      print("şimdi başlatıyorum");

      await startListening();
    }
  }
}
