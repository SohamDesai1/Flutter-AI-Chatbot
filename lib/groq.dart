import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  TextEditingController input = TextEditingController();
  var groqApiKey = dotenv.env['GROQ_API'];
  String output = "";
  Duration responseTime = Duration.zero;
  // @override
  // initState() {
  //   super.initState();
  // getAnswer();
  // }

  void getAnswer(String prompt) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    const model = 'llama3-70b-8192';
    final message = {'role': 'user', 'content': prompt};
    final payload = {
      'messages': [message],
      'model': model
    };

    final headers = {
      'Authorization': 'Bearer $groqApiKey',
      'Content-Type': 'application/json',
    };

    try {
      final startTime = DateTime.now();
      final response =
          await http.post(url, headers: headers, body: jsonEncode(payload));
      final endTime = DateTime.now();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'];
        String text = choices[0]['message']['content'];
        // log(text.toString());
        setState(() {
          output = text;
          responseTime = responseTime = endTime.difference(startTime);
        });
        log(responseTime.inSeconds.toString());
      } else {
        throw Exception('Failed to fetch response: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching explanation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.3,
                child: Markdown(
                  data: output,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 500,
                      child: TextField(
                        controller: input,
                      )),
                  IconButton(
                      onPressed: () {
                        getAnswer(input.text);
                      },
                      icon: const Icon(Icons.arrow_circle_right_rounded))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
