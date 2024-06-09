import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

final chatPDFProvider = ChangeNotifierProvider<PDFNotifier>((ref) {
  final chatModel = ChatGoogleGenerativeAI(
    apiKey: dotenv.env['GEMINI_API'],
    defaultOptions: const ChatGoogleGenerativeAIOptions(
      model: 'gemini-1.5-flash-latest',
      temperature: 0,
    ),
  );
  return PDFNotifier(chatModel);
});

class Message {
  final String sender;
  final String content;

  Message({required this.sender, required this.content});
}

class PDFNotifier extends ChangeNotifier {
  final ChatGoogleGenerativeAI model;
  final List<Message> _messages = [];
  String? _responseText;
  bool _loading = false;
  final ScrollController _scroll = ScrollController();

  bool get loading => _loading;
  String? get responseText => _responseText;
  ScrollController get scroll => _scroll;
  List<Message> get messages => _messages;

  PDFNotifier(this.model);

  Future<String> getPDFtext(String filePath) async {
    final PdfDocument document =
        PdfDocument(inputBytes: File(filePath).readAsBytesSync());
    // ignore: no_leading_underscores_for_local_identifiers
    String _text = PdfTextExtractor(document).extractText();
    _responseText = _text;
    return _text;
  }

  Future<List<String>> getTextChunks(String filePath) async {
    var text = await getPDFtext(filePath);
    var textSplitter = const RecursiveCharacterTextSplitter(
        chunkSize: 10000, chunkOverlap: 1000);
    var chunks = textSplitter.splitText(text);
    return chunks;
  }

  Future<MemoryVectorStore> getVectorStore(String filePath) async {
    var text = await getTextChunks(filePath);
    var embeddings =
        GoogleGenerativeAIEmbeddings(apiKey: dotenv.env['GEMINI_API']);
    final vectorStore = await MemoryVectorStore.fromText(
      texts: text,
      embeddings: embeddings,
    );
    return vectorStore;
  }

  getRes(String query, MemoryVectorStore vectorStore) async {
    _loading = true;
    notifyListeners();

    const promptTemplate = PromptTemplate(
      inputVariables: {"context", "question"},
      template:
          """Answer the question as detailed as possible from the provided context, make sure to provide all the details, if the answer is not in
    provided context just say, "answer is not available in the context", don't provide the wrong answer\n\n
    Context:\n {context}?\n
    Question: \n{question}\n

    Answer:""",
    );
    try {
      var chain = LLMChain(
          llm: model, prompt: promptTemplate.partial({"question": query}));

      final qaChain = StuffDocumentsChain(
        llmChain: chain,
      );

      final retrievalQA = RetrievalQAChain(
          retriever: vectorStore.asRetriever(), combineDocumentsChain: qaChain);

      final res = await retrievalQA(query);
      _messages.add(Message(sender: 'user', content: query));
      _messages.add(Message(sender: 'model', content: res['result']));
      _scrollDown();
    } catch (e) {
      print(e.toString());
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
