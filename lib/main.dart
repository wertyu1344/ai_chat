/*import 'dart:io';

import 'package:ai_chat/views/home_page.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'helper/helper.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const apiKey = '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';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Helper().setUp();
  await dotenv.load(fileName: ".env");
  runApp(MyApp(chatGpt: ChatGpt(apiKey: apiKey)));
}

class MyApp extends StatelessWidget {
  final ChatGpt chatGpt;

  const MyApp({super.key, required this.chatGpt});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      home: Scaffold(body: const HomePage()),
    );
  }
}*/

import 'package:ai_chat/elevanlabs.dart';
import 'package:ai_chat/views/home_page.dart';
import 'package:ai_chat/views/talk_ai_page3.dart';
import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'helper/helper.dart';

const apiKey = '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';
const EL_API_KEY = "f990a48c07ddbb2dac2049ec4bede60c";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Helper().setUp();
  await dotenv.load(fileName: ".env");

  runApp(const GetMaterialApp(
    home: HomePage(),
  ));
}
