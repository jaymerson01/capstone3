import 'package:flutter/material.dart';
import '../theme/app_color.dart'; // Adjust this path if necessary

class FloatingChatBot extends StatefulWidget {
  const FloatingChatBot({super.key});

  @override
  State<FloatingChatBot> createState() => _FloatingChatBotState();
}

class _FloatingChatBotState extends State<FloatingChatBot> {
  bool _isOpen = false;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I am your Community Safety AI Assistant. How can I help you today?',
      'isUser': false,
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      // 1. Add user message
      _messages.add({'text': _messageController.text, 'isUser': true});

      String userText = _messageController.text.toLowerCase();
      _messageController.clear();

      // 2. Simulate AI response delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          String reply =
              "I am processing your request regarding community safety. Please contact local authorities if this is an immediate emergency.";

          if (userText.contains('hello') || userText.contains('hi')) {
            reply = "Hello there! Stay safe. What can I assist you with?";
          } else if (userText.contains('report') ||
              userText.contains('incident')) {
            reply =
                "To report an incident, please navigate to the reporting section or use our emergency shortcuts.";
          }

          _messages.add({'text': reply, 'isUser': false});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          // Change right and bottom to 16 so it offsets perfectly inside its local space
          right: 16,
          bottom: 16,
          width: _isOpen ? 330 : 56,
          height: _isOpen ? 450 : 56,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(_isOpen ? 16 : 28),
            clipBehavior: Clip.antiAlias,
            color: _isOpen ? Colors.white : AppColors.darkGreen,
            child: _isOpen ? _buildChatWindow() : _buildChatButton(),
          ),
        ),
      ],
    );
  }

  // Minimized state: Simple Floating Action Button look-alike
  Widget _buildChatButton() {
    return InkWell(
      onTap: () => setState(() => _isOpen = true),
      child: const Center(
        child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // Expanded state: Windowed UI Component
  Widget _buildChatWindow() {
    return Column(
      children: [
        // Header
        Container(
          color: AppColors.darkGreen,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Safety AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => setState(() => _isOpen = false),
              ),
            ],
          ),
        ),

        // Chat Body Messages List
        Expanded(
          child: Container(
            color: const Color(0xFFF7F9FA), // Subtle grey backdrop for messages
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.darkGreen : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                        topLeft: !isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Input Field Footer
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Type your safety concern...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: AppColors.darkGreen,
                ),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
