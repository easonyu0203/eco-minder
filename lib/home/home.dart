import 'package:eco_minder_flutter_app/home/components/EnergyUsageChart.dart';
import 'package:eco_minder_flutter_app/home/components/LightUsageBarChart.dart';
import 'package:eco_minder_flutter_app/sensor/sensor_param.dart';
import 'package:eco_minder_flutter_app/share/MyCard.dart';
import 'package:eco_minder_flutter_app/sensor/sensor.dart';
import 'package:eco_minder_flutter_app/share/SensorCard.dart';
import 'package:eco_minder_flutter_app/services/FireStore.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
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
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      ),
      body: StreamBuilder(
          stream: FireStoreService().streamSensorDatas(),
          initialData: SensorDatas.getDefault(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            SensorDatas sensorDatas =
                snapshot.hasData ? snapshot.data! : SensorDatas.getDefault();

            List<NumberSensorData> dataPoints =
                sensorDatas.recentEstEnergy.reversed.toList();
            List<FlSpot> chartPoints = dataPoints.asMap().entries.map((entry) {
              int index = entry.key;
              NumberSensorData e = entry.value;
              double value = e.data;
              if (value.isNaN) {
                value = 0;
              }
              return FlSpot(index.toDouble(), value);
            }).toList();

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
                      SensorInfo(
                        0,
                        sensorDatas.indoorTemp.data,
                        "Indoor Temp.",
                        FontAwesomeIcons.temperatureHalf,
                        () => FireStoreService().streamRecentIndoorTemps(30),
                      ),
                      SensorInfo(
                        1,
                        sensorDatas.outdoorTemp.data,
                        "Outdoor Temp.",
                        FontAwesomeIcons.sunPlantWilt,
                        () => FireStoreService().streamRecentOutdoorTemps(30),
                      ),
                    ]),
                    _buildSensorRow(context, [
                      SensorInfo(
                        2,
                        sensorDatas.lightLevel.data,
                        "Light Level",
                        FontAwesomeIcons.lightbulb,
                        () => FireStoreService().streamRecentLightLevels(30),
                      ),
                      SensorInfo(
                        3,
                        sensorDatas.airQuality.data,
                        "Air Quality",
                        FontAwesomeIcons.sprayCanSparkles,
                        () => FireStoreService().streamRecentAirQualitys(30),
                      ),
                    ]),
                    _buildChartCard(
                        context,
                        "Estimate Energy Usage",
                        EstEnergyChart(
                            points: chartPoints, sensorDatas: dataPoints)),
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
              Expanded(child: MyCard(child: _buildSensorCard(context, sensor))))
          .toList(),
    );
  }

  Widget _buildSensorCard(BuildContext context, SensorInfo sensor) {
    return SensorCardData(
      colorId: sensor.colorId,
      value: _formatDouble(sensor.value),
      title: sensor.title,
      iconData: sensor.icon,
      onPress: () => PersistentNavBarNavigator.pushNewScreen(context,
          screen: SensorScreen(SensorParam(
            title: sensor.title,
            icon: sensor.icon,
            colorId: sensor.colorId,
            getStream: sensor.getStream,
          ))),
    );
  }

  Widget _buildChartCard(
      BuildContext context, String title, Widget chartWidget) {
    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
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
  final Stream<List<NumberSensorData>> Function() getStream;

  SensorInfo(this.colorId, this.value, this.title, this.icon, this.getStream);
}
