import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:flutter/material.dart';

class SensorParam {
  final String title;
  final IconData icon;
  final int colorId;
  final Stream<List<NumberSensorData>> Function() getStream;

  SensorParam({
    required this.title,
    required this.colorId,
    required this.icon,
    required this.getStream,
  });
}
