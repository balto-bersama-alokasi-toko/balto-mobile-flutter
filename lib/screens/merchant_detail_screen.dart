import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/merchant_detail_provider.dart';


class MerchantDetailScreen extends StatefulWidget {
  final int merchantId;

  MerchantDetailScreen({required this.merchantId});

  @override
  _MerchantDetailScreenState createState() => _MerchantDetailScreenState();
}

class _MerchantDetailScreenState extends State<MerchantDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final merchantDetailProvider = Provider.of<MerchantDetailProvider>(context, listen: false);
      merchantDetailProvider.fetchMerchantDetail(widget.merchantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final merchantDetailProvider = Provider.of<MerchantDetailProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail UMKM'),
      ),
      body: Stack(
        children: [
          merchantDetailProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : merchantDetailProvider.merchantDetail.isEmpty
              ? Center(child: Text('No data available'))
              : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: merchantDetailProvider.merchantDetail['merchant_photo'] != null
                            ? FadeInImage.assetNetwork(
                          placeholder: 'assets/img/placeholderimg.png',
                          image: merchantDetailProvider.merchantDetail['merchant_photo'],
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context,error,stackTrace) {
                            return Image.asset(
                              'assets/img/pchmerchant.jpg',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : Image.asset(
                          'assets/img/pchmerchant.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      merchantDetailProvider.merchantDetail['merchant_name'],
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16, left: 16),
                    child: Text(
                      merchantDetailProvider.merchantDetail['merchant_address'],
                      style: TextStyle(
                        color: Color(0xff6b7280)
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(right: 16, left: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff082f49),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                        child: Text(
                          merchantDetailProvider.merchantDetail['merchant_category'],
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Rating
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(child: Row(
                          children: [
                            Icon(Icons.star_rounded),
                            const SizedBox(width: 4),
                            Text(
                              merchantDetailProvider.merchantDetail['merchant_review_point'].toString(),
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("(" + merchantDetailProvider.merchantDetail['merchant_review_count'].toString() + " ulasan )")
                          ],
                        )),
                        InkWell(
                          onTap: () {

                          },
                          child: Text(
                            'Lihat Semua Review',
                            style: TextStyle(
                              color: Colors.blue
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (merchantDetailProvider.merchantDetail['merchant_reviews'] ?? []).length,
                      itemBuilder: (context, index) {
                        final review = merchantDetailProvider.merchantDetail['merchant_reviews'][index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: index == 0 ? 16 : 4,
                            right: index == merchantDetailProvider.merchantDetail['merchant_reviews'].length - 1 ? 16: 0
                          ),
                          child: Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(color: Color(0xffe2e8f0), width: 1)
                            ),
                            child: Container(
                              padding: EdgeInsets.only(left: 12,right: 16,top: 12,bottom: 12),
                              width: 320,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/img/usericontemp.png',
                                      width:48,
                                      height: 48,
                                    ),
                                  ),
                                  Expanded(
                                      child:Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child:  Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                              Text(review['user_review_name']?.isNotEmpty == true ? review['user_review_name'] : 'someone'),
                                            const SizedBox(height: 8),
                                            Text(
                                              review['user_review_content']?.isNotEmpty == true? review['user_review_content'] : 'no text review',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                        'Jam Buka',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: (merchantDetailProvider.merchantDetail['merchant_opening_hour'] ?? []).length,
                    itemBuilder: (context, index) {
                      final hour = merchantDetailProvider.merchantDetail['merchant_opening_hour'][index];
                      final time_cleansing = hour['time_desc'].replaceAll(RegExp(r'\s+'), ' ');
                      return ListTile(
                        title: Text(time_cleansing ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(
                      'Informasi Kontak',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.language_rounded),
                              const SizedBox(width: 8),
                              Expanded(child: Text(
                                merchantDetailProvider.merchantDetail['merchant_site']?.isNotEmpty ?  merchantDetailProvider.merchantDetail['merchant_site'] : 'Belum ada data',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ))
                              // Text(review['user_review_name']?.isNotEmpty == true ? review['user_review_name'] : 'someone'),
                            ],
                          )
                        ),
                        const SizedBox(width: 8),
                        merchantDetailProvider.merchantDetail['merchant_site']?.isNotEmpty == true
                            ? InkWell(
                              onTap: () {
                                final urlSiteMerchant = Uri.parse(merchantDetailProvider.merchantDetail['merchant_site']);
                                launchUrl(urlSiteMerchant);
                              },
                              child: Icon(
                                Icons.link,
                                color: Colors.blue,
                              ),
                            )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.call),
                                const SizedBox(width: 8),
                                Text(
                                  merchantDetailProvider.merchantDetail['merchant_phone']?.isNotEmpty ?  merchantDetailProvider.merchantDetail['merchant_phone'] : 'Belum ada data',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Text(review['user_review_name']?.isNotEmpty == true ? review['user_review_name'] : 'someone'),
                              ],
                            )
                        ),
                        const SizedBox(width: 12),
                        merchantDetailProvider.merchantDetail['merchant_phone']?.isNotEmpty == true
                            ? InkWell(
                          onTap: () {
                            final Uri phoneNumber = Uri(scheme: 'tel', path: merchantDetailProvider.merchantDetail['merchant_phone'] );
                            launchUrl(phoneNumber);
                          },
                          child: Icon(
                            Icons.arrow_outward,
                            color: Colors.blue,
                          ),
                        )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  merchantDetailProvider.merchantDetail['merchant_phone']?.isNotEmpty == true
                    ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style:ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(vertical: 16)
                        ) ,
                        onPressed: () {
                          final Uri phoneNumber = Uri.parse('https://wa.me/${merchantDetailProvider.merchantDetail['merchant_phone']}');
                          launchUrl(phoneNumber);
                        },
                        child: Text('Kirim Pesan Kerja Sama'),
                      ),
                    ),
                  )
                    : SizedBox.shrink()
                ],
              ),
          ),
          if (merchantDetailProvider.isLoading)
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
