import 'package:dash_bubble/dash_bubble.dart';
import 'package:flutter/material.dart';

class FloatingBubbleService {
  static final FloatingBubbleService _instance = FloatingBubbleService._internal();
  factory FloatingBubbleService() => _instance;
  FloatingBubbleService._internal();

  bool _isStarted = false;

  Future<void> startBubble(BuildContext context) async {
    if (_isStarted) return;

    final hasPermission = await DashBubble.instance.hasOverlayPermission();
    if (!hasPermission) {
      await DashBubble.instance.requestOverlayPermission();
    }

    _isStarted = await DashBubble.instance.startBubble(
      bubbleOptions: BubbleOptions(
        bubbleIcon: "scorpion_icon", // Should match asset name in Android
        distanceToClose: 100,
        enableAnimateToEdge: true,
        enableClose: true,
        size: 120,
        opacity: 0.8,
      ),
      onTap: () {
        debugPrint("Bubble Tapped!");
        // Logic to open quick translation or Lens
      },
    );
  }

  Future<void> stopBubble() async {
    if (!_isStarted) return;
    await DashBubble.instance.stopBubble();
    _isStarted = false;
  }
}
