import '../models/address_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final ApiService _api = ApiService();

  Future<List<AddressModel>> getAddresses() async {
    final result = await _api.get(ApiConstants.addresses);
    if (result['success'] == true) {
      final list = result['data']['addresses'] as List;
      return list.map((a) => AddressModel.fromJson(a)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> addAddress(AddressModel address) async {
    return await _api.post(ApiConstants.addresses, address.toJson());
  }

  Future<Map<String, dynamic>> updateAddress(
    String id, AddressModel address) async {
    return await _api.put('${ApiConstants.addresses}/$id', address.toJson());
  }

  Future<Map<String, dynamic>> deleteAddress(String id) async {
    return await _api.delete('${ApiConstants.addresses}/$id');
  }
}


