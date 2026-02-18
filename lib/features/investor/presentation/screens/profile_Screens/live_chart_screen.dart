import 'dart:io';

import 'package:farm_vest/core/services/biometric_service.dart'
    show BiometricService;
import 'package:farm_vest/core/utils/app_enums.dart';
import 'package:farm_vest/core/utils/image_helper_compressor.dart';
import 'package:farm_vest/core/utils/string_extensions.dart';
import 'package:farm_vest/features/investor/presentation/widgets/support/chat_bubble.dart';
import 'package:farm_vest/features/investor/presentation/widgets/support/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          ("Please stay on the chat screen. The next available representative will join shortly.".tr),
      type: MessageType.system,
      time: DateTime.now(),
    ),
    ChatMessage(
      text: ("Hi, my name is Durga, and I am here to assist you.".tr),
      type: MessageType.ai,
      time: DateTime.now(),
    ),
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          imageFile: _selectedImage,
          type: MessageType.user,
          time: DateTime.now(),
        ),
      );
      _isTyping = true;
      _selectedImage = null;
    });

    _controller.clear();

    // Simulate AI reply
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(
            text:( "Thanks for sharing. I’m checking this now.".tr),
            type: MessageType.ai,
            time: DateTime.now(),
          ),
        );
      });
    });
  }

  void _endChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('End Chat'.tr),
        content:  Text('Are you sure you want to end this session?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close chat screen
            },
            child:  Text('End Chat'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Chat with us".tr),
        actions: [
          TextButton(
            onPressed: _endChat,
            child:  Text(
              "End Chat".tr,
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                      child: TypingIndicator(),
                    ),
                  );
                }
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            // 🔹 IMAGE THUMBNAIL INSIDE INPUT
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: FileImage(_selectedImage!),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedImage = null);
                      },
                      child: const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            // 🔹 TEXT FIELD
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Start typing your message".tr,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            // 🔹 IMAGE PICKER
            IconButton(
              icon: const Icon(Icons.photo_sharp),
              onPressed: () {
                _pickFromGallery(compress: true, isDocument: true);
              },
            ),

            // 🔹 SEND BUTTON
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepPurple),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery({
    bool compress = true,
    bool isDocument = true,
  }) async {
    try {
      final XFile? image = await BiometricService.runWithLockSuppressed(() {
        return _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      });
      if (image == null) return;
      File selectedFile = File(image.path);
      if (compress) {
        final compressedFile =
            await ImageCompressionHelper.getCompressedImageIfNeeded(
              selectedFile,
              maxSizeKB: 250,
              isDocument: isDocument,
            );
        selectedFile = compressedFile;
      }
      if (!mounted) return;
      setState(() {
        _selectedImage = selectedFile;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image'.tr)));
    }
  }
}
