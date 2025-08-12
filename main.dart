


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'map_page.dart';
import 'qr_scanner_page.dart';
import 'pathfinder.dart';
import 'dart:convert';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainPage(),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);


  @override
  State<MainPage> createState() => _MainPageState();
}


class _MainPageState extends State<MainPage> {
  final GlobalKey<MapPageState> _mapPageKey = GlobalKey<MapPageState>();


  int currentPage = 0;
  String? currentScannedMarkerKey;
  Map<String, dynamic>? allMapData;
  bool isLoading = true;


  String? destinationMarkerKey;
  List<String> shortestPath = [];


  @override
  void initState() {
    super.initState();
    _loadMapData();
  }


  Future<void> _loadMapData() async {
    try {
      final String response = await rootBundle.loadString('assets/map_data.json');
      allMapData = json.decode(response);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorDialog('Error loading map data: $e');
    }
  }


  void _restartApp() {
    setState(() {
      currentScannedMarkerKey = null;
      destinationMarkerKey = null;
      shortestPath = [];
      _mapPageKey.currentState?.resetMap();
    });
    _showSuccessSnackBar('Map has been reset.');
  }


  void onQrDetected(String qrData) {
    String trimmedData = qrData.trim();
    String qrKey = trimmedData.contains('_') ? trimmedData.split('_')[0] : trimmedData;
    final nodes = allMapData?['nodes'] as Map<String, dynamic>?;


    if (nodes != null && nodes.containsKey(qrKey)) {
      setState(() {
        currentScannedMarkerKey = qrKey;
        currentPage = 0;
        if (destinationMarkerKey != null) {
          _findAndSetShortestPath(qrKey, destinationMarkerKey!);
        }
      });
      _showSuccessSnackBar('Location "$qrKey" found!');
    } else {
      _showErrorSnackBar('QR code not recognized: $qrKey');
    }
  }


  void onSearch(String query) {
    final String searchTerm = query.trim().toLowerCase();
    if (searchTerm.isEmpty) {
      setState(() {
        destinationMarkerKey = null;
        shortestPath = [];
      });
      return;
    }


    final nodes = allMapData?['nodes'] as Map<String, dynamic>?;
    if (nodes == null) return;


    String? foundKey;
    for (var key in nodes.keys) {
      if (key.toLowerCase() == searchTerm) {
        foundKey = key;
        break;
      }
    }


    if (foundKey != null) {
      setState(() {
        destinationMarkerKey = foundKey;
        if (currentScannedMarkerKey != null) {
          _findAndSetShortestPath(currentScannedMarkerKey!, foundKey!);
        }
      });
      _showSuccessSnackBar('Destination "$foundKey" found.');
    } else {
      setState(() {
        destinationMarkerKey = null;
        shortestPath = [];
      });
      _showErrorSnackBar('Destination not found.');
    }
  }


  void _findAndSetShortestPath(String start, String end) {
    final pathfinder = PathFinder(
      nodes: allMapData!['nodes'],
      edges: allMapData!['edges'],
    );
    final List<String> foundPath = pathfinder.findShortestPath(start, end);


    // --- DIAGNOSTIC PRINT 1 ---
    print('PathFinder Result from $start to $end: $foundPath');


    setState(() {
      shortestPath = foundPath;
    });
  }


  void switchToPage(int page) => setState(() => currentPage = page);


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }


  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red,
    ));
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }


    final Map<String, dynamic>? scannedNodeData = allMapData?['nodes']?[currentScannedMarkerKey];
    final Map<String, dynamic>? destinationNodeData = allMapData?['nodes']?[destinationMarkerKey];
    final Map<String, dynamic> allNodes = allMapData?['nodes'] ?? {};


    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentPage,
            children: [
              MapPage(
                key: _mapPageKey,
                scannedMarkerData: scannedNodeData,
                destinationMarkerData: destinationNodeData,
                path: shortestPath,
                onSearch: onSearch,
                allNodes: allNodes,
              ),
              ScannerPage(onQrDetected: onQrDetected),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavButton(icon: Icons.map, label: 'Map', isActive: currentPage == 0, onTap: () => switchToPage(0)),
                const SizedBox(width: 20),
                _buildNavButton(icon: Icons.qr_code_scanner, label: 'Scanner', isActive: currentPage == 1, onTap: () => switchToPage(1)),
              ],
            ),
          ),
          if (currentPage == 0)
            Positioned(
              top: 50,
              left: 20,
              child: FloatingActionButton(
                mini: true,
                onPressed: _restartApp,
                backgroundColor: Colors.white.withOpacity(0.85),
                foregroundColor: Colors.black87,
                tooltip: 'Reset Map',
                child: const Icon(Icons.refresh),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildNavButton({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 70 : 60,
            height: isActive ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.blueAccent : Colors.grey[300],
              boxShadow: [BoxShadow(color: isActive ? Colors.blueAccent.withOpacity(0.3) : Colors.black26, blurRadius: isActive ? 15 : 8, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.grey[600], size: isActive ? 32 : 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isActive ? Colors.blueAccent : Colors.grey[600], fontWeight: isActive ? FontWeight.w600 : FontWeight.w500)),
        ],
      ),
    );
  }
}


