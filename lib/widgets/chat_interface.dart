import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';

class ChatInterface extends StatefulWidget {
  const ChatInterface({super.key});

  @override
  State<ChatInterface> createState() => _ChatInterfaceState();
}

class _ChatInterfaceState extends State<ChatInterface> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    
    // ChatProvider'a UserPreferences'ı bildir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userPreferences = Provider.of<UserPreferencesProvider>(context, listen: false);
      Provider.of<ChatProvider>(context, listen: false).updateUserPreferences(userPreferences);
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(_controller.text.trim());
    
    _controller.clear();
    
    // Scroll to bottom after message is sent
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLanguageTurkish = Provider.of<UserPreferencesProvider>(context).language == 'tr';
    
    return Column(
      children: [
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              // Scroll to bottom when new messages arrive
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
              
              if (chatProvider.currentChat.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_outlined,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isLanguageTurkish ? 'Tarifcim ile Sohbet' : 'Chat with Tarifcim',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          isLanguageTurkish 
                              ? 'Evinizdeki malzemeleri yazın, size uygun tarifler önerelim!'
                              : 'Write the ingredients you have at home, and we\'ll suggest suitable recipes!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSuggestionChip(isLanguageTurkish 
                              ? 'Akşam yemeği için ne pişirebilirim?' 
                              : 'What can I cook for dinner?'),
                          _buildSuggestionChip(isLanguageTurkish 
                              ? 'Vejetaryen yemek tarifleri' 
                              : 'Vegetarian recipes'),
                          _buildSuggestionChip(isLanguageTurkish 
                              ? '15 dakikada hazırlanan tarifler' 
                              : 'Recipes ready in 15 minutes'),
                          _buildSuggestionChip(isLanguageTurkish 
                              ? 'Glutensiz tatlı tarifleri' 
                              : 'Gluten-free dessert recipes'),
                        ],
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: chatProvider.currentChat.length + (chatProvider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatProvider.currentChat.length && chatProvider.isLoading) {
                    // Show loading indicator
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Icon(Icons.restaurant, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isLanguageTurkish ? 'Yazıyor...' : 'Typing...',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  final message = chatProvider.currentChat[index];
                  return _buildMessageBubble(message, isDarkMode);
                },
              );
            },
          ),
        ),
        
        // Input area
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: isLanguageTurkish 
                        ? 'Tarifcim\'e bir soru sorun...' 
                        : 'Ask Tarifcim a question...',
                    prefixIcon: const Icon(Icons.restaurant_menu),
                    suffixIcon: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        return chatProvider.isLoading
                            ? Container(
                                margin: const EdgeInsets.all(14),
                                width: 16,
                                height: 16,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send_rounded),
                                color: AppTheme.primaryColor,
                                onPressed: _controller.text.trim().isNotEmpty ? _sendMessage : null,
                              );
                      },
                    ),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: (value) {
                    // Force rebuild to update send button state
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      avatar: const Icon(Icons.lightbulb_outline, size: 16),
      onPressed: () {
        _controller.text = suggestion;
        _sendMessage();
      },
    );
  }
  
  Widget _buildMessageBubble(Message message, bool isDarkMode) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.restaurant, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppTheme.primaryColor
                    : isDarkMode ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
