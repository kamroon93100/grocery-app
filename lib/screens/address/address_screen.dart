import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/address_provider.dart';
import '../../models/address_model.dart';
import '../../services/google_maps_service.dart';

class AddressScreen extends StatefulWidget {
  final bool selectMode;
  const AddressScreen({super.key, this.selectMode = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().loadAddresses();
    });
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':   return Icons.home;
      case 'work':   return Icons.work;
      case 'office': return Icons.business;
      default:       return Icons.location_on;
    }
  }

  Color _labelColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':   return Colors.green;
      case 'work':   return Colors.blue;
      case 'office': return Colors.purple;
      default:       return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressProvider>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select Address' : 'My Addresses'),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : provider.addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined,
                        size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No addresses yet',
                        style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      Text('Add your first address',
                        style: TextStyle(color: Colors.grey.shade400)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:   const EdgeInsets.all(12),
                  itemCount: provider.addresses.length,
                  itemBuilder: (context, index) {
                    final a = provider.addresses[index];
                    final isSelected = widget.selectMode &&
                      provider.selected?.id == a.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isSelected ? Colors.green : Colors.transparent,
                          width: isSelected ? 2 : 0),
                        borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: widget.selectMode
                            ? () {
                                context.read<AddressProvider>().selectAddress(a);
                                Navigator.pop(context, a);
                              }
                            : () => _showAddEditDialog(context, address: a),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _labelColor(a.label).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(_labelIcon(a.label),
                                      color: _labelColor(a.label), size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(a.label.toUpperCase(),
                                    style: TextStyle(
                                      color: _labelColor(a.label),
                                      fontWeight: FontWeight.bold,
                                      fontSize:   13)),
                                  const SizedBox(width: 8),
                                  if (a.isDefault)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('DEFAULT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                    ),
                                  const Spacer(),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, color: Colors.green),
                                  if (!widget.selectMode)
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (val) async {
                                        if (val == 'edit') {
                                          _showAddEditDialog(context, address: a);
                                        } else if (val == 'delete') {
                                          await _confirmDelete(context, a);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ])),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(children: [
                                            Icon(Icons.delete_outline,
                                              color: Colors.red, size: 18),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                              style: TextStyle(color: Colors.red)),
                                          ])),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(a.phone,
                                style: TextStyle(
                                  color: Colors.grey.shade700, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(a.fullAddress,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13, height: 1.4)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon:  const Icon(Icons.add),
        label: const Text('Add Address'),
        onPressed: () => _showAddEditDialog(context),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AddressModel a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete Address?'),
        content: Text('Delete "${a.label}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final result = await context.read<AddressProvider>().deleteAddress(a.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['success'] == true
                ? 'Address deleted' : result['message'] ?? 'Failed'),
            backgroundColor: result['success'] == true
                ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showAddEditDialog(BuildContext context, {AddressModel? address}) {
    final nameCtrl    = TextEditingController(text: address?.name    ?? '');
    final phoneCtrl   = TextEditingController(text: address?.phone   ?? '');
    final line1Ctrl   = TextEditingController(text: address?.line1   ?? '');
    final line2Ctrl   = TextEditingController(text: address?.line2   ?? '');
    final cityCtrl    = TextEditingController(text: address?.city    ?? '');
    final stateCtrl   = TextEditingController(text: address?.state   ?? '');
    final pincodeCtrl = TextEditingController(text: address?.pincode ?? '');
    bool  isDefault   = address?.isDefault ?? false;
    String selectedLabel = address?.label ?? 'Home';
    final labels = ['Home','Work','Office','Other'];

    final mapsService = GoogleMapsService();
    final searchCtrl    = TextEditingController();
    List<Map<String,dynamic>> predictions = [];
    bool searching = false;
    Timer? _debounce;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize:       MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(address == null ? 'Add Address' : 'Edit Address',
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),

                // Google Address Autocomplete
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search with Google...',
                          prefixIcon: const Icon(Icons.search, color: Colors.green),
                          suffixIcon: searching
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (val) {
                          _debounce?.cancel();
                          if (val.trim().length < 3) {
                            setS(() => predictions = []);
                            return;
                          }
                          _debounce = Timer(const Duration(milliseconds: 500), () async {
                            setS(() => searching = true);
                            final result = await mapsService.placeAutocomplete(val.trim());
                            setS(() {
                              predictions = result;
                              searching = false;
                            });
                          });
                        },
                      ),
                      if (predictions.isNotEmpty)
                        SizedBox(
                          height: ((predictions.length * 48).clamp(0, 200)).toDouble(),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: predictions.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final p = predictions[i];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.location_on_outlined, color: Colors.green, size: 20),
                                title: Text(p['description'] ?? '', style: const TextStyle(fontSize: 13)),
                                onTap: () async {
                                  setS(() => searching = true);
                                  final placeId = p['placeId'] ?? '';
                                  final lat = p['lat'] as double?;
                                  final lon = p['lon'] as double?;
                                  final detail = await mapsService.placeDetails(
                                    placeId, lat: lat, lon: lon);
                                  setS(() => searching = false);
                                  if (detail != null) {
                                    final addr = detail['address'] as Map<String,dynamic>? ?? {};
                                    line1Ctrl.text = addr['line1'] ?? '';
                                    cityCtrl.text  = addr['city']  ?? '';
                                    stateCtrl.text = addr['state'] ?? '';
                                    pincodeCtrl.text = addr['pincode'] ?? '';
                                    searchCtrl.text = p['description'] ?? '';
                                    predictions = [];
                                    if (addr['line2'] != null) line2Ctrl.text = addr['line2'];
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Address Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: labels.map((lbl) => ChoiceChip(
                    label: Text(lbl),
                    selected: selectedLabel == lbl,
                    selectedColor: Colors.green,
                    onSelected: (_) => setS(() => selectedLabel = lbl),
                    labelStyle: TextStyle(
                      color: selectedLabel == lbl ? Colors.white : Colors.black),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                _field(nameCtrl,    'Full Name *',     Icons.person_outline),
                const SizedBox(height: 10),
                _field(phoneCtrl,   'Phone Number *',  Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _field(line1Ctrl,   'Address Line 1 *', Icons.home_outlined),
                const SizedBox(height: 10),
                _field(line2Ctrl,   'Address Line 2',  Icons.location_on_outlined),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _field(cityCtrl, 'City *',
                    Icons.location_city_outlined)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(stateCtrl, 'State *', Icons.map_outlined)),
                ]),
                const SizedBox(height: 10),
                _field(pincodeCtrl, 'Pincode *', Icons.pin_outlined,
                  keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default address'),
                  value: isDefault,
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setS(() => isDefault = v ?? false),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width:  double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon:  const Icon(Icons.save),
                    label: Text(address == null ? 'Save Address' : 'Update Address',
                      style: const TextStyle(fontSize: 16)),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty   ||
                          phoneCtrl.text.trim().isEmpty  ||
                          line1Ctrl.text.trim().isEmpty  ||
                          cityCtrl.text.trim().isEmpty   ||
                          stateCtrl.text.trim().isEmpty  ||
                          pincodeCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fill all required fields'),
                            backgroundColor: Colors.red));
                        return;
                      }
                      final newAddress = AddressModel(
                        id:        address?.id ?? '',
                        label:     selectedLabel,
                        name:      nameCtrl.text.trim(),
                        phone:     phoneCtrl.text.trim(),
                        line1:     line1Ctrl.text.trim(),
                        line2:     line2Ctrl.text.trim(),
                        city:      cityCtrl.text.trim(),
                        state:     stateCtrl.text.trim(),
                        pincode:   pincodeCtrl.text.trim(),
                        country:   'India',
                        isDefault: isDefault,
                      );
                      final provider = context.read<AddressProvider>();
                      final result   = address == null
                          ? await provider.addAddress(newAddress)
                          : await provider.updateAddress(address.id, newAddress);
                      if (!context.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['success'] == true
                              ? (address == null
                                  ? 'Address added!' : 'Address updated!')
                              : result['message'] ?? 'Failed'),
                          backgroundColor: result['success'] == true
                              ? Colors.green : Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
    {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller:   ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

