import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_chat/controller/controller.dart';
import 'package:ai_chat/services/speech_to_text.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../elevanlabs.dart';
import '../main.dart';

class TextToSpeechServices {
  Controller controller = Get.put(Controller());
  StreamController<String> myController = StreamController();
  bool isWebsocketDone = false;
  int sayac = 0;
  int gelenVeriSayac = 0;
  StreamSubscription<dynamic>? socketSubscription;
  StreamSubscription<PlayerState>? playerStateSubscription;
  StreamSubscription<dynamic>? audioSubscription;

  Future<void> textToSpeechInputStreaming(
    String voiceId,
    var textIterator,
  ) async {
    controller.socket.sink.add(json.encode({
      "text": " ",
      /* "generation_config": {
        "chunk_length_schedule": [500, 500, 500, 500]
      },*/
      "voice_settings": {"stability": 0.5, "similarity_boost": false},
      "xi_api_key": EL_API_KEY,
    }));

    print("player chunks başlayacak");

    // Player state değişikliklerini dinle
    try {
      playerStateSubscription = controller.audioPlayer.playerStateStream
          .listen((PlayerState playerState) async {
        if (playerState.processingState == ProcessingState.completed) {
          print("SIRADAKİ PARÇA");
          // Çalma tamamlandığında, bir sonraki parçaya geç
          final concatenatedData =
              controller.bufferedAudioDataList.expand((data) => data).toList();
          if (concatenatedData.isNotEmpty) {
            final myCustomSource =
                MyCustomSource(Stream.value(concatenatedData));
            await controller.audioPlayer.setAudioSource(myCustomSource,
                initialPosition: Duration.zero, preload: false);
            sayac++;
            controller.audioPlayer.play();
            print("şu an sayaç $sayac");
            print("şu an veri sayaç $gelenVeriSayac");
            print("isWebsocket done $isWebsocketDone");
          }

          // Listeyi temizle
          controller.bufferedAudioDataList.clear();

          if (sayac == 2 && gelenVeriSayac == 1 && isWebsocketDone) {
            print("tüm verileri okudum");

            controller.speechToText.isNotListening
                ? await SpeechToTextService().startListening()
                : null;
            controller.isTalking.value = false;

            await controller.socket.stream.drain();
          } else if (sayac == gelenVeriSayac && isWebsocketDone) {
            print("tüm verileri okudum");

            controller.speechToText.isNotListening
                ? await SpeechToTextService().startListening()
                : null;

            controller.isTalking.value = false;
          }
        }
      });
    } catch (e) {
      print("plaer subs hata $e");
    }
    try {
      print("null değiş iptal edecem");
      await audioSubscription?.cancel();
      audioSubscription = null;

      audioSubscription = controller.audioStreamController.stream.listen(
        (var message) async {
          final response = jsonDecode(message);
          print("response audio null mı");
          if (response["normalizedAlignment"] != null) {
            gelenVeriSayac++;
            print(
                "gelen veri sayaç $gelenVeriSayac ${response["normalizedAlignment"]}");
          } else {
            print("auido şu an null");
            isWebsocketDone = true;
          }

          var data = json.decode(message);
          if (response['audio'] != null) {
            // Initialize your custom source
            final audioChunk = response['audio'] as String;
            final uint8List = Uint8List.fromList(base64.decode(audioChunk));
            controller.bufferedAudioDataList.add(uint8List);
            //print("liste uzunluk ${bufferedAudioDataList.length}");
            if (sayac == 0 && controller.bufferedAudioDataList.length == 3) {
              final concatenatedData = controller.bufferedAudioDataList
                  .expand((data) => data)
                  .toList();

              final myCustomSource =
                  MyCustomSource(Stream.value(concatenatedData));
              await controller.audioPlayer.setAudioSource(myCustomSource,
                  initialPosition: Duration.zero, preload: false);
              controller.isTalking.value = true;
              sayac++;

              controller.audioPlayer.play();
              print("şu an sayaç $sayac");
              controller.bufferedAudioDataList.clear();
            }
          } else if (data['isFinal'] != null) {
            print("data is final");
            /*      if (!player.playing && bufferedAudioDataList.isNotEmpty) {
              final concatenatedData =
                  bufferedAudioDataList.expand((data) => data).toList();

              final myCustomSource =
                  MyCustomSource(Stream.value(concatenatedData));
              player.setAudioSource(myCustomSource,
                  initialPosition: Duration.zero, preload: false);
              player.play();
              bufferedAudioDataList.clear();
            }
*/
            // Tüm elemanlar çalındı, işlem tamamlandı
          }
        },
        onDone: () async {
          print("bitti el");
          isWebsocketDone = true;
        },
        cancelOnError: true,
        onError: (e) {
          print("hata oluştu $e");
        },
      );
    } catch (e) {
      print("audio subs hata $e");
    }

    await for (var text in textChunker(textIterator)) {
      print("sockete ekleyecem $text");

      controller.socket.sink
          .add(json.encode({"text": text, "try_trigger_generation": true}));
    }
  }

  Future chatCompletion(String query) async {
    final testRequest = ChatCompletionRequest(
      maxTokens: 1000,
      model: ChatGptModel.gpt35Turbo,
      stream: true,
      messages: [Message(role: Role.user.name, content: query)],
    );

    final responseStream =
        await ChatGpt(apiKey: apiKey).createChatCompletionStream(testRequest);
    responseStream?.listen((event) async {
      if (event.streamMessageEnd) {
        print("stream bitti");
        //   await chatCompletion(query);
      } else {
        if (event.choices?.isNotEmpty ?? false) {
          final delta = event.choices!.first.delta;
          if (delta != null) {
            myController.add(delta.content ?? "");
          }
        }
      }
    }, onDone: () {
      print("done chat gbt");
      controller.socket.sink.add(json.encode({
        'text': "",
      }));
    });
    print("merhaba");
    await textToSpeechInputStreaming(
        "ODq5zmih8GrVes37Diz", myController.stream);
  }

  Stream<String> textChunker(Stream<String> chunks) {
    final controller = StreamController<String>();
    final splitters = [
      ".",
      ",",
      "?",
      "!",
    ];

    var buffer = "";
    var addedSentences = <String>{};

    chunks.listen(
      (text) {
        // Split the incoming text into sentences
        final sentences = text.split(RegExp(r'(?<=[.?!])'));

        for (final sentence in sentences) {
          buffer += sentence; // Her cümle sonuna boşluk ekle

          if (splitters.any((splitter) => buffer.contains(splitter))) {
            final trimmedBuffer = buffer.trim(); // Boşlukları temizle

            if (!addedSentences.contains(trimmedBuffer)) {
              print("İstediğim şekilde bitiyor $trimmedBuffer");
              controller.add(trimmedBuffer);
              addedSentences.add(trimmedBuffer);
            }
            buffer = "";
          }
        }
      },
      onDone: () {
        print("buffer bitti $buffer");
        if (buffer.isNotEmpty) {
          final trimmedBuffer = buffer.trim();
          if (!addedSentences.contains(trimmedBuffer)) {
            controller.add('$trimmedBuffer');
            addedSentences.add(trimmedBuffer);
          }
        }
        controller.close();
      },
    );

    return controller.stream;
  }
}
