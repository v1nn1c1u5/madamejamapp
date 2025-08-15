import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RevenueChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const RevenueChartWidget({
    Key? key,
    required this.chartData,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  }) : super(key: key);

  @override
  State<RevenueChartWidget> createState() => _RevenueChartWidgetState();
}

class _RevenueChartWidgetState extends State<RevenueChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Receita',
                style: AppTheme.lightTheme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp)),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        value: widget.selectedPeriod,
                        isDense: true,
                        icon: CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 16),
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                                color: AppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp),
                        items:
                            ['Diário', 'Semanal', 'Mensal'].map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            widget.onPeriodChanged(newValue);
                          }
                        }))),
          ]),
          SizedBox(height: 3.h),
          SizedBox(
              height: 25.h,
              child: widget.chartData.isNotEmpty
                  ? LineChart(LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 100,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                                color:
                                    AppTheme.borderLight.withValues(alpha: 0.3),
                                strokeWidth: 1);
                          }),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    if (value.toInt() <
                                        widget.chartData.length) {
                                      return Padding(
                                          padding: EdgeInsets.only(top: 1.h),
                                          child: Text(
                                              widget.chartData[value.toInt()]
                                                      ['label'] ??
                                                  '',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                      fontSize: 9.sp,
                                                      color: AppTheme
                                                          .textSecondaryLight)));
                                    }
                                    return const Text('');
                                  })),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 200,
                                  reservedSize: 50,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    return Text('R\$${value.toInt()}',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                                fontSize: 9.sp,
                                                color: AppTheme
                                                    .textSecondaryLight));
                                  }))),
                      borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color:
                                  AppTheme.borderLight.withValues(alpha: 0.3))),
                      minX: 0,
                      maxX: (widget.chartData.length - 1).toDouble(),
                      minY: 0,
                      maxY: widget.chartData.isNotEmpty
                          ? widget.chartData
                                  .map((e) => (e['value'] as num).toDouble())
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2
                          : 1000,
                      lineBarsData: [
                        LineChartBarData(
                            spots:
                                widget.chartData.asMap().entries.map((entry) {
                              return FlSpot(entry.key.toDouble(),
                                  (entry.value['value'] as num).toDouble());
                            }).toList(),
                            isCurved: true,
                            gradient: LinearGradient(colors: [
                              AppTheme.lightTheme.primaryColor,
                              AppTheme.lightTheme.primaryColor
                                  .withValues(alpha: 0.3),
                            ]),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                      radius: 4,
                                      color: AppTheme.lightTheme.primaryColor,
                                      strokeWidth: 2,
                                      strokeColor: AppTheme
                                          .lightTheme.colorScheme.surface);
                                }),
                            belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                    colors: [
                                      AppTheme.lightTheme.primaryColor
                                          .withValues(alpha: 0.3),
                                      AppTheme.lightTheme.primaryColor
                                          .withValues(alpha: 0.1),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter))),
                      ],
                      lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final flSpot = barSpot;
                                  return LineTooltipItem(
                                      'R\$ ${flSpot.y.toStringAsFixed(0)}',
                                      AppTheme.lightTheme.textTheme.bodySmall!
                                          .copyWith(
                                              color: AppTheme.lightTheme
                                                  .colorScheme.surface,
                                              fontWeight: FontWeight.w600));
                                }).toList();
                              }),
                          handleBuiltInTouches: true,
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((spotIndex) {
                              return TouchedSpotIndicatorData(
                                  FlLine(
                                      color: AppTheme.lightTheme.primaryColor
                                          .withValues(alpha: 0.5),
                                      strokeWidth: 2),
                                  FlDotData(getDotPainter:
                                      (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                    radius: 6,
                                    color: AppTheme.lightTheme.primaryColor,
                                    strokeWidth: 3,
                                    strokeColor: AppTheme
                                        .lightTheme.colorScheme.surface);
                              }));
                            }).toList();
                          })))
                  : Center(
                      child: Text('Nenhum dado disponível',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondaryLight)))),
        ]));
  }
}
