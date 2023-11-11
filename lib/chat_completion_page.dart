import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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

  final List<QuestionAnswer> questionAnswers = [];

  late TextEditingController textEditingController;

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

  Future<void> getSoundApi(String text, int index) async {
    //display the loading icon while we wait for request
    setState(() {
      _isLoadingVoice = true; //progress indicator turn on now
    });

    String voiceRachel =
        '21m00Tcm4TlvDq8ikWAM'; //Rachel voice - change if you know another Voice ID

    String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceRachel';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': EL_API_KEY,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": "eleven_monolingual_v1",
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
      // throw Exception('Failed to load audio');
      return;
    }
  } //

  void _startListening() async {
    print("dinleyecem");
    try {
      await _speechToText.listen(
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

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    if (result.finalResult) {
      // Stop listening
      _stopListening();
      textEditingController.text = result.recognizedWords;
      await _sendChatMessage();

      // Print the recognized words to the terminal
      print("şu kelimeleri tespit ettim");
      print(result.recognizedWords);
    }
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  void initState() {
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
            ? SizedBox()
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
                child: showIcon ? const TalkingAnimation() : SizedBox()),
          ),
        ));
  }

  _sendChatMessage() async {
    final question = textEditingController.text;
    setState(() {
      textEditingController.clear();
      loading = true;
      questionAnswers.add(
        QuestionAnswer(
          question: question,
          answer: StringBuffer(),
        ),
      );
    });
    final testRequest = ChatCompletionRequest(
      stream: true,
      maxTokens: 4000,
      messages: [Message(role: Role.user.name, content: question)],
      model: ChatGptModel.gpt35Turbo,
    );
    await _chatStreamResponse(testRequest);
  }

  int musicStarted = 0;
  bool streamBittiMi = false;
  bool isMusicPlaying = false;

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

                return questionAnswers.last.answer.write(
                  event.choices?.first.delta?.content,
                );
              }
            },
          ));
    } catch (error) {
      setState(() {
        loading = false;
        questionAnswers.last.answer.write("Error");
      });
      log("Error occurred: $error");
    }
  }

  //yeni cümle gelcek
  //null eklenecek
  //apiyee gitçek
  //response listeye atılcak
  //listedeki elemanlar çalacak
  //çalarken bekleyecek
  //yeni eleman yoksa bekleyecek -

  int soundSayac = 0;
  int apiSayac = 0;
  bool showIcon = false;
  startPlaying() async {
    while (true) {
      if (streamBittiMi) {
        print("stream bitti");
        if (cumleList.length > soundSayac) {
          await oynamiyosaOynat();
        } else {
          setState(() {});
          musicStarted = 0;
          streamBittiMi = false;
          isMusicPlaying = false;
          showIcon = false;
          soundSayac = 0;
          apiSayac = 0;
          byteList.clear();
          cumleList.clear();

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

  Future<void> yeniElemanGeldiMi() async {
    var lastElement = cumleList.last;
    while (true) {
      if (lastElement != cumleList.last) {
        lastElement = cumleList.last;
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }
}
