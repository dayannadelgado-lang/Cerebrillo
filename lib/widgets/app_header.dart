import 'package:flutter/material.dart';
import 'dart:async';

class AppHeader extends StatefulWidget {
  final String title;
  const AppHeader({super.key, required this.title});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String _time = '';

  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    setState(() => _time = '$hh:$mm');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(_time, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const Spacer(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined)),
      ],
    );
  }
}
