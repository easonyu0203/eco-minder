import 'package:eco_minder_flutter_app/home/components/EnergyUsageChart.dart';
import 'package:eco_minder_flutter_app/home/components/LightUsageBarChart.dart';
import 'package:eco_minder_flutter_app/home/components/SensorCard.dart';
import 'package:eco_minder_flutter_app/services/FireStore.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Eco Minder"),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      ),
      body: StreamBuilder(
          stream: FireStoreService().streamSensorDatas(),
          initialData: SensorDatas.GetDefault(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            SensorDatas sensorDatas =
                snapshot.hasData ? snapshot.data! : SensorDatas.GetDefault();

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSensorRow(context, [
                      SensorInfo(0, sensorDatas.indoorTemp.data, "Indoor Temp.",
                          FontAwesomeIcons.temperatureHalf),
                      SensorInfo(1, sensorDatas.outdoorTemp.data,
                          "Outdoor Temp.", FontAwesomeIcons.sunPlantWilt),
                    ]),
                    _buildSensorRow(context, [
                      SensorInfo(2, sensorDatas.lightLevel.data, "Light Level",
                          FontAwesomeIcons.lightbulb),
                      SensorInfo(3, sensorDatas.airQuality.data, "Air Quality",
                          FontAwesomeIcons.sprayCanSparkles),
                    ]),
                    _buildChartCard(
                        context, "Past Week Energy Usage", EnergyUsageChart()),
                    _buildChartCard(context, "Past Week Light Usage hr",
                        LightUsageBarChart()),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildSensorRow(BuildContext context, List<SensorInfo> sensors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sensors
          .map((sensor) =>
              Expanded(child: HomeCard(child: _buildSensorCard(sensor))))
          .toList(),
    );
  }

  Widget _buildSensorCard(SensorInfo sensor) {
    return SensorCard(
      colorId: sensor.colorId,
      value: _formatDouble(sensor.value),
      title: sensor.title,
      iconData: sensor.icon,
    );
  }

  Widget _buildChartCard(
      BuildContext context, String title, Widget chartWidget) {
    return HomeCard(
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
    );
  }

  String _formatDouble(double value) {
    if (value.toInt() == -1) {
      return "No Value yet...";
    }

    return value == value.toInt()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}

class SensorInfo {
  final int colorId;
  final double value;
  final String title;
  final IconData icon;

  SensorInfo(this.colorId, this.value, this.title, this.icon);
}

class HomeCard extends StatelessWidget {
  final Widget? child;
  const HomeCard({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}
