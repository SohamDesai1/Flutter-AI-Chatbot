import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MaterialApp(
    home: Demo(),
  ));
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  String text = '';
  TextEditingController prompt = TextEditingController();
  Duration responseTime = Duration.zero;

  getRes(String prompt) async {
    var apiKey = dotenv.env['GEMINI_API'];
    final model =
        GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: apiKey!);
    final chat = model.startChat(history: []);
    final content = Content.text(prompt);
    final startTime = DateTime.now();
    final response = await chat.sendMessage(content);
    // final responses = chat.history;
    // print(responses.map((e) => e.parts));
    final endTime = DateTime.now();
    // log(response.text!);
    setState(() {
      text = response.text!;
      responseTime = endTime.difference(startTime);
    });
    log(responseTime.inSeconds.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.3,
            child: Markdown(
              data: text,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 500,
                  child: TextField(
                    controller: prompt,
                  )),
              IconButton(
                  onPressed: () {
                    getRes(prompt.text);
                  },
                  icon: const Icon(Icons.arrow_circle_right_rounded))
            ],
          ),
        ],
      ),
    );
  }
}
