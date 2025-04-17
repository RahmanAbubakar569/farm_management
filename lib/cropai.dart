import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

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
  late LettuceAssistant _lettuceAssistant;
  bool _isAssistantReady = false;

  @override
  void initState() {
    super.initState();
    _initLettuceAssistant();
  }

  Future<void> _initLettuceAssistant() async {
    try {
      // Load the JSON data from assets
      final String jsonData = await rootBundle.loadString('assets/lettuce_growth_data.json');
      _lettuceAssistant = LettuceAssistant(jsonData);
      setState(() {
        _isAssistantReady = true;
      });
    } catch (e) {
      print('Error initializing Lettuce Assistant: $e');
      // Show error message in chat
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Sorry, I had trouble loading my knowledge base. Please try again later.',
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
    
    // Get response from Lettuce Assistant
    Future.delayed(const Duration(milliseconds: 500), () {
      String response = '';
      
      if (_isAssistantReady) {
        response = _lettuceAssistant.generateResponse(text);
      } else {
        response = "I'm still loading my lettuce farming knowledge. Please try again in a moment.";
      }
      
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
    });
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

// Ported from Python to Dart
class LettuceAssistant {
  late Map<String, dynamic> data;
  late List<String> categories;
  late List<String> vocabulary;

  LettuceAssistant(String jsonString) {
    try {
      // Parse the JSON data
      data = json.decode(jsonString);
      categories = data.keys.toList();
      print("Lettuce Assistant initialized successfully!");
      
      // Build vocabulary
      vocabulary = _buildVocabulary();
    } catch (e) {
      print("Error initializing Lettuce Assistant: $e");
      data = {};
      categories = [];
      vocabulary = [];
    }
  }
  
  List<String> _buildVocabulary() {
    Set<String> vocabularySet = {};
    
    // Add common lettuce farming terms
    List<String> commonTerms = [
      "lettuce", "water", "irrigation", "soil", "fertilizer", "temperature", 
      "climate", "moisture", "drought", "pH", "NPK", "compost", "organic",
      "nutrient", "drip", "evapotranspiration", "mulch", "greenhouse",
      "hydroponic", "frequency", "drainage", "wilting", "root", "disease",
      "prevention", "strategy", "amendment", "sensor", "monitoring"
    ];
    vocabularySet.addAll(commonTerms);
    
    // Add terms from the data
    for (String category in data.keys) {
      vocabularySet.add(category.toLowerCase());
      Map<String, dynamic> categoryData = data[category];
      
      for (String subcategory in categoryData.keys) {
        vocabularySet.add(subcategory.toLowerCase());
        Map<String, dynamic> subcategoryData = categoryData[subcategory];
        
        for (String section in subcategoryData.keys) {
          vocabularySet.add(section.toLowerCase());
          List<dynamic> sectionItems = subcategoryData[section];
          
          for (String item in sectionItems) {
            // Add words from each item (excluding common words)
            RegExp wordRegex = RegExp(r'\b[a-zA-Z]{4,}\b');
            Iterable<RegExpMatch> matches = wordRegex.allMatches(item.toLowerCase());
            for (RegExpMatch match in matches) {
              vocabularySet.add(match.group(0)!);
            }
          }
        }
      }
    }
    
    return vocabularySet.toList();
  }
  
  String autocorrect(String text) {
    // Simple autocorrection implementation
    List<String> words = text.split(RegExp(r'\s+'));
    List<String> correctedWords = [];
    
    for (String word in words) {
      if (word.length <= 3 || RegExp(r'^\d+$').hasMatch(word)) {
        correctedWords.add(word);
        continue;
      }
      
      String wordLower = word.toLowerCase();
      if (vocabulary.contains(wordLower)) {
        correctedWords.add(word);
        continue;
      }
      
      // Find closest match
      String? closestMatch = _findClosestMatch(wordLower, vocabulary);
      if (closestMatch != null) {
        // Preserve original capitalization
        if (word[0].toUpperCase() == word[0]) {
          closestMatch = closestMatch[0].toUpperCase() + closestMatch.substring(1);
        }
        correctedWords.add(closestMatch);
      } else {
        correctedWords.add(word);
      }
    }
    
    return correctedWords.join(' ');
  }
  
  String? _findClosestMatch(String word, List<String> candidates) {
    int minDistance = 1000;
    String? bestMatch;
    
    for (String candidate in candidates) {
      int distance = _levenshteinDistance(word, candidate);
      if (distance < minDistance && distance <= word.length ~/ 2) {
        minDistance = distance;
        bestMatch = candidate;
      }
    }
    
    return bestMatch;
  }
  
  int _levenshteinDistance(String s, String t) {
    // Initialize matrix of size (s.length+1) x (t.length+1)
    List<List<int>> d = List.generate(
      s.length + 1, (_) => List.filled(t.length + 1, 0)
    );
    
    // Source prefixes can be transformed into empty string by dropping characters
    for (int i = 0; i <= s.length; i++) {
      d[i][0] = i;
    }
    
    // Target prefixes can be reached from empty source by inserting characters
    for (int j = 0; j <= t.length; j++) {
      d[0][j] = j;
    }
    
    for (int j = 1; j <= t.length; j++) {
      for (int i = 1; i <= s.length; i++) {
        int substitutionCost = (s[i-1] == t[j-1]) ? 0 : 1;
        d[i][j] = [
          d[i-1][j] + 1,                  // deletion
          d[i][j-1] + 1,                  // insertion
          d[i-1][j-1] + substitutionCost  // substitution
        ].reduce((curr, next) => curr < next ? curr : next);
      }
    }
    
    return d[s.length][t.length];
  }
  
  List<String> searchKeywords(String query) {
    String queryLower = query.toLowerCase();
    Set<String> relevantCategories = {};
    
    // Define keyword mappings
    Map<String, String> keywordMap = {
      "water": "Watering & Irrigation",
      "irrigation": "Watering & Irrigation",
      "moisture": "Watering & Irrigation",
      "drip": "Watering & Irrigation",
      "drought": "Watering & Irrigation",
      "overwater": "Watering & Irrigation",
      "evapotranspiration": "Watering & Irrigation",
      
      "soil": "Soil & Fertilization",
      "fertiliz": "Soil & Fertilization",
      "fertilis": "Soil & Fertilization",
      "compost": "Soil & Fertilization",
      "organic": "Soil & Fertilization",
      "nutrient": "Soil & Fertilization",
      "pH": "Soil & Fertilization",
      "NPK": "Soil & Fertilization",
      
      "temperature": "Temperature & Climate",
      "climate": "Temperature & Climate",
      "heat": "Temperature & Climate",
      "cool": "Temperature & Climate",
      "celsius": "Temperature & Climate",
      "fahrenheit": "Temperature & Climate",
    };
    
    for (String keyword in keywordMap.keys) {
      if (queryLower.contains(keyword)) {
        relevantCategories.add(keywordMap[keyword]!);
      }
    }
    
    return relevantCategories.toList();
  }
  
  String? findSubcategory(String category, String query) {
    if (!data.containsKey(category)) {
      return null;
    }
    
    List<String> subcategories = data[category].keys.toList();
    String queryLower = query.toLowerCase();
    
    for (String subcategory in subcategories) {
      String subcategoryLower = subcategory.toLowerCase();
      List<String> subcategoryWords = subcategoryLower.split(' ');
      
      for (String word in subcategoryWords) {
        if (queryLower.contains(word) && word.length > 3) {
          return subcategory;
        }
      }
    }
    
    // If no direct match, return the first subcategory
    return subcategories.isNotEmpty ? subcategories[0] : null;
  }
  
  Map<String, dynamic>? getInformation(String category, String subcategory) {
    if (data.containsKey(category) && data[category].containsKey(subcategory)) {
      String sectionKey = data[category][subcategory].keys.first;
      return {
        "category": category,
        "subcategory": subcategory,
        "section_type": sectionKey,
        "points": data[category][subcategory][sectionKey]
      };
    }
    return null;
  }
  
  String generateResponse(String query) {
    // Apply autocorrection
    String originalQuery = query;
    String correctedQuery = autocorrect(query);
    
    // Special case for greetings
    List<String> greetingPatterns = ["hello", "hi ", "hey", "greetings", "howdy"];
    if (greetingPatterns.any((pattern) => correctedQuery.toLowerCase().contains(pattern))) {
      return "Hello! I'm your Lettuce Farming Assistant. I can help you with:\n"
             "- Watering & Irrigation\n"
             "- Soil & Fertilization\n"
             "- Temperature & Climate\n\n"
             "What would you like to know about growing lettuce today?";
    }
    
    // Special case for help
    if (correctedQuery.toLowerCase().contains("help")) {
      return "I can provide information about lettuce farming in these areas:\n\n"
             "1. Watering & Irrigation - Including watering frequency, irrigation methods, "
             "drought stress prevention, and evapotranspiration management.\n\n"
             "2. Soil & Fertilization - Including soil pH management, fertilization practices, "
             "compost usage, and soil nutrient monitoring.\n\n"
             "3. Temperature & Climate - Including optimal temperature ranges for lettuce growth.\n\n"
             "Ask me specific questions like 'How often should I water my lettuce?' or "
             "'What is the best soil pH for lettuce?'";
    }
    
    // Find relevant categories based on keywords
    List<String> relevantCategories = searchKeywords(correctedQuery);
    
    // If no relevant categories found, provide a general response
    if (relevantCategories.isEmpty) {
      return "I'm not sure I understand your question about lettuce farming. "
             "Could you rephrase your question related to watering, soil management, "
             "or temperature control for lettuce? Or type 'help' to see what I can assist with.";
    }
    
    List<String> responses = [];
    String correctionNotice = "";
    
    // Add correction notice if query was changed
    if (originalQuery.toLowerCase() != correctedQuery.toLowerCase()) {
      correctionNotice = "I understood your question as: \"$correctedQuery\"\n\n";
    }
    
    // Generate responses for each relevant category
    for (String category in relevantCategories) {
      String? subcategory = findSubcategory(category, correctedQuery);
      
      if (subcategory != null) {
        Map<String, dynamic>? info = getInformation(category, subcategory);
        
        if (info != null) {
          String response = "📌 About ${info['subcategory']} (${info['category']}):\n\n";
          
          // Add points from the data
          List<dynamic> points = info['points'];
          for (int i = 0; i < points.length; i++) {
            response += "${i + 1}. ${points[i]}\n";
          }
          
          responses.add(response);
        }
      }
    }
    
    // Combine responses or return a fallback
    if (responses.isNotEmpty) {
      String finalResponse = correctionNotice + responses.join("\n\n");
      finalResponse += "\n\nIs there anything specific about these recommendations you'd like me to explain further?";
      return finalResponse;
    } else {
      return "I have information about lettuce farming, but I couldn't find specific details for your query. "
             "Try asking about watering frequency, irrigation methods, soil pH, fertilization, "
             "or optimal temperature ranges for lettuce.";
    }
  }
}