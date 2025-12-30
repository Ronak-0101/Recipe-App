import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Provider/theme_provider.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: const Text("Notifications"),
              value: notificationEnabled,
              activeColor: kprimaryColor,
              onChanged: (value) {
                setState(() {
                  notificationEnabled = value;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              value: context.watch<ThemeProvider>().isDarkMode,
              activeColor: kprimaryColor,
              onChanged: (value) {
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const ListTile(
              leading: Icon(Iconsax.info_circle),
              title: Text("About App"),
              subtitle: Text("Flutter Recipe App v1.0"),
            ),
          ),
        ],
      ),
    );
  }
}
