class AddressModel {
  final String  id;
  final String  label;
  final String  name;
  final String  phone;
  final String  line1;
  final String  line2;
  final String  city;
  final String  state;
  final String  pincode;
  final String  country;
  final bool    isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.isDefault = false,
  });

  String get fullAddress {
    final parts = [line1];
    if (line2.isNotEmpty) parts.add(line2);
    parts.addAll([city, state, pincode]);
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id:        json['id']         ?? '',
    label:     json['label']      ?? 'Home',
    name:      json['name']       ?? '',
    phone:     json['phone']      ?? '',
    line1:     json['line1']      ?? '',
    line2:     json['line2']      ?? '',
    city:      json['city']       ?? '',
    state:     json['state']      ?? '',
    pincode:   json['pincode']    ?? '',
    country:   json['country']    ?? 'India',
    isDefault: json['isDefault']  ?? false,
  );

  Map<String, dynamic> toJson() => {
    'label':     label,
    'name':      name,
    'phone':     phone,
    'line1':     line1,
    'line2':     line2,
    'city':      city,
    'state':     state,
    'pincode':   pincode,
    'country':   country,
    'isDefault': isDefault,
  };
}


