import 'package:flutter/material.dart';
import '../services/location_service.dart';


class LocationPermissionSheet {

  /// Show on app open (like Instamart)
  static Future<LocationResult?> requestOnAppOpen(BuildContext context) async {
    final result = await LocationService().getCurrentLocation();

    if (result.success) return result;

    // Show bottom permission dialog like Instamart
    if (!context.mounted) return null;

    final userAction = await showModalBottomSheet<String>(
      context:         context,
      isDismissible:   false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PermissionBottomSheet(
        errorType: result.errorType ?? LocationErrorType.permissionDenied,
      ),
    );

    if (userAction == 'grant') {
      if (result.errorType == LocationErrorType.serviceDisabled) {
        await LocationService().openLocationSettings();
      } else {
        // Try again after user grants
        await Future.delayed(const Duration(seconds: 1));
        return await LocationService().getCurrentLocation();
      }
    }

    return null;
  }

  /// Blue banner at bottom (like Instamart location off)
  static Widget locationOffBanner(BuildContext context, {
    required VoidCallback onGrant,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFF2962FF),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.my_location, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Location Permission is Off',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                      Text('Granting location permission will ensure accurate address and hassle free delivery',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: onGrant,
                  child: const Text('GRANT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionBottomSheet extends StatelessWidget {
  final LocationErrorType errorType;
  const _PermissionBottomSheet({required this.errorType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('For a better experience,\nyour device will need to use\nLocation Accuracy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3)),
            const SizedBox(height: 20),
            const Text('The following settings should be on:',
              style: TextStyle(
                color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_outlined,
                    color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Device location',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.my_location,
                    color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Location Accuracy, which provides more accurate location for apps and services.',
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'You can change this at any time in location settings.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white60),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => Navigator.pop(context, 'cancel'),
                    child: const Text('No, thanks',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context, 'grant'),
                    child: const Text('Turn on',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
