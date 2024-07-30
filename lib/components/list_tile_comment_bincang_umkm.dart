import 'package:flutter/cupertino.dart';

class ListTileCommentBincangUmkm extends StatelessWidget {
  final Widget leadingContent;
  final Widget titleContent;
  final Widget subtitleContent;

  ListTileCommentBincangUmkm({
    required this.leadingContent,
    required this.titleContent,
    required this.subtitleContent, p
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  subtitleContent
                ],
              )
          )
        ],
      ),
    );
  }
}