import 'package:ai_chatbot/providers/model.dart';
import 'package:ai_chatbot/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sizer/sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../providers/chat.dart';
import 'package:image_picker/image_picker.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late final _prompt = TextEditingController();
  final focus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  List<DropdownMenuItem<String>> dropDownMenu = [
    const DropdownMenuItem(
      value: "gemini-1.5-flash-latest",
      child: Text("Google Gemini 1.5 Flash"),
    ),
    const DropdownMenuItem(
      value: "gemini-1.5-pro-latest",
      child: Text("Google Gemini 1.5 Pro"),
    ),
  ];

  handleImgUpload() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          height: 13.h,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 50,
                          maxWidth: 800,
                          maxHeight: 600);

                      setState(() {
                        _image = image;
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: const Text("Upload from Gallery")),
                TextButton(
                    onPressed: () async {
                      final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 50,
                          maxWidth: 800,
                          maxHeight: 600);

                      setState(() {
                        _image = image;
                      });
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    },
                    child: const Text("Upload from Camera")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final modelSelect = ref.read(modelSelectorProvider.notifier);
    final model = ref.watch(modelSelectorProvider);

    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            actions: [
              const Text(
                "Select Model:",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(
                width: 3.w,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(20)),
                child: DropdownButton(
                    hint: const Text(
                      "Select model",
                      style: TextStyle(color: Colors.white),
                    ),
                    value: model,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    iconSize: 30,
                    elevation: 16,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    dropdownColor: Colors.black,
                    underline: const SizedBox(),
                    onChanged: (newValue) {
                      modelSelect.setModel(newValue!);
                    },
                    items: dropDownMenu),
              ),
            ],
          ),
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
                          height: 83.5.h,
                        ),
                      ),
                      Positioned.fill(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 80.h,
                              child: ListView.builder(
                                controller: chat.scroll,
                                itemBuilder: (context, index) {
                                  final responses =
                                      chat.chatSession.history.toList()[index];
                                  var text = responses.parts
                                      .whereType<TextPart>()
                                      .map<String>((e) => e.text)
                                      .join('');
                                  return ChatBubble(
                                    message: text,
                                    isUser: responses.role.toString(),
                                    image: _image?.path,
                                  );
                                },
                                itemCount: chat.chatSession.history.length,
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            maxLines: null,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                              hintText: "Input your prompt...",
                              hintStyle: const TextStyle(color: Colors.white),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              prefixIcon: _image != null
                                  ? Container(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        File(_image!.path),
                                        width: 10.w,
                                        height: 15.h,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const SizedBox(
                                      width: 0,
                                      height: 0,
                                    ),
                              suffixIcon: IconButton(
                                onPressed: handleImgUpload,
                                icon: const Icon(
                                  Icons.upload_file,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            controller: _prompt,
                            focusNode: focus,
                          ),
                        ),
                        !chat.loading
                            ? IconButton(
                                onPressed: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (_image != null) {
                                    await chat.getImgAns(
                                        _image!.path, _prompt.text, context);
                                    _prompt.clear();
                                  } else {
                                    await chat.getAnswer(_prompt.text, context);
                                    _prompt.clear();
                                  }
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
        );
      },
    );
  }
}
