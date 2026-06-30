import 'package:flutter/material.dart';

class CouponCard extends StatelessWidget {
  final String? coupon;
  final VoidCallback onApply;

  const CouponCard({
    super.key,
    required this.coupon,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16,0,16,16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0,4),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xff0c8f43).withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xff0c8f43),
            ),
          ),

          const SizedBox(width:16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Coupons & Offers",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize:16,
                  ),
                ),

                const SizedBox(height:4),

                Text(
                  coupon == null
                      ? "Apply coupon to save more"
                      : "Applied: $coupon",
                  style: TextStyle(
                    color: coupon == null
                        ? Colors.grey
                        : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          FilledButton(
            onPressed: onApply,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xff0c8f43),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              coupon == null ? "Apply" : "Change",
            ),
          ),
        ],
      ),
    );
  }
}

