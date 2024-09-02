import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ObjectsMenu extends StatelessWidget {
  final Function(String) onActionSelected;
  ObjectsMenu({super.key, required this.onActionSelected});
  final List<String> objects = [
    "Ball",
    "Agility",
    "Strip",
    "Low cone",
    "Cone",
    "Podelprit",
    "Vertical Basket",
    "Basket",
    "Player 6",
    "Player 5",
    "Player 4",
    "Player 3",
    "Player 2",
    "Player 1",
    "Coach 1",
    "Clear items"
  ];
  final List<String> actions = [
    "ball",
    "agility",
    "strip",
    "Low_cone",
    "cone",
    "podelprit",
    "vertical_basket",
    "basket",
    "player",
    "player",
    "player",
    "player",
    "player",
    "player",
    "coach",
    "erase"
  ];

  final List<String> objectImages = [
    'lib/assets/ball.png',
    'lib/assets/agility.png',
    'lib/assets/strip.png',
    'lib/assets/low-cone.png',
    'lib/assets/cone.png',
    'lib/assets/strip.png',
    'lib/assets/vertical-basket.png',
    'lib/assets/basket.png',
    'lib/assets/player.png',
    'lib/assets/player.png',
    'lib/assets/player.png',
    'lib/assets/player.png',
    'lib/assets/player.png',
    'lib/assets/player.png',
    'lib/assets/coach.png',
    'lib/assets/erase.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.75, // 3/4 of the screen height
      decoration: const BoxDecoration(
        color: Color(0xFF2A5D83), // Use the color from the provided image
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                title: Text(
                  objects[index],
                  style: GoogleFonts.lato(
                    color: Colors.white, // You can change this color as needed
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Image.asset(
                  objectImages[index],
                  width: 40,
                  height: 40,
                ),
                onTap: () {
                  onActionSelected(actions[index]);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Divider(
                color: Colors.white,
                thickness: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}
