import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settingsProvider.dart';


class MainPage extends ConsumerStatefulWidget {
  const MainPage({Key? key}) : super(key: key);

@override
  ConsumerState createState() => _MainState();
}

class _MainState extends ConsumerState<MainPage> {


  @override
  Widget build(BuildContext context) {
  bool isConnectedToLg = ref.watch(isConnectedToLGProvider);
  return Scaffold(
    appBar: AppBar(
      title: const Text('LG Gesture & Voice Control'),
      backgroundColor: Colors.black,
      centerTitle: true,
    ),
    body: Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                icon: Icon(
                  Icons.camera_alt_rounded,
                  size: 24.0,
                ),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(20.0),
                  minimumSize: const Size(350.0, 150.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/voice');
                },
                icon: Icon(
                  Icons.mic_none_outlined,
                  size: 24.0,
                ),
                label: Text('Voice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(20.0),
                  minimumSize: const Size(350.0, 150.0),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16.0,
          right: 16.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isConnectedToLg ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              isConnectedToLg ? 'Connected' : 'Disconnected',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: ExpandableFloatingActionButton(),
  );
}
}

class ExpandableFloatingActionButton extends StatefulWidget {
  @override
  _ExpandableFloatingActionButtonState createState() =>
      _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState
    extends State<ExpandableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  List<String> fabLabels = [
    'Settings',
    'About',
    'Utilities',
    'Help',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          const SizedBox(height: 9),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            
            backgroundColor: Colors.black,
            heroTag: 'settings',
            child: const Icon(Icons.settings),
            elevation: 6, // Remove elevation for expanding buttons
            tooltip: fabLabels[0], // Add tooltip/label
          ),
          const SizedBox(height: 9),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/about');
            },
            backgroundColor: Colors.black,
            heroTag: 'about',
            child: const Icon(Icons.info),
            elevation: 6, // Remove elevation for expanding buttons
            tooltip: fabLabels[1], // Add tooltip/label
          ),
          const SizedBox(height: 9),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/help');
            },
            backgroundColor: Colors.black,
            heroTag: 'help',
            child: const Icon(Icons.help),
            elevation: 6, // Remove elevation for expanding buttons
            tooltip: fabLabels[3], // Add tooltip/label
          ),
        ],
        const SizedBox(height: 9),
        FloatingActionButton(
          onPressed: _toggleExpanded,
          backgroundColor: Colors.black,
          heroTag: 'expand',
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _expandAnimation,
          ),
          tooltip: _isOpen ? 'Close' : 'Expand', // Add tooltip/label
        ),
      ],
    );
  }
}
