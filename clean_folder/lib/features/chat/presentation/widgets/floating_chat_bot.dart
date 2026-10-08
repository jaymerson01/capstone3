import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/utils/direct_caller_helper.dart';
import 'package:community_safety_app/features/incident/data/datasources/incident_ai_remote_data_source.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';

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
  late final IncidentAiRemoteDataSource _aiDataSource;

  final List<Map<String, dynamic>> _messages = [
    {
      'text':
          'Mabuhay! I am your Barangay Moonwalk Civil Defense & Safety Assistant. How can I protect and assist you today? You can choose a quick topic below or type your emergency concern.',
      'isUser': false,
      'isAi': false,
      'hotlines': <Map<String, String>>[],
    },
  ];

  final List<String> _suggestedQuestions = [
    "What should I do during a fire?",
    "What to prepare during a flood?",
    "How to stop severe bleeding?",
    "Someone is following me",
    "How to perform CPR?",
    "Amoy gasul / LPG gas leak",
  ];

  @override
  void initState() {
    super.initState();
    _aiDataSource = IncidentAiRemoteDataSourceImpl(client: http.Client());
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

  List<Map<String, String>> _detectHotlines(String text) {
    final lower = text.toLowerCase();
    final List<Map<String, String>> hotlines = [];

    final bool isFire = lower.contains('fire') ||
        lower.contains('sunog') ||
        lower.contains('burn') ||
        lower.contains('smoke') ||
        lower.contains('usok');

    final bool isMedical = lower.contains('bleed') ||
        lower.contains('dugo') ||
        lower.contains('cpr') ||
        lower.contains('heart') ||
        lower.contains('unconscious') ||
        lower.contains('malay') ||
        lower.contains('fracture') ||
        lower.contains('injury') ||
        lower.contains('sugat') ||
        lower.contains('ambulance');

    final bool isPolice = lower.contains('follow') ||
        lower.contains('stalk') ||
        lower.contains('sinusundan') ||
        lower.contains('knife') ||
        lower.contains('kutsilyo') ||
        lower.contains('gun') ||
        lower.contains('baril') ||
        lower.contains('thief') ||
        lower.contains('magnanakaw') ||
        lower.contains('holdap') ||
        lower.contains('nakaw') ||
        lower.contains('intruder') ||
        lower.contains('threat');

    final bool isDisaster = lower.contains('flood') ||
        lower.contains('baha') ||
        lower.contains('bagyo') ||
        lower.contains('typhoon') ||
        lower.contains('lindol') ||
        lower.contains('earthquake') ||
        lower.contains('gas') ||
        lower.contains('lpg');

    if (isFire) {
      hotlines.add({'title': 'Fire 112', 'number': '112', 'type': 'fire'});
    }
    if (isMedical) {
      hotlines.add({'title': 'Red Cross 143', 'number': '143', 'type': 'medical'});
    }
    if (isPolice || hotlines.isEmpty) {
      hotlines.add({'title': 'Police 911', 'number': '911', 'type': 'police'});
    }
    if (isDisaster || hotlines.length < 2) {
      hotlines.add({
        'title': 'Barangay Desk',
        'number': '888-9999',
        'type': 'barangay',
      });
    }

    return hotlines;
  }

  String _getHardcodedAnswer(String message) {
    final text = message.toLowerCase();

    if (text.contains('fire') ||
        text.contains('burning') ||
        text.contains('sunog')) {
      return '''1. Evacuate immediately! Do not stop for belongings.
2. Stay low crawl beneath the smoke where air is cleaner.
3. Feel doors for heat before opening. Never open a hot door.
4. Call Fire Command 112 or 911 once safely outside.
5. Proceed to the designated neighborhood assembly point. Never go back inside.''';
    }

    if (text.contains('bleed') ||
        text.contains('dugo') ||
        text.contains('sugat')) {
      return '''1. Apply continuous firm pressure directly on the wound with a clean cloth or gauze.
2. If cloth soaks through, add another layer on top do NOT remove the first cloth.
3. Elevate the wounded limb above heart level if no broken bones are suspected.
4. Keep the injured person calm and warm.
5. Call Red Cross 143 or 911 immediately for severe hemorrhage.''';
    }

    if (text.contains('cpr') ||
        text.contains('heart') ||
        text.contains('unconscious') ||
        text.contains('malay')) {
      return '''1. Check responsiveness: Tap shoulders firmly and shout "Are you okay?".
2. Call 911 or Red Cross 143 and request an Automated External Defibrillator (AED).
3. If not breathing, place heel of hand on center of chest with other hand interlocked on top.
4. Push hard and fast at 100-120 beats per minute (2 inches deep).
5. Do not stop chest compressions until medical responders take over.''';
    }

    if (text.contains('following') ||
        text.contains('stalking') ||
        text.contains('stranger') ||
        text.contains('sinusundan')) {
      return '''1. Stay calm and DO NOT go directly home.
2. Head immediately towards a crowded, well-lit place, 24/7 store, or Barangay Outpost.
3. Call a family member or Barangay Moonwalk Desk (888-9999) to announce your location.
4. Take note of description, clothing, and vehicle plate if safe to do so.
5. If approached aggressively, make loud noise and yell "Help! Police!" to draw attention.''';
    }

    if (text.contains('flood') ||
        text.contains('bagyo') ||
        text.contains('baha') ||
        text.contains('rain') ||
        text.contains('calamity')) {
      return '''1. Turn off main circuit breaker and LPG gas tanks before floodwaters enter.
2. Evacuate early to the designated Barangay Moonwalk Multi-Purpose Hall.
3. Grab your Go-Bag: drinking water, canned food, flashlight, power bank, and vital IDs.
4. NEVER wade or drive through moving floodwaters (risk of leptospirosis & open manholes).
5. Monitor official Barangay Moonwalk DRRMO radio broadcasts.''';
    }

    if (text.contains('gas') || text.contains('lpg') || text.contains('amoy')) {
      return '''1. Do NOT turn on or off any electric switches, lights, or stove burners.
2. Do not use your smartphone inside the room.
3. Open all exterior windows and doors immediately to vent the fumes.
4. Close the LPG cylinder regulator valve if safe.
5. Evacuate outside and call Bureau of Fire Protection (112).''';
    }

    if (text.contains('earthquake') || text.contains('lindol')) {
      return '''1. DROP, COVER, and HOLD ON under a sturdy table or desk immediately.
2. Shield head and neck with your arms away from glass windows and heavy fixtures.
3. Wait until shaking completely stops before evacuating via stairs (no elevators).
4. Watch out for falling debris, downed power lines, and aftershocks outside.
5. Proceed to the nearest open space or barangay sports complex.''';
    }

    if (text.contains('hello') || text.contains('hi') || text.contains('kumusta')) {
      return "Hello! I am your 24/7 Barangay Moonwalk Civil Defense Assistant. You can ask me what to do during emergencies like fires, floods, medical trauma, or how to report an incident.";
    }

    if (text.contains('report') || text.contains('incident')) {
      return "To file an emergency or community report, tap 'Report Incident' on your home screen, select the category, verify the GPS location, attach photos/video, and submit.";
    }

    return "For any active danger, please prioritize your physical safety and dial 911 or the Barangay Desk (888-9999). You can ask me about fire safety, flood preparation, CPR, severe bleeding, or suspicious persons.";
  }

  void _sendMessage({String? selectedQuestion}) async {
    final userMessage = selectedQuestion ?? _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({
        'text': userMessage,
        'isUser': true,
        'isAi': false,
        'hotlines': <Map<String, String>>[],
      });
      _messageController.clear();
      _isBotTyping = true;
    });
    _scrollToBottom();

    // Prepare conversational history for Gemini 1.5 Flash
    final history = _messages
        .where((m) => m['text'] is String)
        .map((m) => {
              'role': (m['isUser'] == true) ? 'user' : 'model',
              'text': m['text'] as String,
            })
        .toList();

    String botAnswer;
    bool isAiResponse = false;

    try {
      botAnswer = await _aiDataSource.askCivilDefenseAssistant(
        userMessage: userMessage,
        history: history,
      );
      isAiResponse = true;
    } catch (e) {
      debugPrint('[FloatingChatBot] AI error: $e. Falling back to municipal civil defense procedures.');
      botAnswer = _getHardcodedAnswer(userMessage);
      isAiResponse = false;
    }

    if (!mounted) return;

    final hotlines = _detectHotlines('$userMessage $botAnswer');

    setState(() {
      _isBotTyping = false;
      _messages.add({
        'text': botAnswer,
        'isUser': false,
        'isAi': isAiResponse,
        'hotlines': hotlines,
      });
    });
    _scrollToBottom();
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add({
          'text':
              'Mabuhay! I am your Barangay Moonwalk Civil Defense & Safety Assistant. How can I protect and assist you today? You can choose a quick topic below or type your emergency concern.',
          'isUser': false,
          'isAi': false,
          'hotlines': <Map<String, String>>[],
        });
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chatWidth = (screenWidth - 32).clamp(300.0, 360.0);
    const chatHeight = 540.0;

    return Positioned(
      right: 16.0,
      bottom: 16.0,
      child: AnimatedContainer(
        width: _isOpen ? chatWidth : 60,
        height: _isOpen ? chatHeight : 60,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _isOpen ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(_isOpen ? 24 : 30),
          border: _isOpen ? Border.all(color: AppColors.border) : null,
          boxShadow: _isOpen
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: _isOpen ? _buildChatWindow(chatWidth, chatHeight) : _buildFAB(),
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
            child: Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatWindow(double width, double height) {
    return OverflowBox(
      minWidth: width,
      maxWidth: width,
      minHeight: height,
      maxHeight: height,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Civil Defense Assistant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00E676),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "Barangay Moonwalk • Active",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _isOpen = false),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
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
          Text(
            "Quick Civil Defense Guides",
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 7),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedQuestions.length,
              separatorBuilder: (_, _) => SizedBox(width: 7),
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
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      _suggestedQuestions[i],
                      style: TextStyle(color: AppColors.primary,
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
          final hotlines = (msg['hotlines'] as List<dynamic>?)
                  ?.map((e) => Map<String, String>.from(e as Map))
                  .toList() ??
              <Map<String, String>>[];

          return _messageBubble(
            text: msg['text'] as String,
            isUser: msg['isUser'] as bool,
            isAi: msg['isAi'] == true,
            hotlines: hotlines,
          );
        },
      ),
    );
  }

  Widget _messageBubble({
    required String text,
    required bool isUser,
    required bool isAi,
    required List<Map<String, String>> hotlines,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: const BoxConstraints(maxWidth: 280),
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
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAi ? Icons.auto_awesome : Icons.security,
                    size: 12,
                    color: isAi ? AppColors.primary : AppColors.textLight,
                  ),
                  SizedBox(width: 4),
                  Text(
                    isAi ? "RESQ GEMINI AI" : "CIVIL DEFENSE OFFICER",
                    style: TextStyle(
                      color: isAi ? AppColors.primary : AppColors.textLight,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.textDark,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            if (!isUser && hotlines.isNotEmpty) ...[
              SizedBox(height: 10),
              Divider(color: AppColors.border, height: 1),
              SizedBox(height: 8),
              Text(
                "Immediate Hotline Dialers:",
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...hotlines.map((h) => _buildHotlinePill(h)),
                  _buildAllHotlinesPill(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHotlinePill(Map<String, String> hotline) {
    final title = hotline['title'] ?? 'Emergency';
    final number = hotline['number'] ?? '911';
    final type = hotline['type'] ?? '';

    Color btnColor = AppColors.primary;
    if (type == 'fire' || type == 'medical' || number == '911') {
      btnColor = AppColors.danger;
    }

    return GestureDetector(
      onTap: () => DirectCallerHelper.makeDirectCall(context, number, label: title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: btnColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: btnColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call, size: 11, color: btnColor),
            SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: btnColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllHotlinesPill() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EmergencyHotlinesPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contact_phone_outlined,
                size: 11, color: AppColors.textLight),
            SizedBox(width: 4),
            Text(
              "All Hotlines",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
          borderRadius: BorderRadius.circular(16).copyWith(topLeft: Radius.zero),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            SizedBox(width: 4),
            _TypingDot(delay: 200),
            SizedBox(width: 4),
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
        border: Border(top: BorderSide(color: AppColors.border)),
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
                style: TextStyle(fontSize: 13, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Ask safety or first-aid guide...',
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
          SizedBox(width: 8),
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
              child: Icon(
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
