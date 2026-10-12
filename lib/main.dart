import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'services/tools_api.dart';

// Flexible API configuration: change only the URL and API key.
// Groq:   https://api.groq.com/openai/v1
// OpenAI: https://api.openai.com/v1
// Any OpenAI-compatible provider works.
const String kApiBaseUrl = 'https://api.groq.com/openai/v1';
const String kApiEndpoint = '/chat/completions';
const String kApiModel = 'llama-3.3-70b-versatile';
const String kApiKey = String.fromEnvironment('GROQ_API_KEY');

void main() {
  runApp(const OmniLifeAIApp());
}

class OmniLifeAIApp extends StatefulWidget {
  const OmniLifeAIApp({super.key});

  @override
  State<OmniLifeAIApp> createState() => _OmniLifeAIAppState();
}

class _OmniLifeAIAppState extends State<OmniLifeAIApp> {
  Locale _locale = const Locale('en');

  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OmniLife AI',
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        textTheme: ThemeData.dark().textTheme,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFA855F7),
          secondary: Color(0xFF3B82F6),
        ),
      ),
      home: MainNavigationScreen(
        changeLocale: _changeLocale,
        currentLocale: _locale,
      ),
    );
  }
}

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'greeting': 'Hello! How can I help you today?',
      'inputHint': 'Type a message...',
      'home': 'Home',
      'chat': 'Chat',
      'tools': 'Tools',
      'history': 'History',
      'profile': 'Profile',
      'premium': 'Premium User',
      'aiChatBot': 'AI Chat Bot',
      'aiAssistant': 'OmniLife AI',
      'instantAnswers': 'Get instant answers and\nsmart support with AI Chat.',
      'language': 'Language',
      'logout': 'Logout',
      'noHistory': 'No conversations yet',
      'startChat': 'Start a new conversation',
      'typing': 'Typing...',
      'voiceCommand': 'Voice Command',
      'videoAudio': 'Video to Audio',
      'audioText': 'Audio to Text',
      'textVoice': 'Text to Speech',
      'selectFile': 'Select File',
      'processing': 'Processing...',
      'done': 'Done!',
      'settings': 'Settings',
      'about': 'About',
      'version': 'Version',
      'clear': 'Clear',
    },
    'ar': {
      'greeting': 'أهلاً بك! كيف يمكنني مساعدتك اليوم؟',
      'inputHint': 'اكتب رسالتك...',
      'home': 'الرئيسية',
      'chat': 'الدردشة',
      'tools': 'الأدوات',
      'history': 'السجل',
      'profile': 'الملف',
      'premium': 'مستخدم مميز',
      'aiChatBot': 'مساعد AI',
      'aiAssistant': 'OmniLife AI',
      'instantAnswers': 'احصل على إجابات فورية\nودعم ذكي من الذكاء الاصطناعي',
      'language': 'اللغة',
      'logout': 'تسجيل خروج',
      'noHistory': 'لا توجد محادثات بعد',
      'startChat': 'ابدأ محادثة جديدة',
      'typing': 'يكتب...',
      'voiceCommand': 'أمر صوتي',
      'videoAudio': 'فيديو لصوت',
      'audioText': 'صوت لنص',
      'textVoice': 'نص لصوت',
      'selectFile': 'اختر ملف',
      'processing': 'جاري المعالجة...',
      'done': 'تم!',
      'settings': 'الإعدادات',
      'about': 'حول',
      'version': 'الإصدار',
      'clear': 'مسح',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class MainNavigationScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final Locale currentLocale;

  const MainNavigationScreen({
    super.key,
    required this.changeLocale,
    required this.currentLocale,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.currentLocale.languageCode == 'ar';
    final l10n = AppLocalizations(widget.currentLocale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(l10n),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(
              currentLocale: widget.currentLocale,
              changeLocale: widget.changeLocale,
              openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
              navigateToChat: () => setState(() => _currentIndex = 1),
            ),
            ChatScreen(currentLocale: widget.currentLocale),
            ToolsScreen(currentLocale: widget.currentLocale),
            HistoryScreen(currentLocale: widget.currentLocale),
            ProfileScreen(
              currentLocale: widget.currentLocale,
              changeLocale: widget.changeLocale,
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(l10n),
      ),
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF0D0D0D),
                    child: Icon(Icons.person, size: 28, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OmniLife User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.get('premium'),
                        style: const TextStyle(
                          color: Color(0xFFA855F7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          _drawerItem(Icons.home_outlined, l10n.get('home'), () {
            Navigator.pop(context);
            setState(() => _currentIndex = 0);
          }),
          _drawerItem(Icons.chat_bubble_outline, l10n.get('chat'), () {
            Navigator.pop(context);
            setState(() => _currentIndex = 1);
          }),
          _drawerItem(Icons.build_outlined, l10n.get('tools'), () {
            Navigator.pop(context);
            setState(() => _currentIndex = 2);
          }),
          _drawerItem(Icons.history, l10n.get('history'), () {
            Navigator.pop(context);
            setState(() => _currentIndex = 3);
          }),
          _drawerItem(Icons.person_outline, l10n.get('profile'), () {
            Navigator.pop(context);
            setState(() => _currentIndex = 4);
          }),
          const Divider(color: Colors.white12),
          _drawerItem(Icons.language, l10n.get('language'), () {
            Navigator.pop(context);
            _showLanguageDialog();
          }),
          _drawerItem(Icons.settings_outlined, l10n.get('settings'), () {
            Navigator.pop(context);
          }),
          _drawerItem(Icons.info_outline, l10n.get('about'), () {
            Navigator.pop(context);
          }),
          const Spacer(),
          _drawerItem(Icons.logout, l10n.get('logout'), () {
            Navigator.pop(context);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(AppLocalizations(widget.currentLocale).get('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: widget.currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Color(0xFFA855F7))
                  : null,
              onTap: () {
                widget.changeLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              trailing: widget.currentLocale.languageCode == 'ar'
                  ? const Icon(Icons.check, color: Color(0xFFA855F7))
                  : null,
              onTap: () {
                widget.changeLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 0, l10n.get('home')),
          _navItem(Icons.chat_bubble_rounded, 1, l10n.get('chat')),
          _buildCenterButton(),
          _navItem(Icons.build_rounded, 2, l10n.get('tools')),
          _navItem(Icons.menu_rounded, 3, l10n.get('history')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA855F7).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFA855F7) : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFA855F7) : Colors.grey,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x66A855F7),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 24),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) changeLocale;
  final VoidCallback openDrawer;
  final VoidCallback navigateToChat;

  const HomeScreen({
    super.key,
    required this.currentLocale,
    required this.changeLocale,
    required this.openDrawer,
    required this.navigateToChat,
  });

  AppLocalizations get l10n => AppLocalizations(currentLocale);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildTheOrb(),
              const SizedBox(height: 30),
              _buildDescription(),
              const SizedBox(height: 30),
              _buildQuickActions(),
              const SizedBox(height: 30),
              _buildAIFeatures(),
              const SizedBox(height: 20),
              _buildToolsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: openDrawer,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 24),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => changeLocale(
                currentLocale.languageCode == 'en'
                    ? const Locale('ar')
                    : const Locale('en'),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentLocale.languageCode == 'en' ? 'عربي' : 'EN',
                  style: const TextStyle(
                    color: Color(0xFFA855F7),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: openDrawer,
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFA855F7),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTheOrb() {
    return Center(
      child: GestureDetector(
        onTap: navigateToChat,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withOpacity(0.4),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
                gradient: const RadialGradient(
                  colors: [Color(0xFF2D1B4E), Color(0xFF050505)],
                ),
              ),
            ),
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFA855F7).withOpacity(0.8),
                    const Color(0xFF3B82F6).withOpacity(0.8),
                  ],
                ),
              ),
              child: const Icon(Icons.blur_on, size: 80, color: Colors.white),
            ),
            const Positioned(
              bottom: 30,
              child: Icon(Icons.mic, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Center(
      child: Column(
        children: [
          Text(
            currentLocale.languageCode == 'en' ? 'Tap to start' : 'اضغط للبدء',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.get('instantAnswers').replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionBtn(
            Icons.chat_bubble,
            l10n.get('chat'),
            navigateToChat,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionBtn(
            Icons.image,
            l10n.get('aiChatBot'),
            navigateToChat,
          ),
        ),
      ],
    );
  }

  Widget _quickActionBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFA855F7), size: 24),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentLocale.languageCode == 'en' ? 'AI Assistants' : 'مساعدين AI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _aiCard('DeepSeek', 'Chinese', Icons.auto_awesome)),
            const SizedBox(width: 12),
            Expanded(child: _aiCard('GPT-4', 'OpenAI', Icons.bolt)),
            const SizedBox(width: 12),
            Expanded(child: _aiCard('Claude', 'Anthropic', Icons.psychology)),
          ],
        ),
      ],
    );
  }

  Widget _aiCard(String model, String provider, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFA855F7).withOpacity(0.15),
              const Color(0xFF3B82F6).withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(height: 8),
            Text(
              model,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            Text(
              provider,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentLocale.languageCode == 'en' ? 'Tools' : 'الأدوات',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _toolCard(l10n.get('videoAudio'), Icons.videocam)),
            const SizedBox(width: 12),
            Expanded(child: _toolCard(l10n.get('audioText'), Icons.mic)),
            const SizedBox(width: 12),
            Expanded(
              child: _toolCard(l10n.get('textVoice'), Icons.record_voice_over),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toolCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFA855F7), size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Locale currentLocale;
  const ChatScreen({super.key, required this.currentLocale});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String _selectedModel = 'DeepSeek';

  @override
  void initState() {
    super.initState();
    if (_messages.isEmpty) {
      _addMessage(
        AppLocalizations(widget.currentLocale).get('greeting'),
        false,
      );
    }
  }

  void _addMessage(String text, bool isMe) {
    final messageText = text.trim().isEmpty
        ? 'Sorry, I could not generate a response. Please try again.'
        : text.trim();

    setState(() {
      _messages.add({
        'text': messageText,
        'isMe': isMe,
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    _controller.clear();
    _addMessage(prompt, true);

    if (!mounted) return;
    setState(() => _isTyping = true);

    try {
      final response = await callGroqAPI(_messages);
      _addMessage(response, false);
    } catch (error) {
      final errorMessage = error is Exception
          ? error.toString()
          : 'Unknown error';
      _addMessage('⚠️ API Error: $errorMessage', false);
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    }
  }

  String _getSelectedApiModel() {
    return kApiModel;
  }

  String _buildApiUrl() {
    if (kApiEndpoint.isEmpty) {
      return kApiBaseUrl;
    }

    if (kApiEndpoint.startsWith('http://') ||
        kApiEndpoint.startsWith('https://')) {
      return kApiEndpoint;
    }

    if (kApiBaseUrl.endsWith(kApiEndpoint)) {
      return kApiBaseUrl;
    }

    if (kApiBaseUrl.endsWith('/') && kApiEndpoint.startsWith('/')) {
      return kApiBaseUrl + kApiEndpoint.substring(1);
    }

    if (!kApiBaseUrl.endsWith('/') && !kApiEndpoint.startsWith('/')) {
      return '$kApiBaseUrl/$kApiEndpoint';
    }

    return kApiBaseUrl + kApiEndpoint;
  }

  Future<String> callGroqAPI(List<Map<String, dynamic>> chatMessages) async {
    if (kApiKey.isEmpty) {
      throw StateError(
        'GROQ_API_KEY is missing. Provide it through build-time configuration.',
      );
    }

    final url = _buildApiUrl();

    // Build messages array with conversation history
    final messages = [
      {
        'role': 'system',
        'content':
            'You are OmniLife AI, a helpful and friendly AI assistant. Respond naturally and helpfully. Always respond in the same language the user uses.',
      },
      ...chatMessages.map(
        (msg) => {
          'role': msg['isMe'] ? 'user' : 'assistant',
          'content': msg['text'],
        },
      ),
    ];

    final payload = {
      'model': _getSelectedApiModel(),
      'messages': messages,
      'max_tokens': 1024,
      'temperature': 0.8,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $kApiKey',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 45));

      if (response.statusCode != 200) {
        final remoteError = _parseErrorMessage(response.body);
        throw Exception(
          'Server returned ${response.statusCode}${remoteError.isNotEmpty ? ': $remoteError' : ''}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _parseCompletionContent(data);

      if (content.isEmpty) {
        throw Exception('The AI returned an empty response.');
      }
      return content;
    } on SocketException catch (e) {
      throw Exception('Network unavailable. ${e.message}');
    } on HttpException catch (e) {
      throw Exception('HTTP error. ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Invalid response format. ${e.message}');
    } on TimeoutException catch (e) {
      throw Exception('Request timed out. ${e.message ?? ''}');
    } catch (e) {
      throw Exception('Request failed. ${e.toString()}');
    }
  }

  String _parseCompletionContent(Map<String, dynamic> data) {
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return '';

    final firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) return '';

    var content = '';
    if (firstChoice['message'] is Map<String, dynamic>) {
      content = (firstChoice['message']['content'] as String?)?.trim() ?? '';
    }
    content = content.isEmpty
        ? (firstChoice['text'] as String?)?.trim() ?? ''
        : content;
    content = content.isEmpty
        ? (firstChoice['delta'] is Map<String, dynamic>
              ? (firstChoice['delta']['content'] as String?)?.trim() ?? ''
              : '')
        : content;
    return content;
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final jsonBody = jsonDecode(responseBody) as Map<String, dynamic>;
      if (jsonBody['error'] is Map<String, dynamic>) {
        return (jsonBody['error']['message'] as String?)?.trim() ?? '';
      }
      return responseBody.trim();
    } catch (_) {
      return responseBody.trim();
    }
  }

  void _showModelSelector() {
    final l10n = AppLocalizations(widget.currentLocale);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('aiChatBot'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _modelOption('DeepSeek', 'DeepSeek Chinese', true),
            _modelOption('GPT-4', 'OpenAI', false),
            _modelOption('Claude 3', 'Anthropic', false),
          ],
        ),
      ),
    );
  }

  Widget _modelOption(String model, String provider, bool isSelected) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA855F7).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.auto_awesome,
          color: isSelected ? const Color(0xFFA855F7) : Colors.white70,
          size: 20,
        ),
      ),
      title: Text(model),
      subtitle: Text(
        provider,
        style: TextStyle(color: Colors.white.withOpacity(0.5)),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFFA855F7))
          : null,
      onTap: () {
        setState(() => _selectedModel = model);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = widget.currentLocale.languageCode == 'ar';
    final l10n = AppLocalizations(widget.currentLocale);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: GestureDetector(
          onTap: _showModelSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.get('aiAssistant'),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedModel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA855F7),
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF1A1A1A),
            itemBuilder: (context) => [
              PopupMenuItem(child: Text(l10n.get('clear'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _typingIndicator();
                }
                final msg = _messages[index];
                return _chatBubble(msg['text'], msg['isMe'], isRtl);
              },
            ),
          ),
          _buildChatInput(l10n),
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations(widget.currentLocale).get('typing'),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(String message, bool isMe, bool isRtl) {
    return Align(
      alignment: isMe
          ? (isRtl ? Alignment.centerLeft : Alignment.centerRight)
          : (isRtl ? Alignment.centerRight : Alignment.centerLeft),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFA855F7)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.white70,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white70),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: l10n.get('inputHint'),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                        ),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolsScreen extends StatefulWidget {
  final Locale currentLocale;
  const ToolsScreen({super.key, required this.currentLocale});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  AppLocalizations get l10n => AppLocalizations(widget.currentLocale);

  void _openTool(String tool, IconData icon) {
    switch (tool) {
      case 'videoAudio':
        _showVideoToAudio();
        break;
      case 'audioText':
        _showAudioToText();
        break;
      case 'textVoice':
        _showTextToSpeech();
        break;
      case 'imageGen':
        _showImageGen();
        break;
      case 'codeGen':
        _showCodeGen();
        break;
      case 'translate':
        _showTranslate();
        break;
    }
  }

  void _showVideoToAudio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _VideoToAudioSheet(),
      ),
    );
  }

  void _showAudioToText() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AudioToTextSheet(),
      ),
    );
  }

  void _showTextToSpeech() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _TextToSpeechSheet(),
      ),
    );
  }

  void _showImageGen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _ImageGenSheet(),
      ),
    );
  }

  void _showCodeGen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _CodeGenSheet(),
      ),
    );
  }

  void _showTranslate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _TranslateSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('tools'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _toolCard(
                    l10n.get('videoAudio'),
                    Icons.videocam,
                    l10n.get('videoAudio'),
                  ),
                  _toolCard(
                    l10n.get('audioText'),
                    Icons.mic,
                    l10n.get('audioText'),
                  ),
                  _toolCard(
                    l10n.get('textVoice'),
                    Icons.record_voice_over,
                    l10n.get('textVoice'),
                  ),
                  _toolCard('Image Gen', Icons.image, 'AI Images'),
                  _toolCard('Code Gen', Icons.code, 'Write Code'),
                  _toolCard('Translate', Icons.translate, '50+ Langs'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(String title, IconData icon, String subtitle) {
    return GestureDetector(
      onTap: () {
        final key = title.toLowerCase().replaceAll(' ', '');
        if (key.contains('video'))
          _openTool('videoAudio', icon);
        else if (key.contains('audio'))
          _openTool('audioText', icon);
        else if (key.contains('text') || key.contains('voice'))
          _openTool('textVoice', icon);
        else if (key.contains('image'))
          _openTool('imageGen', icon);
        else if (key.contains('code'))
          _openTool('codeGen', icon);
        else if (key.contains('translate'))
          _openTool('translate', icon);
        else
          _openTool(key, icon);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFFA855F7), size: 28),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoToAudioSheet extends StatefulWidget {
  @override
  State<_VideoToAudioSheet> createState() => _VideoToAudioSheetState();
}

class _VideoToAudioSheetState extends State<_VideoToAudioSheet> {
  bool _processing = false;
  String _error = '';

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _processing = true;
      _error = '';
    });

    try {
      final audioPath = await ToolsApiService.videoToAudio(
        File(result.files.single.path!),
      );
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Audio saved: $audioPath')));
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _error = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Video to Audio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_processing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Processing...'),
              ],
            )
          else if (_error.isNotEmpty)
            Column(
              children: [
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('Retry'),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Video'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _AudioToTextSheet extends StatefulWidget {
  @override
  State<_AudioToTextSheet> createState() => _AudioToTextSheetState();
}

class _AudioToTextSheetState extends State<_AudioToTextSheet> {
  bool _processing = false;
  String _result = '';
  String _error = '';

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;

    setState(() {
      _processing = true;
      _result = '';
      _error = '';
    });

    try {
      final text = await ToolsApiService.audioToText(
        File(result.files.single.path!),
      );
      if (mounted)
        setState(() {
          _processing = false;
          _result = text;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _error = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Audio to Text',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_processing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Transcribing...'),
              ],
            )
          else if (_error.isNotEmpty)
            Column(
              children: [
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _pickAudio,
                  child: const Text('Retry'),
                ),
              ],
            )
          else if (_result.isNotEmpty)
            Column(
              children: [
                SelectText(text: _result),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _pickAudio,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('New Audio'),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _pickAudio,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Audio'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _TextToSpeechSheet extends StatefulWidget {
  @override
  State<_TextToSpeechSheet> createState() => _TextToSpeechSheetState();
}

class _TextToSpeechSheetState extends State<_TextToSpeechSheet> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  bool _processing = false;
  String _error = '';
  bool _playing = false;
  String? _audioPath;

  Future<void> _generateSpeech() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();

    setState(() {
      _processing = true;
      _error = '';
      _audioPath = null;
      _playing = false;
    });

    try {
      final path = await ToolsApiService.textToSpeech(text);
      if (mounted)
        setState(() {
          _processing = false;
          _audioPath = path;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _error = e.toString();
        });
    }
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
    } else {
      await _player.play(DeviceFileSource(_audioPath!));
      setState(() => _playing = true);
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playing = false);
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Text to Speech',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter text...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (_processing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Generating speech...'),
              ],
            )
          else if (_error.isNotEmpty)
            Column(
              children: [
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 15),
              ],
            )
          else if (_audioPath != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _playAudio,
                  icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  label: Text(_playing ? 'Pause' : 'Play'),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  onPressed: _generateSpeech,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _generateSpeech,
              icon: const Icon(Icons.volume_up),
              label: const Text('Generate Speech'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ImageGenSheet extends StatefulWidget {
  @override
  State<_ImageGenSheet> createState() => _ImageGenSheetState();
}

class _ImageGenSheetState extends State<_ImageGenSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _processing = false;
  String _error = '';
  String? _imagePath;

  Future<void> _generateImage() async {
    if (_controller.text.trim().isEmpty) return;
    final prompt = _controller.text.trim();

    setState(() {
      _processing = true;
      _error = '';
      _imagePath = null;
    });

    try {
      final path = await ToolsApiService.generateImage(prompt);
      if (mounted)
        setState(() {
          _processing = false;
          _imagePath = path;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _error = e.toString();
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Image Generation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe the image...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (_processing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Generating image...'),
              ],
            )
          else if (_error.isNotEmpty)
            Column(
              children: [
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 15),
              ],
            )
          else if (_imagePath != null)
            Column(
              children: [
                Image.file(File(_imagePath!), height: 200),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _generateImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate Again'),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _generateImage,
              icon: const Icon(Icons.image),
              label: const Text('Generate'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _CodeGenSheet extends StatefulWidget {
  @override
  State<_CodeGenSheet> createState() => _CodeGenSheetState();
}

class _CodeGenSheetState extends State<_CodeGenSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _processing = false;
  String _error = '';
  String _result = '';

  Future<void> _generateCode() async {
    if (_controller.text.trim().isEmpty) return;
    final prompt = _controller.text.trim();

    setState(() {
      _processing = true;
      _error = '';
      _result = '';
    });

    try {
      final code = await ToolsApiService.generateCode(prompt);
      if (mounted)
        setState(() {
          _processing = false;
          _result = code;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _error = e.toString();
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Code Generation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe the code you need...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (_processing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Writing code...'),
              ],
            )
          else if (_error.isNotEmpty)
            Column(
              children: [
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 15),
              ],
            )
          else if (_result.isNotEmpty)
            Column(
              children: [
                SelectText(text: _result),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _generateCode,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate Again'),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _generateCode,
              icon: const Icon(Icons.code),
              label: const Text('Generate Code'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _TranslateSheet extends StatefulWidget {
  @override
  State<_TranslateSheet> createState() => _TranslateSheetState();
}

class _TranslateSheetState extends State<_TranslateSheet> {
  final TextEditingController _controller = TextEditingController();
  String _targetLang = 'en';
  bool _processing = false;
  String _error = '';
  String _result = '';

  Future<void> _translate() async {
    if (_controller.text.trim().isEmpty) return;
    final text = _controller.text.trim();

    setState(() {
      _processing = true;
      _error = '';
      _result = '';
    });

    try {
      final translated = await ToolsApiService.translate(
        text,
        targetLanguage: _targetLang,
      );
      if (mounted)
        setState(() {
          _processing = false;
          _result = translated;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _processing = false;
          _error = e.toString();
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Translate',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('To:', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _targetLang,
                dropdownColor: const Color(0xFF1A1A1A),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  DropdownMenuItem(value: 'fr', child: Text('French')),
                  DropdownMenuItem(value: 'es', child: Text('Spanish')),
                ],
                onChanged: (v) => setState(() => _targetLang = v!),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_processing)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text('Translating...'),
              ],
            )
          else if (_error.isNotEmpty)
            Column(
              children: [
                Text(_error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 15),
              ],
            )
          else if (_result.isNotEmpty)
            Column(
              children: [
                SelectText(text: _result),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _translate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Translate Again'),
                ),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _translate,
              icon: const Icon(Icons.translate),
              label: const Text('Translate'),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class SelectText extends StatelessWidget {
  final String text;
  const SelectText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: SelectableText(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final Locale currentLocale;
  const HistoryScreen({super.key, required this.currentLocale});

  AppLocalizations get l10n => AppLocalizations(currentLocale);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('history'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 60,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      l10n.get('noHistory'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.get('startChat'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final Locale currentLocale;
  final Function(Locale) changeLocale;
  const ProfileScreen({
    super.key,
    required this.currentLocale,
    required this.changeLocale,
  });

  AppLocalizations get l10n => AppLocalizations(currentLocale);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
                ),
              ),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF0D0D0D),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Ahmed Mohamed',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              l10n.get('premium'),
              style: const TextStyle(color: Color(0xFFA855F7)),
            ),
            const SizedBox(height: 30),
            _profileItem(
              Icons.language,
              l10n.get('language'),
              currentLocale.languageCode == 'en' ? 'English' : 'العربية',
            ),
            _profileItem(Icons.settings, l10n.get('settings'), ''),
            _profileItem(
              Icons.info,
              l10n.get('about'),
              l10n.get('version') + ' 1.0.0',
            ),
            const SizedBox(height: 20),
            _logoutBtn(),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, String value) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 15),
            Expanded(child: Text(title)),
            if (value.isNotEmpty)
              Text(
                value,
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _logoutBtn() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            l10n.get('logout'),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
