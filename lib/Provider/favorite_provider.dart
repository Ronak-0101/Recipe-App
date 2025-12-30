import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favorites => _favoriteIds;

  FavoriteProvider(product) {
    loadFavorite();
  }

  void togglefavorite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId); // Removes from favorites
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId); // Add from favorites
    }
    notifyListeners();
  }

  // Check if the item is favorite
  bool isExist(QueryDocumentSnapshot prouct) {
    return _favoriteIds.contains(prouct.id);
  }

  // Add favorite to Firestore
  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        'isFavorite': true
      }); // Create userFavorite collection and add items as favorite in firestore.
    } catch (e) {
      print(e.toString());
    }
  }

  // Remove favorite from Firestore
  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
      // Create userFavorite collection and add items as favorite in firestore.
    } catch (e) {
      print(e.toString());
    }
  }

  // Load favorites from Firestore ( Store favorite or not )
  Future<void> loadFavorite() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection("userFavorite").get();
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  // Static method to access the provider from any context
  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(
      context,
      listen: listen,
    );
  }
}
