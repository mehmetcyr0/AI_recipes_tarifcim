import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/ingredient_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/app_theme.dart';

class IngredientInput extends StatefulWidget {
  const IngredientInput({super.key});

  @override
  State<IngredientInput> createState() => _IngredientInputState();
}

class _IngredientInputState extends State<IngredientInput> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _addIngredient() {
    if (_controller.text.trim().isNotEmpty) {
      Provider.of<IngredientProvider>(context, listen: false)
          .addIngredient(_controller.text.trim());
      _controller.clear();
    }
  }
  
  void _findRecipes() {
    final ingredientProvider = Provider.of<IngredientProvider>(context, listen: false);
    
    if (!ingredientProvider.hasIngredients) {
      final isLanguageTurkish = Provider.of<UserPreferencesProvider>(context, listen: false).language == 'tr';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isLanguageTurkish 
            ? 'Lütfen en az bir malzeme ekleyin' 
            : 'Please add at least one ingredient')),
      );
      return;
    }
    
    // Tarifleri güncelle
    Provider.of<RecipeProvider>(context, listen: false).refreshRecommendedRecipes();
    
    // Sohbet ekranına da gönder
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final ingredientsList = ingredientProvider.getIngredientsAsString();
    final isLanguageTurkish = Provider.of<UserPreferencesProvider>(context, listen: false).language == 'tr';
    
    chatProvider.sendMessage(
      isLanguageTurkish
          ? "Elimde şu malzemeler var: $ingredientsList. Bana bu malzemelerle yapabileceğim özgün bir tarif önerir misin?"
          : "I have these ingredients: $ingredientsList. Can you suggest a unique recipe I can make with these ingredients?",
    );
    
    // Başarılı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isLanguageTurkish 
            ? 'Yapay zeka tariflerinizi hazırlıyor...' 
            : 'AI is preparing your recipes...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLanguageTurkish = Provider.of<UserPreferencesProvider>(context).language == 'tr';
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: isLanguageTurkish
                      ? 'Malzeme ekleyin (örn. domates, soğan, peynir)'
                      : 'Add ingredient (e.g. tomato, onion, cheese)',
                  prefixIcon: const Icon(Icons.shopping_basket_outlined),
                  suffixIcon: _controller.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _controller.clear()),
                      )
                    : null,
                ),
                onSubmitted: (_) => _addIngredient(),
                onChanged: (value) {
                  // Force rebuild to update clear button
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add),
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Malzeme çipleri
        Consumer<IngredientProvider>(
          builder: (context, ingredientProvider, child) {
            if (!ingredientProvider.hasIngredients) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome, 
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isLanguageTurkish
                            ? 'Malzemelerinizi ekleyin ve yapay zeka size özel tarifler oluştursun!'
                            : 'Add your ingredients and let AI create custom recipes for you!',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isLanguageTurkish
                                ? 'Eklenen Malzemeler (${ingredientProvider.ingredients.length})'
                                : 'Added Ingredients (${ingredientProvider.ingredients.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(isLanguageTurkish ? 'Malzemeleri Temizle' : 'Clear Ingredients'),
                                  content: Text(isLanguageTurkish 
                                      ? 'Tüm malzemeleri silmek istediğinize emin misiniz?' 
                                      : 'Are you sure you want to remove all ingredients?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(isLanguageTurkish ? 'İptal' : 'Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ingredientProvider.clearIngredients();
                                        Navigator.pop(context);
                                      },
                                      child: Text(isLanguageTurkish ? 'Temizle' : 'Clear'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: Text(isLanguageTurkish ? 'Temizle' : 'Clear'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                          ingredientProvider.ingredients.length,
                          (index) => Chip(
                            label: Text(
                              ingredientProvider.ingredients[index],
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => ingredientProvider.removeIngredient(index),
                            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
                            side: BorderSide(
                              color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _findRecipes,
            icon: const Icon(Icons.auto_awesome),
            label: Text(isLanguageTurkish ? 'Yapay Zeka ile Tarif Bul' : 'Find AI Recipes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              backgroundColor: Colors.purple,
            ),
          ),
        ),
      ],
    );
  }
}
