import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_chat/main.dart';
import 'package:ai_chat/models/ai_model.dart';
import 'package:ai_chat/services/speech_to_text.dart';
import 'package:ai_chat/services/text_to_speech.dart';
import 'package:ai_chat/views/home_page.dart';
import 'package:ai_chat/widgets/talk_wait_widget.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';

import 'controller/controller.dart';
import 'models/message_model.dart';

class Elevanlabs extends StatefulWidget {
  AiModel aiModel;
  Elevanlabs({required this.aiModel, super.key});

  @override
  State<Elevanlabs> createState() => _ElevanlabsState();
}

class _ElevanlabsState extends State<Elevanlabs> {
  int audioDataCounter = 0;
  bool webSocketOnDone = false;
  Controller controller = Get.put(Controller());
  var uri = Uri.parse(
      "wss://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM/stream-input?model_id=eleven_multilingual_v2&optimize_streaming_latency=3&output_format=mp3_44100");

  @override
  void initState() {
    super.initState();
    controller.audioPlayer = AudioPlayer();
    controller.lastWords.value = "";
    /*chatCompletion(
        "birden 10 a kadar say en sonra her sayı arasına . koy ama kelime olarak yaz");*/
    controller.socket = IOWebSocketChannel.connect(uri);
    controller.showIcon.value = false;
    controller.bufferedAudioDataList.clear();
    controller.socket.stream.listen((var message) {
      controller.audioStreamController.add(message);
    });
    SpeechToTextService().initSpeech();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: AppBar(
          leading: SizedBox(),
          backgroundColor: Colors.black,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () async {
                  await controller.speechToText.stop();

                  controller.audioPlayer.stop();

                  Get.offAll(const HomePage());
                },
                child: Icon(
                  Icons.call_end,
                  color: Colors.red,
                ),
              ),
            )
          ],
          title: Text(
            widget.aiModel.name,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        floatingActionButton: Obx(
          () => InkWell(
              onTap: () => controller.isListening.value
                  ? SpeechToTextService().stopListening()
                  : SpeechToTextService().startListening(),
              // onTap:
              // If not yet listening for speech start, otherwise stop
              // speechToText.isNotListening ? _startListening : _stopListening,
              child: controller.isListening.value
                  ? const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 64,
                    )
                  : const Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: 64,
                    )),
        ),
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => SafeArea(
                child: controller.isListening.value
                    ? Center(
                        child: const SpinKitWaveSpinner(
                          color: Colors.white,
                          size: 80.0,
                        ),
                      )
                    : Center(child: TalkWaitWidget()),
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  controller.isTalking.value ? "" : controller.lastWords.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ));
  }
}

class MyCustomSource extends StreamAudioSource {
  final StreamController<List<int>> _controller;
  final List<int> bytes = [];
  late AudioPlayer _audioPlayer;

  MyCustomSource(Stream<List<int>> byteStream)
      : _controller = StreamController<List<int>>() {
    byteStream.listen((data) {
      _controller.add(data);
      bytes.addAll(data);
    });

    _audioPlayer = AudioPlayer();
  }

  // Oynatma fonksiyonu

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;

    // Başlangıçtan bitişe kadar olan kısmı al
    final sublist = bytes.sublist(start, end);

    // İlgili kısmı içeren bir Stream oluştur
    final stream = Stream<List<int>>.fromIterable([sublist]);

    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: stream,
      contentType: 'audio/mpeg',
    );
  }
}
