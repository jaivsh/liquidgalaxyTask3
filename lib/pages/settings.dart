import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../connections/sshConnect.dart';
import '../providers/settingsProvider.dart';
import '../utils/extensions.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController rigsController = TextEditingController();
  late SharedPreferences prefs;
  late String dropdownValue;

  CameraPosition currentMapPosition = const CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 2,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((x) async {
      ref.read(isLoadingProvider.notifier).state = false;
    });
    initTextControllers();
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

  @override
  Widget build(BuildContext context) {
    bool isConnectedToLg = ref.watch(isConnectedToLGProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF3498DB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Settings',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.help_outline, color: Colors.white),
                        onPressed: () => Navigator.pushNamed(context, '/settingshelp'),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Connection Form
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildInputField(
                                  controller: ipController,
                                  label: 'IP Address',
                                  hint: 'Example: 192.168.150.20',
                                  icon: Icons.computer,
                                ),
                                SizedBox(height: 15),
                                _buildInputField(
                                  controller: portController,
                                  label: 'Port Number',
                                  hint: 'Example: 22',
                                  icon: Icons.route,
                                ),
                                SizedBox(height: 15),
                                _buildInputField(
                                  controller: usernameController,
                                  label: 'Master ID',
                                  hint: 'Example: lg',
                                  icon: Icons.person,
                                ),
                                SizedBox(height: 15),
                                _buildInputField(
                                  controller: passwordController,
                                  label: 'Master Password',
                                  hint: 'Example: lg',
                                  icon: Icons.lock,
                                  isPassword: true,
                                ),
                                SizedBox(height: 15),
                                _buildInputField(
                                  controller: rigsController,
                                  label: 'Number of Screens',
                                  hint: 'Example: 4',
                                  icon: Icons.devices,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Connection Button
                        _buildActionButton(
                          onPressed: () async {
                            if (!isConnectedToLg) {
                              await setSharedPrefs();
                              await SSH(ref: ref).connect();
                              await SSH(ref: ref).renderInSlave(context, 3, openLogoKML);
                              await SSH(ref: ref).flyTo(
                                currentMapPosition.target.latitude,
                                currentMapPosition.target.longitude,
                                currentMapPosition.zoom.zoomLG,
                                currentMapPosition.tilt,
                                currentMapPosition.bearing,
                              );
                            } else {
                              await SSH(ref: ref).disconnect();
                            }
                          },
                          icon: Icons.power_settings_new,
                          label: isConnectedToLg ? 'Disconnect' : 'Connect',
                          color: isConnectedToLg ? Colors.green : Colors.orange.shade400,
                          isFullWidth: true,
                        ),

                        SizedBox(height: 20),

                        // Control Buttons Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 2.5,
                          children: [
                            _buildActionButton(
                              onPressed: () async {
                                if (isConnectedToLg) {
                                  await showConfirmationDialog(
                                    context,
                                    'Relaunch LG',
                                    'Are you sure you want to relaunch LG?',
                                        () async => await SSH(ref: ref).relaunchLG(),
                                  );
                                }
                              },
                              icon: Icons.restart_alt,
                              label: 'Relaunch LG',
                              isEnabled: isConnectedToLg,
                            ),
                            _buildActionButton(
                              onPressed: () async {
                                if (isConnectedToLg) {
                                  await showConfirmationDialog(
                                    context,
                                    'Shutdown LG',
                                    'Are you sure you want to shut down LG?',
                                        () async => await SSH(ref: ref).shutdownLG(),
                                  );
                                }
                              },
                              icon: Icons.power_off,
                              label: 'Shutdown LG',
                              isEnabled: isConnectedToLg,
                              color: Colors.red.shade400,
                            ),
                            _buildActionButton(
                              onPressed: () async {
                                if (isConnectedToLg) {
                                  await showConfirmationDialog(
                                    context,
                                    'Clean Logos',
                                    'Are you sure you want to clean logos?',
                                        () async {},
                                  );
                                }
                              },
                              icon: Icons.cleaning_services,
                              label: 'Clean Logos',
                              isEnabled: isConnectedToLg,
                            ),
                            _buildActionButton(
                              onPressed: () async {
                                if (isConnectedToLg) {
                                  await showConfirmationDialog(
                                    context,
                                    'Reboot LG',
                                    'Are you sure you want to reboot LG?',
                                        () async => await SSH(ref: ref).rebootLG(),
                                  );
                                }
                              },
                              icon: Icons.refresh,
                              label: 'Reboot LG',
                              isEnabled: isConnectedToLg,
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Load Logos Button
                        _buildActionButton(
                          onPressed: () async {
                            if (isConnectedToLg) {
                              await showConfirmationDialog(
                                context,
                                'Load Logos',
                                'Are you sure you want to load logos?',
                                    () async => await SSH(ref: ref).renderInSlave(context, 3, openLogoKML),
                              );
                            }
                          },
                          icon: Icons.download_done,
                          label: 'Load Logos',
                          isEnabled: isConnectedToLg,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    Color? color,
    bool isEnabled = true,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? (color ?? Colors.blue.shade400)
              : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> showConfirmationDialog(
      BuildContext context,
      String title,
      String message,
      Function confirmedAction,
      ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await confirmedAction();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final String openLogoKML = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document id ="logo">
         <name>LG Gesture And Voice</name>
             <Folder>
                  <name>LogoLGV</name>
                  <ScreenOverlay>
                      <name>LogoLGV</name>
                      <Icon><href>https://github.com/savitore/STEAM-Celestial-Satellite-tracker-in-real-time/blob/8e3d132fc18d08f0f39b624e7cdb96e00a56fc0b/assets/mainLogo.jpg?raw=true</href> </Icon>
                      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                      <screenXY x="0.025" y="0.95" xunits="fraction" yunits="fraction"/>
                      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                      <size x="500" y="500" xunits="pixels" yunits="pixels"/>
                  </ScreenOverlay>
             </Folder>
    </Document>
</kml>''';
}