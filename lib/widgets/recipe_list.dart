import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/recipe_detail_screen.dart';
import '../theme/app_theme.dart';
import '../providers/recipe_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/user_preferences_provider.dart';

class RecipeList extends StatelessWidget {
  const RecipeList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLanguageTurkish =
        Provider.of<UserPreferencesProvider>(context).language == 'tr';

    return Consumer2<RecipeProvider, IngredientProvider>(
      builder: (context, recipeProvider, ingredientProvider, child) {
        if (recipeProvider.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(isLanguageTurkish
                      ? 'Yapay zeka tariflerinizi hazırlıyor...'
                      : 'AI is preparing your recipes...'),
                ],
              ),
            ),
          );
        }

        final recipes = recipeProvider.recommendedRecipes;

        if (!ingredientProvider.hasIngredients) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.shopping_basket_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isLanguageTurkish
                        ? 'Henüz malzeme eklemediniz'
                        : 'You haven\'t added any ingredients yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLanguageTurkish
                        ? 'Yapay zeka tarafından tarif önerileri için malzeme ekleyin ve "Tarif Bul" butonuna tıklayın'
                        : 'Add ingredients and click "Find Recipes" button for AI-generated recipe suggestions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (recipes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.no_meals, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isLanguageTurkish ? 'Tarif bulunamadı' : 'No recipes found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLanguageTurkish
                        ? 'Farklı malzemeler veya filtreler deneyebilirsiniz'
                        : 'You can try different ingredients or filters',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => recipeProvider.refreshRecommendedRecipes(),
                    icon: const Icon(Icons.refresh),
                    label: Text(isLanguageTurkish ? 'Yenile' : 'Refresh'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            if (ingredientProvider.hasIngredients) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isLanguageTurkish
                            ? 'Yapay zeka, ${ingredientProvider.getIngredientsAsString()} malzemelerinize özel tarifler oluşturdu.'
                            : 'AI has created custom recipes based on your ingredients: ${ingredientProvider.getIngredientsAsString()}.',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...recipes
                .map((recipe) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recipe Image
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
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
                                            size: 64,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                              Icons.local_fire_department,
                                              color: Colors.white,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${recipe.calories} kcal',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Yapay zeka etiketi
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome,
                                              color: Colors.white, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            isLanguageTurkish
                                                ? 'Yapay Zeka Tarifi'
                                                : 'AI Recipe',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      style: AppTheme.subheadingStyle,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      recipe.description,
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Kullanılan malzemeler
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: _getHighlightedIngredients(
                                              recipe.ingredients,
                                              ingredientProvider.ingredients)
                                          .map((ingredient) {
                                        final isUserIngredient =
                                            ingredientProvider.ingredients.any(
                                                (userIngredient) => ingredient
                                                    .toLowerCase()
                                                    .contains(userIngredient
                                                        .toLowerCase()));

                                        return Chip(
                                          label: Text(
                                            ingredient,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isUserIngredient
                                                  ? Colors.white
                                                  : (isDarkMode
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                          ),
                                          backgroundColor: isUserIngredient
                                              ? AppTheme.primaryColor
                                              : (isDarkMode
                                                  ? Colors.grey[700]
                                                  : Colors.grey[200]),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: EdgeInsets.zero,
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _buildInfoChip(
                                          context,
                                          Icons.timer_outlined,
                                          '${recipe.cookingTime} ${isLanguageTurkish ? 'dk' : 'min'}',
                                        ),
                                        const SizedBox(width: 8),
                                        _buildInfoChip(
                                          context,
                                          Icons.people_outline,
                                          '${recipe.servings} ${isLanguageTurkish ? 'kişilik' : 'servings'}',
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.favorite_border),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(isLanguageTurkish
                                                    ? 'Favorilere eklendi'
                                                    : 'Added to favorites'),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          color: Colors.red[400],
                                          iconSize: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ],
        );
      },
    );
  }

  // Kullanıcının malzemelerini vurgulayan fonksiyon
  List<String> _getHighlightedIngredients(
      List<String> recipeIngredients, List<String> userIngredients) {
    if (recipeIngredients.length <= 5) {
      return recipeIngredients;
    }

    // Kullanıcının malzemelerini içeren tarif malzemelerini önceliklendir
    final prioritizedIngredients = recipeIngredients.where((ingredient) {
      return userIngredients.any((userIngredient) =>
          ingredient.toLowerCase().contains(userIngredient.toLowerCase()));
    }).toList();

    // Eğer kullanıcı malzemesi içeren 5'ten az malzeme varsa, diğer malzemelerden ekle
    if (prioritizedIngredients.length < 5) {
      final remainingIngredients = recipeIngredients
          .where((ingredient) => !prioritizedIngredients.contains(ingredient))
          .toList();

      prioritizedIngredients
          .addAll(remainingIngredients.take(5 - prioritizedIngredients.length));
    }

    // En fazla 5 malzeme göster
    return prioritizedIngredients.take(5).toList();
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRecipeIcon(String title) {
    final lowercaseTitle = title.toLowerCase();
    if (lowercaseTitle.contains('makarna') ||
        lowercaseTitle.contains('pasta')) {
      return Icons.dinner_dining;
    } else if (lowercaseTitle.contains('çorba') ||
        lowercaseTitle.contains('soup')) {
      return Icons.soup_kitchen;
    } else if (lowercaseTitle.contains('salata') ||
        lowercaseTitle.contains('salad')) {
      return Icons.eco;
    } else if (lowercaseTitle.contains('tatlı') ||
        lowercaseTitle.contains('dessert') ||
        lowercaseTitle.contains('pasta') ||
        lowercaseTitle.contains('cake') ||
        lowercaseTitle.contains('kurabiye') ||
        lowercaseTitle.contains('cookie')) {
      return Icons.cake;
    } else if (lowercaseTitle.contains('et') ||
        lowercaseTitle.contains('meat') ||
        lowercaseTitle.contains('köfte') ||
        lowercaseTitle.contains('meatball')) {
      return Icons.set_meal;
    } else if (lowercaseTitle.contains('balık') ||
        lowercaseTitle.contains('fish')) {
      return Icons.set_meal;
    } else if (lowercaseTitle.contains('tavuk') ||
        lowercaseTitle.contains('chicken')) {
      return Icons.egg;
    } else if (lowercaseTitle.contains('kahvaltı') ||
        lowercaseTitle.contains('breakfast') ||
        lowercaseTitle.contains('omlet') ||
        lowercaseTitle.contains('omelet')) {
      return Icons.breakfast_dining;
    } else if (lowercaseTitle.contains('elma') ||
        lowercaseTitle.contains('apple') ||
        lowercaseTitle.contains('meyve') ||
        lowercaseTitle.contains('fruit')) {
      return Icons.apple;
    } else if (lowercaseTitle.contains('sebze') ||
        lowercaseTitle.contains('vegetable')) {
      return Icons.eco;
    } else if (lowercaseTitle.contains('içecek') ||
        lowercaseTitle.contains('drink') ||
        lowercaseTitle.contains('smoothie') ||
        lowercaseTitle.contains('juice')) {
      return Icons.local_drink;
    } else {
      return Icons.restaurant;
    }
  }
}
