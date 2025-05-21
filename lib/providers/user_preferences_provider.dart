import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesProvider extends ChangeNotifier {
  // SharedPreferences anahtarları
  static const String _keyVegetarian = 'vegetarian';
  static const String _keyVegan = 'vegan';
  static const String _keyKeto = 'keto';
  static const String _keyLowCarb = 'lowCarb';
  
  static const String _keyGlutenAllergy = 'glutenAllergy';
  static const String _keyLactoseAllergy = 'lactoseAllergy';
  static const String _keyNutAllergy = 'nutAllergy';
  static const String _keySeafoodAllergy = 'seafoodAllergy';
  static const String _keyEggAllergy = 'eggAllergy';
  
  static const String _keyServings = 'servings';
  static const String _keyMaxCookingTime = 'maxCookingTime';
  
  static const String _keyDarkMode = 'darkMode';
  static const String _keyTTSEnabled = 'ttsEnabled';
  static const String _keyLanguage = 'language';
  
  // Diyet Tercihleri
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isKeto = false;
  bool _isLowCarb = false;
  
  // Alerjiler
  bool _hasGlutenAllergy = false;
  bool _hasLactoseAllergy = false;
  bool _hasNutAllergy = false;
  bool _hasSeafoodAllergy = false;
  bool _hasEggAllergy = false;
  
  // Tarif Tercihleri
  int _servings = 2;
  int _maxCookingTime = 30;
  
  // Uygulama Ayarları
  bool _isDarkMode = false;
  bool _isTTSEnabled = true;
  String _language = 'tr';
  
  // Initialization flag
  bool _isInitialized = false;
  
  // SharedPreferences instance
  final SharedPreferences _prefs;
  
  // Constructor
  UserPreferencesProvider(this._prefs) {
    _loadPreferences();
  }
  
  // Preferences'ları yükle
  Future<void> _loadPreferences() async {
    _isVegetarian = _prefs.getBool(_keyVegetarian) ?? false;
    _isVegan = _prefs.getBool(_keyVegan) ?? false;
    _isKeto = _prefs.getBool(_keyKeto) ?? false;
    _isLowCarb = _prefs.getBool(_keyLowCarb) ?? false;
    
    _hasGlutenAllergy = _prefs.getBool(_keyGlutenAllergy) ?? false;
    _hasLactoseAllergy = _prefs.getBool(_keyLactoseAllergy) ?? false;
    _hasNutAllergy = _prefs.getBool(_keyNutAllergy) ?? false;
    _hasSeafoodAllergy = _prefs.getBool(_keySeafoodAllergy) ?? false;
    _hasEggAllergy = _prefs.getBool(_keyEggAllergy) ?? false;
    
    _servings = _prefs.getInt(_keyServings) ?? 2;
    _maxCookingTime = _prefs.getInt(_keyMaxCookingTime) ?? 30;
    
    _isDarkMode = _prefs.getBool(_keyDarkMode) ?? false;
    _isTTSEnabled = _prefs.getBool(_keyTTSEnabled) ?? true;
    _language = _prefs.getString(_keyLanguage) ?? 'tr';
    
    _isInitialized = true;
    notifyListeners();
  }
  
  // Getters
  bool get isVegetarian => _isVegetarian;
  bool get isVegan => _isVegan;
  bool get isKeto => _isKeto;
  bool get isLowCarb => _isLowCarb;
  
  bool get hasGlutenAllergy => _hasGlutenAllergy;
  bool get hasLactoseAllergy => _hasLactoseAllergy;
  bool get hasNutAllergy => _hasNutAllergy;
  bool get hasSeafoodAllergy => _hasSeafoodAllergy;
  bool get hasEggAllergy => _hasEggAllergy;
  
  int get servings => _servings;
  int get maxCookingTime => _maxCookingTime;
  
  bool get isDarkMode => _isDarkMode;
  bool get isTTSEnabled => _isTTSEnabled;
  String get language => _language;
  bool get isInitialized => _isInitialized;
  
  // Setters
  void setVegetarian(bool value) {
    _isVegetarian = value;
    _prefs.setBool(_keyVegetarian, value);
    notifyListeners();
  }
  
  void setVegan(bool value) {
    _isVegan = value;
    _prefs.setBool(_keyVegan, value);
    notifyListeners();
  }
  
  void setKeto(bool value) {
    _isKeto = value;
    _prefs.setBool(_keyKeto, value);
    notifyListeners();
  }
  
  void setLowCarb(bool value) {
    _isLowCarb = value;
    _prefs.setBool(_keyLowCarb, value);
    notifyListeners();
  }
  
  void setGlutenAllergy(bool value) {
    _hasGlutenAllergy = value;
    _prefs.setBool(_keyGlutenAllergy, value);
    notifyListeners();
  }
  
  void setLactoseAllergy(bool value) {
    _hasLactoseAllergy = value;
    _prefs.setBool(_keyLactoseAllergy, value);
    notifyListeners();
  }
  
  void setNutAllergy(bool value) {
    _hasNutAllergy = value;
    _prefs.setBool(_keyNutAllergy, value);
    notifyListeners();
  }
  
  void setSeafoodAllergy(bool value) {
    _hasSeafoodAllergy = value;
    _prefs.setBool(_keySeafoodAllergy, value);
    notifyListeners();
  }
  
  void setEggAllergy(bool value) {
    _hasEggAllergy = value;
    _prefs.setBool(_keyEggAllergy, value);
    notifyListeners();
  }
  
  void setServings(int value) {
    _servings = value;
    _prefs.setInt(_keyServings, value);
    notifyListeners();
  }
  
  void setMaxCookingTime(int value) {
    _maxCookingTime = value;
    _prefs.setInt(_keyMaxCookingTime, value);
    notifyListeners();
  }
  
  void setDarkMode(bool value) {
    _isDarkMode = value;
    _prefs.setBool(_keyDarkMode, value);
    notifyListeners();
  }
  
  void setTTSEnabled(bool value) {
    _isTTSEnabled = value;
    _prefs.setBool(_keyTTSEnabled, value);
    notifyListeners();
  }
  
  void setLanguage(String value) {
    _language = value;
    _prefs.setString(_keyLanguage, value);
    notifyListeners();
  }
  
  // Get user preferences as a formatted string for AI prompt
  String getUserPreferencesForPrompt() {
    final List<String> preferences = [];
    
    if (_isVegetarian) preferences.add('vejetaryen');
    if (_isVegan) preferences.add('vegan');
    if (_isKeto) preferences.add('ketojenik');
    if (_isLowCarb) preferences.add('düşük karbonhidrat');
    
    final List<String> allergies = [];
    if (_hasGlutenAllergy) allergies.add('gluten');
    if (_hasLactoseAllergy) allergies.add('laktoz');
    if (_hasNutAllergy) allergies.add('fındık/kuruyemiş');
    if (_hasSeafoodAllergy) allergies.add('deniz ürünleri');
    if (_hasEggAllergy) allergies.add('yumurta');
    
    String result = '';
    
    if (preferences.isNotEmpty) {
      result += 'Diyet tercihleri: ${preferences.join(', ')}. ';
    }
    
    if (allergies.isNotEmpty) {
      result += 'Alerjiler: ${allergies.join(', ')}. ';
    }
    
    result += 'Tercih edilen porsiyon sayısı: $_servings kişilik. ';
    result += 'Maksimum hazırlama süresi: $_maxCookingTime dakika.';
    
    return result;
  }
}
