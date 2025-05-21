import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            Provider.of<UserPreferencesProvider>(context).language == 'tr'
                ? 'Ayarlar'
                : 'Settings'),
      ),
      body: Consumer<UserPreferencesProvider>(
        builder: (context, preferences, child) {
          // Dil ayarına göre metinleri belirle
          final isLanguageTurkish = preferences.language == 'tr';
          final texts = _getLocalizedTexts(isLanguageTurkish);

          return ListView(
            children: [
              // Diyet Tercihleri
              _buildSectionHeader(context, texts['dietPreferences']!),
              SwitchListTile(
                title: Text(texts['vegetarian']!),
                value: preferences.isVegetarian,
                onChanged: (value) {
                  preferences.setVegetarian(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['vegan']!),
                value: preferences.isVegan,
                onChanged: (value) {
                  preferences.setVegan(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.spa, color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['keto']!),
                value: preferences.isKeto,
                onChanged: (value) {
                  preferences.setKeto(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center,
                      color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['lowCarb']!),
                value: preferences.isLowCarb,
                onChanged: (value) {
                  preferences.setLowCarb(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.grain, color: AppTheme.primaryColor),
                ),
              ),

              const Divider(),

              // Alerjiler
              _buildSectionHeader(context, texts['allergies']!),
              SwitchListTile(
                title: Text(texts['gluten']!),
                value: preferences.hasGlutenAllergy,
                onChanged: (value) {
                  preferences.setGlutenAllergy(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.no_food, color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['lactose']!),
                value: preferences.hasLactoseAllergy,
                onChanged: (value) {
                  preferences.setLactoseAllergy(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.no_drinks, color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['nuts']!),
                value: preferences.hasNutAllergy,
                onChanged: (value) {
                  preferences.setNutAllergy(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['seafood']!),
                value: preferences.hasSeafoodAllergy,
                onChanged: (value) {
                  preferences.setSeafoodAllergy(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.set_meal, color: AppTheme.primaryColor),
                ),
              ),
              SwitchListTile(
                title: Text(texts['egg']!),
                value: preferences.hasEggAllergy,
                onChanged: (value) {
                  preferences.setEggAllergy(value);
                  _refreshRecipes(context);
                },
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.egg, color: AppTheme.primaryColor),
                ),
              ),

              const Divider(),

              // Uygulama Ayarları
              _buildSectionHeader(context, texts['appSettings']!),
              SwitchListTile(
                title: Text(texts['darkMode']!),
                value: preferences.isDarkMode,
                onChanged: (value) => preferences.setDarkMode(value),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    preferences.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(texts['tts']!),
                value: preferences.isTTSEnabled,
                onChanged: (value) => preferences.setTTSEnabled(value),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.volume_up, color: AppTheme.primaryColor),
                ),
              ),
              ListTile(
                title: Text(texts['language']!),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.language, color: AppTheme.primaryColor),
                ),
                trailing: DropdownButton<String>(
                  value: preferences.language,
                  items: [
                    DropdownMenuItem(
                        value: 'tr', child: Text(texts['turkish']!)),
                    DropdownMenuItem(
                        value: 'en', child: Text(texts['english']!)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      preferences.setLanguage(value);

                      // Dil değişikliği bildirim mesajı
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value == 'tr'
                              ? 'Dil Türkçe olarak ayarlandı'
                              : 'Language set to English'),
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // ChatProvider'a dil değişikliğini bildir
                      Provider.of<ChatProvider>(context, listen: false)
                          .updateUserPreferences(preferences);

                      // Tarifleri yenile
                      _refreshRecipes(context);
                    }
                  },
                  underline: Container(),
                ),
              ),

              const Divider(),

              // Hakkında
              ListTile(
                title: Text(texts['about']!),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline,
                      color: AppTheme.primaryColor),
                ),
                onTap: () => _showAboutDialog(context, isLanguageTurkish),
              ),
              ListTile(
                title: Text(texts['privacyPolicy']!),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.privacy_tip_outlined,
                      color: AppTheme.primaryColor),
                ),
                onTap: () => _showPrivacyPolicy(context, isLanguageTurkish),
              ),
              ListTile(
                title: Text(texts['version']!),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.new_releases_outlined,
                      color: AppTheme.primaryColor),
                ),
                trailing: const Text('1.0.0'),
              ),

              const SizedBox(height: 24),

              // Ayarları Sıfırla Butonu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _showResetConfirmation(
                      context, preferences, isLanguageTurkish),
                  icon: const Icon(Icons.restore),
                  label: Text(texts['resetSettings']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isLanguageTurkish) {
    final texts = _getLocalizedTexts(isLanguageTurkish);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['aboutTitle']!),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(texts['aboutDescription']!),
              const SizedBox(height: 16),
              Text(
                texts['features']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${texts['feature1']!}'),
              Text('• ${texts['feature2']!}'),
              Text('• ${texts['feature3']!}'),
              Text('• ${texts['feature4']!}'),
              Text('• ${texts['feature5']!}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(texts['ok']!),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context, bool isLanguageTurkish) {
    final texts = _getLocalizedTexts(isLanguageTurkish);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['privacyPolicy']!),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(texts['privacyDescription']!),
              const SizedBox(height: 16),
              Text(
                texts['collectedData']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${texts['dataItem1']!}'),
              Text('• ${texts['dataItem2']!}'),
              Text('• ${texts['dataItem3']!}'),
              const SizedBox(height: 16),
              Text(texts['dataUsage']!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(texts['understand']!),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context,
      UserPreferencesProvider preferences, bool isLanguageTurkish) {
    final texts = _getLocalizedTexts(isLanguageTurkish);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts['resetSettings']!),
        content: Text(texts['resetConfirmation']!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(texts['cancel']!),
          ),
          TextButton(
            onPressed: () {
              // Tüm ayarları sıfırla
              preferences.setVegetarian(false);
              preferences.setVegan(false);
              preferences.setKeto(false);
              preferences.setLowCarb(false);

              preferences.setGlutenAllergy(false);
              preferences.setLactoseAllergy(false);
              preferences.setNutAllergy(false);
              preferences.setSeafoodAllergy(false);
              preferences.setEggAllergy(false);

              preferences.setServings(2);
              preferences.setMaxCookingTime(30);

              preferences.setDarkMode(false);
              preferences.setTTSEnabled(true);

              // Dili sıfırlama (mevcut dili koru)
              // preferences.setLanguage('tr');

              Navigator.pop(context);

              // Tarifleri yenile
              _refreshRecipes(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(texts['resetComplete']!),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(texts['reset']!),
          ),
        ],
      ),
    );
  }

  // Ayarlar değiştiğinde tarifleri yenile
  void _refreshRecipes(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 300), () {
      Provider.of<RecipeProvider>(context, listen: false)
          .refreshRecommendedRecipes();
    });
  }

  // Dil desteği için metinler
  Map<String, String> _getLocalizedTexts(bool isLanguageTurkish) {
    if (isLanguageTurkish) {
      return {
        'dietPreferences': 'Diyet Tercihleri',
        'vegetarian': 'Vejetaryen',
        'vegan': 'Vegan',
        'keto': 'Ketojenik',
        'lowCarb': 'Düşük Karbonhidrat',
        'allergies': 'Alerjiler',
        'gluten': 'Gluten',
        'lactose': 'Laktoz',
        'nuts': 'Fındık/Kuruyemiş',
        'seafood': 'Deniz Ürünleri',
        'egg': 'Yumurta',
        'appSettings': 'Uygulama Ayarları',
        'darkMode': 'Karanlık Mod',
        'tts': 'Sesli Anlatım',
        'language': 'Dil',
        'turkish': 'Türkçe',
        'english': 'İngilizce',
        'about': 'Hakkında',
        'aboutTitle': 'Tarifcim Hakkında',
        'aboutDescription':
            'Tarifcim, yapay zeka destekli bir tarif öneri uygulamasıdır. Evinizdeki malzemelere göre size uygun tarifler önerir ve diyet tercihlerinize göre kişiselleştirilmiş öneriler sunar.',
        'features': 'Uygulama Özellikleri:',
        'feature1': 'Malzemeye göre tarif önerileri',
        'feature2': 'Diyet ve alerji filtrelemeleri',
        'feature3': 'Yapay zeka destekli sohbet',
        'feature4': 'Sesli tarif anlatımı',
        'feature5': 'Gıda israfını azaltma ipuçları',
        'privacyPolicy': 'Gizlilik Politikası',
        'privacyDescription':
            'Tarifcim uygulaması, kullanıcı deneyimini iyileştirmek için bazı verileri cihazınızda saklar. Bu veriler arasında diyet tercihleri, alerjiler ve uygulama ayarları bulunur.',
        'collectedData': 'Toplanan Veriler:',
        'dataItem1': 'Diyet tercihleri ve alerjiler',
        'dataItem2': 'Uygulama ayarları (tema, dil vb.)',
        'dataItem3': 'Sohbet geçmişi',
        'dataUsage':
            'Bu veriler sadece cihazınızda saklanır ve herhangi bir sunucuya gönderilmez. Yapay zeka ile iletişim sırasında gönderilen veriler, kişisel bilgilerinizi içermez ve sadece tarif önerileri almak için kullanılır.',
        'version': 'Sürüm',
        'resetSettings': 'Ayarları Sıfırla',
        'resetConfirmation':
            'Tüm ayarlarınız varsayılan değerlere sıfırlanacak. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?',
        'resetComplete': 'Tüm ayarlar sıfırlandı',
        'ok': 'Tamam',
        'understand': 'Anladım',
        'cancel': 'İptal',
        'reset': 'Sıfırla',
      };
    } else {
      return {
        'dietPreferences': 'Diet Preferences',
        'vegetarian': 'Vegetarian',
        'vegan': 'Vegan',
        'keto': 'Ketogenic',
        'lowCarb': 'Low Carbohydrate',
        'allergies': 'Allergies',
        'gluten': 'Gluten',
        'lactose': 'Lactose',
        'nuts': 'Nuts',
        'seafood': 'Seafood',
        'egg': 'Egg',
        'appSettings': 'App Settings',
        'darkMode': 'Dark Mode',
        'tts': 'Voice Narration',
        'language': 'Language',
        'turkish': 'Turkish',
        'english': 'English',
        'about': 'About',
        'aboutTitle': 'About Tarifcim',
        'aboutDescription':
            'Tarifcim is an AI-powered recipe recommendation app. It suggests recipes based on the ingredients you have at home and offers personalized recommendations according to your dietary preferences.',
        'features': 'App Features:',
        'feature1': 'Recipe recommendations based on ingredients',
        'feature2': 'Diet and allergy filtering',
        'feature3': 'AI-powered chat',
        'feature4': 'Voice narration of recipes',
        'feature5': 'Food waste reduction tips',
        'privacyPolicy': 'Privacy Policy',
        'privacyDescription':
            'The Tarifcim app stores some data on your device to improve the user experience. This data includes dietary preferences, allergies, and app settings.',
        'collectedData': 'Collected Data:',
        'dataItem1': 'Dietary preferences and allergies',
        'dataItem2': 'App settings (theme, language, etc.)',
        'dataItem3': 'Chat history',
        'dataUsage':
            'This data is only stored on your device and is not sent to any server. Data sent during communication with AI does not contain your personal information and is only used to get recipe recommendations.',
        'version': 'Version',
        'resetSettings': 'Reset Settings',
        'resetConfirmation':
            'All your settings will be reset to default values. This action cannot be undone. Do you want to continue?',
        'resetComplete': 'All settings have been reset',
        'ok': 'OK',
        'understand': 'I Understand',
        'cancel': 'Cancel',
        'reset': 'Reset',
      };
    }
  }
}
