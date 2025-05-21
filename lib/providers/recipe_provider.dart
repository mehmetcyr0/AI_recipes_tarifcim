import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/gemini_service.dart';
import 'user_preferences_provider.dart';
import 'ingredient_provider.dart';
import 'dart:convert';

class RecipeProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  List<Recipe> _recommendedRecipes = [];
  bool _isLoading = false;
  UserPreferencesProvider? _userPreferences;
  IngredientProvider? _ingredientProvider;
  String _errorMessage = '';
  
  List<Recipe> get recommendedRecipes => _recommendedRecipes;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  RecipeProvider() {
    _recommendedRecipes = [];
  }
  
  void updateProviders(UserPreferencesProvider userPreferences, IngredientProvider ingredientProvider) {
    _userPreferences = userPreferences;
    _ingredientProvider = ingredientProvider;
    
    // Eğer malzeme listesi değiştiyse tarifleri güncelle
    if (_ingredientProvider != null && _ingredientProvider!.hasIngredients) {
      fetchRecommendedRecipes();
    }
  }
  
  Future<void> fetchRecommendedRecipes() async {
    if (_userPreferences == null) return;
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final userPrefsString = _userPreferences!.getUserPreferencesForPrompt();
      final language = _userPreferences!.language;
      
      // Malzeme listesini al
      String ingredientsString = "";
      if (_ingredientProvider != null && _ingredientProvider!.hasIngredients) {
        ingredientsString = language == 'tr' 
            ? "Elimdeki malzemeler: ${_ingredientProvider!.getIngredientsAsString()}."
            : "My available ingredients: ${_ingredientProvider!.getIngredientsAsString()}.";
      } else {
        // Malzeme yoksa boş liste döndür
        _recommendedRecipes = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final prompt = language == 'tr'
          ? '''
          Bana elimdeki malzemelere göre 3 özgün tarif oluştur. Bu tarifleri SADECE verdiğim malzemeleri kullanarak veya mümkün olduğunca bu malzemelere odaklanarak oluştur. JSON formatında dön.
          
          $ingredientsString
          Kullanıcı tercihleri: $userPrefsString
          
          Lütfen şu kriterlere dikkat et:
          1. SADECE verdiğim malzemeleri kullan veya bu malzemeleri ana malzemeler olarak kullan
          2. Her tarif için yaratıcı ve lezzetli bir seçenek sun
          3. Tariflerin zorluk seviyesi orta düzeyde olsun
          4. Her tarif için kalori, hazırlama süresi, porsiyon sayısı, malzemeler listesi, hazırlanış adımları ve gıda israfını azaltma ipuçları ekle
          
          JSON formatı şöyle olmalı:
          [
            {
              "id": "1",
              "title": "Tarif Adı",
              "description": "Kısa açıklama",
              "cookingTime": 30,
              "servings": 2,
              "calories": 450,
              "ingredients": ["Malzeme 1", "Malzeme 2", ...],
              "instructions": ["Adım 1", "Adım 2", ...],
              "wasteReductionTips": "Gıda israfını azaltma ipuçları"
            },
            ...
          ]
          
          Sadece JSON döndür, başka açıklama ekleme. Eğer verilen malzemelerle tarif oluşturulamıyorsa, basit bir tarif öner ve eksik malzemeleri belirt.
          '''
          : '''
          Create 3 unique recipes for me based on my available ingredients. Create these recipes using ONLY the ingredients I provide or focusing as much as possible on these ingredients. Return in JSON format.
          
          $ingredientsString
          User preferences: $userPrefsString
          
          Please pay attention to these criteria:
          1. Use ONLY the ingredients I provided or use them as main ingredients
          2. Provide creative and delicious options for each recipe
          3. The difficulty level of the recipes should be moderate
          4. For each recipe, include calories, preparation time, number of servings, list of ingredients, preparation steps, and food waste reduction tips
          
          JSON format should be:
          [
            {
              "id": "1",
              "title": "Recipe Name",
              "description": "Short description",
              "cookingTime": 30,
              "servings": 2,
              "calories": 450,
              "ingredients": ["Ingredient 1", "Ingredient 2", ...],
              "instructions": ["Step 1", "Step 2", ...],
              "wasteReductionTips": "Food waste reduction tips"
            },
            ...
          ]
          
          Return only JSON, don't add any explanation. If recipes cannot be created with the given ingredients, suggest a simple recipe and indicate the missing ingredients.
          ''';
      
      final response = await _geminiService.getResponse(prompt, language: language);
      
      // Extract JSON from response (in case there's any text before or after)
      final jsonRegExp = RegExp(r'\[\s*\{.*\}\s*\]', dotAll: true);
      final match = jsonRegExp.firstMatch(response);
      
      if (match != null) {
        final jsonStr = match.group(0);
        
        try {
          final List<dynamic> recipesJson = jsonDecode(jsonStr!);
          
          final List<Recipe> recipes = recipesJson.map((json) {
            return Recipe(
              id: json['id']?.toString() ?? '',
              title: json['title'] ?? '',
              description: json['description'] ?? '',
              imageUrl: 'https://via.placeholder.com/300x200', // Placeholder image
              cookingTime: json['cookingTime'] is int ? json['cookingTime'] : 30,
              servings: json['servings'] is int ? json['servings'] : 2,
              calories: json['calories'] is int ? json['calories'] : 0,
              ingredients: List<String>.from(json['ingredients'] ?? []),
              instructions: List<String>.from(json['instructions'] ?? []),
              wasteReductionTips: json['wasteReductionTips'] ?? '',
            );
          }).toList();
          
          if (recipes.isNotEmpty) {
            _recommendedRecipes = recipes;
          } else {
            // Boş liste durumunda fallback tarifler oluştur
            _createFallbackRecipes(language);
          }
        } catch (e) {
          debugPrint('JSON parsing error: $e');
          // JSON ayrıştırma hatası durumunda fallback tarifler oluştur
          _createFallbackRecipes(language);
        }
      } else {
        debugPrint('No JSON found in response');
        // JSON bulunamadığında fallback tarifler oluştur
        _createFallbackRecipes(language);
      }
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
      // Hata durumunda fallback tarifler oluştur
      _createFallbackRecipes(_userPreferences?.language ?? 'tr');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void _createFallbackRecipes(String language) {
    final ingredients = _ingredientProvider?.ingredients ?? [];
    if (ingredients.isEmpty) {
      _recommendedRecipes = [];
      return;
    }
    
    // Basit fallback tarifler oluştur
    if (language == 'tr') {
      if (ingredients.contains('yumurta')) {
        _recommendedRecipes = [
          Recipe(
            id: '1',
            title: 'Basit Omlet',
            description: 'Hızlıca hazırlayabileceğiniz lezzetli bir omlet',
            imageUrl: 'https://via.placeholder.com/300x200',
            cookingTime: 10,
            servings: 1,
            calories: 200,
            ingredients: ['Yumurta', ...ingredients.where((i) => i != 'yumurta')],
            instructions: ['Yumurtaları çırpın', 'Diğer malzemeleri ekleyin', 'Tavada pişirin'],
            wasteReductionTips: 'Kalan malzemeleri buzdolabında saklayabilirsiniz.',
          ),
        ];
      } else if (ingredients.contains('soğan')) {
        _recommendedRecipes = [
          Recipe(
            id: '1',
            title: 'Soğanlı Karışım',
            description: 'Soğan bazlı basit bir tarif',
            imageUrl: 'https://via.placeholder.com/300x200',
            cookingTime: 15,
            servings: 2,
            calories: 150,
            ingredients: ['Soğan', ...ingredients.where((i) => i != 'soğan')],
            instructions: ['Soğanları doğrayın', 'Diğer malzemeleri ekleyin', 'Karıştırarak pişirin'],
            wasteReductionTips: 'Kalan malzemeleri buzdolabında saklayabilirsiniz.',
          ),
        ];
      } else {
        _recommendedRecipes = [
          Recipe(
            id: '1',
            title: '${ingredients.first.capitalize()} Karışımı',
            description: 'Basit ve lezzetli bir tarif',
            imageUrl: 'https://via.placeholder.com/300x200',
            cookingTime: 20,
            servings: 2,
            calories: 180,
            ingredients: ingredients,
            instructions: ['Malzemeleri hazırlayın', 'Karıştırın', 'Servis yapın'],
            wasteReductionTips: 'Kalan malzemeleri buzdolabında saklayabilirsiniz.',
          ),
        ];
      }
    } else {
      if (ingredients.contains('egg') || ingredients.contains('eggs')) {
        _recommendedRecipes = [
          Recipe(
            id: '1',
            title: 'Simple Omelette',
            description: 'A quick and delicious omelette',
            imageUrl: 'https://via.placeholder.com/300x200',
            cookingTime: 10,
            servings: 1,
            calories: 200,
            ingredients: ['Eggs', ...ingredients.where((i) => i != 'egg' && i != 'eggs')],
            instructions: ['Beat the eggs', 'Add other ingredients', 'Cook in a pan'],
            wasteReductionTips: 'Store leftover ingredients in the refrigerator.',
          ),
        ];
      } else if (ingredients.contains('onion') || ingredients.contains('onions')) {
        _recommendedRecipes = [
          Recipe(
            id: '1',
            title: 'Onion Mix',
            description: 'A simple onion-based recipe',
            imageUrl: 'https://via.placeholder.com/300x200',
            cookingTime: 15,
            servings: 2,
            calories: 150,
            ingredients: ['Onion', ...ingredients.where((i) => i != 'onion' && i != 'onions')],
            instructions: ['Chop the onions', 'Add other ingredients', 'Cook while stirring'],
            wasteReductionTips: 'Store leftover ingredients in the refrigerator.',
          ),
        ];
      } else {
        _recommendedRecipes = [
          Recipe(
            id: '1',
            title: '${ingredients.first.capitalize()} Mix',
            description: 'A simple and delicious recipe',
            imageUrl: 'https://via.placeholder.com/300x200',
            cookingTime: 20,
            servings: 2,
            calories: 180,
            ingredients: ingredients,
            instructions: ['Prepare the ingredients', 'Mix them together', 'Serve'],
            wasteReductionTips: 'Store leftover ingredients in the refrigerator.',
          ),
        ];
      }
    }
  }
  
  void refreshRecommendedRecipes() {
    if (_ingredientProvider != null && _ingredientProvider!.hasIngredients) {
      fetchRecommendedRecipes();
    } else {
      _recommendedRecipes = [];
      notifyListeners();
    }
  }
}

// String extension for capitalizing first letter
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
