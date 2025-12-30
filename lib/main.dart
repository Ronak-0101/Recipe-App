import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Provider/favorite_provider.dart';
import 'package:flutter_recipe_app/Provider/quantity.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'Views/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // For favorite provider
        // ignore: no_wildcard_variable_uses
        ChangeNotifierProvider(create: (_)=>FavoriteProvider(_)),
        // For quantity provider
        ChangeNotifierProvider(create: (_)=>QuantityProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppMainScreen(),
      ),
    );
  }
}

