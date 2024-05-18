import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sizer/sizer.dart';
import 'dart:developer';

import 'package:tex_markdown/tex_markdown.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final _prompt = TextEditingController();
  late final GenerativeModel _model;
  late final ChatSession _chat;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    var apiKey = dotenv.env['GEMINI_API'];
    _model = GenerativeModel(model: "gemini-1.5-flash-latest", apiKey: apiKey!);
    _chat = _model.startChat();
  }

  Future getAnswer(String prompt) async {
    setState(() {
      _loading = true;
    });
    try {
      final content = Content.text(prompt);
      final response = await _chat.sendMessage(content);
      var text = response.text;

      if (text == null && mounted) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: SizedBox(
              child: Center(
                child: Text("Error occured\nPlease try again later."),
              ),
            ),
          ),
        );
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: SizedBox(
              child: Center(
                child: Text("$e\n Please try again later."),
              ),
            ),
          ),
        );
      }
    } finally {
      _prompt.clear();
      setState(() {
        _loading = false;
      });
    }
    // print(responses.map((e) => e.parts));
    // final endTime = DateTime.now();
    // setState(() {
    //   text = response.text!;
    //   responseTime = endTime.difference(startTime);
    // });
    // log(responseTime.inSeconds.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Opacity(
                          opacity: 0.85,
                          child: Image.asset(
                            "assets/images/iimg.jpg",
                            fit: BoxFit.cover,
                            width: 100.w,
                            height: 84.95.h,
                          ),
                        ),
                        Positioned.fill(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 83.h,
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    final responses =
                                        _chat.history.toList()[index];
                                    var text = responses.parts
                                        .whereType<TextPart>()
                                        .map<String>((e) => e.text)
                                        .join('');
                                    return chatBubble(
                                        text, responses.role.toString());
                                  },
                                  itemCount: _chat.history.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 10.h,
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80.w,
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                hintText: "Input your prompt...",
                                hintStyle: TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              controller: _prompt,
                            ),
                          ),
                          !_loading
                              ? IconButton(
                                  onPressed: () async {
                                    getAnswer(_prompt.text);
                                  },
                                  icon: const Icon(
                                      Icons.arrow_circle_right_rounded),
                                  color: Colors.blueAccent,
                                  iconSize: 6.h,
                                )
                              : const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget chatBubble(String message, String isUser) {
    return Container(
      margin: EdgeInsets.only(
          top: 10.0,
          bottom: 10.0,
          left: isUser == "user" ? 12.w : 1.h,
          right: isUser == "user" ? 1.h : 12.w),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: isUser == "user" ? Colors.blue[200] : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser == "user" ? 16.0 : 0.0),
          topRight: Radius.circular(isUser == "user" ? 0.0 : 16.0),
          bottomRight: const Radius.circular(16.0),
          bottomLeft: const Radius.circular(16.0),
        ),
      ),
      child: TexMarkdown(
        message,
      ),
    );
  }
}
