import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerMenu extends StatelessWidget {
  final Function(String) onActionSelected;

  const DrawerMenu({Key? key, required this.onActionSelected})
      : super(key: key);

  final List<DrawerItem> items = const [
    // DrawerItem("New Project", Icons.add, "new_project"),
    DrawerItem("Player 6", "lib/assets/player-6.png", "player_6"),
    DrawerItem("Player 5", "lib/assets/player-5.png", "player_5"),
    DrawerItem("Player 4", "lib/assets/player-4.png", "player_4"),
    DrawerItem("Player 3", "lib/assets/player.png", "player"),
    DrawerItem("Player 2", "lib/assets/player.png", "player"),
    DrawerItem("Player 1", "lib/assets/player.png", "player"),
    DrawerItem("Ball", "lib/assets/ball.png", "ball"),
    DrawerItem("Agility", "lib/assets/agility.png", "agility"),
    DrawerItem("Strip", "lib/assets/strip.png", "strip"),
    DrawerItem("Low cone", "lib/assets/low-cone.png", "low_cone"),
    DrawerItem("Cone", "lib/assets/cone.png", "cone"),
    DrawerItem("Podelprit", "lib/assets/strip.png", "podelprit"),
    DrawerItem(
        "Vertical Basket", "lib/assets/vertical-basket.png", "vertical_basket"),
    DrawerItem("Basket", "lib/assets/basket.png", "basket"),
    DrawerItem("Coach 1", "lib/assets/coach.png", "coach"),
    DrawerItem("Clear items", "lib/assets/erase.png", "erase"),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return DrawerListTile(
                    item: item,
                    onTap: () {
                      try {
                        onActionSelected(item.action);
                        print(item.action);
                        // Navigator.of(context, rootNavigator: true);
                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error handling action: $e');
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A5D83),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 16),
          Text(
            'Menu',
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final DrawerItem item;
  final VoidCallback onTap;

  const DrawerListTile({Key? key, required this.item, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: item.isIcon
          ? Icon(item.icon, color: const Color(0xFF2A5D83))
          : Image.asset(item.iconPath!, width: 24, height: 24),
      title: Text(
        item.title,
        style: GoogleFonts.lato(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

class DrawerItem {
  final String title;
  final String action;
  final IconData? icon;
  final String? iconPath;

  const DrawerItem(this.title, dynamic iconOrPath, this.action)
      : icon = iconOrPath is IconData ? iconOrPath : null,
        iconPath = iconOrPath is String ? iconOrPath : null;

  bool get isIcon => icon != null;
}
