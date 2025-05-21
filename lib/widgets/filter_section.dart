import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';
import '../theme/app_theme.dart';

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<UserPreferencesProvider>(
      builder: (context, preferences, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtreler',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 16),
            
            // Porsiyon Sayısı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Porsiyon: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: preferences.servings,
                        items: [1, 2, 3, 4, 5, 6].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value kişilik'),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            preferences.setServings(newValue);
                          }
                        },
                        underline: Container(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  
                  // Hazırlama Süresi
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Hazırlama Süresi: ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: preferences.maxCookingTime,
                        items: [15, 30, 45, 60, 90, 120].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text('$value dk veya daha az'),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            preferences.setMaxCookingTime(newValue);
                          }
                        },
                        underline: Container(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Diyet Filtreleri
            const Text(
              'Diyet Tercihleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Vejetaryen'),
                  selected: preferences.isVegetarian,
                  onSelected: (selected) => preferences.setVegetarian(selected),
                  avatar: const Icon(Icons.eco, size: 16),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
                FilterChip(
                  label: const Text('Vegan'),
                  selected: preferences.isVegan,
                  onSelected: (selected) => preferences.setVegan(selected),
                  avatar: const Icon(Icons.spa, size: 16),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
                FilterChip(
                  label: const Text('Keto'),
                  selected: preferences.isKeto,
                  onSelected: (selected) => preferences.setKeto(selected),
                  avatar: const Icon(Icons.fitness_center, size: 16),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
                FilterChip(
                  label: const Text('Glutensiz'),
                  selected: preferences.hasGlutenAllergy,
                  onSelected: (selected) => preferences.setGlutenAllergy(selected),
                  avatar: const Icon(Icons.no_food, size: 16),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
                FilterChip(
                  label: const Text('Laktozsuz'),
                  selected: preferences.hasLactoseAllergy,
                  onSelected: (selected) => preferences.setLactoseAllergy(selected),
                  avatar: const Icon(Icons.no_drinks, size: 16),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
