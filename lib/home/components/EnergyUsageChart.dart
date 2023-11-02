import 'package:eco_minder_flutter_app/AppColors.dart';
import 'package:eco_minder_flutter_app/services/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EnergyUsageChart extends StatelessWidget {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(mainData());
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('25th    ', style: style);
        break;
      case 1:
        text = const Text('26th    ', style: style);
        break;
      case 2:
        text = const Text('27th    ', style: style);
        break;
      case 3:
        text = const Text('28th    ', style: style);
        break;
      case 4:
        text = const Text('29th    ', style: style);
        break;
      case 5:
        text = const Text('30th    ', style: style);
        break;
      case 6:
        text = const Text('31th    ', style: style);
        break;
      default:
        throw Error();
      // case 2:
      //   text = const Text('10/31    ', style: style);
      //   break;
      // case 5:
      //   text = const Text('JUN', style: style);
      //   break;
      // case 8:
      //   text = const Text('SEP', style: style);
      //   break;
      // default:
      //   text = const Text('', style: style);
      //   break;
    }

    return SideTitleWidget(
      angle: -0.785398,
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 2),
            FlSpot(2, 5),
            FlSpot(3, 3.1),
            FlSpot(4, 4),
            FlSpot(5, 3),
            FlSpot(6, 4),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.4))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class EstEnergyChart extends StatelessWidget {
  final List<FlSpot> points;
  final List<NumberSensorData> sensorDatas;
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];
  EstEnergyChart({super.key, required this.points, required this.sensorDatas});

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
    double? xInterval =
        points.isEmpty ? null : (points.last.x - points.first.x) / 5;
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
            drawVerticalLine: true,
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
        colors: gradientColors,
      ),
      barWidth: 6,
      isCurved: true,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors:
              gradientColors.map((color) => color.withOpacity(0.6)).toList(),
        ),
      ),
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
