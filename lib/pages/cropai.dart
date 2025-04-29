import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late GeminiAssistant _geminiAssistant;
  bool _isAssistantReady = false;

  @override
  void initState() {
    super.initState();
    _initGeminiAssistant();
  }

  Future<void> _initGeminiAssistant() async {
    try {
      // Initialize with API key from environment variables
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in environment variables');
      }
      
      _geminiAssistant = GeminiAssistant(apiKey);
      setState(() {
        _isAssistantReady = true;
        // Add initial welcome message
        _messages.add(
          ChatMessage(
            text: 'Hello! I\'m your Lettuce Farming Assistant powered by Gemini AI. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      print('Error initializing Gemini Assistant: $e');
      // Show error message in chat
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I had trouble connecting to the AI service. Please check your API key and try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    _messageController.clear();
    
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    
    // Scroll to bottom after adding message
    _scrollToBottom();
    
    // Get response from Gemini Assistant
    if (_isAssistantReady) {
      _geminiAssistant.generateResponse(text).then((response) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        
        // Scroll to bottom after bot response
        _scrollToBottom();
      }).catchError((error) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: "Sorry, I encountered an error: ${error.toString()}. Please try again.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        
        // Scroll to bottom after bot response
        _scrollToBottom();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: "I'm still initializing. Please try again in a moment.",
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        });
        
        // Scroll to bottom after bot response
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lettuce Assistant'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Help Topics'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('• Ask about watering schedules'),
                      Text('• Get fertilizer recommendations'),
                      Text('• Learn about soil pH for lettuce'),
                      Text('• Get temperature recommendations'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
              ),
              child: _messages.isEmpty
                  ? _buildWelcomeMessage()
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
            ),
          ),
          
          // Bot typing indicator
          if (_isTyping)
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: [
                  const Text(
                    'Lettuce Assistant is typing',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypingIndicator(),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Message input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about lettuce farming...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                
                // Send button
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Colors.white,
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_rounded,
              size: 40,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lettuce Assistant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ask me anything about lettuce farming',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Watering tips'),
              _buildSuggestionChip('Soil pH'),
              _buildSuggestionChip('Temperature'),
              _buildSuggestionChip('Help'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(
        Icons.spa_outlined,
        size: 18,
        color: Colors.green.shade700,
      ),
      backgroundColor: Colors.green.shade50,
      side: BorderSide(color: Colors.green.shade100),
      onPressed: () => _handleSubmitted(label),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) _buildAvatar(message.isUser),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isUser ? Radius.zero : null,
                  bottomLeft: !message.isUser ? Radius.zero : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(message.isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? Colors.grey.shade300 : Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person : Icons.eco_rounded,
          size: 16,
          color: isUser ? Colors.grey.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          3,
          (index) => _buildPulsingDot(
            delay: Duration(milliseconds: index * 300),
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingDot({required Duration delay}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Container(
          width: 6 * value,
          height: 6 * value,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class GeminiAssistant {
  final String apiKey;
  final String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  GeminiAssistant(this.apiKey);
  
  Future<String> generateResponse(String query) async {
    try {
      // Add context about lettuce farming to every query
      String enhancedQuery = "As a lettuce farming expert, please respond to: $query\n\n"
                            "Focus on providing accurate information about lettuce cultivation, including "
                            "watering needs, soil requirements, temperature preferences, pest management, "
                            "harvesting techniques, and other relevant aspects of lettuce farming.";
      
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {'text': enhancedQuery}
            ]
          }
        ]
      };

      // Make the API request
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Extract the response text from the Gemini API response
        if (data.containsKey('candidates') && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0].containsKey('content') &&
            data['candidates'][0]['content'].containsKey('parts') &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          return data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          return "I received a response but couldn't parse the content. Please try again.";
        }
      } else {
        // Handle error based on status code
        if (response.statusCode == 400) {
          return "There was an issue with the request. Please try asking a different question.";
        } else if (response.statusCode == 401) {
          return "API authentication failed. Please check your API key.";
        } else if (response.statusCode == 429) {
          return "You've reached the rate limit. Please try again later.";
        } else {
          return "Error: HTTP ${response.statusCode}. Please try again later.";
        }
      }
    } catch (e) {
      return "Sorry, I encountered an error while processing your request: ${e.toString()}";
    }
  }
}