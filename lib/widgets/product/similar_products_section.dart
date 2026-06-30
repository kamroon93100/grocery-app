import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class SimilarProductsSection extends StatelessWidget {
  final List<ProductModel> products;
  final void Function(ProductModel)? onTap;

  const SimilarProductsSection({
    super.key,
    required this.products,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20,20,20,20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Similar Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height:16),

          SizedBox(
            height:250,
            child:ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length > 8 ? 8 : products.length,
              separatorBuilder: (_,__) => const SizedBox(width:14),
              itemBuilder:(context,index){

                final p = products[index];

                return GestureDetector(
                  onTap: () => onTap?.call(p),
                  child: Container(
                    width:150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0,4),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Expanded(
                            child: Center(
                              child: Image.network(
                                p.displayImage,
                                fit: BoxFit.contain,
                                errorBuilder: (_,__,___) =>
                                  const Icon(Icons.image,size:60),
                              ),
                            ),
                          ),

                          Text(
                            p.name,
                            maxLines:2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height:6),

                          Text(
                            p.unit,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize:12,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "₹${p.finalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize:18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


