import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../KMLHandle/KML.dart';
import '../providers/dataprov.dart';
import '../providers/settingsProvider.dart';
import '../utils/helper.dart';

class SSH {
  final encoder = const Utf8Encoder();
  final WidgetRef ref;

  SSH({required this.ref});

  Future<bool> connect() async {
    SSHSocket socket;
    try {
      socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
    } catch (e) {
      ref.read(isConnectedToLGProvider.notifier).state = false;
      print(e);
      return false;
    }

    ref.read(sshClient.notifier).state = SSHClient(
      socket,
      username: ref.read(usernameProvider)!,
      onPasswordRequest: () => ref.read(passwordProvider)!,
    );

    ref.read(isConnectedToLGProvider.notifier).state = true;
    return true;
  }

  disconnect() async {
    ref.read(sshClient)?.close();
    ref.read(isConnectedToLGProvider.notifier).state = false;
  }

  Future<String> renderInSlave(context, int slaveNo, String kml) async {
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
    int rigs = 3;
    rigs = ((3/2).floor() + 1);
    try {
      await ref
          .read(sshClient)
          ?.run("echo '$blank' > /var/www/html/kml/slave_$rigs.kml");
      print('abcd');
      return kml;
    } catch (error) {
      print('abc');
      return blank;
    }
  }

  cleanSlaves() async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        await ref
            .read(sshClient)
            ?.run("echo '' > /var/www/html/kml/slave_$i.kml");
      }
    } catch (e) {
      print(e);
    }
  }

  cleanKML() async {
    try {
      await stopOrbit();
      await ref.read(sshClient)!.run('echo "" > /tmp/query.txt');
      await ref.read(sshClient)!.run("echo '' > /var/www/html/kmls.txt");
    } catch (e) {
      print(e);
    }
  }

  setRefresh() async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';
        String replace =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';

        await ref.read(sshClient)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml\'');
        await ref.read(sshClient)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
      print("DONE");
    } catch (e) {
      print(e);
    }
  }

  resetRefresh() async {
    try {
      for (var i = 2; i <= ref.read(rigsProvider); i++) {
        String search =
            '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
        String replace = '<href>##LG_PHPIFACE##kml\\/slave_$i.kml<\\/href>';

        await ref.read(sshClient)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i \'echo ${ref.read(passwordProvider)} | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml\'');
      }
      print("DONE");
    } catch (e) {
      print(e);
    }
  }

  relaunchLG() async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        String cmd = """RELAUNCH_CMD="\\
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
          " && sshpass -p ${ref.read(passwordProvider)} ssh -x -t lg@lg$i "\$RELAUNCH_CMD\"""";
        await ref.read(sshClient)?.run(
            '"/home/${ref.read(usernameProvider)}/bin/lg-relaunch" > /home/${ref.read(usernameProvider)}/log.txt');
        await ref.read(sshClient)?.run(cmd);
      }
    } catch (e) {
      print(e);
    }
  }

  rebootLG() async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await ref.read(sshClient)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S reboot');
      }
    } catch (e) {
      print(e);
    }
  }

  shutdownLG() async {
    try {
      for (var i = 1; i <= ref.read(rigsProvider); i++) {
        await ref.read(sshClient)?.run(
            'sshpass -p ${ref.read(passwordProvider)} ssh -t lg$i "echo ${ref.read(passwordProvider)} | sudo -S poweroff"');
      }
    } catch (e) {
      print(e);
    }
  }

  flyTo(double latitude, double longitude, double zoom, double tilt,
      double bearing) async {
    ref.read(lastGMapPositionProvider.notifier).state = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
      tilt: tilt,
      bearing: bearing,
    );
    await ref.read(sshClient)?.run(
        'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
  }

  kmlFileUpload(File inputFile, String kmlName) async {
    bool uploading = true;
    await ref.read(sshClient)?.sftp();
    final sftp = await ref.read(sshClient)?.sftp();
    final file = await sftp?.open('/var/www/html/$kmlName.kml',
        mode: SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.write);
    var fileSize = await inputFile.length();
    file?.write(inputFile.openRead().cast(), onProgress: (progress) {
      ref.read(loadingPercentageProvider.notifier).state = progress / fileSize;
      if (fileSize == progress) {
        uploading = false;
      }
    });
    if (file == null) {
      return;
    }
    await waitWhile(() => uploading);
    ref.read(loadingPercentageProvider.notifier).state = null;
  }

  runKml(String kmlName) async {
    await ref
        .read(sshClient)
        ?.run("echo '\nhttp://lg1:81/$kmlName.kml' > /var/www/html/kmls.txt");
  }

  startOrbit() async {
    await ref.read(sshClient)?.run('echo "playtour=Orbit" > /tmp/query.txt');
  }

  stopOrbit() async {
    await ref.read(sshClient)?.run('echo "exittour=true" > /tmp/query.txt');
  }

  moveNorth(double latitude, double longitude, double zoom, double tilt,
      double bearing) async {
    ref.read(lastGMapPositionProvider.notifier).state = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: zoom,
      tilt: tilt,
      bearing: bearing,
    );
    await ref.read(sshClient)?.run(
        'echo "flytoview=${KMLMakers.lookAtLinear(latitude, longitude, zoom, tilt, bearing)}" > /tmp/query.txt');
  }

  connectionRetry(context, {int i = 0}) async {
    ref.read(sshClient)?.close();
    SSHSocket socket;
    try {
      socket = await SSHSocket.connect(
          ref.read(ipProvider), ref.read(portProvider),
          timeout: const Duration(seconds: 5));
    } catch (error) {
      ref.read(isConnectedToLGProvider.notifier).state = false;
      return false;
    }

    ref.read(sshClient.notifier).state = SSHClient(
      socket,
      username: ref.read(usernameProvider)!,
      onPasswordRequest: () => ref.read(passwordProvider)!,
    );
  }
}
