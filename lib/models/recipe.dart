class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // Kept for compatibility, but we'll use icons instead
  final int cookingTime; // in minutes
  final int servings;
  final int calories;
  final List<String> ingredients;
  final List<String> instructions;
  final String wasteReductionTips;
  
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.servings,
    required this.calories,
    required this.ingredients,
    required this.instructions,
    required this.wasteReductionTips,
  });
}
