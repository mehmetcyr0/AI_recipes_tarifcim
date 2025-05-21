import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class IngredientProvider extends ChangeNotifier {
  static const String _ingredientsKey = 'ingredients';
  
  List<String> _ingredients = [];
  bool _isInitialized = false;
  
  final SharedPreferences _prefs;
  
  List<String> get ingredients => _ingredients;
  bool get isInitialized => _isInitialized;
  bool get hasIngredients => _ingredients.isNotEmpty;
  
  IngredientProvider(this._prefs) {
    _loadIngredients();
  }
  
  Future<void> _loadIngredients() async {
    try {
      final String? ingredientsJson = _prefs.getString(_ingredientsKey);
      if (ingredientsJson != null) {
        final List<dynamic> decoded = jsonDecode(ingredientsJson);
        _ingredients = decoded.map((item) => item.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error loading ingredients: $e');
      _ingredients = [];
    }
    
    _isInitialized = true;
    notifyListeners();
  }
  
  Future<void> _saveIngredients() async {
    try {
      final String ingredientsJson = jsonEncode(_ingredients);
      await _prefs.setString(_ingredientsKey, ingredientsJson);
    } catch (e) {
      debugPrint('Error saving ingredients: $e');
    }
  }
  
  void addIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    
    // Aynı malzeme zaten varsa ekleme
    if (_ingredients.contains(ingredient.trim())) return;
    
    _ingredients.add(ingredient.trim());
    _saveIngredients();
    notifyListeners();
  }
  
  void removeIngredient(int index) {
    if (index >= 0 && index < _ingredients.length) {
      _ingredients.removeAt(index);
      _saveIngredients();
      notifyListeners();
    }
  }
  
  void removeIngredientByName(String ingredient) {
    _ingredients.remove(ingredient);
    _saveIngredients();
    notifyListeners();
  }
  
  void clearIngredients() {
    _ingredients.clear();
    _saveIngredients();
    notifyListeners();
  }
  
  String getIngredientsAsString() {
    return _ingredients.join(', ');
  }
}
