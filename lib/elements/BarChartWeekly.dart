import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:planaholic/services/DbService.dart';
import 'package:planaholic/util/PresetColors.dart';

/// Weekly overview bar chart
class BarChartWeekly extends StatefulWidget {
  const BarChartWeekly({Key key}) : super(key: key);

  @override
  _BarChartWeeklyState createState() => _BarChartWeeklyState();
}

class _BarChartWeeklyState extends State<BarChartWeekly> {
  DbService _db = new DbService();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AspectRatio(
      aspectRatio: 1,
      child: FutureBuilder(
        future: _db.getWeekly(),
        builder: (context, snapshot) {
          Map data = {
            "Studies": 0,
            "Social": 0,
            "Others": 0,
            "Arts": 0,
            "Fitness": 0,
            "uncompleted": 0,
          };
          if (snapshot.hasData) {
            snapshot.data.forEach((key, value) {
              data[key] = value;
            });
          }
          int maxValue = 1 +
              data.values.reduce((value, element) => max<int>(value, element));
          int maxY = maxValue > 12 ? maxValue : 12;
          return BarChart(
            BarChartData(
              barGroups: [
                makeGroupData(1, data["Studies"], maxY),
                makeGroupData(2, data["Fitness"], maxY,
                    color: PresetColors.purple),
                makeGroupData(3, data["Arts"], maxY,
                    color: PresetColors.lightGreen),
                makeGroupData(4, data["Social"], maxY,
                    color: PresetColors.orangeAccent),
                makeGroupData(5, data["Others"], maxY, color: PresetColors.red),
                makeGroupData(6, data["uncompleted"], maxY,
                    color: Colors.grey[600]),
              ],
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: SideTitles(
                  showTitles: true,
                  getTextStyles: (value) => TextStyle(
                    color: PresetColors.blackAccent,
                    fontSize: screenWidth / 38,
                  ),
                  // margin: 16,
                  getTitles: (double value) {
                    switch (value.toInt()) {
                      case 1:
                        return 'Studies';
                      case 2:
                        return 'Fitness';
                      case 3:
                        return 'Arts';
                      case 4:
                        return 'Social';
                      case 5:
                        return 'Others';
                      case 6:
                        return 'Uncompleted';
                      default:
                        return '';
                    }
                  },
                ),
                leftTitles: SideTitles(
                  showTitles: false,
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              axisTitleData: FlAxisTitleData(
                topTitle: AxisTitle(
                  showTitle: true,
                  titleText: "Weekly Overview",
                  textStyle: TextStyle(fontSize: 18),
                  margin: 8.0,
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  tooltipPadding: const EdgeInsets.all(0),
                  // tooltipMargin: 8,
                  getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                      ) {
                    return BarTooltipItem(
                      rod.y.round().toString(),
                      TextStyle(
                        color: Color(0xFF1D1D1F),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Make bar chart group data with index [x], data value [y] and [max] value
  ///
  /// Default colour is preset blue.
  /// Change according to category when used.
  BarChartGroupData makeGroupData(int x, int y, int max,
      {Color color = PresetColors.blue}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y * 1.0,
          width: 22,
          colors: [color],
          backDrawRodData: BackgroundBarChartRodData(
            y: max * 1.0,
            show: true,
            colors: [Colors.grey[300]],
          ),
        ),
      ],
    );
  }
}