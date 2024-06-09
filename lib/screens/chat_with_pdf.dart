import 'dart:developer';

import 'package:ai_chatbot/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchain/langchain.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_pdf.dart';
import '../widgets/chat_bubble.dart';

class ChatPDF extends ConsumerStatefulWidget {
  const ChatPDF({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPDFState();
}

class _ChatPDFState extends ConsumerState<ChatPDF> {
  late final _prompt = TextEditingController();
  final focus = FocusNode();
  File? file;
  late MemoryVectorStore vectorStore;

  handlePDFUpload() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: ['pdf'], type: FileType.custom);

    if (result != null) {
      file = File(result.files.single.path!);
      log(file!.path);
      vectorStore = await ref.read(chatPDFProvider).getVectorStore(file!.path);
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => const AlertDialog(
                title: Text('Success'),
                content: Text('File Uploaded!'),
              ));
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatPDF = ref.watch(chatPDFProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      drawer: const AppDrawer(),
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
                            controller: chatPDF.scroll,
                            itemBuilder: (context, index) {
                              final message = chatPDF.messages[index];
                              return ChatBubble(
                                message: message.content,
                                isUser: message.sender,
                              );
                            },
                            itemCount: chatPDF.messages.length,
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
                          prefixIcon: file != null
                              ? Image.asset(
                                  'assets/images/pdf.jpg',
                                  width: 3.w,
                                  height: 5.h,
                                )
                              : const SizedBox(
                                  width: 0,
                                  height: 0,
                                ),
                          suffixIcon: file == null
                              ? IconButton(
                                  onPressed: handlePDFUpload,
                                  icon: const Icon(
                                    Icons.attach_file,
                                    color: Colors.white,
                                  ),
                                )
                              : const SizedBox(
                                  width: 0,
                                  height: 0,
                                ),
                        ),
                        controller: _prompt,
                        focusNode: focus,
                      ),
                    ),
                    !chatPDF.loading
                        ? IconButton(
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              chatPDF.getRes(_prompt.text, vectorStore);
                            },
                            icon: const Icon(Icons.arrow_circle_right_rounded),
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
  }
}
