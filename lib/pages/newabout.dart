import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class NewAbout extends StatefulWidget {
  const NewAbout({super.key});

  @override
  State<NewAbout> createState() => _NewAboutState();
}

class _NewAboutState extends State<NewAbout> {
  // padding constants
  final double horizontalPadding = 40;
  final double verticalPadding = 25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Row with back button and text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushNamed(context, '/HomePage');
                    },
                  ),
                  Center(
                    child: Text(
                      'ABOUT',
                      style: GoogleFonts.bebasNeue(fontSize: 50),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Adjust the width as needed for spacing
                ],
              ),
            ),
            // Other content
            const SizedBox(height: 15),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: Divider(
                thickness: 1,
                color: Color.fromARGB(255, 204, 204, 204),
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/splash.png',
                    width: double.infinity,
                    height: 500,
                  ),
                ],
              ),
            ),

            Padding(
  padding: EdgeInsets.symmetric(horizontal: 20), // Adjust the horizontal value to set margins
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.all(10),
    child: Column(
      children: [
        Text(
          'The LG Gesture and Voice Control Project aims to improve the control of the Liquid Galaxy System by providing a more comprehensive solution using voice commands, body poses, and hand gestures. The project will consist of two parts:',
          textAlign: TextAlign.justify,
          style: GoogleFonts.bebasNeue(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
          '- The LG Gesture and Voice Control App and the LG Gesture and Voice Control Library. The core technology used to make the above would be Flutter (Dart), and incorporate various APIs, especially ML Kit and Geocoding. The app will offer a more intuitive approach for users to interact with the Liquid Galaxy setup, making it simpler to explore and navigate. Users will be able to control the Liquid Galaxy without physically touching any devices, increasing the immersive experience.',
          textAlign: TextAlign.justify,
          style: GoogleFonts.bebasNeue(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Text(
           '- The LG Gesture and Voice Control Library will allow for the implementation of the apps key functionalities in other Liquid Galaxy apps and projects, providing a wider range of situations for implementation. One potential application for the library is incorporating it into the previously built Liquid Galaxy Controller to provide additional functionality for voice and gesture control, enhancing the user experience.',
          textAlign: TextAlign.justify,
          style: GoogleFonts.bebasNeue(fontSize: 18),
        ),
      ],
    ),
  ),
),

            Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credits:',
                        style: GoogleFonts.bebasNeue(fontSize: 25),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Developer: Sudhanyo Chatterjee',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                            'Mentors: Andreu Ibanez, Gabry, Merul Dhiman, Alejandro Illán Marcos',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Main Mentor: Merul Dhiman',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                            'Co-Mentors: Andreu Ibanez, Gabry, Alejandro Illán Marcos',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                            'Liquid Galaxy LAB Testers : Mohamed Zazou, Navdeep Singh, Imad Laichi',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                      ),
                    ],
                  )),
              Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reach Out:',
                        style: GoogleFonts.bebasNeue(fontSize: 25),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('Liquid Galaxy',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                        onTap: () => launchUrl(
                            Uri.parse('https://www.liquidgalaxy.eu/')),
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('LinkedIn',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                        onTap: () => launchUrl(Uri.parse(
                            'https://www.linkedin.com/in/sudhanyo-chatterjee/')),
                      ),
                      ListTile(
                        leading: Icon(Icons.link),
                        title: Text('GitHub',
                            style: GoogleFonts.bebasNeue(fontSize: 18)),
                        onTap: () => launchUrl(Uri.parse(
                            'https://github.com/Sudhanyo/LG-Gesture-And-Voice-Control')),
                      ),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}
