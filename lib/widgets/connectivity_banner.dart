import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shop_provider.dart';

/// Connectivity banner that shows online/offline status
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final status = shop.connectivityStatus;
    final colors = Theme.of(context).colorScheme;

    // Don't show anything when online
    if (status == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String message;

    if (status == ConnectivityStatus.offline) {
      backgroundColor = colors.error.withValues(alpha: 0.1);
      textColor = colors.error;
      icon = Icons.cloud_off_rounded;
      message = 'You are offline. Showing cached data.';
    } else {
      // Restored status
      backgroundColor = colors.primary.withValues(alpha: 0.1);
      textColor = colors.primary;
      icon = Icons.cloud_done_rounded;
      message = 'Connection restored! Data refreshed.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: textColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (status == ConnectivityStatus.offline)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'OFFLINE',
                style: TextStyle(
                  fontSize: 10,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small connectivity indicator for app bar
class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = Provider.of<ShopProvider>(context);
    final isOnline = shop.isOnline;
    final colors = Theme.of(context).colorScheme;

    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Offline Mode - Showing cached data',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 14, color: colors.error),
            const SizedBox(width: 4),
            Text(
              'OFFLINE',
              style: TextStyle(
                fontSize: 10,
                color: colors.error,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
