import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:ai_chat/models/message_model.dart';
import 'package:ai_chat/ripple_effect.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'controller/controller.dart';
import 'elevanlabs.dart';
import 'message_with_stream.dart';
import 'models/question_answer.dart';

class ChatCompletionPage extends StatefulWidget {
  final ChatGpt chatGpt;

  const ChatCompletionPage({super.key, required this.chatGpt});

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage> {
  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    await _startListening();

    setState(() {});
  }

  Controller controller = Get.put(Controller());
  String _lastWords = '';
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  final TextEditingController _textFieldController = TextEditingController();
  final player = AudioPlayer(); //audio player obj that will play audio
  bool _isLoadingVoice = false; //fo
  List<String> cumleList = [];
  List byteList = [];
  String? answer;
  bool loading = false;
  final testPrompt =
      'Which Disney character famously leaves a glass slipper behind at a royal ball?';

  final List<MessageModel> messageList = [];

  late TextEditingController textEditingController;
  bool haveVoiceError = false;

  @override
  void dispose() {
    _textFieldController.dispose();
    player.dispose();
    textEditingController.dispose();
    controller.chatStreamSubscription?.cancel();
    super.dispose();
  }

  //For the Text To Speech

  Future<void> playSound(bytes) async {
    try {
      print("müzik çalıyor");
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      controller.showIcon.value = true;
      setState(() {});
      await player.play().whenComplete(() {
        print("ÇALAN MÜZİK BİTTİ");
        isMusicPlaying = false;
        soundSayac++;
      });
    } catch (e) {
      print("ses çalarken hata $e");
    }
  }

