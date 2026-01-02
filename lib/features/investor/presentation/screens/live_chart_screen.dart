import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/features/investor/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Please stay on the chat screen. The next available representative will join shortly.",
      type: MessageType.system,
      time: DateTime.now(),
    ),
    ChatMessage(
      text: "Hi, my name is Durga, and I am here to assist you.",
      type: MessageType.ai,
      time: DateTime.now(),
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: _controller.text,
      type: MessageType.user,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
    });

    _controller.clear();

    // Simulate AI reply (replace with API call)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "I understand your concern. Let me check this for you.",
            type: MessageType.ai,
            time: DateTime.now(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with us"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "End Chat",
              style: TextStyle(color: Colors.orange),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Start typing your message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  isDense: true,
                  suffixIcon: const Icon(Icons.photo_sharp)
                ),
                
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepPurple),
              onPressed: _sendMessage,
            )
          ],
        ),
      ),
    );
  }
}
