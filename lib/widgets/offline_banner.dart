import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../constants/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: connectivity.isOnline ? 0 : 44,
              child: connectivity.isOnline
              ? const SizedBox.shrink()
                      : const MaterialBanner(
                      padding: EdgeInsets.zero,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text('You are offline',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      actions: const [SizedBox.shrink()],
                    ),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}


