import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/image_upload_service.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.get(ApiConstants.dashboard),
        _api.get('${ApiConstants.orders}?limit=50'),
        _api.get('${ApiConstants.products}?limit=50'),
        _api.get('${ApiConstants.users}?limit=50'),
      ]);
      setState(() {
        _stats    = results[0]['data'] ?? {};
        _orders   = results[1]['data'] ?? [];
        _products = results[2]['data'] ?? [];
        _users    = results[3]['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':   return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default:          return Colors.grey;
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
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Stats'),
            Tab(icon: Icon(Icons.receipt_outlined),   text: 'Orders'),
            Tab(icon: Icon(Icons.inventory_outlined), text: 'Products'),
            Tab(icon: Icon(Icons.people_outline),     text: 'Users'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : TabBarView(
              controller: _tab,
              children: [_statsTab(), _ordersTab(), _productsTab(), _usersTab()],
            ),
    );
  }

  Widget _statsTab() {
    final users    = _stats['users']    ?? {};
    final orders   = _stats['orders']   ?? {};
    final revenue  = _stats['revenue']  ?? {};
    final products = _stats['products'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            _statCard('Orders', '${orders['total'] ?? 0}',
              Icons.receipt_outlined, Colors.blue),
            const SizedBox(width: 12),
            _statCard('Pending', '${orders['pending'] ?? 0}',
              Icons.pending_outlined, Colors.orange),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('Revenue', 'Rs${revenue['total'] ?? 0}',
              Icons.attach_money, Colors.green),
            const SizedBox(width: 12),
            _statCard('Users', '${users['total'] ?? 0}',
              Icons.people_outline, Colors.purple),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('Products', '${products['total'] ?? 0}',
              Icons.inventory_outlined, Colors.teal),
            const SizedBox(width: 12),
            _statCard('Today', 'Rs${revenue['today'] ?? 0}',
              Icons.today_outlined, Colors.indigo),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 28,
                child: Icon(icon, color: color, size: 26)),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(
                color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ordersTab() {
    if (_orders.isEmpty) return const Center(child: Text('No orders'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _orders.length,
      itemBuilder: (context, i) {
        final o = _orders[i];
        final status = o['status'] as String? ?? 'pending';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${o['orderNumber'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: status,
                      underline: const SizedBox(),
                      items: ['pending','confirmed','preparing','ready',
                              'picked_up','out_for_delivery','delivered','cancelled']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.replaceAll('_',' '),
                                style: TextStyle(color: _statusColor(s)))))
                          .toList(),
                      onChanged: (val) async {
                        await _api.put('${ApiConstants.orders}/${o['id']}/status',
                          {'status': val});
                        _loadAll();
                      },
                    ),
                  ],
                ),
                Text('Customer: ${o['user']?['name'] ?? ''}'),
                Text('Total: Rs${o['totalAmount']}',
                  style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _productsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            onPressed: () => _showProductDialog(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, i) {
              final p = _products[i];
              final thumb = p['thumbnail'] ?? '';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: thumb.toString().startsWith('http')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(thumb, width: 50, height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 40)))
                      : Text(thumb.isNotEmpty ? thumb : '🛒',
                          style: const TextStyle(fontSize: 32)),
                  title: Text(p['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rs${p['price']} | Stock: ${p['stock']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showProductDialog(product: p)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await _api.delete('${ApiConstants.products}/${p['id']}');
                          _loadAll();
                        }),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProductDialog({Map? product}) {
    final isEdit = product != null;
    final nameCtrl  = TextEditingController(text: product?['name']     ?? '');
    final priceCtrl = TextEditingController(text: product?['price']?.toString()    ?? '');
    final discCtrl  = TextEditingController(text: product?['discount']?.toString() ?? '0');
    final stockCtrl = TextEditingController(text: product?['stock']?.toString()    ?? '100');
    final imgCtrl   = TextEditingController(text: product?['thumbnail'] ?? '🛒');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(isEdit ? 'Edit Product' : 'Add Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image preview
                if (imgCtrl.text.startsWith('http'))
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Image.network(imgCtrl.text,
                      errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 60))),

                TextField(controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: discCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount %',
                    border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: imgCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Image URL or Emoji',
                    border: OutlineInputBorder())),
                const SizedBox(height: 12),
                // Upload buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Uploading...')));
                          final url = await ImageUploadService()
                              .pickAndUpload(fromCamera: true);
                          if (url != null) {
                            setS(() => imgCtrl.text = url);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Uploaded!'),
                                backgroundColor: Colors.green));
                          }
                        }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Uploading...')));
                          final url = await ImageUploadService().pickAndUpload();
                          if (url != null) {
                            setS(() => imgCtrl.text = url);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Uploaded!'),
                                backgroundColor: Colors.green));
                          }
                        }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name':      nameCtrl.text.trim(),
                  'price':     double.tryParse(priceCtrl.text) ?? 0,
                  'discount':  double.tryParse(discCtrl.text)  ?? 0,
                  'stock':     int.tryParse(stockCtrl.text)    ?? 100,
                  'thumbnail': imgCtrl.text.trim(),
                };
                if (isEdit) {
                  await _api.put('${ApiConstants.products}/${product['id']}', data);
                } else {
                  if (_products.isNotEmpty) {
                    data['categoryId'] = _products[0]['categoryId'] ?? '';
                  }
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

  Widget _usersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _users.length,
      itemBuilder: (context, i) {
        final u = _users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: u['role'] == 'admin' ? Colors.blue : Colors.green,
              child: Text((u['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white))),
            title: Text(u['name'] ?? ''),
            subtitle: Text('${u['email'] ?? ''}\n${u['phone'] ?? ''}'),
            trailing: Text((u['role'] ?? 'user').toUpperCase(),
              style: TextStyle(
                color: u['role'] == 'admin' ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold)),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

