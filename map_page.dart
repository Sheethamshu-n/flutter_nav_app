import 'package:flutter/material.dart';
import 'path_painter.dart';
import 'live_tracker_marker.dart'; // Ensure this file exists
import 'dart:math' as math;


class MapPage extends StatefulWidget {
  final Map<String, dynamic>? scannedMarkerData;
  final Map<String, dynamic>? destinationMarkerData;
  final List<String> path;
  final Function(String) onSearch;
  final Map<String, dynamic> allNodes;


  const MapPage({
    Key? key,
    this.scannedMarkerData,
    this.destinationMarkerData,
    required this.path,
    required this.onSearch,
    required this.allNodes,
  }) : super(key: key);


  @override
  MapPageState createState() => MapPageState();
}


// The 'TickerProviderStateMixin' is no longer needed as we've removed the animation.
class MapPageState extends State<MapPage> {
  // Configurable options
  static const double imageWidth = 736;
  static const double imageHeight = 1280;
  static const double baseMarkerSize = 24.0;


  // Controllers
  final TransformationController _transformationController = TransformationController();
  final TextEditingController _searchController = TextEditingController();


  // The AnimationController and Animation have been removed.


  @override
  void initState() {
    super.initState();
    // The listener remains to update marker sizes on manual zoom.
    _transformationController.addListener(() {
      setState(() {});
    });
  }


  // The 'didUpdateWidget' method has been removed as it was only used for auto-zoom.


  @override
  void dispose() {
    _transformationController.dispose();
    _searchController.dispose();
    // The AnimationController dispose call has been removed.
    super.dispose();
  }


  void resetMap() {
    // Reset the zoom and pan manually.
    _transformationController.value = Matrix4.identity();
    _searchController.clear();
    widget.onSearch('');
  }


  // The '_zoomToFitPath' method has been completely removed.


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double screenHeight = constraints.maxHeight;
      final double scale = screenHeight / imageHeight;
      final double scaledWidth = imageWidth * scale;


      // This logic remains to ensure markers appear the same size on manual zoom.
      final double currentZoom = _transformationController.value.getMaxScaleOnAxis();
      final double effectiveZoom = math.max(currentZoom, 1.0);
      final double dynamicMarkerSize = baseMarkerSize / effectiveZoom;


      return Scaffold(
        body: Stack(
          children: [
            ClipRect(
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: EdgeInsets.zero,
                minScale: 0.5,
                maxScale: 8.0,
                constrained: false,
                child: SizedBox(
                  width: scaledWidth,
                  height: screenHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Map Image
                      Image.asset('assets/fmap.jpg', fit: BoxFit.cover),


                      // Path Painter
                      if (widget.path.isNotEmpty)
                        CustomPaint(
                          size: Size.infinite,
                          painter: PathPainter(
                            nodes: widget.allNodes,
                            path: widget.path,
                            scale: scale,
                            imageSize: Size(scaledWidth, screenHeight),
                          ),
                        ),


                      // Live Tracker Marker
                      if (widget.scannedMarkerData != null)
                        Positioned(
                          left: (widget.scannedMarkerData!['x'] as num) * scaledWidth - (dynamicMarkerSize / 2),
                          top: (widget.scannedMarkerData!['y'] as num) * screenHeight - (dynamicMarkerSize / 2),
                          child: LiveTrackerMarker(size: dynamicMarkerSize),
                        ),


                      // Destination Marker
                      if (widget.destinationMarkerData != null)
                        Positioned(
                          left: (widget.destinationMarkerData!['x'] as num) * scaledWidth - (baseMarkerSize / effectiveZoom / 2),
                          top: (widget.destinationMarkerData!['y'] as num) * screenHeight - (baseMarkerSize / effectiveZoom / 2),
                          child: Icon(
                            Icons.location_on,
                            size: baseMarkerSize / effectiveZoom,
                            color: Colors.green,
                            shadows: [Shadow(color: Colors.black, blurRadius: 4 / effectiveZoom)],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),


            // Floating Search Bar
            Positioned(
              top: 50,
              left: 80,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: widget.onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search destination...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => widget.onSearch(_searchController.text),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
