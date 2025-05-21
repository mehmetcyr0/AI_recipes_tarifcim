import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/tts_player.dart';
import '../theme/app_theme.dart';
import '../providers/user_preferences_provider.dart';
import 'package:provider/provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLanguageTurkish = Provider.of<UserPreferencesProvider>(context).language == 'tr';
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          Color(0xFF66BB6A),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getRecipeIcon(recipe.title),
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Recipe title at the bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // AI Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isLanguageTurkish ? 'Yapay Zeka Tarifi' : 'AI Recipe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isLanguageTurkish ? 'Favorilere eklendi' : 'Added to favorites')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isLanguageTurkish ? 'Paylaşım özelliği yakında' : 'Sharing feature coming soon')),
                  );
                },
              ),
            ],
          ),
          
          // Recipe Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          Icons.timer_outlined,
                          '${recipe.cookingTime} ${isLanguageTurkish ? 'dk' : 'min'}',
                          isLanguageTurkish ? 'Hazırlama' : 'Preparation',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          Icons.people_outline,
                          '${recipe.servings} ${isLanguageTurkish ? 'kişilik' : 'servings'}',
                          isLanguageTurkish ? 'Porsiyon' : 'Servings',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          Icons.local_fire_department_outlined,
                          '${recipe.calories} kcal',
                          isLanguageTurkish ? 'Kalori' : 'Calories',
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ingredients
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLanguageTurkish ? 'Malzemeler' : 'Ingredients',
                        style: AppTheme.subheadingStyle,
                      ),
                      Chip(
                        label: Text(isLanguageTurkish 
                            ? '${recipe.ingredients.length} malzeme' 
                            : '${recipe.ingredients.length} ingredients'),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: recipe.ingredients.map((ingredient) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: AppTheme.primaryColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLanguageTurkish ? 'Hazırlanışı' : 'Instructions',
                        style: AppTheme.subheadingStyle,
                      ),
                      TTSPlayer(text: recipe.instructions.join(' ')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  ...List.generate(recipe.instructions.length, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            recipe.instructions[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Food Waste Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.green[900]!.withOpacity(0.3) : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode ? Colors.green[800]! : Colors.green[200]!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              isLanguageTurkish ? 'Gıda İsrafını Azaltma İpuçları' : 'Food Waste Reduction Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          recipe.wasteReductionTips,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isLanguageTurkish ? 'Tarif paylaşıldı' : 'Recipe shared')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: Text(isLanguageTurkish ? 'Bu Tarifi Paylaş' : 'Share This Recipe'),
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
  
  Widget _buildInfoCard(BuildContext context, IconData icon, String value, String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRecipeIcon(String title) {
    final lowercaseTitle = title.toLowerCase();
    if (lowercaseTitle.contains('makarna') || lowercaseTitle.contains('pasta')) {
      return Icons.dinner_dining;
    } else if (lowercaseTitle.contains('çorba') || lowercaseTitle.contains('soup')) {
      return Icons.soup_kitchen;
    } else if (lowercaseTitle.contains('salata') || lowercaseTitle.contains('salad')) {
      return Icons.eco;
    } else if (lowercaseTitle.contains('tatlı') || lowercaseTitle.contains('dessert')) {
      return Icons.cake;
    } else if (lowercaseTitle.contains('et') || lowercaseTitle.contains('meat')) {
      return Icons.set_meal;
    } else if (lowercaseTitle.contains('balık') || lowercaseTitle.contains('fish')) {
      return Icons.set_meal;
    } else if (lowercaseTitle.contains('tavuk') || lowercaseTitle.contains('chicken')) {
      return Icons.egg;
    } else if (lowercaseTitle.contains('kahvaltı') || lowercaseTitle.contains('breakfast') || lowercaseTitle.contains('omlet')) {
      return Icons.breakfast_dining;
    } else if (lowercaseTitle.contains('elma') || lowercaseTitle.contains('apple')) {
      return Icons.apple;
    } else {
      return Icons.restaurant;
    }
  }
}
