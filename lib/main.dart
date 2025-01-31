import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lgtask3/pages/newabout.dart';
import 'package:lgtask3/pages/newgesturehelp.dart';
import 'package:lgtask3/pages/newhelp.dart';
import 'package:lgtask3/pages/newhome.dart';
import 'package:lgtask3/pages/newsettingshelp.dart';
import 'package:lgtask3/pages/settings.dart';
import 'package:lgtask3/pages/utilities.dart';
import 'package:lgtask3/pages/voicepage.dart';

import 'camera/pose_view.dart';
import 'pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var delegate = await LocalizationDelegate.create(
      basePath: 'assets/i18n/',
      fallbackLocale: 'en_US',
      supportedLocales: ['en_US']);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(ProviderScope(child: LocalizedApp(delegate, const Routes())));
  });
}

class Routes extends StatefulWidget {
  const Routes({Key? key}) : super(key: key);

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Liquid Galaxy Gesture & Voice Control',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashPage(),
          '/HomePage': (context) => const HomePage(),
          '/settings': (context) => const SettingsPage(),
          '/help' :(context) => const NewHelpPage(),
          '/voice' : (context) => const SpeechScreen(),
          '/about' : (context) => const NewAbout(),
          '/utilities' : (context) => const UtilPage(),
          '/camera' : (context) => PoseDetectorView(),
          '/gesturehelp' : (context) => const GestureHelp(),
          '/settingshelp' : (context) => const SettingsHelp(),
        },
      ),
    );
  }
}