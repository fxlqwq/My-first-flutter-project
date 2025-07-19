import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/spin_data.dart';
import '../services/storage_service.dart';

class StatisticsScreen extends StatefulWidget {
  final SpinData? spinData;

  const StatisticsScreen({super.key, this.spinData});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<SpinResult> allResults = [];
  SpinData? selectedSpinData;

  @override
  void initState() {
    super.initState();
    selectedSpinData = widget.spinData;
    _loadData();
  }

  void _loadData() {
    setState(() {
      allResults = StorageService.getSpinResults();
      if (selectedSpinData != null) {
        // 重新加载最新的转盘数据
        final spinDataList = StorageService.getSpinDataList();
        final updated = spinDataList.where((data) => data.id == selectedSpinData!.id).firstOrNull;
        if (updated != null) {
          selectedSpinData = updated;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: selectedSpinData == null
          ? _buildEmptyState()
          : _buildStatisticsView(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '暂无统计数据',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsView() {
    return Column(
      children: [
        Expanded(
          child: selectedSpinData != null
              ? _buildDetailedStatistics(selectedSpinData!)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildDetailedStatistics(SpinData spinData) {
    final results = StorageService.getSpinResultsForData(spinData.id);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 基本统计信息
        _buildBasicStats(spinData, results),
        const SizedBox(height: 20),
        
        // 饼图
        _buildPieChart(spinData),
        const SizedBox(height: 20),
        
        // 柱状图
        _buildBarChart(spinData),
        const SizedBox(height: 20),
        
        // 最近转盘记录
        _buildRecentResults(results),
      ],
    );
  }

  Widget _buildBasicStats(SpinData spinData, List<SpinResult> results) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基本统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('总转动次数', spinData.totalSpins.toString()),
                _buildStatItem('选项数量', spinData.items.length.toString()),
                _buildStatItem('最近使用', _formatDate(spinData.lastUsed)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(SpinData spinData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选项分布',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: _buildPieChartSections(spinData),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(SpinData spinData) {
    int totalHits = spinData.items.fold(0, (sum, item) => sum + item.hitCount);
    
    return spinData.items.map((item) {
      final percentage = totalHits > 0 ? (item.hitCount / totalHits) * 100 : 0.0;
      return PieChartSectionData(
        color: Color(item.color),
        value: item.hitCount.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildBarChart(SpinData spinData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '命中次数',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: spinData.items.isEmpty ? 1 : spinData.items
                      .map((item) => item.hitCount)
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble() + 1,
                  barGroups: _buildBarGroups(spinData),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < spinData.items.length) {
                            return Text(
                              spinData.items[index].text,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(SpinData spinData) {
    return spinData.items.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.hitCount.toDouble(),
            color: Color(entry.value.color),
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  Widget _buildRecentResults(List<SpinResult> results) {
    final recentResults = results.reversed.take(10).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近转盘记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (recentResults.isEmpty)
              const Text('暂无记录')
            else
              ...recentResults.map((result) => ListTile(
                title: Text(result.text),
                subtitle: Text(_formatDateTime(result.timestamp)),
                leading: const Icon(Icons.casino),
              )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
