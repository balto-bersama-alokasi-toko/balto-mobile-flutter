import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/merchant_category_provider.dart';
import 'merchant_detail_screen.dart';

class MerchantCategoryScreen extends StatefulWidget {
  final String category;

  MerchantCategoryScreen({required this.category});

  @override
  _MerchantCategoryScreenState createState() => _MerchantCategoryScreenState();
}

class _MerchantCategoryScreenState extends State<MerchantCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final merchantCategoryProvider = Provider.of<MerchantCategoryProvider>(context, listen: false);
      merchantCategoryProvider.fetchMerchantsByCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final merchantCategoryProvider = Provider.of<MerchantCategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant Kategori: ${widget.category}'),
      ),
      body: Stack(
        children: [
          merchantCategoryProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : merchantCategoryProvider.merchants.isEmpty
              ? Center(child: Text('No data available'))
              : ListView.builder(
            itemCount: merchantCategoryProvider.merchants.length,
            itemBuilder: (context, index) {
              final merchant = merchantCategoryProvider.merchants[index];
              return ListTile(
                title: Text(merchant['merchant_name']),
                subtitle: Text(merchant['merchant_kelurahan_name']),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: merchant['merchant_photo'] != null && merchant['merchant_photo'].isNotEmpty
                    ? FadeInImage.assetNetwork(
                      width: 48,
                      height: 48,
                      placeholder: 'assets/img/placeholderimg.png',
                      image: merchant['merchant_photo'],
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          width: 48,
                          height: 48,
                          'assets/img/pchmerchant.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                      )
                    : const CircleAvatar(
                    radius: 24,
                    backgroundImage:
                    AssetImage('assets/img/placeholderimg.png'),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MerchantDetailScreen(merchantId: merchant['merchant_id']),
                    ),
                  );
                },
              );
            },
          ),
          if (merchantCategoryProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
