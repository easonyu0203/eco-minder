import 'dart:ffi';

import 'package:eco_minder_flutter_app/home/components/EnergyUsageChart.dart';
import 'package:eco_minder_flutter_app/sensor/components/real_time_chart.dart';
import 'package:eco_minder_flutter_app/sensor/sensor_param.dart';
import 'package:eco_minder_flutter_app/services/FireStore.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:eco_minder_flutter_app/share/MyCard.dart';
import 'package:eco_minder_flutter_app/share/SensorCard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SensorScreen extends StatelessWidget {
  final SensorParam sensorParam;
  const SensorScreen(
    this.sensorParam, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sensorParam.title),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      ),
      body: StreamBuilder(
          stream: sensorParam.getStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<NumberSensorData> dataPoints =
                snapshot.data!.reversed.toList();
            List<FlSpot> chartPoints = dataPoints.asMap().entries.map((entry) {
              int index = entry.key;
              NumberSensorData e = entry.value;
              return FlSpot(index.toDouble(), e.data);
            }).toList();

            double min = double.infinity;
            double max = double.negativeInfinity;
            double sum = 0.0;

            dataPoints.forEach((e) {
              if (e.data < min) min = e.data;
              if (e.data > max) max = e.data;
              sum += e.data;
            });

            double avg = sum / dataPoints.length;
            double last = dataPoints.last.data;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.8),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      _buildCurrentStat(sensorParam, last),
                      SizedBox(height: 15),
                      _buildSmallStats(min, max, avg),
                      SizedBox(height: 15),
                      chartPoints.isEmpty
                          ? Container()
                          : _buildChartCard(
                              context,
                              "Real-Time ${sensorParam.title} Chart",
                              RealTimeChart(
                                  points: chartPoints,
                                  sensorDatas: dataPoints)),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Row _buildSmallStats(double min, double max, double avg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SmallState(
          icon: FontAwesomeIcons.arrowDown,
          title: "Minimum",
          value: min.toStringAsFixed(2),
        ),
        SmallState(
          icon: FontAwesomeIcons.arrowUp,
          title: "Maximum",
          value: max.toStringAsFixed(2),
        ),
        SmallState(
          icon: FontAwesomeIcons.scaleBalanced,
          title: "Average",
          value: avg.toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _buildCurrentStat(SensorParam sensorParam, double current) {
    return Row(
      children: [
        Expanded(
          child: MyCard(
            child: SensorCardData(
              colorId: sensorParam.colorId,
              value: current.toStringAsFixed(2),
              title: "Current ${sensorParam.title}",
              iconData: sensorParam.icon,
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
