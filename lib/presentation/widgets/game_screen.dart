import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // List to store stars
  final List<Star> stars = [];

  // List to store connections between stars
  final List<Connection> connections = [];

  // Currently selected star
  Star? selectedStar;

  // Animation controller for twinkling effect
  late AnimationController _twinkleController;

  // Background gradient colors
  final List<Color> _bgColors = [
    const Color(0xFF111936),
    const Color(0xFF1E2859),
  ];

  // Saved constellations
  final List<List<Connection>> savedConstellations = [];

  @override
  void initState() {
    super.initState();

    // Set up twinkling animation
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Add some initial stars
    _addRandomStars(15);
  }

  void _addRandomStars(int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      stars.add(
        Star(
          id: i,
          position: Offset(
            random.nextDouble() * 300 + 50,
            random.nextDouble() * 500 + 50,
          ),
          size: random.nextDouble() * 3 + 2,
          color: HSLColor.fromAHSL(
            1.0,
            random.nextDouble() * 60 + 180, // blue to purple hues
            random.nextDouble() * 0.3 + 0.7, // high saturation
            random.nextDouble() * 0.3 + 0.7, // bright
          ).toColor(),
        ),
      );
    }
  }

  void _addStar(Offset position) {
    setState(() {
      stars.add(
        Star(
          id: stars.length,
          position: position,
          size: Random().nextDouble() * 3 + 2,
          color: HSLColor.fromAHSL(
            1.0,
            Random().nextDouble() * 60 + 180,
            Random().nextDouble() * 0.3 + 0.7,
            Random().nextDouble() * 0.3 + 0.7,
          ).toColor(),
        ),
      );
    });
  }

  void _selectStar(Star star) {
    setState(() {
      if (selectedStar == null) {
        selectedStar = star;
      } else if (selectedStar != star) {
        // Create a connection between the selected star and the tapped star
        connections.add(Connection(
          star1: selectedStar!,
          star2: star,
          color: Color.lerp(selectedStar!.color, star.color, 0.5)!,
        ));
        selectedStar = null;
      } else {
        selectedStar = null;
      }
    });
  }

  void _saveConstellation() {
    if (connections.isNotEmpty) {
      setState(() {
        savedConstellations.add(List.from(connections));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Constellation saved!'))
        );
      });
    }
  }

  void _clearCanvas() {
    setState(() {
      connections.clear();
      selectedStar = null;
    });
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _bgColors,
          ),
        ),
        child: Stack(
          children: [
            // Stars and connections canvas
            GestureDetector(
              onTapDown: (details) {
                // Check if a star was tapped
                for (final star in stars) {
                  final distance = (star.position - details.localPosition).distance;
                  if (distance < max(star.size * 3, 20)) {
                    _selectStar(star);
                    return;
                  }
                }

                // If no star was tapped, add a new one
                _addStar(details.localPosition);
              },
              child: CustomPaint(
                painter: StarsPainter(
                  stars: stars,
                  connections: connections,
                  selectedStar: selectedStar,
                  twinkleAnimation: _twinkleController,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // UI controls
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: "save",
                    backgroundColor: Colors.indigo[300],
                    onPressed: _saveConstellation,
                    child: const Icon(Icons.save_outlined),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: "clear",
                    backgroundColor: Colors.indigo[300],
                    onPressed: _clearCanvas,
                    child: const Icon(Icons.clear),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    heroTag: "gallery",
                    backgroundColor: Colors.indigo[300],
                    onPressed: () {
                      _showConstellationGallery(context);
                    },
                    child: const Icon(Icons.collections),
                  ),
                ],
              ),
            ),

            // Help text
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Tap to place stars, connect stars to form constellations",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConstellationGallery(BuildContext context) {
    if (savedConstellations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No constellations saved yet'))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          decoration: BoxDecoration(
            color: Colors.indigo[900]!.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Constellations",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: savedConstellations.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          connections.clear();
                          connections.addAll(savedConstellations[index]);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomPaint(
                          painter: ConstellationThumbnailPainter(
                            connections: savedConstellations[index],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Star {
  final int id;
  final Offset position;
  final double size;
  final Color color;

  Star({
    required this.id,
    required this.position,
    required this.size,
    required this.color,
  });
}

class Connection {
  final Star star1;
  final Star star2;
  final Color color;

  Connection({
    required this.star1,
    required this.star2,
    required this.color,
  });
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final List<Connection> connections;
  final Star? selectedStar;
  final Animation<double> twinkleAnimation;

  StarsPainter({
    required this.stars,
    required this.connections,
    this.selectedStar,
    required this.twinkleAnimation,
  }) : super(repaint: twinkleAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint background stars (small dots)
    final smallStarPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent star pattern
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;

      canvas.drawCircle(Offset(x, y), radius, smallStarPaint);
    }

    // Draw connections
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      linePaint.color = connection.color.withOpacity(0.7);
      canvas.drawLine(
        connection.star1.position,
        connection.star2.position,
        linePaint,
      );
    }

    // Draw stars
    for (final star in stars) {
      final isSelected = selectedStar == star;

      // Twinkle effect
      final twinkleFactor = isSelected
          ? 1.0
          : 0.8 + 0.2 * twinkleAnimation.value;

      // Glow effect
      final glowPaint = Paint()
        ..color = star.color.withOpacity(0.3 * twinkleFactor)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      // Main star
      final starPaint = Paint()
        ..color = star.color.withOpacity(twinkleFactor)
        ..style = PaintingStyle.fill;

      // Selection indicator
      final selectionPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      // Draw glow
      canvas.drawCircle(
        star.position,
        star.size * 2.5,
        glowPaint,
      );

      // Draw star
      canvas.drawCircle(
        star.position,
        star.size * twinkleFactor,
        starPaint,
      );

      // Draw selection indicator if selected
      if (isSelected) {
        canvas.drawCircle(
          star.position,
          star.size * 3.5,
          selectionPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) {
    return stars != oldDelegate.stars ||
        connections != oldDelegate.connections ||
        selectedStar != oldDelegate.selectedStar;
  }
}

class ConstellationThumbnailPainter extends CustomPainter {
  final List<Connection> connections;

  ConstellationThumbnailPainter({required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    if (connections.isEmpty) return;

    // Find the bounds of the constellation
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = 0;
    double maxY = 0;

    final Set<Star> constellationStars = {};

    for (final connection in connections) {
      constellationStars.add(connection.star1);
      constellationStars.add(connection.star2);

      minX = min(minX, min(connection.star1.position.dx, connection.star2.position.dx));
      minY = min(minY, min(connection.star1.position.dy, connection.star2.position.dy));
      maxX = max(maxX, max(connection.star1.position.dx, connection.star2.position.dx));
      maxY = max(maxY, max(connection.star1.position.dy, connection.star2.position.dy));
    }

    // Calculate scaling factor to fit the constellation in the thumbnail
    final width = maxX - minX;
    final height = maxY - minY;
    final scaleX = (size.width - 20) / width;
    final scaleY = (size.height - 20) / height;
    final scale = min(scaleX, scaleY);

    final translateX = (size.width - width * scale) / 2 - minX * scale;
    final translateY = (size.height - height * scale) / 2 - minY * scale;

    // Draw connections
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      linePaint.color = connection.color.withOpacity(0.7);

      final p1 = Offset(
        connection.star1.position.dx * scale + translateX,
        connection.star1.position.dy * scale + translateY,
      );

      final p2 = Offset(
        connection.star2.position.dx * scale + translateX,
        connection.star2.position.dy * scale + translateY,
      );

      canvas.drawLine(p1, p2, linePaint);
    }

    // Draw stars
    for (final star in constellationStars) {
      final starPaint = Paint()
        ..color = star.color
        ..style = PaintingStyle.fill;

      final position = Offset(
        star.position.dx * scale + translateX,
        star.position.dy * scale + translateY,
      );

      canvas.drawCircle(
        position,
        star.size * scale,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ConstellationThumbnailPainter oldDelegate) {
    return connections != oldDelegate.connections;
  }
}