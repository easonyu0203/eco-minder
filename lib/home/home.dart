import 'package:eco_minder_flutter_app/home/components/EnergyUsageChart.dart';
import 'package:eco_minder_flutter_app/home/components/LightUsageBarChart.dart';
import 'package:eco_minder_flutter_app/home/components/SensorCard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eco Minder"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 32),
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: HomeCard(
                      child: SensorCard(
                        colorId: 0,
                        value: _formatDouble(20),
                        title: "Indoor Temp.",
                        iconData: FontAwesomeIcons.temperatureHalf,
                      ),
                    ),
                  ),
                  Expanded(
                    child: HomeCard(
                      child: SensorCard(
                        colorId: 1,
                        value: _formatDouble(20),
                        title: "Outdoor Temp.",
                        iconData: FontAwesomeIcons.sunPlantWilt,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: HomeCard(
                      child: SensorCard(
                        colorId: 2,
                        value: _formatDouble(20.3434),
                        title: "Ligh Level",
                        iconData: FontAwesomeIcons.lightbulb,
                      ),
                    ),
                  ),
                  Expanded(
                    child: HomeCard(
                      child: SensorCard(
                        colorId: 3,
                        value: _formatDouble(20),
                        title: "ligh value",
                        iconData: FontAwesomeIcons.sprayCanSparkles,
                      ),
                    ),
                  ),
                ],
              ),
              HomeCard(
                child: Column(
                  children: [
                    Text(
                      "Past Week Energy Usage",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Expanded(child: EnergyUsageChart()),
                    ),
                  ],
                ),
              ),
              HomeCard(
                child: Column(
                  children: [
                    Text(
                      "Past Week Light Usage %",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: Expanded(child: LightUsageBarChart()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDouble(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}

class HomeCard extends StatelessWidget {
  final Widget? child;
  const HomeCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(7.0), // spacing around the card
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface
            .withOpacity(0.7), // secondary theme color
        borderRadius: BorderRadius.circular(10.0), // round border
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
