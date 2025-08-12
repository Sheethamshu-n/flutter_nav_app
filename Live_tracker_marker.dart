import 'package:flutter/material.dart';


class LiveTrackerMarker extends StatefulWidget {
  final double size;


  const LiveTrackerMarker({
    Key? key,
    required this.size,
  }) : super(key: key);


  @override
  _LiveTrackerMarkerState createState() => _LiveTrackerMarkerState();
}


class _LiveTrackerMarkerState extends State<LiveTrackerMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Controls the speed of the pulse
    );


    // Create a curved animation that goes from 0.0 to 1.0 and back
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );


    // Make the animation repeat indefinitely
    _animationController.repeat(reverse: true);
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder is an efficient way to apply an animation to a widget
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value, // The animation controls the scale
          child: Opacity(
            opacity: _animation.value, // The animation also controls the opacity
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.red, // Solid red color
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: widget.size / 2,
              spreadRadius: widget.size / 3,
            ),
          ],
        ),
      ),
    );
  }
}


