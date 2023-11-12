import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:ai_chat/models/message_model.dart';
import 'package:ai_chat/ripple_effect.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'elevanlabs.dart';
import 'models/question_answer.dart';

class ChatCompletionPage extends StatefulWidget {
  final ChatGpt chatGpt;

  const ChatCompletionPage({super.key, required this.chatGpt});

  @override
  State<ChatCompletionPage> createState() => _ChatCompletionPageState();
}

class _ChatCompletionPageState extends State<ChatCompletionPage> {
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    //_startListening();

    setState(() {});
  }

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

  final List<MessageModel> messageList = [
    MessageModel(
        text:
            "You are a German teacher and you will only teach German. You will speak in Turkish. If he asks any other questions, you will say that I cannot help. Also, after every answer, you will say Laga luga yapma sor",
        isMe: true,
        isPrompt: false)
  ];

  late TextEditingController textEditingController;
  bool haveVoiceError = false;
  StreamSubscription<CompletionResponse>? streamSubscription;
  StreamSubscription<StreamCompletionResponse>? chatStreamSubscription;

  @override
  void dispose() {
    _textFieldController.dispose();
    player.dispose();
    textEditingController.dispose();
    chatStreamSubscription?.cancel();
    super.dispose();
  }

  //For the Text To Speech

  Future<void> playSound(bytes) async {
    try {
      print("müzik çalıyor");
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      showIcon = true;
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
    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceMimi';
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
      haveVoiceError = true;
      // throw Exception('Failed to load audio');
      return;
    }
  } //

  void _startListening() async {
    print("dinleyecem");
    try {
      await _speechToText.listen(
        localeId: "tr-TR",
        onResult: (result) async {
          await _onSpeechResult(result);
        },
        pauseFor: const Duration(seconds: 5),
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
        floatingActionButton: showIcon
            ? const SizedBox()
            : FloatingActionButton(
                onPressed:
                    // If not yet listening for speech start, otherwise stop
                    _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                tooltip: 'Listen',
                child: loading
                    ? const CircularProgressIndicator()
                    : Icon(_speechToText.isNotListening
                        ? Icons.mic_off
                        : Icons.mic),
              ),
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: showIcon
                    ? const TalkingAnimation(
                        color: Colors.deepOrange,
                      )
                    : const SizedBox()),
          ),
        ));
  }

  _sendChatMessage() async {
    const prompt =
        "You will speak in Turkish.Your name is huysuz. Also, after every answer, you will say I love you very much";
    setState(() {
      textEditingController.clear();
      loading = true;
    });
    final testRequest = ChatCompletionRequest(
      stream: true,
      maxTokens: 300,
      messages: messageList
          .map((e) => Message(
              role: e.isMe ? Role.user.name : Role.assistant.name,
              content: e.text))
          .toList(),
      model: ChatGptModel.gpt35Turbo0301,
    );
    await _chatStreamResponse(testRequest);
  }

  int musicStarted = 0;
  bool streamBittiMi = false;
  bool isMusicPlaying = false;
  String gbtAnswer = "";
  _chatStreamResponse(ChatCompletionRequest request) async {
    chatStreamSubscription?.cancel();
    String currentCumle = "";

    try {
      final stream = await widget.chatGpt.createChatCompletionStream(request);
      chatStreamSubscription = stream?.listen((event) => setState(
            () {
              if (event.streamMessageEnd) {
                streamBittiMi = true;
                chatStreamSubscription?.cancel();
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
    }
  }

  int soundSayac = 0;
  int apiSayac = 0;
  bool showIcon = false;
  startPlaying() async {
    while (true) {
      if (haveVoiceError) {
        print("voice hatası yüzünden durdum");
        setState(() {});
        musicStarted = 0;
        streamBittiMi = false;
        isMusicPlaying = false;
        showIcon = false;
        soundSayac = 0;
        haveVoiceError = false;
        apiSayac = 0;
        byteList.clear();
        cumleList.clear();
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
          showIcon = false;
          soundSayac = 0;
          apiSayac = 0;
          byteList.clear();
          cumleList.clear();
          if (messageList.length > 6) {
            messageList.removeAt(1);
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

          //  _speechToText.isNotListening ? _startListening() : null;

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

          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch (e) {
        print("error $e");
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
}
