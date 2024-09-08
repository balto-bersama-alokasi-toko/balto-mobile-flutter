import 'package:flutter/material.dart';


class CardUmkmCategoryAround extends StatelessWidget {
  final VoidCallback onTap;
  final String imagePath;
  final String title;

  CardUmkmCategoryAround({
    required this.onTap,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Color(0xffe2e8f0), width: 1)
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.0),
              Image.asset(
                imagePath,
                width: 40.0,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
