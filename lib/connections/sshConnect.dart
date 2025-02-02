import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../KMLHandle/KML.dart';
import '../providers/dataprov.dart';
import '../providers/settingsProvider.dart';
import '../utils/helper.dart';

class SSH {
  final encoder = const Utf8Encoder();
  final WidgetRef ref;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration connectionTimeout = Duration(seconds: 5);

  SSH({required this.ref});

  Future<bool> connect() async {
    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final socket = await SSHSocket.connect(
          ref.read(ipProvider),
          ref.read(portProvider),
          timeout: connectionTimeout,
        ).timeout(connectionTimeout);

        ref.read(sshClient.notifier).state = SSHClient(
          socket,
          username: ref.read(usernameProvider)!,
          onPasswordRequest: () => ref.read(passwordProvider)!,
        );

        ref.read(isConnectedToLGProvider.notifier).state = true;
        return true;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          ref.read(isConnectedToLGProvider.notifier).state = false;
          ref.read(errorMessageProvider.notifier).state =
          'Failed to connect after $maxRetries attempts: $e';
          return false;
        }
        await Future.delayed(retryDelay);
      }
    }
    return false;
  }

  Future<void> disconnect() async {
    try {
      final client = ref.read(sshClient);
      if (client != null) {
        client.close();  // Since close() returns void, we don't await it
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error during disconnect: $e';
    } finally {
      ref.read(isConnectedToLGProvider.notifier).state = false;
      ref.read(sshClient.notifier).state = null;
    }
  }

  Future<String> renderInSlave(BuildContext context, int slaveNo, String kml) async {
    String blank = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
    <Document id ="logo">
         <name>Liquid Galaxy Gesture & Voice Control</name>
             <Folder>
                  <name>Splash Screen</name>
                  <ScreenOverlay>
                      <name>Logo</name>
                      <Icon><href>https://raw.githubusercontent.com/Sudhanyo/LG-Gesture-And-Voice-Control/4542b294f9186692dfa649bb9d6c8f0028749b14/assets/images/splash.png</href> </Icon>
                      <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                      <screenXY x="0.02" y="0.95" xunits="fraction" yunits="fraction"/>
                      <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                      <size x="400" y="400" xunits="pixels" yunits="pixels"/>
                  </ScreenOverlay>
             </Folder>
    </Document>
</kml>''';

    int rigs = ((ref.read(rigsProvider) / 2).floor() + 1);
    try {
      await _executeCommand('echo \'$blank\' > /var/www/html/kml/slave_$rigs.kml');
      return kml;
    } catch (error) {
      await connectionRetry(context);
      return blank;
    }
  }

  Future<void> cleanSlaves() async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        await _executeCommand('echo \'\' > /var/www/html/kml/slave_$i.kml');
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error cleaning slaves: $e';
    }
  }

  Future<void> cleanKML() async {
    try {
      await stopOrbit();
      await _executeCommand('echo "" > /tmp/query.txt');
      await _executeCommand("echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error cleaning KML: $e';
    }
  }

  Future<void> setRefresh() async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        final searchPattern = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        final replacePattern =
            '$searchPattern<refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await _executeCommand('''
          sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i '
            echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$replacePattern/$searchPattern/" ~/earth/kml/slave/myplaces.kml
            echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$searchPattern/$replacePattern/" ~/earth/kml/slave/myplaces.kml'
        ''');
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error setting refresh: $e';
    }
  }

  Future<void> resetRefresh() async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        final searchPattern =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
        final replacePattern = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';

        await _executeCommand('''
          sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i '
            echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$searchPattern/$replacePattern/" ~/earth/kml/slave/myplaces.kml'
        ''');
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error resetting refresh: $e';
    }
  }

  Future<void> relaunchLG() async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        final cmd = '''
          RELAUNCH_CMD="\\
            if [ -f /etc/init/lxdm.conf ]; then
              export SERVICE=lxdm
            elif [ -f /etc/init/lightdm.conf ]; then
              export SERVICE=lightdm
            else
              exit 1
            fi
            if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
              echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} start
            else
              echo ${ref.read(passwordProvider)} | sudo -S service \\\${SERVICE} restart
            fi
            " && sshpass -p ${ref.read(passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD"
        ''';

        await _executeCommand(cmd);
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error relaunching LG: $e';
    }
  }

  Future<void> rebootLG() async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await _executeCommand(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S reboot"'
        );
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error rebooting LG: $e';
    }
  }

  Future<void> shutdownLG() async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await _executeCommand(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S poweroff"'
        );
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error shutting down LG: $e';
    }
  }

  Future<void> flyTo(double latitude, double longitude, double zoom, double tilt,
      double bearing) async {
    try {
      // Update last position
      ref.read(lastGMapPositionProvider.notifier).state = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: zoom,
        tilt: tilt,
        bearing: bearing,
      );

      // Execute fly command
      await _executeCommand(
          'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt'
      );
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error during flyTo: $e';
      throw e;  // Re-throw to handle in the calling function
    }
  }

  Future<void> kmlFileUpload(File inputFile, String kmlName) async {
    bool uploading = true;
    try {
      final sftp = await ref.read(sshClient)?.sftp();
      if (sftp == null) throw Exception('Failed to initialize SFTP');

      final file = await sftp.open(
          '/var/www/html/$kmlName.kml',
          mode: SftpFileOpenMode.create |
          SftpFileOpenMode.truncate |
          SftpFileOpenMode.write
      );

      if (file == null) throw Exception('Failed to create remote file');

      var fileSize = await inputFile.length();
      await file.write(
          inputFile.openRead().cast(),
          onProgress: (progress) {
            ref.read(loadingPercentageProvider.notifier).state = progress / fileSize;
            if (fileSize == progress) {
              uploading = false;
            }
          }
      );

      await waitWhile(() => uploading);
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error uploading KML: $e';
      throw e;
    } finally {
      ref.read(loadingPercentageProvider.notifier).state = null;
    }
  }

  Future<void> runKml(String kmlName) async {
    try {
      await _executeCommand(
          "echo '\nhttp://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt"
      );
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error running KML: $e';
    }
  }

  Future<void> startOrbit() async {
    try {
      await _executeCommand('echo "playtour=Orbit" > /tmp/query.txt');
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error starting orbit: $e';
    }
  }

  Future<void> stopOrbit() async {
    try {
      await _executeCommand('echo "exittour=true" > /tmp/query.txt');
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'Error stopping orbit: $e';
    }
  }

  Future<bool> connectionRetry(BuildContext context) async {
    ref.read(sshClient)?.close();
    return await connect();
  }

  Future<void> _executeCommand(String command) async {
    final client = ref.read(sshClient);
    if (client == null) {
      throw Exception('SSH client not initialized');
    }

    try {
      await client.run(command);
    } catch (e) {
      throw Exception('Command execution failed: $e');
    }
  }
}