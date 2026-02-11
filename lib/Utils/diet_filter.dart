import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/Provider/diet_filter_provider.dart';

class DietFilterUtils {
  static const List<String> _nonVegKeywords = [
    'chicken',
    'mutton',
    'beef',
    'pork',
    'fish',
    'tuna',
    'salmon',
    'shrimp',
    'prawn',
    'crab',
    'egg',
    'meat',
    'bacon',
    'ham',
  ];

  static bool matchesFilter(
    QueryDocumentSnapshot recipe,
    DietFilter filter,
  ) {
    final data = recipe.data() as Map<String, dynamic>;
    return matchesData(data, filter);
  }

  static bool matchesData(
    Map<String, dynamic> data,
    DietFilter filter,
  ) {
    if (filter == DietFilter.all) return true;

    final bool isVeg = _isVegRecipe(data);

    if (filter == DietFilter.veg) return isVeg;
    return !isVeg;
  }

  static bool _isVegRecipe(Map<String, dynamic> data) {
    final bool? explicitVeg = _readBool(data, ['isVeg', 'is_veg', 'veg']);
    if (explicitVeg != null) return explicitVeg;

    final bool? explicitVegetarian = _readBool(data, ['vegetarian']);
    if (explicitVegetarian != null) return explicitVegetarian;

    final combinedText = <String>[
      data['name']?.toString() ?? '',
      data['description']?.toString() ?? '',
      data['category']?.toString() ?? '',
      data['type']?.toString() ?? '',
      data['foodType']?.toString() ?? '',
      data['diet']?.toString() ?? '',
      data['mealType']?.toString() ?? '',
      ...List<String>.from(data['ingredients'] ?? const []),
      ...List<String>.from(data['tags'] ?? const []),
      ...List<String>.from(data['ingredientName'] ?? const []),
    ].join(' ').toLowerCase();

    final hashNonVegKeyword =
        _nonVegKeywords.any((keyword) => combinedText.contains(keyword));

    return !hashNonVegKeyword;
  }

  static bool? _readBool(Map<String, dynamic> data, List<String> keys) {
    for(final key in keys) {
      final dynamic value = data[key];
      if(value is bool) return value;
      if(value is String) {
        final normalized = value.trim().toLowerCase();
        if(normalized == 'true') return true;
        if(normalized == 'false') return false;
      }
    }
    return null;
  }
}
