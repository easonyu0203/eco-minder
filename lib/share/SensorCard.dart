import 'package:eco_minder_flutter_app/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SensorCardData extends StatelessWidget {
  final int colorId;
  final String value;
  final String title;
  final IconData iconData;
  final VoidCallback? onPress;
  const SensorCardData({
    super.key,
    this.colorId = 0,
    required this.value,
    required this.title,
    required this.iconData,
    required this.onPress,
  });

  List<Color> get availableColors => <Color>[
        AppColors.contentColorPurple.withOpacity(0.7),
        AppColors.contentColorBlue.withOpacity(0.7),
        AppColors.contentColorPink.withOpacity(0.7),
        AppColors.contentColorRed.withOpacity(0.7),
      ];

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPress,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 33,
              backgroundColor: availableColors[colorId],
              child: Icon(
                iconData,
                size: 30,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
