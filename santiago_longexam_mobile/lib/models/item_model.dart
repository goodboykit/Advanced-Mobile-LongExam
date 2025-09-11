class Item {
  final String uid;
  final String name;
  final List<String> description;
  final String photoUrl;
  final int qtyTotal;
  final int qtyAvailable;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    required this.uid,
    required this.name,
    this.description = const [''],
    this.photoUrl = '',
    required this.qtyTotal,
    required this.qtyAvailable,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      uid: json['_id'] ?? json['uid'] ?? '',
      name: json['name'] ?? '',
      description: List<String>.from(json['description'] ?? ['']),
      photoUrl: json['photoUrl'] ?? '',
      qtyTotal: json['qtyTotal'] ?? 0,
      qtyAvailable: json['qtyAvailable'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'qtyTotal': qtyTotal,
      'qtyAvailable': qtyAvailable,
      'isActive': isActive,
    };
  }
}

class ItemModel {
  final String? id;
  final String name;
  final List<String> description;
  final String photoUrl;
  final int qtyTotal;
  final int qtyAvailable;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ItemModel({
    this.id,
    required this.name,
    this.description = const [''],
    this.photoUrl = '',
    required this.qtyTotal,
    required this.qtyAvailable,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'],
      name: json['name'],
      description: List<String>.from(json['description'] ?? ['']),
      photoUrl: json['photoUrl'] ?? '',
      qtyTotal: json['qtyTotal'],
      qtyAvailable: json['qtyAvailable'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'qtyTotal': qtyTotal,
      'qtyAvailable': qtyAvailable,
      'isActive': isActive,
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    List<String>? description,
    String? photoUrl,
    int? qtyTotal,
    int? qtyAvailable,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      qtyTotal: qtyTotal ?? this.qtyTotal,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ItemModel{id: $id, name: $name, qtyTotal: $qtyTotal, qtyAvailable: $qtyAvailable, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  Item toItem() {
    return Item(
      uid: id ?? '',
      name: name,
      description: description,
      photoUrl: photoUrl,
      qtyTotal: qtyTotal,
      qtyAvailable: qtyAvailable,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}