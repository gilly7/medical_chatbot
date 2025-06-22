import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class GeminiService {
  late final GenerativeModel model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env');
    }
    model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      systemInstruction: Content.text(
        'You are a medical assistant. Provide accurate, general health advice but clarify you are not a doctor.',
      ),
    );
  }

  Future<String> getResponse(String prompt, {String? imagePath}) async {
    final content = [
      Content.text(prompt),
      if (imagePath != null)
        Content.data('image/jpeg', await File(imagePath).readAsBytes()),
    ];
    final response = await model.generateContent(content);
    return response.text ?? 'No response';
  }
}
