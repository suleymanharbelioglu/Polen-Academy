import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Uygulama üst kısmında, internet yokken görünen uyarı şeridi.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final results = snapshot.data!;
        final isOffline = results.isEmpty ||
            results.every((r) => r == ConnectivityResult.none);
        if (!isOffline) return const SizedBox.shrink();
        return Material(
          elevation: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: Colors.orange.shade800,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'İnternet bağlantısı yok. Bazı işlemler çalışmayabilir.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
