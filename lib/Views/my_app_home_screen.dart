import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';
import 'package:flutter_recipe_app/Views/search_screen.dart';
import 'package:flutter_recipe_app/Views/view_all_items.dart';
import 'package:flutter_recipe_app/Widget/banner.dart';
import 'package:flutter_recipe_app/Widget/food_items_display.dart';
import 'package:flutter_recipe_app/Widget/my_icon_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_recipe_app/Views/search_screen.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  String searchQuery = ""; // Add search query state
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce; // For debouncing search

  // For categories
  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("App_category");

  // For all items display - UPDATED to include search
  Query get filteredRecipe {
    Query query = FirebaseFirestore.instance.collection("flutter_recipe_app");

    // Apply category filter
    if (category != "All") {
      query = query.where('category', isEqualTo: category);
    }

    // Apply search filter if query exists
    if (searchQuery.isNotEmpty) {
      // We'll use array-contains for tags search
      // For name search, we'll do client-side filtering or use Firestore limitations
      return query;
    }

    return query;
  }

  Query get allRecipes =>
      FirebaseFirestore.instance.collection("flutter_recipe_app");

  Query get selectedRecipe => category == "All" ? allRecipes : filteredRecipe;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Debounce search to avoid too many Firestore queries
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value.toLowerCase().trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    mySearchBar(),
                    // For Banner
                    const BannerToExplore(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // For Categories
                    selectedCategory(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quick & Easy",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllItems(),
                              ),
                            );
                          },
                          child: const Text(
                            "View All",
                            style: TextStyle(
                                color: kBannerColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              // Replace the StreamBuilder section with this:
              StreamBuilder(
                stream: selectedRecipe.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    List<QueryDocumentSnapshot> recipes =
                        snapshot.data?.docs ?? [];

                    // Client-side search filtering
                    if (searchQuery.isNotEmpty) {
                      recipes = recipes.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name =
                            data['name']?.toString().toLowerCase() ?? '';
                        final description =
                            data['description']?.toString().toLowerCase() ?? '';
                        final ingredients =
                            List<String>.from(data['ingredients'] ?? [])
                                .map((ing) => ing.toLowerCase())
                                .toList();

                        return name.contains(searchQuery) ||
                            description.contains(searchQuery) ||
                            ingredients.any((ing) => ing.contains(searchQuery));
                      }).toList();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 15, top: 5),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recipes
                              .map((e) => FoodItemsDisplay(documentSnapshot: e))
                              .toList(),
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamsnapshot) {
        if (streamsnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                  streamsnapshot.data!.docs.length,
                  (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            category = streamsnapshot.data!.docs[index]["name"];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: category ==
                                    streamsnapshot.data!.docs[index]["name"]
                                ? kprimaryColor
                                : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(right: 20),
                          child: Text(
                            streamsnapshot.data!.docs[index]["name"],
                            style: TextStyle(
                              color: category ==
                                      streamsnapshot.data!.docs[index]["name"]
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
            ),
          );
        }
        // it means if snapshot has data then it will show data otherwose show the progress bar.
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onTap: () {
          // Navigate to dedicated search screen when clicked
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SearchScreen(initialQuery: searchQuery),
            ),
          );
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Iconsax.search_normal),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      searchQuery = "";
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search any recipes",
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Row headerParts() {
    return Row(
      children: [
        const Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.notification,
          pressed: () {},
        ),
      ],
    );
  }
}
