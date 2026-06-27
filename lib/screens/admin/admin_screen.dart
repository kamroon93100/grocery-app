import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../constants/api_constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final ApiService _api = ApiService();
  Map<String, dynamic> _stats = {};
  List<dynamic> _orders = [];
  List<dynamic> _products = [];
  List<dynamic> _users = [];
  List<dynamic> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.get(ApiConstants.dashboard),
        _api.get(ApiConstants.orders + '?limit=50'),
        _api.get(ApiConstants.products + '?limit=100'),
        _api.get(ApiConstants.users + '?limit=50'),
        _api.get(ApiConstants.categories),
      ]);
      setState(() {
        _stats      = results[0]['data'] ?? {};
        _orders     = results[1]['data'] ?? [];
        _products   = results[2]['data'] ?? [];
        _users      = results[3]['data'] ?? [];
        _categories = results[4]['data']?['categories'] ?? [];
        _loading    = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  // Upload image to Imgur (free, no API key needed for anonymous)
  Future<String?> _uploadImage({bool fromCamera = false}) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (file == null) return null;

      // Show uploading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...'),
            duration: Duration(seconds: 10)));
      }

      final bytes = await File(file.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {
          'Authorization': 'Client-ID 546c25a59c58ad7',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'image': base64Image, 'type': 'base64'},
      ).timeout(const Duration(seconds: 30));

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['data']['link'] as String?;
        if (mounted && url != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded!'),
              backgroundColor: Color(0xFF12B76A)));
        }
        return url;
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed'),
            backgroundColor: Colors.red));
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: const Color(0xFF12B76A),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF12B76A),
          tabs: const [
            Tab(text: 'Stats'),
            Tab(text: 'Orders'),
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF12B76A)))
          : TabBarView(
              controller: _tab,
              children: [
                _statsTab(),
                _ordersTab(),
                _productsTab(),
                _categoriesTab(),
                _usersTab(),
              ],
            ),
    );
  }

  // STATS TAB
  Widget _statsTab() {
    final u = _stats['users'] ?? {};
    final o = _stats['orders'] ?? {};
    final r = _stats['revenue'] ?? {};
    final p = _stats['products'] ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          _stat('Orders', o['total']?.toString() ?? '0', Icons.receipt, Colors.blue),
          const SizedBox(width: 12),
          _stat('Revenue', 'Rs' + (r['total']?.toString() ?? '0'), Icons.attach_money, const Color(0xFF12B76A)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _stat('Users', u['total']?.toString() ?? '0', Icons.people, Colors.purple),
          const SizedBox(width: 12),
          _stat('Products', p['total']?.toString() ?? '0', Icons.inventory, Colors.teal),
        ]),
      ]),
    );
  }

  Widget _stat(String title, String value, IconData icon, Color color) {
    return Expanded(child: Card(
      child: Padding(padding: const EdgeInsets.all(20),
        child: Column(children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]))));
  }

  // ORDERS TAB
  Widget _ordersTab() {
    if (_orders.isEmpty) return const Center(child: Text('No orders'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _orders.length,
      itemBuilder: (ctx, i) {
        final o = _orders[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text('#' + (o['orderNumber'] ?? ''),
              style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Rs' + (o['totalAmount']?.toString() ?? '0')),
            trailing: Text(o['status'] ?? '',
              style: TextStyle(
                color: o['status'] == 'delivered' ? const Color(0xFF12B76A) : Colors.orange,
                fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        );
      },
    );
  }

  // PRODUCTS TAB (with image upload)
  Widget _productsTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
          onPressed: () => _showProductDialog(),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _products.length,
          itemBuilder: (ctx, i) {
            final p = _products[i];
            final thumb = p['thumbnail']?.toString() ?? '';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: SizedBox(width: 50, height: 50,
                  child: thumb.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(thumb, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image)))
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text(thumb.isNotEmpty ? thumb : '?',
                          style: const TextStyle(fontSize: 24))))),
                title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Rs' + (p['price']?.toString() ?? '0') + ' | Stock: ' + (p['stock']?.toString() ?? '0')),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  // CAMERA BUTTON - Upload image
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF12B76A)),
                    tooltip: 'Upload image',
                    onPressed: () => _uploadProductImage(p)),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showProductDialog(product: p)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await _api.delete(ApiConstants.products + '/' + p['id']);
                      _loadAll();
                    }),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // Upload image for a product
  Future<void> _uploadProductImage(Map product) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF12B76A)),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(ctx, 'camera')),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(ctx, 'gallery')),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (choice == null) return;

    final url = await _uploadImage(fromCamera: choice == 'camera');
    if (url != null) {
      await _api.put(ApiConstants.products + '/' + product['id'], {
        'thumbnail': url,
        'images': [url],
      });
      _loadAll();
    }
  }

  // CATEGORIES TAB (with image upload)
  Widget _categoriesTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Category'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
          onPressed: () => _showCategoryDialog(),
        ),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _categories.length,
          itemBuilder: (ctx, i) {
            final c = _categories[i];
            final img = c['image']?.toString() ?? '';
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ListTile(
                leading: SizedBox(width: 50, height: 50,
                  child: img.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(img, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                            Center(child: Text(c['icon'] ?? '?', style: const TextStyle(fontSize: 24)))))
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F8EF),
                          borderRadius: BorderRadius.circular(8)),
                        child: Center(child: Text(c['icon'] ?? '?',
                          style: const TextStyle(fontSize: 24))))),
                title: Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(c['description'] ?? ''),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  // CAMERA BUTTON
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Color(0xFF12B76A)),
                    tooltip: 'Upload image',
                    onPressed: () => _uploadCategoryImage(c)),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showCategoryDialog(category: c)),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }

  // Upload image for a category
  Future<void> _uploadCategoryImage(Map category) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Color(0xFF12B76A)),
            title: const Text('Take Photo'),
            onTap: () => Navigator.pop(ctx, 'camera')),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.blue),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(ctx, 'gallery')),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (choice == null) return;

    final url = await _uploadImage(fromCamera: choice == 'camera');
    if (url != null) {
      await _api.put(ApiConstants.categories + '/' + category['id'], {
        'image': url,
      });
      _loadAll();
    }
  }

  // ADD/EDIT PRODUCT DIALOG
  void _showProductDialog({Map? product}) {
    final isEdit = product != null;
    final nameCtrl  = TextEditingController(text: product?['name'] ?? '');
    final priceCtrl = TextEditingController(text: product?['price']?.toString() ?? '');
    final discCtrl  = TextEditingController(text: product?['discount']?.toString() ?? '0');
    final stockCtrl = TextEditingController(text: product?['stock']?.toString() ?? '100');
    final unitCtrl  = TextEditingController(text: product?['unit'] ?? 'piece');
    final imgCtrl   = TextEditingController(text: product?['thumbnail'] ?? '');
    String? selectedCatId = product?['categoryId'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(isEdit ? 'Edit Product' : 'Add Product'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Image preview
              if (imgCtrl.text.startsWith('http'))
                Container(
                  height: 80, margin: const EdgeInsets.only(bottom: 10),
                  child: Image.network(imgCtrl.text,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: discCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount %', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: unitCtrl,
                decoration: const InputDecoration(labelText: 'Unit (kg/piece/ml)', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: imgCtrl,
                decoration: const InputDecoration(labelText: 'Image URL or emoji', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              // Upload buttons
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
                  onPressed: () async {
                    final url = await _uploadImage(fromCamera: true);
                    if (url != null) setS(() => imgCtrl.text = url);
                  })),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    final url = await _uploadImage();
                    if (url != null) setS(() => imgCtrl.text = url);
                  })),
              ]),
              const SizedBox(height: 8),
              // Category dropdown
              if (_categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedCatId,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: _categories.map<DropdownMenuItem<String>>((c) =>
                    DropdownMenuItem(value: c['id'] as String, child: Text(c['name'] ?? ''))).toList(),
                  onChanged: (v) => setS(() => selectedCatId = v),
                ),
            ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
              onPressed: () async {
                final data = {
                  'name': nameCtrl.text.trim(),
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'discount': double.tryParse(discCtrl.text) ?? 0,
                  'stock': int.tryParse(stockCtrl.text) ?? 100,
                  'unit': unitCtrl.text.trim(),
                  'thumbnail': imgCtrl.text.trim(),
                };
                if (isEdit) {
                  await _api.put(ApiConstants.products + '/' + product!['id'], data);
                } else {
                  data['categoryId'] = selectedCatId ?? (_categories.isNotEmpty ? _categories[0]['id'] : '');
                  data['description'] = nameCtrl.text;
                  await _api.post(ApiConstants.products, data);
                }
                Navigator.pop(ctx);
                _loadAll();
              },
              child: Text(isEdit ? 'Save' : 'Add')),
          ],
        ),
      ),
    );
  }

  // ADD/EDIT CATEGORY DIALOG
  void _showCategoryDialog({Map? category}) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: category?['name'] ?? '');
    final descCtrl = TextEditingController(text: category?['description'] ?? '');
    final iconCtrl = TextEditingController(text: category?['icon'] ?? '');
    final imgCtrl  = TextEditingController(text: category?['image'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(isEdit ? 'Edit Category' : 'Add Category'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (imgCtrl.text.startsWith('http'))
                Container(height: 80, margin: const EdgeInsets.only(bottom: 10),
                  child: Image.network(imgCtrl.text,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: iconCtrl,
                decoration: const InputDecoration(labelText: 'Emoji icon', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: imgCtrl,
                decoration: const InputDecoration(labelText: 'Image URL', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
                  onPressed: () async {
                    final url = await _uploadImage(fromCamera: true);
                    if (url != null) setS(() => imgCtrl.text = url);
                  })),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async {
                    final url = await _uploadImage();
                    if (url != null) setS(() => imgCtrl.text = url);
                  })),
              ]),
            ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF12B76A)),
              onPressed: () async {
                final data = {
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'icon': iconCtrl.text.trim(),
                  'image': imgCtrl.text.trim(),
                };
                if (isEdit) {
                  await _api.put(ApiConstants.categories + '/' + category!['id'], data);
                } else {
                  await _api.post(ApiConstants.categories, data);
                }
                Navigator.pop(ctx);
                _loadAll();
              },
              child: Text(isEdit ? 'Save' : 'Add')),
          ],
        ),
      ),
    );
  }

  // USERS TAB
  Widget _usersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _users.length,
      itemBuilder: (ctx, i) {
        final u = _users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: u['role'] == 'admin' ? Colors.blue : const Color(0xFF12B76A),
              child: Text((u['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white))),
            title: Text(u['name'] ?? ''),
            subtitle: Text(u['email'] ?? ''),
            trailing: Text((u['role'] ?? '').toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11,
                color: u['role'] == 'admin' ? Colors.blue : const Color(0xFF12B76A))),
          ),
        );
      },
    );
  }
}
