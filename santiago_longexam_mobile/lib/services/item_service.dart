import '../constants.dart';
import '../models/item_model.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemService {
  Map<dynamic, dynamic> mapData = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'items';

  // Flag to determine which backend to use (true = Firebase, false = MongoDB)
  bool useFirebase = true;

  // ============ FIREBASE METHODS ============

  Future<List<ItemModel>> getItemsFromFirebase() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ItemModel.fromJson({
          '_id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to load items from Firebase: $e');
    }
  }

  Future<ItemModel> createItemInFirebase(ItemModel item) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add({
        'name': item.name,
        'description': item.description,
        'photoUrl': item.photoUrl,
        'qtyTotal': item.qtyTotal,
        'qtyAvailable': item.qtyAvailable,
        'isActive': item.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;
      return ItemModel.fromJson({
        '_id': doc.id,
        ...data,
      });
    } catch (e) {
      throw Exception('Failed to create item in Firebase: $e');
    }
  }

  Future<ItemModel> updateItemInFirebase(String id, ItemModel item) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'name': item.name,
        'description': item.description,
        'photoUrl': item.photoUrl,
        'qtyTotal': item.qtyTotal,
        'qtyAvailable': item.qtyAvailable,
        'isActive': item.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _firestore.collection(_collectionName).doc(id).get();
      final data = doc.data() as Map<String, dynamic>;
      return ItemModel.fromJson({
        '_id': doc.id,
        ...data,
      });
    } catch (e) {
      throw Exception('Failed to update item in Firebase: $e');
    }
  }

  Future<void> deleteItemFromFirebase(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete item from Firebase: $e');
    }
  }

  // ============ MONGODB METHODS ============

  Future<List<ItemModel>> getItemsFromMongoDB() async {
    final response = await get(Uri.parse('$host/api/items'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data from MongoDB');
    }
  }

  Future<Map> getAllItemFromMongoDB() async {
    final response = await get(Uri.parse('$host/api/items'));
    if (response.statusCode == 200) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception('Failed to load data from MongoDB');
    }
  }

  Future<Map> createItemInMongoDB(dynamic article) async {
    final response = await post(
      Uri.parse('$host/api/items'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
          'Failed to create item in MongoDB: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map> updateItemInMongoDB(String id, dynamic article) async {
    final response = await put(
      Uri.parse('$host/api/items/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
          'Failed to update item in MongoDB: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map> deleteItemFromMongoDB(String id, dynamic article) async {
    final response = await delete(
      Uri.parse('$host/api/items/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(article),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      mapData = jsonDecode(response.body);
      return mapData;
    } else {
      throw Exception(
          'Failed to delete item from MongoDB: ${response.statusCode} ${response.body}');
    }
  }

  // ============ UNIFIED METHODS (Auto-switch between Firebase/MongoDB) ============

  Future<List<ItemModel>> getItems() async {
    try {
      if (useFirebase) {
        return await getItemsFromFirebase();
      } else {
        return await getItemsFromMongoDB();
      }
    } catch (e) {
      // If Firebase fails, try MongoDB as fallback
      if (useFirebase) {
        try {
          return await getItemsFromMongoDB();
        } catch (mongoError) {
          throw Exception('Both Firebase and MongoDB failed: $e, $mongoError');
        }
      }
      rethrow;
    }
  }

  Future<Map> getAllItem() async {
    if (useFirebase) {
      final items = await getItemsFromFirebase();
      // Convert ItemModel list to proper format for Item.fromJson
      return {
        'items': items.map((item) {
          return {
            '_id': item.id,
            'name': item.name,
            'description': item.description,
            'photoUrl': item.photoUrl,
            'qtyTotal': item.qtyTotal,
            'qtyAvailable': item.qtyAvailable,
            'isActive': item.isActive,
            'createdAt': item.createdAt?.toIso8601String(),
            'updatedAt': item.updatedAt?.toIso8601String(),
          };
        }).toList()
      };
    } else {
      return await getAllItemFromMongoDB();
    }
  }

  Future<dynamic> createItem(dynamic article) async {
    if (useFirebase) {
      final ItemModel item = ItemModel(
        name: article['name'],
        description: List<String>.from(article['description'] ?? ['']),
        photoUrl: article['photoUrl'] ?? '',
        qtyTotal: article['qtyTotal'],
        qtyAvailable: article['qtyAvailable'],
        isActive: article['isActive'] ?? true,
      );
      return await createItemInFirebase(item);
    } else {
      return await createItemInMongoDB(article);
    }
  }

  Future<dynamic> updateItem(String id, dynamic article) async {
    if (useFirebase) {
      final ItemModel item = ItemModel(
        id: id,
        name: article['name'],
        description: List<String>.from(article['description'] ?? ['']),
        photoUrl: article['photoUrl'] ?? '',
        qtyTotal: article['qtyTotal'],
        qtyAvailable: article['qtyAvailable'],
        isActive: article['isActive'] ?? true,
      );
      return await updateItemInFirebase(id, item);
    } else {
      return await updateItemInMongoDB(id, article);
    }
  }

  Future<dynamic> deleteItem(String id, dynamic article) async {
    if (useFirebase) {
      await deleteItemFromFirebase(id);
      return {'message': 'Item deleted successfully'};
    } else {
      return await deleteItemFromMongoDB(id, article);
    }
  }
}