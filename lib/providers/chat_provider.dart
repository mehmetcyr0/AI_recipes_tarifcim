import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/gemini_service.dart';
import 'user_preferences_provider.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<List<Message>> _chatHistory = [];
  List<Message> _currentChat = [];
  bool _isLoading = false;
  UserPreferencesProvider? _userPreferences;
  
  List<Message> get currentChat => _currentChat;
  List<List<Message>> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  
  void updateUserPreferences(UserPreferencesProvider userPreferences) {
    _userPreferences = userPreferences;
  }
  
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    
    // Add user message
    final userMessage = Message(
      content: content,
      isUser: true,
    );
    
    _currentChat.add(userMessage);
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get language preference
      final language = _userPreferences?.language ?? 'tr';
      
      // Get AI response
      final response = await _geminiService.getResponse(content, language: language);
      
      // Add AI message
      final aiMessage = Message(
        content: response,
        isUser: false,
      );
      
      _currentChat.add(aiMessage);
    } catch (e) {
      // Handle error
      final language = _userPreferences?.language ?? 'tr';
      final errorMessage = Message(
        content: language == 'tr' 
            ? 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.' 
            : 'Sorry, an error occurred. Please try again.',
        isUser: false,
      );
      
      _currentChat.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
      
      // Save to history if this is a new conversation
      if (_currentChat.length == 2) {
        saveCurrentChatToHistory();
      }
    }
  }
  
  void saveCurrentChatToHistory() {
    if (_currentChat.isNotEmpty) {
      // Create a copy of the current chat
      final chatCopy = List<Message>.from(_currentChat);
      
      // Add to history if not already there
      if (!_chatHistory.contains(chatCopy)) {
        _chatHistory.add(chatCopy);
        notifyListeners();
      }
    }
  }
  
  void loadChatHistory(int index) {
    if (index >= 0 && index < _chatHistory.length) {
      _currentChat = List<Message>.from(_chatHistory[index]);
      notifyListeners();
    }
  }
  
  void clearCurrentChat() {
    _currentChat = [];
    notifyListeners();
  }
}
