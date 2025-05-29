import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Replace with your actual SleepStorage and record model import
// import 'your_storage_file.dart';

class StatPage extends StatefulWidget {
  const StatPage({super.key});

  @override
  _StatPageState createState() => _StatPageState();
}

class _StatPageState extends State<StatPage> {
  static const List<Color> gradientColors = [
    Color(0xff23b6e6),
    Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, screenHeight * 0.1),
          child: Column(
            children: [
              Row(children: [Stack(children:[
                      
                    ]
                  )]),

              Text(
                'Sleep duration this week',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 30,
                    left: 20,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(mainData()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('Mon', style: style);
        break;
      case 2:
        text = const Text('Tue', style: style);
        break;
      case 3:
        text = const Text('Wed', style: style);
        break;
      case 4:
        text = const Text('Thu', style: style);
        break;
      case 5:
        text = const Text('Fri', style: style);
        break;
      case 6:
        text = const Text('Sat', style: style);
        break;
      case 7:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(meta: meta, child: text);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    String text;
    switch (value.toInt()) {
      case 2:
        text = '2h';
        break;
      case 4:
        text = '4h';
        break;
      case 6:
        text = '6h';
        break;
      case 8:
        text = '8h';
        break;
      case 10:
        text = '10h';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(color: Colors.grey, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(1, 7),
            FlSpot(2, 6.5),
            FlSpot(3, 8),
            FlSpot(4, 7.5),
            FlSpot(5, 6),
            FlSpot(6, 9),
            FlSpot(7, 8.5),
          ],
          isCurved: false,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: 0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
