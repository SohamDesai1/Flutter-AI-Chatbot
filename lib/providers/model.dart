import 'package:flutter_riverpod/flutter_riverpod.dart';

final modelSelectorProvider = StateNotifierProvider<ModelSelector, String>((ref) {
  return ModelSelector();
});

class ModelSelector extends StateNotifier<String> {
  ModelSelector() : super('gemini-1.5-flash-latest');

  void setModel(String modelName) {
    state = modelName;
  }
}
