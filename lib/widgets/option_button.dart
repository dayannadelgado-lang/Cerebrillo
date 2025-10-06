// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class OptionButton extends StatefulWidget {
  final String text;
  final String imagePath;
  final VoidCallback onTap;
  final bool isSelected;
  final Color backgroundColor;
  final double borderRadius;
  final Color textColor;

  const OptionButton({
    super.key,
    required this.text,
    required this.imagePath,
    required this.onTap,
    required this.isSelected,
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 0.3),
    this.borderRadius = 20,
    this.textColor = Colors.white,
  });

  @override
  State<OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _animController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _animController.reverse();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.isSelected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(2, 3),
                  ),
                  if (widget.isSelected)
                    BoxShadow(
                      color: const Color.fromARGB(255, 225, 191, 251).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(widget.imagePath, width: 40, height: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                        shadows: widget.isSelected
                            ? [
                                Shadow(
                                  color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
                  if (widget.isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
