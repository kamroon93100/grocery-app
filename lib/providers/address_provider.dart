import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service = AddressService();

  List<AddressModel> _addresses = [];
  bool               _loading   = false;
  AddressModel?      _selected;

  List<AddressModel> get addresses => _addresses;
  bool               get loading   => _loading;
  AddressModel?      get selected  => _selected;

  AddressModel? get defaultAddress {
    if (_addresses.isEmpty) return null;
    return _addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => _addresses.first,
    );
  }

  Future<void> loadAddresses() async {
    _loading = true;
    notifyListeners();
    _addresses = await _service.getAddresses();
    if (_selected == null && _addresses.isNotEmpty) {
      _selected = defaultAddress;
    }
    _loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> addAddress(AddressModel address) async {
    final result = await _service.addAddress(address);
    if (result['success'] == true) {
      await loadAddresses();
    }
    return result;
  }

  Future<Map<String, dynamic>> updateAddress(
    String id, AddressModel address) async {
    final result = await _service.updateAddress(id, address);
    if (result['success'] == true) {
      await loadAddresses();
    }
    return result;
  }

  Future<Map<String, dynamic>> deleteAddress(String id) async {
    final result = await _service.deleteAddress(id);
    if (result['success'] == true) {
      await loadAddresses();
    }
    return result;
  }

  void selectAddress(AddressModel address) {
    _selected = address;
    notifyListeners();
  }
}

