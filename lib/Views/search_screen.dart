// search_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recipe_app/Provider/diet_filter_provider.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';
import 'package:flutter_recipe_app/Utils/diet_filter.dart';
import 'package:flutter_recipe_app/Widget/food_items_display.dart';
import 'package:flutter_recipe_app/main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  
  const SearchScreen({super.key, this.initialQuery = ""});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce;
  
  // Firestore query for all recipes
  final CollectionReference _recipesCollection = 
      FirebaseFirestore.instance.collection("flutter_recipe_app");

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _searchController.text = widget.initialQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.toLowerCase().trim();
      });
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.search_normal),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = "";
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: "Search recipes, ingredients, categories...",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildRecentSearches();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _recipesCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        List<QueryDocumentSnapshot> allRecipes = snapshot.data!.docs;
        
        // Filter recipes based on search query
        List<QueryDocumentSnapshot> filteredRecipes = allRecipes.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          // Search in name
          final name = data['name']?.toString().toLowerCase() ?? '';
          if (name.contains(_searchQuery)) return true;
          
          // Search in description
          final description = data['description']?.toString().toLowerCase() ?? '';
          if (description.contains(_searchQuery)) return true;
          
          // Search in ingredients
          final ingredients = List<String>.from(data['ingredients'] ?? []);
          if (ingredients.any((ing) => ing.toLowerCase().contains(_searchQuery))) {
            return true;
          }
          
          // Search in tags
          final tags = List<String>.from(data['tags'] ?? []);
          if (tags.any((tag) => tag.toLowerCase().contains(_searchQuery))) {
            return true;
          }
          
          // Search in category
          final category = data['category']?.toString().toLowerCase() ?? '';
          if (category.contains(_searchQuery)) return true;
          
          return false;
        }).toList();

        final dietFilter = context.watch<DietFilterProvider>().dietFilter;
        filteredRecipes = filteredRecipes
        .where((doc) => DietFilterUtils.matchesFilter(doc, dietFilter))
        .toList();

        if (filteredRecipes.isEmpty) {
          return _buildNoResults();
        }

        return _buildRecipeGrid(filteredRecipes);
      },
    );
  }

  Widget _buildRecentSearches() {
    // You can implement recent searches storage using SharedPreferences
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Recent Searches",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        // Add recent searches list here
        const Center(
          child: Padding(
            padding: EdgeInsets.all(50),
            child: Column(
              children: [
                Icon(Iconsax.search_normal, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  "Search for recipes, ingredients, or categories",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.note_remove, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "No recipes found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.search_status, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            "No results for '$_searchQuery'",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Try searching for something else",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid(List<QueryDocumentSnapshot> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return FoodItemsDisplay(documentSnapshot: recipes[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      appBar: AppBar(
        backgroundColor: kbackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Search Recipes",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }
}