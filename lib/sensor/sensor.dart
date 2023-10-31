import 'package:eco_minder_flutter_app/home/components/EnergyUsageChart.dart';
import 'package:eco_minder_flutter_app/share/MyCard.dart';
import 'package:eco_minder_flutter_app/share/SensorCard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Light Level"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                _buildCurrentStat(),
                SizedBox(height: 15),
                _buildSmallStats(),
                SizedBox(height: 15),
                _buildChartCard(
                    context, "Past Week Energy Usage", EnergyUsageChart()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildSmallStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SmallState(
          icon: FontAwesomeIcons.arrowDown,
          title: "Minimum",
          value: "23.23",
        ),
        SmallState(
          icon: FontAwesomeIcons.arrowUp,
          title: "Maximum",
          value: "23.23",
        ),
        SmallState(
          icon: FontAwesomeIcons.scaleBalanced,
          title: "Average",
          value: "23.23",
        ),
      ],
    );
  }

  Widget _buildCurrentStat() {
    return Row(
      children: [
        Expanded(
          child: MyCard(
            child: SensorCardData(
              value: "23",
              title: "Current Light Level",
              iconData: FontAwesomeIcons.lightbulb,
              onPress: null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(
      BuildContext context, String title, Widget chartWidget) {
    return MyCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 200, child: chartWidget),
          ],
        ),
      ),
    );
  }
}

class SmallState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const SmallState({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(icon),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
