//chat gbt key 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
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'chat_completion_page.dart';

const apiKey = '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';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp(chatGpt: ChatGpt(apiKey: apiKey)));
}

class MyApp extends StatelessWidget {
  final ChatGpt chatGpt;

  const MyApp({super.key, required this.chatGpt});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Elevanlabs | Chat Gbt",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ChatCompletionPage(chatGpt: chatGpt),
      ),
    );
  }
}
