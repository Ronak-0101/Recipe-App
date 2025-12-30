import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/Utils/Constant.dart';

class BannerToExplore extends StatelessWidget {
  const BannerToExplore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: kBannerColor,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 32,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cook the best\nrecipes at home",
                  style: TextStyle(
                    height: 1.1,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 33,
                    ),
                    backgroundColor: Colors.white,
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Explore",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              top: 0,
              bottom: 0,
              right: -45,
              child: Image.network(
                "https://th.bing.com/th/id/R.f83655257f2043ae4a1771fb297e8eb3?rik=5GSu2IqzOMbuSw&riu=http%3a%2f%2fpngimg.com%2fuploads%2fchef%2fchef_PNG152.png&ehk=dJ7FvxJQWD9MQBMkRCELqhj9u5vmLkA61OKP0odum4I%3d&risl=&pid=ImgRaw&r=0",
              ))
        ],
      ),
    );
  }
}
