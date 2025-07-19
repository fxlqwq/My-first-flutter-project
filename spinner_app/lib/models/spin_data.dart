import 'dart:convert';

class SpinData {
  final String id;
  final String name;
  final List<SpinItem> items;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int totalSpins;

  SpinData({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    required this.lastUsed,
    this.totalSpins = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((item) => item.toJson()).toList(),
    'createdAt': createdAt.millisecondsSinceEpoch,
    'lastUsed': lastUsed.millisecondsSinceEpoch,
    'totalSpins': totalSpins,
  };

  factory SpinData.fromJson(Map<String, dynamic> json) => SpinData(
    id: json['id'],
    name: json['name'],
    items: (json['items'] as List).map((item) => SpinItem.fromJson(item)).toList(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    lastUsed: DateTime.fromMillisecondsSinceEpoch(json['lastUsed']),
    totalSpins: json['totalSpins'] ?? 0,
  );

  SpinData copyWith({
    String? id,
    String? name,
    List<SpinItem>? items,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? totalSpins,
  }) {
    return SpinData(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      totalSpins: totalSpins ?? this.totalSpins,
    );
  }
}

class SpinItem {
  final String id;
  final String text;
  final int color;
  final double weight;
  final int hitCount;
  final DateTime? lastHit;

  SpinItem({
    required this.id,
    required this.text,
    required this.color,
    this.weight = 1.0,
    this.hitCount = 0,
    this.lastHit,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'color': color,
    'weight': weight,
    'hitCount': hitCount,
    'lastHit': lastHit?.millisecondsSinceEpoch,
  };

  factory SpinItem.fromJson(Map<String, dynamic> json) => SpinItem(
    id: json['id'],
    text: json['text'],
    color: json['color'],
    weight: json['weight']?.toDouble() ?? 1.0,
    hitCount: json['hitCount'] ?? 0,
    lastHit: json['lastHit'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['lastHit'])
        : null,
  );

  SpinItem copyWith({
    String? id,
    String? text,
    int? color,
    double? weight,
    int? hitCount,
    DateTime? lastHit,
  }) {
    return SpinItem(
      id: id ?? this.id,
      text: text ?? this.text,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      hitCount: hitCount ?? this.hitCount,
      lastHit: lastHit ?? this.lastHit,
    );
  }
}

class SpinResult {
  final String itemId;
  final String text;
  final DateTime timestamp;
  final String spinDataId;

  SpinResult({
    required this.itemId,
    required this.text,
    required this.timestamp,
    required this.spinDataId,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'text': text,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'spinDataId': spinDataId,
  };

  factory SpinResult.fromJson(Map<String, dynamic> json) => SpinResult(
    itemId: json['itemId'],
    text: json['text'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    spinDataId: json['spinDataId'],
  );
}
