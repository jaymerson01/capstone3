import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class FloatingChatBot extends StatefulWidget {
  const FloatingChatBot({super.key});

  @override
  State<FloatingChatBot> createState() => _FloatingChatBotState();
}

class _FloatingChatBotState extends State<FloatingChatBot> {
  bool _isOpen = false;
  bool _isBotTyping = false;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I am your Community Safety Assistant. Choose a question below or type your safety concern.',
      'isUser': false,
    },
  ];

  final List<String> _suggestedQuestions = [
    "What should I do during a fire?",
    "What should I do if someone is following me?",
    "What should I prepare during flood?",
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _getHardcodedAnswer(String message) {
    final text = message.toLowerCase();

    if (text.contains('fire') || text.contains('burning')) {
      return '''
During a fire:

1. Stay calm and leave the area immediately.
2. Do not try to save belongings.
3. Warn nearby people if it is safe.
4. Stay low if there is smoke.
5. Cover your nose and mouth with cloth.
6. Do not use elevators.
7. Call fire station, barangay, or emergency hotline.
8. Move to an open and safe area.

Important: Do not go back inside the burning house or building.
''';
    }

    if (text.contains('following') ||
        text.contains('stalking') ||
        text.contains('stranger')) {
      return '''
If someone is following you:

1. Stay calm.
2. Do not go home directly.
3. Go to a crowded or well-lit place.
4. Enter a nearby store, barangay outpost, or guard post.
5. Call a trusted person and share your location.
6. Avoid isolated streets or shortcuts.
7. Do not confront the person.
8. Call police or barangay if the person continues following you.

Important: Go where there are people and ask for help.
''';
    }

    if (text.contains('flood') ||
        text.contains('bagyo') ||
        text.contains('rain') ||
        text.contains('calamity')) {
      return '''
Prepare these before or during flood:

1. Drinking water.
2. Ready-to-eat food.
3. Flashlight and extra batteries.
4. Power bank and charged phone.
5. First-aid kit and medicines.
6. Important documents in waterproof bag.
7. Extra clothes and hygiene items.
8. Emergency contact list and cash.

During flood:
- Move to higher ground.
- Avoid floodwater.
- Turn off electricity if safe.
- Follow barangay announcements.
''';
    }

    if (text.contains('hello') || text.contains('hi')) {
      return "Hello! Stay safe. You can choose one of the quick safety questions or type your concern.";
    }

    if (text.contains('report') || text.contains('incident')) {
      return "To report an incident, tap the Report Incident button on your dashboard, choose the category, add location/details, then submit.";
    }

    if (text.contains('emergency') || text.contains('help')) {
      return "If this is an immediate emergency, contact the barangay, police, fire station, ambulance, or emergency hotline right away.";
    }

    return "I can answer basic safety concerns. Try asking about fire, flood, emergency, reporting an incident, or what to do if someone is following you.";
  }

  void _sendMessage({String? selectedQuestion}) {
    final userMessage = selectedQuestion ?? _messageController.text.trim();

    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({'text': userMessage, 'isUser': true});

      _messageController.clear();
      _isBotTyping = true;
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      setState(() {
        _isBotTyping = false;
        _messages.add({
          'text': _getHardcodedAnswer(userMessage),
          'isUser': false,
        });
      });

      _scrollToBottom();
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add({
        'text':
            'Hello! I am your Community Safety Assistant. Choose a question below or type your safety concern.',
        'isUser': false,
      });
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          right: 16,
          bottom: 16,
          width: _isOpen ? 340 : 56,
          height: _isOpen ? 500 : 56,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(_isOpen ? 18 : 28),
            clipBehavior: Clip.antiAlias,
            color: _isOpen ? Colors.white : AppColors.darkGreen,
            child: _isOpen ? _buildChatWindow() : _buildChatButton(),
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton() {
    return InkWell(
      onTap: () {
        setState(() {
          _isOpen = true;
        });
      },
      child: const Center(
        child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildChatWindow() {
    return Column(
      children: [
        _buildHeader(),
        _buildQuestionButtons(),
        Expanded(child: _buildMessages()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.darkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Safety Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          InkWell(
            onTap: _clearChat,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              setState(() {
                _isOpen = false;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionButtons() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Questions",
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedQuestions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final question = _suggestedQuestions[index];

                return InkWell(
                  onTap: () => _sendMessage(selectedQuestion: question),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.darkGreen.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      question,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Container(
      color: const Color(0xFFF7F9FA),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _messages.length + (_isBotTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isBotTyping && index == _messages.length) {
            return _buildTypingBubble();
          }

          final message = _messages[index];
          final bool isUser = message['isUser'] as bool;

          return _buildMessageBubble(
            text: message['text'] as String,
            isUser: isUser,
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isUser ? AppColors.darkGreen : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(12),
            topLeft: !isUser
                ? const Radius.circular(0)
                : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 13,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(
            12,
          ).copyWith(topLeft: const Radius.circular(0)),
        ),
        child: const Text(
          "Assistant is typing...",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Type your safety concern...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12.5),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _sendMessage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                color: AppColors.darkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
