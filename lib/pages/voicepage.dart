import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:lgtask3/utils/extensions.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../KMLHandle/KML.dart';
import '../connections/sshConnect.dart';
import '../providers/settingsProvider.dart';

class SpeechScreen extends ConsumerStatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);
  @override
  ConsumerState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends ConsumerState<SpeechScreen> {
  final Map<String, HighlightedWord> highlights = {
    'Move': HighlightedWord(
        onTap: () => print('Move'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.green, fontWeight: FontWeight.w600)),
    'Zoom': HighlightedWord(
        onTap: () => print('Zoom'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.blue, fontWeight: FontWeight.w600)),
    'Fly': HighlightedWord(
        onTap: () => print('Fly'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.yellow, fontWeight: FontWeight.w600)),
    'Orbit': HighlightedWord(
        onTap: () => print('Orbit'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.red, fontWeight: FontWeight.w600)),
    'North': HighlightedWord(
        onTap: () => print('North'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.green, fontWeight: FontWeight.w600)),
    'South': HighlightedWord(
        onTap: () => print('South'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.green, fontWeight: FontWeight.w600)),
    'East': HighlightedWord(
        onTap: () => print('East'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.green, fontWeight: FontWeight.w600)),
    'West': HighlightedWord(
        onTap: () => print('West'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.green, fontWeight: FontWeight.w600)),
    'Out': HighlightedWord(
        onTap: () => print('Out'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.blue, fontWeight: FontWeight.w600)),
    'Earth': HighlightedWord(
        onTap: () => print('Earth'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.orange, fontWeight: FontWeight.w600)),
    'Moon': HighlightedWord(
        onTap: () => print('Moon'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.orange, fontWeight: FontWeight.w600)),
    'Planet': HighlightedWord(
        onTap: () => print('Planet'),
        textStyle: const TextStyle(
            fontSize: 50, color: Colors.orange, fontWeight: FontWeight.w600)),
  };

  final SpeechToText speechToText = SpeechToText();

  var text = "Hold The Button And Start Speaking";
  var isListening = false;

  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(isConnectedToLGProvider);
    CameraPosition currentMapPosition = ref.watch(currentMapPositionProvider);
    int rev = 0;

    void moveNorth() async {
      if (isConnectedToLg) {
        double newLatitude = currentMapPosition.target.latitude;
        double newLongitude = currentMapPosition.target.longitude;
        if (rev == 1) {
          newLatitude = currentMapPosition.target.latitude - 10;
          newLongitude = currentMapPosition.target.longitude;
        } else {
          newLatitude = currentMapPosition.target.latitude + 10;
          newLongitude = currentMapPosition.target.longitude;
        }

        // Check if the new latitude exceeds the maximum or minimum value
        if (newLatitude > 90) {
          newLatitude = 90 - (newLatitude - 90);
          newLongitude = -newLongitude;
          rev = 1;
        } else if (newLatitude < -90) {
          newLatitude = -90 + (newLatitude + 90);
          newLongitude = -newLongitude;
          rev = 0;
        }

        currentMapPosition = CameraPosition(
          target: LatLng(
            newLatitude,
            newLongitude,
          ),
          zoom: currentMapPosition.zoom,
          tilt: currentMapPosition.tilt,
          bearing: currentMapPosition.bearing,
        );
        ref.read(currentMapPositionProvider.notifier).state =
            currentMapPosition;

        await SSH(ref: ref).flyTo(
          currentMapPosition.target.latitude,
          currentMapPosition.target.longitude,
          currentMapPosition.zoom.zoomLG,
          currentMapPosition.tilt,
          currentMapPosition.bearing,
        );
      }
    }

    void moveSouth() async {
      if (isConnectedToLg) {
        double newLatitude = currentMapPosition.target.latitude - 10;

        // Check if the new latitude exceeds the maximum or minimum value
        if (newLatitude > 90) {
          newLatitude = -90 + (newLatitude - 90);
        } else if (newLatitude < -90) {
          newLatitude = 90 - (newLatitude + 90);
        }

        currentMapPosition = CameraPosition(
          target: LatLng(
            newLatitude,
            currentMapPosition.target.longitude,
          ),
          zoom: currentMapPosition.zoom,
          tilt: currentMapPosition.tilt,
          bearing: currentMapPosition.bearing,
        );
        ref.read(currentMapPositionProvider.notifier).state =
            currentMapPosition;

        await SSH(ref: ref).flyTo(
          currentMapPosition.target.latitude,
          currentMapPosition.target.longitude,
          currentMapPosition.zoom.zoomLG,
          currentMapPosition.tilt,
          currentMapPosition.bearing,
        );
      }
    }

    void moveEast() async {
      if (isConnectedToLg) {
        double newLongitude = currentMapPosition.target.longitude + 10;

        // Wrap the longitude within the valid range (-180 to 180 degrees)
        if (newLongitude > 180) {
          newLongitude = -180 + (newLongitude - 180);
        } else if (newLongitude < -180) {
          newLongitude = 180 - (newLongitude + 180);
        }

        currentMapPosition = CameraPosition(
          target: LatLng(
            currentMapPosition.target.latitude,
            newLongitude,
          ),
          zoom: currentMapPosition.zoom,
          tilt: currentMapPosition.tilt,
          bearing: currentMapPosition.bearing,
        );
        ref.read(currentMapPositionProvider.notifier).state =
            currentMapPosition;

        await SSH(ref: ref).flyTo(
          currentMapPosition.target.latitude,
          currentMapPosition.target.longitude,
          currentMapPosition.zoom.zoomLG,
          currentMapPosition.tilt,
          currentMapPosition.bearing,
        );
      }
    }

    void moveWest() async {
      if (isConnectedToLg) {
        double newLongitude = currentMapPosition.target.longitude - 10;

        // Wrap the longitude within the valid range (-180 to 180 degrees)
        if (newLongitude > 180) {
          newLongitude = 180 - (newLongitude - 180);
        } else if (newLongitude < -180) {
          newLongitude = -180 + (newLongitude + 180);
        }

        currentMapPosition = CameraPosition(
          target: LatLng(
            currentMapPosition.target.latitude,
            newLongitude,
          ),
          zoom: currentMapPosition.zoom,
          tilt: currentMapPosition.tilt,
          bearing: currentMapPosition.bearing,
        );
        ref.read(currentMapPositionProvider.notifier).state =
            currentMapPosition;

        await SSH(ref: ref).flyTo(
          currentMapPosition.target.latitude,
          currentMapPosition.target.longitude,
          currentMapPosition.zoom.zoomLG,
          currentMapPosition.tilt,
          currentMapPosition.bearing,
        );
      }
    }

    void zoomIn() async {
      if (isConnectedToLg) {
        double newZoom =
            currentMapPosition.zoom + 1.0; // Increase zoom level by 1

        // Limit the zoom level within a reasonable range
        if (newZoom > 10) {
          newZoom = 10;
        }

        currentMapPosition = CameraPosition(
          target: currentMapPosition.target,
          zoom: newZoom,
          tilt: currentMapPosition.tilt,
          bearing: currentMapPosition.bearing,
        );
        ref.read(currentMapPositionProvider.notifier).state =
            currentMapPosition;

        await SSH(ref: ref).flyTo(
          currentMapPosition.target.latitude,
          currentMapPosition.target.longitude,
          newZoom.zoomLG,
          currentMapPosition.tilt,
          currentMapPosition.bearing,
        );
      }
    }

    void zoomOut() async {
      if (isConnectedToLg) {
        double newZoom =
            currentMapPosition.zoom - 1.0; // Decrease zoom level by 1

        // Limit the zoom level within a reasonable range
        if (newZoom < 1) {
          newZoom = 1;
        }

        currentMapPosition = CameraPosition(
          target: currentMapPosition.target,
          zoom: newZoom,
          tilt: currentMapPosition.tilt,
          bearing: currentMapPosition.bearing,
        );
        ref.read(currentMapPositionProvider.notifier).state =
            currentMapPosition;

        await SSH(ref: ref).flyTo(
          currentMapPosition.target.latitude,
          currentMapPosition.target.longitude,
          newZoom.zoomLG,
          currentMapPosition.tilt,
          currentMapPosition.bearing,
        );
      }
    }

    startOrbit(context) async {
      try {
        await ref
            .read(sshClient)
            ?.run('echo "playtour=Orbit" > /tmp/query.txt');
      } catch (error) {
        await SSH(ref: ref).connectionRetry(context);
        await startOrbit(context);
      }
    }

    stopOrbit(context) async {
      await ref.read(sshClient)?.run('echo "exittour=true" > /tmp/query.txt');
    }

    void flyTo(double latitude, double longitude, double zoom, double tilt,
        double bearing) async {
      ref.read(currentMapPositionProvider.notifier).state = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: currentMapPosition.zoom,
        tilt: currentMapPosition.tilt,
        bearing: currentMapPosition.bearing,
      );
      await ref.read(sshClient)?.run(
          'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        //endRadius: 75.0,
        animate: isListening,
        duration: Duration(milliseconds: 2000),
        glowColor: Colors.black,
        repeat: true,
        //repeatPauseDuration: Duration(microseconds: 100),
        //showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) async {
            if (!isListening) {
              var available = await speechToText.initialize();
              if (available) {
                setState(() {
                  isListening = true;
                  speechToText.listen(onResult: (result) async {
                    setState(() {
                      text = result.recognizedWords;
                    });
                    if (result.recognizedWords
                        .toLowerCase()
                        .contains('north')) {
                      moveNorth();
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('south')) {
                      moveSouth();
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('east')) {
                      moveEast();
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('west')) {
                      moveWest();
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('in')) {
                      zoomIn();
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('out')) {
                      zoomOut();
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('orbit')) {
                      await startOrbit(context);
                    } else if (result.recognizedWords
                        .toLowerCase()
                        .contains('stop')) {
                      await stopOrbit(context);
                    }
                    String recognizedCity =
                        getRecognizedCity(result.recognizedWords.toLowerCase());

                    if (recognizedCity != '') {
                      LatLng? cityCoordinates =
                          cityCoordinatesMap[recognizedCity];
                      if (cityCoordinates != null) {
                        flyTo(
                          cityCoordinates.latitude,
                          cityCoordinates.longitude,
                          3, // Replace with your default zoom value
                          currentMapPosition.tilt,
                          currentMapPosition
                              .bearing, // Replace with your default bearing value
                        );
                      }
                    }
                    ;
                  });
                });
              }
            }
          },
          onTapUp: (details) {
            setState(() {
              isListening = false;
            });
            speechToText.stop();
          },
          child: CircleAvatar(
            backgroundColor: Colors.black,
            radius: 35,
            child: Icon(isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Voice Recognition Mode",
          style: GoogleFonts.bebasNeue(fontSize: 50, color: Colors.black),textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help, color: Colors.black,),
            tooltip: 'Help Section',
            onPressed: () {
              Navigator.pushNamed(context, '/voicehelp');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          margin: const EdgeInsets.only(bottom: 15),
          child: TextHighlight(
            text: text,
            words: highlights,
            textStyle: TextStyle(
                fontSize: 50, color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

Map<String, LatLng> cityCoordinatesMap = {
  'new york': LatLng(40.7128, -74.0060),
  'los angeles': LatLng(34.0522, -118.2437),
  'london': LatLng(51.5074, -0.1278),
  'paris': LatLng(48.8566, 2.3522),
  'tokyo': LatLng(35.6895, 139.6917),
  'sydney': LatLng(-33.8688, 151.2093),
  'rio de janeiro': LatLng(-22.9068, -43.1729),
  'beijing': LatLng(39.9042, 116.4074),
  'rome': LatLng(41.9028, 12.4964),
  'cairo': LatLng(30.0444, 31.2357),
  // ... Add more city coordinates as needed
  'mumbai': LatLng(19.0760, 72.8777),
  'cape town': LatLng(-33.9249, 18.4241),
  'toronto': LatLng(43.6532, -79.3832),
  'moscow': LatLng(55.7558, 37.6173),
  'hong kong': LatLng(22.3193, 114.1694),
  'singapore': LatLng(1.3521, 103.8198),
  'istanbul': LatLng(41.0082, 28.9784),
  'seoul': LatLng(37.5665, 126.9780),
  'sao paulo': LatLng(-23.5505, -46.6333),
  'chicago': LatLng(41.8781, -87.6298),
  'jakarta': LatLng(-6.2088, 106.8456),
  'mexico city': LatLng(19.4326, -99.1332),
  'amsterdam': LatLng(52.3676, 4.9041),
  'madrid': LatLng(40.4168, -3.7038),
  'bangkok': LatLng(13.7563, 100.5018),
  'budapest': LatLng(47.4979, 19.0402),
  'dubai': LatLng(25.276987, 55.296249),
  'athens': LatLng(37.9838, 23.7275),
  'vienna': LatLng(48.2082, 16.3738),
  'buenos aires': LatLng(-34.6037, -58.3816),
  'dallas': LatLng(32.7767, -96.7970),
  'vancouver': LatLng(49.2827, -123.1207),
  'helsinki': LatLng(60.1695, 24.9354),
  'lisbon': LatLng(38.7223, -9.1393),
  'kuala lumpur': LatLng(3.1390, 101.6869),
  'santiago': LatLng(-33.4489, -70.6693),
  'oslo': LatLng(59.9139, 10.7522),
  'nairobi': LatLng(-1.2921, 36.8219),
  'washington': LatLng(38.9072, -77.0379),
  'san francisco': LatLng(37.7749, -122.4194),
  'barcelona': LatLng(41.3851, 2.1734),
  'valencia': LatLng(39.4699, -0.3763),
  'seville': LatLng(37.3886, -5.9823),
  'zaragoza': LatLng(41.6488, -0.8891),
  'malaga': LatLng(36.7213, -4.4214),
  'murcia': LatLng(37.9838, -1.1280),
  'palma de mallorca': LatLng(39.5696, 2.6502),
  'las palmas de gran canaria': LatLng(28.1248, -15.4300),
  'bilbao': LatLng(43.2630, -2.9340),
  'alicante': LatLng(38.3452, -0.4810),
  'cordoba': LatLng(37.8882, -4.7794),
  'valladolid': LatLng(41.6520, -4.7284),
  'vigo': LatLng(42.2406, -8.7207),
  'gijon': LatLng(43.5321, -5.6611),
  'a coruna': LatLng(43.3619, -8.4187),
  'vitoria-gasteiz': LatLng(42.8467, -2.6726),
  'granada': LatLng(37.1773, -3.5986),
  'elche': LatLng(38.2699, -0.7126),
  'tarragona': LatLng(41.1189, 1.2445),
  'oviedo': LatLng(43.3619, -5.8494),
  'badalona': LatLng(41.4505, 2.2474),
  'cartagena': LatLng(37.6257, -0.9966),
  'terrassa': LatLng(41.5662, 2.0088),
  'jerez de la frontera': LatLng(36.6850, -6.1269),
  'sabadell': LatLng(41.5483, 2.1079),
  'santa cruz de tenerife': LatLng(28.4636, -16.2518),
  'pamplona': LatLng(42.8125, -1.6458),
  'almeria': LatLng(36.8381, -2.4597),
  'fuenlabrada': LatLng(40.2842, -3.7949),
  'leganes': LatLng(40.3280, -3.7635),
  'san sebastian': LatLng(43.3183, -1.9812),
  'getafe': LatLng(40.3081, -3.7345),
  'burgos': LatLng(42.3439, -3.6969),
  'alcala de henares': LatLng(40.4819, -3.3648),
  'salamanca': LatLng(40.9701, -5.6635),
  'albacete': LatLng(38.9944, -1.8584),
  'castellon de la plana': LatLng(39.9864, -0.0513),
  'logrono': LatLng(42.4664, -2.4498),
  'badajoz': LatLng(38.8794, -6.9707),
  'huelva': LatLng(37.2614, -6.9447),
  'lleida': LatLng(41.6176, 0.6200),
  'marbella': LatLng(36.5105, -4.8820),
  'tarrasa': LatLng(41.5662, 2.0088),
  'jaen': LatLng(37.7796, -3.7902),
  'algeciras': LatLng(36.1408, -5.4562),
  'ourense': LatLng(42.3364, -7.8645),
  'reus': LatLng(41.1579, 1.1065),
  'ciudad real': LatLng(38.9860, -3.9271),
  'girona': LatLng(41.9793, 2.8195),
  'lugo': LatLng(43.0125, -7.5558),
  'leon': LatLng(42.5987, -5.5671),
  'palencia': LatLng(42.0096, -4.5280),
  'caceres': LatLng(39.4753, -6.3723),
  'segovia': LatLng(40.9429, -4.1089),
  'toledo': LatLng(39.8628, -4.0273),
  'zamora': LatLng(41.5035, -5.7464),
};

String getRecognizedCity(String recognizedText) {
  for (String city in cityCoordinatesMap.keys) {
    if (recognizedText.contains(city)) {
      return city;
    }
  }
  return ''; // No recognized city found
}
