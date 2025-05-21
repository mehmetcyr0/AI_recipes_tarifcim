import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/ingredient_input.dart';
import '../widgets/recipe_list.dart';
import '../widgets/filter_section.dart';
import '../widgets/chat_interface.dart';
import '../providers/chat_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Malzeme listesi varsa tarifleri güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ingredientProvider = Provider.of<IngredientProvider>(context, listen: false);
      if (ingredientProvider.hasIngredients) {
        Provider.of<RecipeProvider>(context, listen: false).refreshRecommendedRecipes();
      }
      
      // ChatProvider'a UserPreferences'ı bildir
      final userPreferences = Provider.of<UserPreferencesProvider>(context, listen: false);
      Provider.of<ChatProvider>(context, listen: false).updateUserPreferences(userPreferences);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLanguageTurkish = Provider.of<UserPreferencesProvider>(context).language == 'tr';
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_menu, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              'Tarifcim',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.home_outlined), 
              text: isLanguageTurkish ? 'Ana Sayfa' : 'Home'
            ),
            Tab(
              icon: const Icon(Icons.chat_outlined), 
              text: isLanguageTurkish ? 'Sohbet' : 'Chat'
            ),
            Tab(
              icon: const Icon(Icons.history_outlined), 
              text: isLanguageTurkish ? 'Geçmiş' : 'History'
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Ana Sayfa
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          Color(0xFF66BB6A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLanguageTurkish ? 'Evinizdeki Malzemeler' : 'Ingredients at Home',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLanguageTurkish 
                              ? 'Dolabınızdaki malzemeleri ekleyin, size uygun tarifleri bulalım!'
                              : 'Add the ingredients from your pantry, and we\'ll find suitable recipes for you!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const IngredientInput(),
                  const SizedBox(height: 24),
                  const FilterSection(),
                  const SizedBox(height: 24),
                  Consumer<IngredientProvider>(
                    builder: (context, ingredientProvider, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ingredientProvider.hasIngredients 
                                ? (isLanguageTurkish ? 'Malzemelerinize Göre Tarifler' : 'Recipes Based on Your Ingredients')
                                : (isLanguageTurkish ? 'Önerilen Tarifler' : 'Recommended Recipes'),
                            style: AppTheme.headingStyle,
                          ),
                          Consumer<RecipeProvider>(
                            builder: (context, recipeProvider, _) {
                              return TextButton.icon(
                                onPressed: () => recipeProvider.refreshRecommendedRecipes(),
                                icon: const Icon(Icons.refresh),
                                label: Text(isLanguageTurkish ? 'Yenile' : 'Refresh'),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const RecipeList(),
                ],
              ),
            ),
          ),
          
          // Sohbet
          const ChatInterface(),
          
          // Geçmiş
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.chatHistory.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isLanguageTurkish ? 'Henüz sohbet geçmişiniz yok' : 'No chat history yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLanguageTurkish 
                            ? 'Tarifcim ile sohbet ederek tarif önerileri alabilirsiniz'
                            : 'Chat with Tarifcim to get recipe recommendations',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: chatProvider.chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = chatProvider.chatHistory[index];
                  final reversedIndex = chatProvider.chatHistory.length - 1 - index;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(
                        isLanguageTurkish 
                            ? 'Tarif Sohbeti ${reversedIndex + 1}'
                            : 'Recipe Chat ${reversedIndex + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        chat.isNotEmpty ? chat.first.content.substring(0, chat.first.content.length > 50 ? 50 : chat.first.content.length) + '...' : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: const Icon(
                          Icons.history,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        chatProvider.loadChatHistory(reversedIndex);
                        _tabController.animateTo(1); // Switch to chat tab
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
