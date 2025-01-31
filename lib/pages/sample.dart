import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lgtask3/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../KMLHandle/KML.dart';
import '../connections/sshConnect.dart';
import '../constants/constants.dart';
import '../constants/images.dart';
import '../providers/settingsProvider.dart';

/// The SettingsPage() class is used to display the Menu for the LG Gesture & Voice Control app through which,
/// Users can set up the app to connect with their LG rig.

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsPage> {
  CameraPosition currentMapPosition = const CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 2,
  );

  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController rigsController = TextEditingController();
  late SharedPreferences prefs;
  late String dropdownValue;

  setSharedPrefs() async {
    await prefs.setString('ip', ipController.text);
    await prefs.setString('username', usernameController.text);
    await prefs.setString('password', passwordController.text);
    await prefs.setInt('port', int.parse(portController.text));
    await prefs.setInt('rigs', int.parse(rigsController.text));
    ref.read(ipProvider.notifier).state = ipController.text;
    ref.read(usernameProvider.notifier).state = usernameController.text;
    ref.read(passwordProvider.notifier).state = passwordController.text;
    ref.read(portProvider.notifier).state = int.parse(portController.text);
    setRigs(int.parse(rigsController.text), ref);
  }

  initTextControllers() async {
    setState(() {
      dropdownValue = ref.read(languageProvider);
      ipController.text = ref.read(ipProvider);
      usernameController.text = ref.read(usernameProvider);
      passwordController.text = ref.read(passwordProvider);
      portController.text = ref.read(portProvider).toString();
      rigsController.text = ref.read(rigsProvider).toString();
    });
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((x) async {
      ref.read(isLoadingProvider.notifier).state = false;
    });
    initTextControllers();
  }

  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(isConnectedToLGProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: ipController,
                      decoration: InputDecoration(
                        labelText: 'IP Address',
                        hintText: 'Example: 192.168.150.20',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid IP address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: portController,
                      decoration: InputDecoration(
                        labelText: 'Port Number',
                        hintText: 'Example: 22',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid port number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Enter Master ID',
                        hintText: 'Example: lg',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid Master ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Master Password',
                        hintText: 'Example: lg',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: rigsController,
                      decoration: InputDecoration(
                        labelText: 'Number of Screens',
                        hintText: 'Example: 4',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the valid number of screens';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (!isConnectedToLg) {
                          await setSharedPrefs();
                          await SSH(ref: ref).connect();
                          await SSH(ref: ref).flyTo(
                              currentMapPosition.target.latitude,
                              currentMapPosition.target.longitude,
                              currentMapPosition.zoom.zoomLG,
                              currentMapPosition.tilt,
                              currentMapPosition.bearing);
                        } else {
                          await SSH(ref: ref).disconnect();
                        }
                        ;
                      },
                      icon: Icon(
                        Icons.power,
                        size: 24.0,
                      ),
                      label: Text('Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isConnectedToLg ? Colors.green : Colors.black,
                        minimumSize: const Size(300.0, 50.0),
                      ),
                    ),
                    ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.clear_all_outlined,
                    size: 24.0,
                  ),
                  label: Text('Clean Logos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isConnectedToLg ? Colors.black : Colors.grey,
                    minimumSize: const Size(300.0, 50.0),
                  ),
                ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      // ... Button properties ...
                      label: Text('Show Logos'),
                      icon: Icon(Icons.visibility, size: 24.0),
                    ),
                  ],
                ),
                SizedBox(width: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isConnectedToLg) {
                          await SSH(ref: ref).shutdownLG();
                        }
                      },
                      icon: Icon(
                        Icons.power_off_outlined,
                        size: 24.0,
                      ),
                      label: Text('Shutdown LG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isConnectedToLg ? Colors.black : Colors.grey,
                        minimumSize: const Size(300.0, 50.0),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isConnectedToLg) {
                          await SSH(ref: ref).rebootLG();
                        }
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 24.0,
                      ),
                      label: Text('Reboot LG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isConnectedToLg ? Colors.black : Colors.grey,
                        minimumSize: const Size(300.0, 50.0),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (isConnectedToLg) {
                          await SSH(ref: ref).relaunchLG();
                        }
                      },
                      icon: Icon(
                        Icons.restart_alt_rounded,
                        size: 24.0,
                      ),
                      label: Text('Relaunch LG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isConnectedToLg ? Colors.black : Colors.grey,
                        minimumSize: const Size(300.0, 50.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
