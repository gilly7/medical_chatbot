import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/image_upload.dart';
import 'package:hive/hive.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  final GeminiService _geminiService = GeminiService();
  String? _selectedImagePath;
  late Box<Message> _messageBox;

  @override
  void initState() {
    super.initState();
    _messageBox = Hive.box<Message>('messages');
    _messages.addAll(_messageBox.values);
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImagePath == null) return;

    final userMessage = Message(
      text: text,
      isUser: true,
      imageUrl: _selectedImagePath,
    );
    setState(() {
      _messages.add(userMessage);
      _controller.clear();
      _selectedImagePath = null;
    });
    await _messageBox.add(userMessage);

    final response = await _geminiService.getResponse(
      text,
      imagePath: _selectedImagePath,
    );
    final botMessage = Message(text: response, isUser: false);
    setState(() {
      _messages.add(botMessage);
    });
    await _messageBox.add(botMessage);
  }

  void _onImageSelected(String path) {
    setState(() {
      _selectedImagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medical Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  ChatBubble(message: _messages[index]),
            ),
          ),
          ImageUpload(onImageSelected: _onImageSelected),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask a health question...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
