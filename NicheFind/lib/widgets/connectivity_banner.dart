import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _offline = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final initial = await Connectivity().checkConnectivity();
    if(mounted) setState(() => _offline = _isOffline(initial));
    
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      if(mounted) setState(() => _offline = _isOffline(results));
    });
  }

  bool _isOffline(List<ConnectivityResult> results) {
    if(results.isEmpty) return true;
    return results.every((r) => r == ConnectivityResult.none);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_offline)
          Material(
            color: Colors.red.shade700,
            child: SafeArea(
              bottom: false,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18,),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "You're offline. Niche suggestions need an internet connection.",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: widget.child)
      ],
    );
  }
}