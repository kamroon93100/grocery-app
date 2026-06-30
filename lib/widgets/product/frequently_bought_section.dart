import 'package:flutter/material.dart';
import '../../models/product_model.dart';

class FrequentlyBoughtSection extends StatelessWidget {
  final List<ProductModel> products;

  const FrequentlyBoughtSection({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    final items = products.take(6).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20,20,20,8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Frequently Bought Together",
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
              itemCount:items.length,
              separatorBuilder:(_,__)=>const SizedBox(width:14),
              itemBuilder:(context,index){

                final p=items[index];

                return Container(
                  width:150,
                  decoration:BoxDecoration(
                    color:Colors.white,
                    borderRadius:BorderRadius.circular(18),
                    boxShadow:[
                      BoxShadow(
                        color:Colors.black.withOpacity(.05),
                        blurRadius:10,
                        offset:const Offset(0,4),
                      )
                    ],
                  ),
                  child:Padding(
                    padding:const EdgeInsets.all(12),
                    child:Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children:[

                        Expanded(
                          child:Center(
                            child:Image.network(
                              p.displayImage,
                              fit:BoxFit.contain,
                              errorBuilder:(_,__,___)=>const Icon(Icons.image,size:60),
                            ),
                          ),
                        ),

                        Text(
                          p.name,
                          maxLines:2,
                          overflow:TextOverflow.ellipsis,
                          style:const TextStyle(
                            fontWeight:FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height:6),

                        Text(
                          p.unit,
                          style:const TextStyle(
                            color:Colors.grey,
                            fontSize:12,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          "₹${p.finalPrice.toStringAsFixed(0)}",
                          style:const TextStyle(
                            fontSize:18,
                            fontWeight:FontWeight.w900,
                          ),
                        ),
                      ],
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


