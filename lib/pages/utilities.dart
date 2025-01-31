import 'package:flutter/material.dart';

class UtilPage extends StatefulWidget {
  const UtilPage({Key? key}) : super(key: key);

  @override
  State<UtilPage> createState() => _UtilPageState();
}

class _UtilPageState extends State<UtilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LG Quick Access'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.power_off_outlined,
                  size: 24.0,
                ),
                label: Text('ShutDown LG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(300.0, 50.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.restart_alt_rounded,
                  size: 24.0,
                ),
                label: Text('Relaunch LG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
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
                  backgroundColor: Colors.black,
                  minimumSize: const Size(300.0, 50.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 24.0,
                ),
                label: Text('Reboot LG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(300.0, 50.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