  Future<void> getVoices() async {
    //display the loading icon while we wait for request

    String url = 'https://api.elevenlabs.io/v1/voices';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': EL_API_KEY,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final posts = json.decode(response.body);
      final filteredPosts = posts["voices"]
          .map((post) => {"voice_id": post["voice_id"], "name": post["name"]})
          .toList();
      // Liste öğelerinin model_id ve "name" alanlarını bir liste içinde kaydet
      filteredPosts.forEach((post) {
        print(post["voice_id"] + ": " + post["name"]);
      });
    } else {
      print("Get models APİ HATASI ${response.statusCode}");
      // throw Exception('Failed to load audio');
      return;
    }
  } //

  Future<void> getSoundApi(String text, int index) async {
    //display the loading icon while we wait for request
    setState(() {
      _isLoadingVoice = true; //progress indicator turn on now
    });
    String voiceJessie = "t0jbNlBVZ17f02VDIeMI";
    String voiceRachel =
        '21m00Tcm4TlvDq8ikWAM'; //Rachel voice - change if you know another Voice ID
    String voicePatrick = "ODq5zmih8GrVes37Dizd";
    String voiceMimi = "zrHiDhphv9ZnVXBqCLjz";
    String ethan = "g5CIjZEefAph4nQFvHAz";
    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voicePatrick';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': EL_API_KEY,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );

    setState(() {
      _isLoadingVoice = false; //progress indicator turn off now
    });

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      byteList[index] = bytes;
    } else {
      print("APİ HATASI ${response.statusCode}");
      print("İndex şu an ${index}");
      print("listede eleman sayısı şu an ${byteList.length}");
      /*  haveVoiceError = true;
      musicStarted = 0;
      streamBittiMi = false;
      isMusicPlaying = false;
      controller.showIcon.value = false;
      soundSayac = 0;
      haveVoiceError = false;
      apiSayac = 0;
      byteList.clear();
      cumleList.clear();
      _startListening();*/
      // throw Exception('Failed to load audio');
      return;
    }
  } //

  Future<void> _startListening() async {
    print("dinleyecem");
    try {
      await _speechToText.listen(
        localeId: "tr-TR",
        onResult: (result) async {
          await _onSpeechResult(result);
        },
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();

    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.finalResult) {
      // Stop listening
      print("dinleme bitti");
      _stopListening();
      textEditingController.text = result.recognizedWords;
      print("şu kelimeleri tespit ettim");
      print(result.recognizedWords);
      messageList.add(MessageModel(
          text: result.recognizedWords, isMe: true, isPrompt: false));

      await _sendChatMessage();

      // Print the recognized words to the terminal
    }
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  getLocales() async {
    var locales = await SpeechToText().locales();
    var localeId = locales.map((e) => e.localeId).toList();
    print("localler $localeId");
  }

  @override
  void initState() {
    // getVoices();

    _initSpeech();
    textEditingController = TextEditingController();
    textEditingController.text = "give me 3 sentence.";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: InkWell(
            onTap:
                // If not yet listening for speech start, otherwise stop
                //speechToText.isNotListening ? _startListening :
                _stopListening,
            child: _speechToText.isListening
                ? Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 64,
                  )
                : SizedBox()),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: _speechToText.isListening
              ? const SpinKitFoldingCube(
                  color: Colors.white,
                  size: 50.0,
                )
              : Center(child: MessageWithStream()),
        ));
  }

  _sendChatMessage() async {
    const prompt = "You will speak in Turkish.Your name is huysuz.";
    setState(() {
      //textEditingController.clear();
      loading = true;
    });
    final testRequest = ChatCompletionRequest(
        maxTokens: 1000,
        stream: true,
        messages: [Message(role: Role.user.name, content: prompt)] +
            messageList
                .map((e) => Message(
                    role: e.isMe ? Role.user.name : Role.assistant.name,
                    content: e.text))
                .toList(),
        model: ChatGptModel
            .gpt35Turbo /* messageList
          .map((e) => Message(
              role: e.isMe ? Role.user.name : Role.assistant.name,
              content: e.text))
          .toList(),
      */
        );
    await _chatStreamResponse(testRequest);
  }

  int musicStarted = 0;
  bool streamBittiMi = false;
  bool isMusicPlaying = false;
  String gbtAnswer = "";

  _chatStreamResponse(ChatCompletionRequest request) async {
    controller.chatStreamSubscription?.cancel();
    String currentCumle = "";

    try {
      final stream = await widget.chatGpt.createChatCompletionStream(request);
      controller.chatStreamSubscription = stream?.listen((event) => setState(
            () {
              if (event.streamMessageEnd) {
                streamBittiMi = true;
                controller.chatStreamSubscription?.cancel();
              } else {
                currentCumle += event.choices?.first.delta?.content ?? "";
                if (currentCumle.endsWith(".") ||
                    currentCumle.endsWith("?") ||
                    currentCumle.endsWith("!")) {
                  cumleList.add(currentCumle);

                  byteList.add(null);
                  currentCumle = "";
                  getSoundApi(cumleList[apiSayac], apiSayac);

                  apiSayac++;
                  if (musicStarted == 0) {
                    startPlaying();
                    loading = false;
                    setState(() {});

                    musicStarted = 1;
                  }
                }
                gbtAnswer += event.choices?.first.delta?.content ?? "";
              }
            },
          ));
    } catch (error) {
      setState(() {
        loading = false;
        gbtAnswer = "";
      });
      log("Error occurred: $error");
      _startListening();
    }
  }

  int soundSayac = 0;
  int apiSayac = 0;
  startPlaying() async {
    while (true) {
      if (haveVoiceError) {
        print("voice hatası yüzünden durdum");
        setState(() {});
        musicStarted = 0;
        streamBittiMi = false;
        isMusicPlaying = false;
        controller.showIcon.value = false;
        soundSayac = 0;
        haveVoiceError = false;
        apiSayac = 0;
        byteList.clear();
        cumleList.clear();
        _startListening();
        break;
      }
      if (streamBittiMi) {
        print("stream bitti");
        print("gbt cevap: $gbtAnswer");

        if (cumleList.length > soundSayac) {
          await oynamiyosaOynat();
        } else {
          print("işle bitti baba");
          setState(() {});
          musicStarted = 0;
          streamBittiMi = false;
          isMusicPlaying = false;
          controller.showIcon.value = false;
          soundSayac = 0;
          apiSayac = 0;
          byteList.clear();
          cumleList.clear();
          if (messageList.length > 3) {
            messageList.removeAt(0);
          }
          messageList
              .add(MessageModel(text: gbtAnswer, isMe: false, isPrompt: true));
          gbtAnswer = "";
          print("gbt cevap iş bittikten sonra: $gbtAnswer");
          print("şu an liste şöyle");
          for (MessageModel i in messageList) {
            print(i.text);
          }
          gbtAnswer = "";

          _speechToText.isNotListening ? _startListening() : null;

          break;
        }
      } else {
        if (byteList.isNotEmpty) {
          await oynamiyosaOynat();
        } else {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
  }

  oynamiyosaOynat() async {
    if (player.playing) {
      player.stop();
      print("müzik çalllllıyo");
      await Future.delayed(const Duration(milliseconds: 200));
    } else {
      try {
        if (byteList[soundSayac] != null) {
          print(3);

          isMusicPlaying = true;
          await playSound(byteList[soundSayac]);
        } else {
          print(4);
          print("sayaç $soundSayac");
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        print("error $e");
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
}
