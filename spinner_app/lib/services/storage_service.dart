import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spin_data.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const String _spinDataKey = 'spin_data_list';
  static const String _spinResultsKey = 'spin_results';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized');
    }
    return _prefs!;
  }

  // 保存转盘数据
  static Future<void> saveSpinData(List<SpinData> spinDataList) async {
    final jsonList = spinDataList.map((data) => data.toJson()).toList();
    await prefs.setString(_spinDataKey, jsonEncode(jsonList));
  }

  // 获取转盘数据
  static List<SpinData> getSpinDataList() {
    final jsonString = prefs.getString(_spinDataKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SpinData.fromJson(json)).toList();
  }

  // 保存单个转盘数据
  static Future<void> saveSpinDataItem(SpinData spinData) async {
    final spinDataList = getSpinDataList();
    final index = spinDataList.indexWhere((data) => data.id == spinData.id);
    
    if (index >= 0) {
      spinDataList[index] = spinData;
    } else {
      spinDataList.add(spinData);
    }
    
    await saveSpinData(spinDataList);
  }

  // 删除转盘数据
  static Future<void> deleteSpinData(String id) async {
    final spinDataList = getSpinDataList();
    spinDataList.removeWhere((data) => data.id == id);
    await saveSpinData(spinDataList);
  }

  // 保存转盘结果
  static Future<void> saveSpinResult(SpinResult result) async {
    final results = getSpinResults();
    results.add(result);
    
    // 只保留最近1000个结果
    if (results.length > 1000) {
      results.removeRange(0, results.length - 1000);
    }
    
    final jsonList = results.map((result) => result.toJson()).toList();
    await prefs.setString(_spinResultsKey, jsonEncode(jsonList));
  }

  // 获取转盘结果
  static List<SpinResult> getSpinResults() {
    final jsonString = prefs.getString(_spinResultsKey);
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => SpinResult.fromJson(json)).toList();
  }

  // 获取特定转盘的结果
  static List<SpinResult> getSpinResultsForData(String spinDataId) {
    return getSpinResults()
        .where((result) => result.spinDataId == spinDataId)
        .toList();
  }

  // 清除特定转盘的结果
  static Future<void> clearSpinResults(String spinDataId) async {
    final allResults = getSpinResults();
    final filteredResults = allResults.where((result) => result.spinDataId != spinDataId).toList();
    
    final jsonList = filteredResults.map((result) => result.toJson()).toList();
    await prefs.setString(_spinResultsKey, jsonEncode(jsonList));
  }

  // 清除所有数据
  static Future<void> clearAllData() async {
    await prefs.remove(_spinDataKey);
    await prefs.remove(_spinResultsKey);
  }
}
