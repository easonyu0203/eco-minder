import 'package:eco_minder_flutter_app/AppColors.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RealTimeChart extends StatelessWidget {
  final List<FlSpot> points;
  final List<NumberSensorData> sensorDatas;
  const RealTimeChart(
      {super.key, required this.points, required this.sensorDatas});

  @override
  Widget build(BuildContext context) {
    // Calculate minY and maxY with a 10% margin
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minY = minY < point.y ? minY : point.y;
      maxY = maxY > point.y ? maxY : point.y;
    }

    // Apply a 10% margin
    final margin = 0.1 * (maxY - minY);

    // Calculate intervals for titles
    double xInterval = (points.last.x - points.first.x) / 5;
    double yInterval = (maxY - minY) / 5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: LineChart(
        LineChartData(
          minY: minY - margin,
          maxY: maxY + margin,
          minX: points.first.x,
          maxX: points.last.x,
          lineTouchData: LineTouchData(enabled: false),
          clipData: FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            lineData(points),
          ],
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: xInterval == 0 ? null : xInterval,
                getTitlesWidget: bottomTitleWidgets,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yInterval == 0 ? null : yInterval,
                getTitlesWidget: (value, meta) =>
                    leftTitleWidgets(value, meta, minY, maxY),
                reservedSize: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData lineData(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [
          AppColors.contentColorBlue.withOpacity(0.2),
          AppColors.contentColorBlue
        ],
      ),
      barWidth: 6,
      isCurved: true,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value >= points.last.x) {
      return Container();
    }
    final DateTime dateTime = sensorDatas[value.toInt()].timestamp;

    // Assuming data might span over multiple days, we can format it accordingly
    final Duration difference =
        sensorDatas.last.timestamp.difference(sensorDatas.first.timestamp);

    String timeString;
    if (difference.inHours < 1) {
      timeString =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 1) {
      timeString =
          '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      timeString = '${dateTime.month}/${dateTime.day}';
    }

    return SideTitleWidget(
      angle: -0.785398,
      axisSide: meta.axisSide,
      child: Text(
        "$timeString    ",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget leftTitleWidgets(
      double value, TitleMeta meta, double minY, double maxY) {
    if (value < minY - 0.4 || value > maxY) {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        value.toStringAsFixed(1),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          // color: AppColors.contentColorBlue,
        ),
      ),
    );
  }
}
