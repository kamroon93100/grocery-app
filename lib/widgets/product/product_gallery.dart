import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';

class ProductGallery extends StatefulWidget {
  final ProductModel product;

  const ProductGallery({
    super.key,
    required this.product,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images.isNotEmpty
        ? widget.product.images
        : [widget.product.displayImage];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) {
                final img = images[i];

                return Hero(
                  tag: 'product_${widget.product.id}',
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: img.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: img,
                            fit: BoxFit.contain,
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.image, size: 80),
                          )
                        : Center(
                            child: Text(
                              img,
                              style: const TextStyle(fontSize: 90),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 7,
                    width: _index == i ? 20 : 7,
                    decoration: BoxDecoration(
                      color: _index == i
                          ? const Color(0xff0c8f43)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
