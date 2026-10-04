import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BillHeaderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      // The SVG will automatically scale to fit this container
      child: SvgPicture.asset(
        'assets/icons/bill_aesthetic.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}