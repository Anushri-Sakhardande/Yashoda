import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _apiKey = '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';
  static const String _apiUrl = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
          'HTTP-Referer': 'https://yourapp.com', // Use your domain or placeholder
          'X-Title': 'Yashoda AI',
        },
        body: jsonEncode({
          'model': 'openai/gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant for new mothers and pregnant women.'},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}';
      }
    } catch (e) {
      return 'Failed to connect to OpenRouter: $e';
    }
  }
}
