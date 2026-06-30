import 'package:flutter/material.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final String sortBy;
  final Function(double, double, String) onApply;

  const SearchFilterBottomSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late RangeValues _priceRange;
  late String      _selectedSort;

  final List<Map<String, String>> _sortOptions = [
    {'value':'createdAt_DESC',  'label':'Newest First',    'icon':'🆕'},
    {'value':'price_ASC',       'label':'Price Low to High','icon':'💰'},
    {'value':'price_DESC',      'label':'Price High to Low','icon':'💎'},
    {'value':'name_ASC',        'label':'Name A to Z',     'icon':'🔤'},
    {'value':'rating_DESC',     'label':'Top Rated',       'icon':'⭐'},
    {'value':'reviewCount_DESC','label':'Most Reviewed',   'icon':'💬'},
  ];

  @override
  void initState() {
    super.initState();
    _priceRange   = RangeValues(widget.minPrice, widget.maxPrice);
    _selectedSort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width:  40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters & Sort',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Price Range
            const Text('Price Range',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text('\$${_priceRange.start.toInt()}',
                    style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
                ),
                Text('to', style: TextStyle(color: Colors.grey.shade600)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text('\$${_priceRange.end.toInt()}',
                    style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min:    0,
              max:    50,
              divisions:   50,
              activeColor: Colors.green,
              labels: RangeLabels(
                '\$${_priceRange.start.toInt()}',
                '\$${_priceRange.end.toInt()}',
              ),
              onChanged: (values) => setState(() => _priceRange = values),
            ),

            const SizedBox(height: 16),

            // Sort By
            const Text('Sort By',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ..._sortOptions.map((opt) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: _selectedSort == opt['value']
                    ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedSort == opt['value']
                      ? Colors.green : Colors.grey.shade200),
              ),
              child: RadioListTile<String>(
                title: Row(children: [
                  Text(opt['icon']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Text(opt['label']!,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
                value:       opt['value']!,
                groupValue:  _selectedSort,
                activeColor: Colors.green,
                onChanged: (v) => setState(() => _selectedSort = v!),
              ),
            )).toList(),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _priceRange   = const RangeValues(0, 50);
                        _selectedSort = 'createdAt_DESC';
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Colors.green),
                    ),
                    child: const Text('Reset',
                      style: TextStyle(color: Colors.green, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon:  const Icon(Icons.check),
                    label: const Text('Apply Filters',
                      style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () {
                      widget.onApply(
                        _priceRange.start,
                        _priceRange.end,
                        _selectedSort,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

