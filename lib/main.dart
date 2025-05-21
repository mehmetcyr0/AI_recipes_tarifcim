import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/ingredient_provider.dart';
import 'theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SharedPreferences örneğini başlat
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  
  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserPreferencesProvider(sharedPreferences),
        ),
        ChangeNotifierProvider(
          create: (_) => IngredientProvider(sharedPreferences),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProxyProvider2<UserPreferencesProvider, IngredientProvider, RecipeProvider>(
          create: (_) => RecipeProvider(),
          update: (_, userPrefs, ingredientProvider, recipeProvider) => 
            recipeProvider!..updateProviders(userPrefs, ingredientProvider),
        ),
      ],
      child: Consumer<UserPreferencesProvider>(
        builder: (context, preferences, _) {
          if (!preferences.isInitialized) {
            // Show loading screen while preferences are being loaded
            return MaterialApp(
              title: 'Tarifcim',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          
          return MaterialApp(
            title: 'Tarifcim',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: Locale(preferences.language),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
