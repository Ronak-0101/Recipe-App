import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Provider/favorite_provider.dart';
import 'package:flutter_recipe_app/Provider/quantity.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';
import 'package:flutter_recipe_app/Widget/my_icon_button.dart';
import 'package:flutter_recipe_app/Widget/quantity_inc_dec.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> documentSnapshot;
  const RecipeDetailScreen({super.key, required this.documentSnapshot});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
//   @override
//   void initState() {
// // initialise base ingredient amount in the provider
//     List<double> baseAmounts = widget.documentSnapshot['ingredientAmmount']
//         .map<double>(
//           (amount) => double.parse(
//             amount.toString(),
//           ),
//         )
//         .toList();
//     Provider.of<QuantityProvider>(context, listen: false)
//         .setBaseIngredientAmounts(baseAmounts);
//     super.initState();
//   }
  @override
  void initState() {
    super.initState();

    // initialise base ingredient amount in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<double> baseAmounts = widget.documentSnapshot['ingredientAmmount']
          .map<double>((amount) => double.parse(amount.toString()))
          .toList();

      Provider.of<QuantityProvider>(context, listen: false)
          .setBaseIngredientAmounts(baseAmounts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    final quantityProvider = Provider.of<QuantityProvider>(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // For Image

                Hero(
                  tag: widget.documentSnapshot['image'],
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2.1,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          widget.documentSnapshot['image'],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back_ios_new,
                        pressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      MyIconButton(
                        icon: Iconsax.notification,
                        pressed: () {},
                      ),
                    ],
                  ),
                ),
                Positioned(
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.width,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ))
              ],
            ),
            // For drag handle
            Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Iconsax.flash_1,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 1),
                      Text(
                        "${widget.documentSnapshot['cal']} kcal",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Text(
                        " . ",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey,
                        ),
                      ),
                      const Icon(
                        Iconsax.clock,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // For Rating
                  Row(
                    children: [
                      const Icon(
                        Iconsax.star1,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.documentSnapshot['rating'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("/5"),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['reviews'.toString()]} Reviews",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredients',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "How many Servings?",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      QuantityIncrementDecrement(
                        currentNumber: quantityProvider.currentNumber,
                        onAdd: () => quantityProvider.increaseQuantity(),
                        onRemov: () => quantityProvider.decreaseQuantity(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // List of ingredients
                  Column(
                    children: [
                      Row(  
                        children: [
                          // Ingredients image
                          Column(
                            children: widget.documentSnapshot['ingredientImage']
                                .map<Widget>(
                                  (imageUrl) => Container(
                                    height: 60,
                                    width: 60,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          imageUrl,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(width: 20),
                          // Ingredients name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.documentSnapshot['ingredientName']
                                .map<Widget>(
                                  (ingredient) => SizedBox(
                                    height: 70,
                                    child: Center(
                                      child: Text(
                                        ingredient,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const Spacer(),
                          // Ingredients amount
                          Column(
                            children: quantityProvider.updateIngredientAmounts
                                .map<Widget>(
                                  (amount) => SizedBox(
                                    height: 70,
                                    child: Center(
                                      child: Text(
                                        "${amount}gm",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FloatingActionButton startCookingAndFavoriteButton(
      FavoriteProvider provider) {
    return FloatingActionButton.extended(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {},
      label: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kprimaryColor,
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 100),
                foregroundColor: Colors.white,
              ),
              onPressed: () {},
              child: const Text(
                "Start Cooking",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              style: IconButton.styleFrom(
                shape: CircleBorder(
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 2,
                  ),
                ),
              ),
              onPressed: () {
                provider.togglefavorite(widget.documentSnapshot);
              },
              icon: Icon(
                provider.isExist(widget.documentSnapshot)
                    ? Iconsax.heart5
                    : Iconsax.heart,
                color: provider.isExist(widget.documentSnapshot)
                    ? Colors.red
                    : Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
