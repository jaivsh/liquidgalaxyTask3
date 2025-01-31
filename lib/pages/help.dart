import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3E50),
      appBar: AppBar(
        title: Text(
          'Help',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: basicTiles.map(buildTile).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Image.asset(
              'assets/images/liquidgalaxy.png',
              width: 100,
              height: 100,
            ),
          )
        ],
      ),
    );
  }

  Widget buildTile(BasicTile tile) {
    if (tile.tiles.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(left: 50.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          title: Text(
            tile.title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExpansionTile(
          leading: Icon(
            Icons.add_circle_outline,
            color: Colors.white.withOpacity(0.9),
          ),
          title: Text(
            tile.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          childrenPadding: EdgeInsets.only(bottom: 16),
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          children: tile.tiles.map((tile) => buildTile(tile)).toList(),
        ),
      );
    }
  }
}

class BasicTile {
  final String title;
  final List<BasicTile> tiles;

  const BasicTile({
    required this.title,
    this.tiles = const [],
  });
}

final basicTiles = <BasicTile>[
  const BasicTile(
    title: 'Gesture Commands',
    tiles: [
      BasicTile(title: 'Right Hand Up → Move North'),
      BasicTile(title: 'Right Hand Down → Move South'),
      BasicTile(title: 'Left Hand Up → Move East'),
      BasicTile(title: 'Left Hand Down → Move West'),
      BasicTile(title: 'Both Hands Up → Zoom In'),
      BasicTile(title: 'Both Hands Down → Zoom Out'),
    ],
  ),
  const BasicTile(
    title: 'Documentation',
    tiles: [
      BasicTile(
          title: 'Visit www.liquidgalaxy.eu for official documentation')
    ],
  ),
];