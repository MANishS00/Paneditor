import 'package:flutter/material.dart';

const ktextstyle = TextStyle(
  fontSize: 20,
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

class Button extends StatefulWidget {
  final VoidCallback ontap;
  final String text;
  final IconData? icons;

  const Button({super.key, required this.ontap, required this.text, this.icons});

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.ontap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          width: 120,
          decoration: BoxDecoration(
            gradient: _isHovered
                ? const LinearGradient(colors: [Colors.teal, Colors.blue])
                : const LinearGradient(colors: [Colors.blue, Colors.teal]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovered
                ? [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.text, style: ktextstyle),
              if (widget.icons != null)
                Icon(
                  widget.icons,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
