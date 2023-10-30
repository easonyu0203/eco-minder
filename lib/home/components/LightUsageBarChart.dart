import 'package:eco_minder_flutter_app/AppColors.dart';
import 'package:eco_minder_flutter_app/util/extentions/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LightUsageBarChart extends StatefulWidget {
  LightUsageBarChart({super.key});

  final Color barBackgroundColor = AppColors.contentColorBlue.withOpacity(0.3);
  final Color barColor = AppColors.contentColorBlue;
  final Color touchedBarColor = AppColors.contentColorCyan;

  @override
  State<LightUsageBarChart> createState() => _LightUsageBarChartState();
}

class _LightUsageBarChartState extends State<LightUsageBarChart> {
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      mainBarData(),
      swapAnimationDuration: animDuration,
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 0.5 : y,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: widget.touchedBarColor.darken(80))
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 24,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 12, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 14, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 11, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 5, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 10, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 18, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 14, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = '10/26';
                break;
              case 1:
                weekDay = '10/27';
                break;
              case 2:
                weekDay = '10/28';
                break;
              case 3:
                weekDay = '10/29';
                break;
              case 4:
                weekDay = '10/30';
                break;
              case 5:
                weekDay = '10/31';
                break;
              case 6:
                weekDay = '11/1';
                break;
              default:
                throw Error();
            }
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "${rod.toY - 0.5} hr",
                  style: TextStyle(
                    color: widget.touchedBarColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
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
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('26th', style: style);
        break;
      case 1:
        text = const Text('27th', style: style);
        break;
      case 2:
        text = const Text('28th', style: style);
        break;
      case 3:
        text = const Text('29th', style: style);
        break;
      case 4:
        text = const Text('30th', style: style);
        break;
      case 5:
        text = const Text('31th', style: style);
        break;
      case 6:
        text = const Text('1th', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      angle: -0.785398,
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
}
