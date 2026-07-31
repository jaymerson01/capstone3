/*import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class FloatingChatBot extends StatefulWidget {
  const FloatingChatBot({super.key});

  @override
  State<FloatingChatBot> createState() => _FloatingChatBotState();
}

class _FloatingChatBotState extends State<FloatingChatBot>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  bool _isBotTyping = false;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fabPulse;

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Hello! I am your Community Safety Assistant. Choose a question below or type your safety concern.',
      'isUser': false,
    },
  ];

  final List<String> _suggestedQuestions = [
    "What should I do during a fire?",
    "What if someone is following me?",
    "What to prepare during flood?",
  ];

  @override
  void initState() {
    super.initState();
    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabPulse.dispose();
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
      return '''During a fire:

1. Stay calm and leave immediately.
2. Do not try to save belongings.
3. Warn nearby people if safe.
4. Stay low if there is smoke.
5. Cover your nose and mouth.
6. Do not use elevators.
7. Call fire station or emergency hotline.
8. Move to an open safe area.

Important: Do not go back inside.''';
    }

    if (text.contains('following') ||
        text.contains('stalking') ||
        text.contains('stranger')) {
      return '''If someone is following you:

1. Stay calm.
2. Do not go home directly.
3. Go to a crowded, well-lit place.
4. Enter a store or barangay outpost.
5. Call a trusted person.
6. Avoid isolated streets.
7. Do not confront the person.
8. Call police or barangay if needed.

Important: Go where there are people.''';
    }

    if (text.contains('flood') ||
        text.contains('bagyo') ||
        text.contains('rain') ||
        text.contains('calamity')) {
      return '''Prepare before/during flood:

1. Drinking water.
2. Ready-to-eat food.
3. Flashlight and batteries.
4. Charged phone and power bank.
5. First-aid kit and medicines.
6. Documents in waterproof bag.
7. Extra clothes and hygiene items.
8. Emergency contacts and cash.

During flood: Move to higher ground. Avoid floodwater. Follow barangay announcements.''';
    }

    if (text.contains('hello') || text.contains('hi')) {
      return "Hello! Stay safe. You can choose one of the quick safety questions or type your concern.";
    }

    if (text.contains('report') || text.contains('incident')) {
      return "To report an incident, tap Report Incident on your dashboard, choose the category, add location/details, then submit.";
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

    Future.delayed(const Duration(milliseconds: 700), () {
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
      _messages
        ..clear()
        ..add({
          'text':
              'Hello! I am your Community Safety Assistant. Choose a question below or type your safety concern.',
          'isUser': false,
        });
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16.0,
      bottom: 16.0,
      child: AnimatedContainer(
        width: _isOpen ? 340 : 60,
        height: _isOpen ? 520 : 60,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _isOpen ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(_isOpen ? 24 : 30),
          border: _isOpen ? Border.all(color: AppColors.border) : null,
          boxShadow: _isOpen
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: _isOpen ? _buildChatWindow() : _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _fabPulse,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => setState(() => _isOpen = true),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.4 + 0.25 * _fabPulse.value,
                  ),
                  blurRadius: 16 + 8 * _fabPulse.value,
                  spreadRadius: 1 + _fabPulse.value,
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatWindow() {
    return OverflowBox(
      minWidth: 340,
      maxWidth: 340,
      minHeight: 520,
      maxHeight: 520,
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          _buildHeader(),
          _buildQuickChips(),
          Expanded(child: _buildMessages()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Safety Assistant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Always here to help",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _clearChat,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _isOpen = false),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Questions",
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () =>
                      _sendMessage(selectedQuestion: _suggestedQuestions[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      _suggestedQuestions[i],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10.5,
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
      color: AppColors.background,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _messages.length + (_isBotTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isBotTyping && index == _messages.length) {
            return _typingBubble();
          }
          final msg = _messages[index];
          return _messageBubble(
            text: msg['text'] as String,
            isUser: msg['isUser'] as bool,
          );
        },
      ),
    );
  }

  Widget _messageBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 265),
        decoration: BoxDecoration(
          gradient: isUser ? AppColors.primaryGradient : null,
          color: isUser ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            topLeft: isUser ? const Radius.circular(16) : Radius.zero,
          ),
          border: isUser ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textDark,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _typingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(
            16,
          ).copyWith(topLeft: Radius.zero),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 200),
            const SizedBox(width: 4),
            _TypingDot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Type your safety concern...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
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

/// Animated typing dot
class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween<double>(
      begin: 0,
      end: -6,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _anim.value),
          child: child,
        );
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
*/
