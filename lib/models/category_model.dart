class CategoryModel {
  final String  id;
  final String  name;
  final String  description;
  final String? image;
  final String  icon;
  final bool    isActive;
  final int     sortOrder;
  final int?    productCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.icon,
    required this.isActive,
    required this.sortOrder,
    this.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id:           json['id']           ?? '',
    name:         json['name']         ?? '',
    description:  json['description']  ?? '',
    image:        json['image'],
    icon:         json['icon']         ?? '🛒',
    isActive:     json['isActive']     ?? true,
    sortOrder:    json['sortOrder']    ?? 0,
    productCount: json['productCount'],
  );
}
