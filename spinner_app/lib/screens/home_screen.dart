import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/spin_data.dart';
import '../services/storage_service.dart';
import '../widgets/spin_wheel.dart';
import 'statistics_screen.dart';
import 'create_spin_screen.dart';
import 'spin_screen.dart';

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 绘制外层阴影
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final shadowPath = Path();
    shadowPath.moveTo(size.width / 2 + 1, 3);
    shadowPath.lineTo(size.width / 2 - 12 + 1, size.height - 5 + 3);
    shadowPath.lineTo(size.width / 2 + 12 + 1, size.height - 5 + 3);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // 绘制箭头主体（渐变效果）
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.red.shade400,
        Colors.red.shade600,
        Colors.red.shade800,
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2 - 12, size.height - 8);
    path.lineTo(size.width / 2 + 12, size.height - 8);
    path.close();
    canvas.drawPath(path, paint);

    // 绘制高光
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width / 2, 2);
    highlightPath.lineTo(size.width / 2 - 8, size.height - 12);
    highlightPath.lineTo(size.width / 2 - 2, size.height - 12);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlightPaint);

    // 绘制边框
    final borderPaint = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  SpinItem? _selectedItem;
  bool _isSpinning = false;
  SpinData? _currentSpinData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSpinData();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeSpinData() {
    List<SpinData> existingData = StorageService.getSpinDataList();
    if (existingData.isEmpty) {
      // 创建默认转盘
      _currentSpinData = SpinData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '默认转盘',
        items: [
          SpinItem(id: '1', text: '选项1', color: Colors.red.value),
          SpinItem(id: '2', text: '选项2', color: Colors.blue.value),
          SpinItem(id: '3', text: '选项3', color: Colors.green.value),
          SpinItem(id: '4', text: '选项4', color: Colors.orange.value),
          SpinItem(id: '5', text: '选项5', color: Colors.purple.value),
          SpinItem(id: '6', text: '选项6', color: Colors.teal.value),
          SpinItem(id: '7', text: '选项7', color: Colors.pink.value),
          SpinItem(id: '8', text: '选项8', color: Colors.indigo.value),
        ],
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );
      StorageService.saveSpinDataItem(_currentSpinData!);
    } else {
      _currentSpinData = existingData.first;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildSpinTab(),
          StatisticsScreen(spinData: _currentSpinData),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '转盘',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSpinTab() {
    if (_currentSpinData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentSpinData!.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 转盘（会旋转）
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animation.value * 2 * math.pi,
                        child: SpinWheel(
                          items: _currentSpinData!.items,
                          size: 300,
                        ),
                      );
                    },
                  ),
                  // 固定的指针（不会旋转）
                  Positioned(
                    top: 15,
                    child: Container(
                      width: 0,
                      height: 0,
                      child: CustomPaint(
                        painter: PointerPainter(),
                        size: const Size(35, 35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                if (_selectedItem != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '上次结果',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedItem!.text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSpinning ? null : _spin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isSpinning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('开始转盘'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _spin() async {
    if (_isSpinning || _currentSpinData == null) return;

    setState(() {
      _isSpinning = true;
      _selectedItem = null;
    });

    // 计算权重总和
    double totalWeight = _currentSpinData!.items
        .fold(0.0, (sum, item) => sum + item.weight);

    // 生成随机数
    double random = math.Random().nextDouble() * totalWeight;
    
    // 找到对应的项目
    double currentWeight = 0.0;
    SpinItem? selected;
    for (var item in _currentSpinData!.items) {
      currentWeight += item.weight;
      if (random <= currentWeight) {
        selected = item;
        break;
      }
    }

    if (selected == null) {
      selected = _currentSpinData!.items.last;
    }

    // 计算旋转角度
    double targetAngle = _calculateTargetAngle(selected);
    double totalRotation = (math.Random().nextInt(3) + 5) * 2 * math.pi + targetAngle;

    // 开始动画
    _animation = Tween<double>(
      begin: _animation.value,
      end: _animation.value + totalRotation / (2 * math.pi),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.reset();
    await _animationController.forward();

    // 保存结果
    await _saveSpinResult(selected);

    setState(() {
      _selectedItem = selected;
      _isSpinning = false;
    });

    // 显示结果
    _showResult(selected);
  }

  double _calculateTargetAngle(SpinItem item) {
    int selectedIndex = _currentSpinData!.items.indexOf(item);
    double anglePerItem = 2 * math.pi / _currentSpinData!.items.length;
    
    // 简化逻辑：转盘需要旋转，使第selectedIndex个扇形的中心对准顶部指针
    // 由于第0个扇形已经在顶部中心，所以要旋转 -selectedIndex * anglePerItem
    double targetAngle = -selectedIndex * anglePerItem;
    
    // 规范化角度到[0, 2π)范围
    targetAngle = targetAngle % (2 * math.pi);
    if (targetAngle < 0) targetAngle += 2 * math.pi;
    
    return targetAngle;
  }

  Future<void> _saveSpinResult(SpinItem item) async {
    // 保存转盘结果
    final result = SpinResult(
      itemId: item.id,
      text: item.text,
      timestamp: DateTime.now(),
      spinDataId: _currentSpinData!.id,
    );
    await StorageService.saveSpinResult(result);

    // 更新项目统计
    final updatedItems = _currentSpinData!.items.map((spinItem) {
      if (spinItem.id == item.id) {
        return spinItem.copyWith(
          hitCount: spinItem.hitCount + 1,
          lastHit: DateTime.now(),
        );
      }
      return spinItem;
    }).toList();

    // 更新转盘数据
    _currentSpinData = _currentSpinData!.copyWith(
      items: updatedItems,
      totalSpins: _currentSpinData!.totalSpins + 1,
      lastUsed: DateTime.now(),
    );

    await StorageService.saveSpinDataItem(_currentSpinData!);
  }

  void _showResult(SpinItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('转盘结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(item.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              item.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('第 ${item.hitCount} 次抽中'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('重置统计'),
              onTap: () {
                Navigator.pop(context);
                _resetStatistics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑选项'),
              onTap: () {
                Navigator.pop(context);
                _editOptions();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetStatistics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置统计'),
        content: const Text('确定要重置所有统计数据吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 重置统计数据
              final resetItems = _currentSpinData!.items.map((item) {
                return item.copyWith(hitCount: 0, lastHit: null);
              }).toList();

              _currentSpinData = _currentSpinData!.copyWith(
                items: resetItems,
                totalSpins: 0,
              );

              await StorageService.saveSpinDataItem(_currentSpinData!);
              
              // 清除转盘结果
              await StorageService.clearAllData();
              await StorageService.saveSpinDataItem(_currentSpinData!);

              setState(() {
                _selectedItem = null;
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('统计数据已重置')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _editOptions() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSpinScreen(spinData: _currentSpinData),
      ),
    );
    
    if (result == true) {
      // 重新加载数据
      final updatedData = StorageService.getSpinDataList()
          .firstWhere((data) => data.id == _currentSpinData!.id);
      setState(() {
        _currentSpinData = updatedData;
      });
    }
  }
}
