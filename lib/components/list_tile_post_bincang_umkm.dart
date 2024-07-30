import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListTilePostBincangUmkm extends StatelessWidget {
  final Widget leadingContent;
  final Widget titleContent;
  final Widget subtitleContent;
  final VoidCallback? onTap;

  ListTilePostBincangUmkm({
    required this.leadingContent,
    required this.titleContent,
    required this.subtitleContent,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: leadingContent,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleContent,
                  const SizedBox(height: 8),
                  subtitleContent
                ],
              )
            )
          ],
        ),
      ),
    );
  }

}