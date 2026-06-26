import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants/api_constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController        _tab;
  final ApiService          _api      = ApiService();
  Map<String, dynamic>      _stats    = {};
  List<dynamic>             _orders   = [];
  List<dynamic>             _products = [];
  List<dynamic>             _users    = [];
  bool                      _loading  = true;

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
        _api.get(ApiConstants.orders + '?limit=50'),
        _api.get(ApiConstants.products + '?limit=50'),
        _api.get(ApiConstants.users + '?limit=50'),
      ]);
      setState(() {
        _stats    = results[0]['data'] ?? {};
        _orders   = results[1]['data'] ?? [];
        _products = results[2]['data'] ?? [];
        _users    = results[3]['data'] ?? [];
        _loading  = false;
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
          controller:           _tab,
          indicatorColor:       Colors.white,
          labelColor:           Colors.white,
          unselectedLabelColor: Colors.white60,
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
              children: [
                _statsTab(),
                _ordersTab(),
                _productsTab(),
                _usersTab(),
              ],
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
          const SizedBox(height: 8),
          Row(children: [
            _statCard('Total Orders',  '${orders['total']   ?? 0}', Icons.receipt_outlined,    Colors.blue),
            const SizedBox(width: 12),
            _statCard('Pending',       '${orders['pending'] ?? 0}', Icons.pending_outlined,    Colors.orange),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('Revenue', '\$${revenue['total'] ?? 0}', Icons.attach_money,   Colors.green),
            const SizedBox(width: 12),
            _statCard('Customers', '${users['total']   ?? 0}', Icons.people_outline, Colors.purple),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard('Products',   '${products['total'] ?? 0}', Icons.inventory_outlined, Colors.teal),
            const SizedBox(width: 12),
            _statCard('Today Rev.', '\$${revenue['today'] ?? 0}', Icons.today_outlined,     Colors.indigo),
          ]),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  _summaryRow('Today Orders',    '${orders['today']     ?? 0}'),
                  _summaryRow('This Week',       '${orders['week']      ?? 0}'),
                  _summaryRow('This Month',      '${orders['month']     ?? 0}'),
                  _summaryRow('Delivered',       '${orders['delivered'] ?? 0}'),
                  _summaryRow('Avg Order Value', '\$${revenue['avgOrder'] ?? 0}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 28,
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(title,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ordersTab() {
    if (_orders.isEmpty) {
      return const Center(child: Text('No orders yet'));
    }
    return ListView.builder(
      padding:   const EdgeInsets.all(12),
      itemCount: _orders.length,
      itemBuilder: (context, i) {
        final o      = _orders[i];
        final status = o['status'] as String? ?? 'pending';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${o['orderNumber'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    DropdownButton<String>(
                      value:     status,
                      underline: const SizedBox(),
                      items: ['pending','confirmed','preparing','ready',
                              'picked_up','out_for_delivery','delivered','cancelled']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.replaceAll('_',' '),
                                style: TextStyle(color: _statusColor(s), fontSize: 12))))
                          .toList(),
                      onChanged: (val) async {
                        await _api.put(
                          '${ApiConstants.orders}/${o['id']}/status',
                          {'status': val},
                        );
                        _loadAll();
                      },
                    ),
                  ],
                ),
                Text('👤 ${o['user']?['name'] ?? o['userName'] ?? ''}'),
                Text('💰 \$${o['totalAmount']}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text('📅 ${(o['createdAt'] ?? '').toString().substring(0, 16)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
            icon:     const Icon(Icons.add),
            label:    const Text('Add Product'),
            onPressed: () => _showAddProduct(context),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, i) {
              final p = _products[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: Text(p['thumbnail'] ?? '🛒',
                    style: const TextStyle(fontSize: 32)),
                  title: Text(p['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '\$${p['price']} | Stock: ${p['stock']} | ${p['discount']}% off'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showEditProduct(context, p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () async {
                          await _api.delete('${ApiConstants.products}/${p['id']}');
                          _loadAll();
                        },
                      ),
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

  void _showAddProduct(BuildContext context) {
    final nameCtrl  = TextEditingController();
    final priceCtrl = TextEditingController();
    final discCtrl  = TextEditingController(text: '0');
    final stockCtrl = TextEditingController(text: '100');
    final imgCtrl   = TextEditingController(text: '🛒');
    String catId    = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Product Name',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: discCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount %',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: imgCtrl,
                decoration: const InputDecoration(labelText: 'Emoji',
                  border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_products.isNotEmpty) catId = _products[0]['categoryId'] ?? '';
              await _api.post(ApiConstants.products, {
                'name':       nameCtrl.text,
                'price':      double.tryParse(priceCtrl.text) ?? 0,
                'discount':   double.tryParse(discCtrl.text)  ?? 0,
                'stock':      int.tryParse(stockCtrl.text)    ?? 100,
                'thumbnail':  imgCtrl.text,
                'categoryId': catId,
                'description': nameCtrl.text,
              });
              Navigator.pop(context);
              _loadAll();
            },
            child: const Text('Add')),
        ],
      ),
    );
  }

  void _showEditProduct(BuildContext context, Map p) {
    final nameCtrl  = TextEditingController(text: p['name']);
    final priceCtrl = TextEditingController(text: p['price'].toString());
    final discCtrl  = TextEditingController(text: p['discount'].toString());
    final stockCtrl = TextEditingController(text: p['stock'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit ${p['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: discCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount %',
                  border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: stockCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock',
                  border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _api.put('${ApiConstants.products}/${p['id']}', {
                'name':     nameCtrl.text,
                'price':    double.tryParse(priceCtrl.text)  ?? p['price'],
                'discount': double.tryParse(discCtrl.text)   ?? p['discount'],
                'stock':    int.tryParse(stockCtrl.text)     ?? p['stock'],
              });
              Navigator.pop(context);
              _loadAll();
            },
            child: const Text('Save')),
        ],
      ),
    );
  }

  Widget _usersTab() {
    return ListView.builder(
      padding:   const EdgeInsets.all(12),
      itemCount: _users.length,
      itemBuilder: (context, i) {
        final u = _users[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: u['role'] == 'admin' ? Colors.blue : Colors.green,
              child: Text(
                (u['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(u['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u['email'] ?? '', style: const TextStyle(fontSize: 12)),
                Text(u['phone'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: u['role'] == 'admin'
                    ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: u['role'] == 'admin' ? Colors.blue : Colors.green),
              ),
              child: Text(
                (u['role'] ?? 'user').toUpperCase(),
                style: TextStyle(
                  color:      u['role'] == 'admin' ? Colors.blue : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize:   11,
                )),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
