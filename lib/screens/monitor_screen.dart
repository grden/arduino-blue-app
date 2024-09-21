import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/provider/ble_provider.dart';
import '../utils/theme/color_manager.dart';
import '../utils/theme/text_manager.dart';
import '../widgets/sizedbox.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: ColorManager.background,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Height(16),
              _buildBPMTile(),
              const Height(16),
              Divider(
                color: ColorManager.grey,
                height: 1,
                thickness: 0.2,
              ),
              const Height(16),
              _buildTempTile(),
              const Height(16),
              Divider(
                color: ColorManager.grey,
                height: 1,
                thickness: 0.2,
              ),
              const Height(16),
              _buildGPSTile(),
              const Height(24),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: Icon(
        Icons.favorite,
        color: ColorManager.white,
      ),
      centerTitle: false,
      titleSpacing: 0,
      title: Text(
        'My Health Monitor',
        style: TextManager.main21,
      ),
      backgroundColor: ColorManager.background,
    );
  }

  Widget _buildTempTile() {
    return Consumer(builder: (context, ref, _) {
      final tempData = ref.watch(tempProvider);
      return Row(
        children: [
          Text('체온', style: TextManager.second19),
          const Width(86),
          Text('38',
              // '${dataToString(tempData)} °C',
              style: TextManager.inverse19),
          const Width(12),
          // if (double.parse(dataToString(tempData)) > 37)
          //   Text(
          //     '체온이 정상보다 높습니다.',
          //     style: TextManager.error17,
          //   ),
        ],
      );
    });
  }

  Widget _buildBPMTile() {
    return Consumer(builder: (context, ref, _) {
      final bpmData = ref.watch(bpmProvider);
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '심박수',
              style: TextManager.second19,
            ),
            Text(
              '72 bpm',
              // dataToString(bpmData),
              style: TextManager.main29,
            ),
            // SizedBox(
            //   height: 150,
            //   child: LineChart(
            //     LineChartData(
            //       lineBarsData: [
            //         LineChartBarData(
            //           spots: _heartRateData,
            //           isCurved: true,
            //           color: ColorManager.highlight,
            //           barWidth: 4,
            //           dotData: const FlDotData(show: false),
            //           belowBarData: BarAreaData(
            //             show: true,
            //             gradient: LinearGradient(
            //               colors: [
            //                 ColorManager.highlight.withOpacity(0.1),
            //                 ColorManager.highlight.withOpacity(0.0),
            //               ],
            //               begin: Alignment.topCenter,
            //               end: Alignment.bottomCenter,
            //             ),
            //           ),
            //         ),
            //       ],
            //       titlesData: const FlTitlesData(show: false),
            //       borderData: FlBorderData(show: false),
            //       gridData: const FlGridData(show: false),
            //       minX: 0,
            //       maxX: 59,
            //       minY: 0,
            //       maxY: 200, // Assuming max heart rate of 200 bpm
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget _buildGPSTile() {
    return Consumer(builder: (context, ref, _) {
      final gpsData = ref.watch(gpsProvider);
      return Column(
        children: [
          Row(
            children: [
              Text('위도, 경도', style: TextManager.second19),
              const Width(48),
              Text('37.5, 120.5',
                  // dataToString(gpsData),
                  style: TextManager.inverse19),
            ],
          ),
        ],
      );
    });
  }
}

String dataToString(List<int> data) {
  final result = String.fromCharCodes(data);
  return result;
}
