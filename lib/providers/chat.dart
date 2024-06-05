import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'model.dart';

final chatProvider = ChangeNotifierProvider<ChatNotifier>((ref) {
  final modelName = ref.watch(modelSelectorProvider);
  final model =
      GenerativeModel(model: modelName, apiKey: dotenv.env['GEMINI_API']!);
  final chatService = model.startChat();
  return ChatNotifier(chatService);
});

class ChatNotifier extends ChangeNotifier {
  final ChatSession _chatSession;
  bool _loading = false;
  String? _responseText;
  final ScrollController _scroll = ScrollController();

  ChatSession get chatSession => _chatSession;
  bool get loading => _loading;
  String? get responseText => _responseText;
  ScrollController get scroll => _scroll;

  ChatNotifier(this._chatSession);

  Future<void> getAnswer(String prompt, BuildContext context) async {
    _loading = true;
    notifyListeners();

    try {
      final content = Content.text(prompt);
      final response = await _chatSession.sendMessage(content);
      var text = response.text;

      if (text == null) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => const AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: SizedBox(
              child: Center(
                child: Text("Please try again later."),
              ),
            ),
          ),
        );
      } else {
        _responseText = text;
        _scrollDown();
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
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
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future getImgAns(
      String filepath, String question, BuildContext context) async {
    _loading = true;
    notifyListeners();
    try {
      final img = await File(filepath).readAsBytes();
      final prompt = TextPart(question);
      final imagePart = DataPart('image/png', img);
      final response =
          await _chatSession.sendMessage(Content.multi([prompt, imagePart]));
      var text = response.text;
      if (text == null) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => const AlertDialog(
            title: Text(
              "Error",
              style: TextStyle(color: Colors.red),
            ),
            content: SizedBox(
              child: Center(
                child: Text("Please try again later."),
              ),
            ),
          ),
        );
      } else {
        _responseText = text;
        _scrollDown();
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
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
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 2400,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }
}
