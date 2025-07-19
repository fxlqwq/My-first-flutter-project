import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/spin_data.dart';
import '../services/storage_service.dart';

class CreateSpinScreen extends StatefulWidget {
  final SpinData? spinData;

  const CreateSpinScreen({super.key, this.spinData});

  @override
  State<CreateSpinScreen> createState() => _CreateSpinScreenState();
}

class _CreateSpinScreenState extends State<CreateSpinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<SpinItem> _items = [];
  bool _isEditing = false;

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.spinData != null;
    if (_isEditing) {
      _nameController.text = widget.spinData!.name;
      _items = List.from(widget.spinData!.items);
    } else {
      _addDefaultItems();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addDefaultItems() {
    _items = [
      SpinItem(
        id: _generateId(),
        text: '选项1',
        color: _availableColors[0].value,
      ),
      SpinItem(
        id: _generateId(),
        text: '选项2',
        color: _availableColors[1].value,
      ),
    ];
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           math.Random().nextInt(1000).toString();
  }

  void _addItem() {
    setState(() {
      _items.add(SpinItem(
        id: _generateId(),
        text: '选项${_items.length + 1}',
        color: _availableColors[_items.length % _availableColors.length].value,
      ));
    });
  }

  void _removeItem(int index) {
    if (_items.length > 2) {
      setState(() {
        _items.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少需要保留2个选项')),
      );
    }
  }

  void _updateItem(int index, SpinItem item) {
    setState(() {
      _items[index] = item;
    });
  }

  void _saveSpinData() async {
    if (_formKey.currentState!.validate()) {
      final spinData = SpinData(
        id: _isEditing ? widget.spinData!.id : _generateId(),
        name: _nameController.text,
        items: _items,
        createdAt: _isEditing ? widget.spinData!.createdAt : DateTime.now(),
        lastUsed: _isEditing ? widget.spinData!.lastUsed : DateTime.now(),
        totalSpins: _isEditing ? widget.spinData!.totalSpins : 0,
      );

      await StorageService.saveSpinDataItem(spinData);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑转盘' : '创建转盘'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _saveSpinData,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '转盘名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入转盘名称';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '选项列表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('添加选项'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _items[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 颜色选择器
            GestureDetector(
              onTap: () => _showColorPicker(index),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(item.color),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 文本输入
            Expanded(
              child: TextFormField(
                initialValue: item.text,
                decoration: const InputDecoration(
                  labelText: '选项文本',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _updateItem(index, item.copyWith(text: value));
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入选项文本';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            // 权重输入
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: item.weight.toString(),
                decoration: const InputDecoration(
                  labelText: '权重',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final weight = double.tryParse(value) ?? 1.0;
                  _updateItem(index, item.copyWith(weight: weight));
                },
              ),
            ),
            const SizedBox(width: 16),
            // 删除按钮
            IconButton(
              onPressed: () => _removeItem(index),
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            return GestureDetector(
              onTap: () {
                _updateItem(index, _items[index].copyWith(color: color.value));
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _items[index].color == color.value
                        ? Colors.black
                        : Colors.grey,
                    width: _items[index].color == color.value ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
