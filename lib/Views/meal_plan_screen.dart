import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';
import 'package:iconsax/iconsax.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final Map<String, String> mealPlan = {
    "Monday": "",
    "Tuesday": "",
    "Wednesday": "",
    "Thursday": "",
    "Friday": "",
    "Saturday": "",
    "Sunday": "",
  };

  @override
  void initState() {
    super.initState();
    loadMealPlan();
  }

  Future<void> loadMealPlan() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('meal_plan')
        .get();

    for (var doc in snapshot.docs) {
      mealPlan[doc.id] = doc['recipe'];
    }

    if (!mounted) return;
    setState(() {});
  }

  Future<void> discardMealPlan() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Discard Meal Plan?"),
        content: const Text(
          "This will remove all your planned meals.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('meal_plan')
                  .get();

              for (var doc in snapshot.docs) {
                await doc.reference.delete();
              }

              if (!mounted) return;
              setState(() {
                mealPlan.updateAll((key, value) => "");
              });

              Navigator.pop(context);
            },
            child: const Text(
              "Discard",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void selectMeal(String day) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select a Recipe",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                /// 🔥 FETCH FROM FIREBASE
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('flutter_recipe_app')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No recipes found");
                    }

                    final recipes = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipeName = recipes[index]['name']; // ✅ FIELD

                        return ListTile(
                          title: Text(recipeName),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            final recipeName = recipes[index]['name'];

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .collection('meal_plan')
                                .doc(day)
                                .set({
                              'recipe': recipeName,
                            });

                            if (!mounted) return;
                            setState(() {
                              mealPlan[day] = recipeName;
                            });

                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Meal Plan",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: discardMealPlan,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: mealPlan.keys.map((day) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                mealPlan[day]!.isEmpty ? "No meal planned" : mealPlan[day]!,
              ),
              trailing: IconButton(
                icon: const Icon(Iconsax.add_circle),
                color: kprimaryColor,
                onPressed: () => selectMeal(day),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
