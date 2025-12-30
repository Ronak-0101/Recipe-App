import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Provider/favorite_provider.dart';
import 'package:flutter_recipe_app/Provider/quantity.dart';
import 'package:flutter_recipe_app/Provider/theme_provider.dart';
import 'package:flutter_recipe_app/Views/auth/auth_wrapper.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

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
        // Favorites provider
        ChangeNotifierProvider(create: (_) => FavoriteProvider(_)),

        // Quantity provider
        ChangeNotifierProvider(create: (_) => QuantityProvider()),

        // Theme provider (Dark Mode)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // 🌞 Light Theme
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: kprimaryColor,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 🌙 Dark Theme
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: kprimaryColor,
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 🔄 Theme switch
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // 🔐 Auth based navigation
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
