import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/item_model.dart';
import '../services/item_service.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_input.dart';
import 'detail_screen.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final _svc = ItemService();
  final List<Item> _items = [];
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final res = await _svc.getAllItem();
      debugPrint('API Response: $res');
      final list =
          (res['items'] ?? res) as dynamic; // supports {items:[...]} OR [...]
      final List data = list is List ? list : (list['data'] ?? []);
      debugPrint('Parsed data: $data');
      _items
        ..clear()
        ..addAll(data.map<Item>((e) => Item.fromJson(e)));
      debugPrint('Loaded ${_items.length} items');
    } catch (e) {
      debugPrint('Error loading items: $e');
    }
  }

  // ---- Add Item Dialog ----
  Future<void> _openAddItemDialog() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final photoCtrl = TextEditingController();
    final qtyTotalCtrl = TextEditingController();
    final qtyAvailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool isActive = true;

    List<String> _parseDesc(String raw) => raw
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String? _req(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Required' : null;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSaving,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            Future<void> _save() async {
              if (isSaving) return;
              if (!formKey.currentState!.validate()) return;
              setLocal(() => isSaving = true);

              try {
                String photoUrl = photoCtrl.text.trim();
                if (photoUrl.isNotEmpty && !photoUrl.startsWith('http://') && !photoUrl.startsWith('https://')) {
                  photoUrl = 'https://$photoUrl';
                }

                final payload = {
                  'name': nameCtrl.text.trim(),
                  'description': _parseDesc(descCtrl.text),
                  'photoUrl': photoUrl,
                  'qtyTotal': int.parse(qtyTotalCtrl.text.trim()),
                  'qtyAvailable': int.parse(qtyAvailCtrl.text.trim()),
                  'isActive': isActive,
                };

                final res = await _svc.createItem(payload);

                // Handle both Firebase (returns ItemModel) and MongoDB (returns Map)
                final Item newItem;
                if (res is ItemModel) {
                  // Firebase returns ItemModel directly
                  newItem = res.toItem();
                } else {
                  // MongoDB returns Map
                  final created = (res['item'] ?? res);
                  newItem = Item.fromJson(created);
                }

                setState(() => _items.insert(0, newItem));

                if (ctx.mounted) Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Item added.')));
                }
              } catch (e) {
                setLocal(() => isSaving = false);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Failed to add: $e')));
                }
              }
            }

            // Helper to build image preview
            Widget buildImagePreview() {
              final url = photoCtrl.text.trim();
              if (url.isEmpty) {
                return Container(
                  height: 140.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 48, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text(
                        'No image',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
                      ),
                    ],
                  ),
                );
              }

              // Normalize URL
              String normalizedUrl = url;
              if (!url.startsWith('http://') && !url.startsWith('https://')) {
                normalizedUrl = 'https://$url';
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: normalizedUrl,
                  height: 140.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined, size: 48, color: Colors.red.shade300),
                        SizedBox(height: 8.h),
                        Text(
                          'Invalid URL',
                          style: TextStyle(color: Colors.red.shade600, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return AlertDialog(
              title: Row(
                children: [
                  IconButton(
                    onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                  const Expanded(
                    child: Text('Add New Item'),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(ctx).size.width * 0.9,
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Preview
                        buildImagePreview(),
                        SizedBox(height: 12.h),

                        // Photo URL Input
                        URLInput(
                          label: 'Photo URL',
                          hint: 'Enter image URL (optional)',
                          controller: photoCtrl,
                          isRequired: false,
                          onChanged: (_) => setLocal(() {}), // Refresh preview
                        ),
                        SizedBox(height: 10.h),

                        // Name Input
                        TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: _req,
                      ),
                      SizedBox(height: 10.h),

                      // Description Input
                      TextFormField(
                        controller: descCtrl,
                        minLines: 2,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Description (one per line or comma-sep)',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => _parseDesc(v ?? '').isEmpty
                            ? 'Add at least one line'
                            : null,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(
                            child: NumberInput(
                              label: 'Qty Total',
                              hint: 'Enter total quantity',
                              controller: qtyTotalCtrl,
                              min: 0,
                              max: 999999,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: NumberInput(
                              label: 'Qty Available',
                              hint: 'Enter available quantity',
                              controller: qtyAvailCtrl,
                              min: 0,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Available quantity is required';
                                }
                                final a = int.tryParse(v.trim());
                                final t = int.tryParse(qtyTotalCtrl.text.trim());
                                if (a == null || a < 0) return 'Must be a valid number';
                                if (t != null && a > t) return 'Cannot exceed total quantity';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        value: isActive,
                        onChanged: (val) => setLocal(() => isActive = val),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _save,
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(isSaving ? 'Saving...' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _leadingThumb(Item item) {
    final url = item.photoUrl.trim();
    const double imageSize = 56.0; // Fixed size instead of responsive

    if (url.isEmpty) {
      return Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: Icon(
          Icons.inventory_2_outlined,
          color: Colors.grey.shade600,
        ),
      );
    }

    // Normalize URL - ensure it has http:// or https://
    String normalizedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      normalizedUrl = 'https://$url';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: normalizedUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade100,
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
            color: Colors.red.shade50,
          ),
          child: Icon(
            Icons.broken_image_outlined,
            color: Colors.red.shade400,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItemDialog,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator.adaptive(strokeWidth: 3.sp),
                    SizedBox(height: 10.h),
                    const CustomText(text: 'Loading items...'),
                  ],
                ),
              ),
            );
          }

          if (snap.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CustomText(text: 'Failed to load items'),
              ),
            );
          }

          if (_items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CustomText(text: 'No items to display...'),
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              top: 10.h,
              bottom: 100.h, // Extra bottom padding for FAB
              left: 20.w,
              right: 20.w,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              final subtitle = item.description.isNotEmpty
                  ? item.description.first
                  : '';
              return Card(
                child: InkWell(
                  onTap: () async {
                    //TODO: navigate to detail if needed
                    debugPrint('Open item ${item.uid}');
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(item: item),
                      ),
                    );

                    // If deleted:
                    if (result is Map && result['deleted'] == true) {
                      final id = result['id'] as String;
                      setState(() {
                        _items.removeWhere((e) => e.uid == id);
                      });
                    }

                    // If updated:
                    if (result is Item) {
                      setState(() {
                        final i = _items.indexWhere((e) => e.uid == result.uid);
                        if (i != -1) _items[i] = result;
                      });
                    }
                  },
                  child: ListTile(
                    leading: _leadingThumb(item),
                    title: CustomText(
                      text: item.name.isEmpty ? 'Untitled' : item.name,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: CustomText(
                      text: subtitle, 
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: GestureDetector(
                      onTap: () => debugPrint('More ${item.uid}'),
                      child: const Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}