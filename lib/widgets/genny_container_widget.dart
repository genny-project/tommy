import 'package:flutter/material.dart';
class GennyContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  const GennyContainer({required this.child, this.width, this.height, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[350],
        border: Border.all(color: Colors.black, width: 4.0)
        // color: Color.fromARGB(255, Random().nextInt(255), Random().nextInt(255), Random().nextInt(255)),
      ),
      width: width,
      height: height,
      child: child,
    );
  }
}
