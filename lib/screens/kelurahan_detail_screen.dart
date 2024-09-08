///
/// Screen to show detail of kelurahan
/// about location UMKM prediction


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/kelurahan_detail_provider.dart';
import 'merchant_detail_screen.dart';


class KelurahanDetailScreen extends StatefulWidget {
  final String kelurahanName;
  final double kelurahanRating;
  final int kelurahanPopulation;
  final double kelurahanTransaction;

  KelurahanDetailScreen({
    required this.kelurahanName,
    required this.kelurahanRating,
    required this.kelurahanPopulation,
    required this.kelurahanTransaction,
  });

  @override
  State<KelurahanDetailScreen> createState() => _KelurahanDetailScreenState();
}

class _KelurahanDetailScreenState extends State<KelurahanDetailScreen> {

  String? selectedCategory;

  String formatNumber(int number) {
    final formatter = NumberFormat.decimalPattern('id');
    return formatter.format(number);
  }

  String formatNumberTransaksi(String numberString) {
    // Konversi dari string ke double
    double number = double.parse(numberString);
    double absoluteNumber = number.abs();
    // Inisialisasi formatter untuk format angka dengan pemisah ribuan sesuai locale Indonesia
    final formatter = NumberFormat.decimalPattern('id');

    // Memformat angka
    return formatter.format(absoluteNumber);
  }

  List<dynamic> get filteredMerchants {
    final kelurahanDetailProvider = Provider.of<KelurahanDetailProvider>(context);
    final merchants = kelurahanDetailProvider.kelurahanDetail['kesuluran_merchants'] ?? [];
    if (selectedCategory == null) {
      return merchants;
    }
    return merchants.where((merchant) => merchant['merchant_category'] == selectedCategory).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final kelurahanDetailProvider = Provider.of<KelurahanDetailProvider>(context);
    final merchants = kelurahanDetailProvider.kelurahanDetail['kesuluran_merchants'] ?? [];
    final categories = merchants.map((merchant) => merchant['merchant_category']).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Kelurahan Star Location'),
        actions: [
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('On Developmet'))
                );
              },
              icon: Icon(Icons.bookmark_border_outlined)
          )
        ],
      ),
      body: kelurahanDetailProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: kelurahanDetailProvider.kelurahanDetail['kelurahan_photo'] != null
                      ? FadeInImage.assetNetwork(
                    placeholder: 'assets/img/placeholderimg.png',
                    image: kelurahanDetailProvider.kelurahanDetail['kelurahan_photo'],
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context,error,stackTrace) {
                      return Image.asset(
                        'assets/img/tangsel.jpg',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/img/tangsel.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  height:  MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.0)
                          ]
                      )
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
              child: Text(
                  '${widget.kelurahanName}',
                  style: TextStyle(
                    fontSize: 20
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16,top: 8),
              child: (
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('Penduduk: ${widget.kelurahanPopulation}'),
                        ],
                      )
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.storefront,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text('UMKM sekitar: ' + kelurahanDetailProvider.kelurahanDetail['kelurahan_merchant_count'].toString()),
                          ],
                        )
                    ),
                  ],
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16,right: 16, top: 8 ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Color(0xffe2e8f0), width: 1)
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 12, bottom: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Skor Lokasi'),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.info_rounded,
                                          size: 20,
                                        )
                                      )
                                    ],
                                  ),
                                  Text(
                                    '${widget.kelurahanRating.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 20
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                      ),
                      SizedBox(width: 8),
                      Expanded(
                          child: Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Color(0xffe2e8f0), width: 1)
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 12, bottom: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Est. Pendapatan'),
                                      IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.info_rounded,
                                            size: 20,
                                          )
                                      )
                                    ],
                                  ),
                                  Text(
                                    'Rp ' + formatNumberTransaksi(widget.kelurahanTransaction.toInt().toString()),
                                    // 'Rp ' + formatNumber(int.parse(widget.kelurahanTransaction.toString())),
                                    style: TextStyle(
                                      fontSize: 20
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height:12),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xffdbeafe),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 8, right: 8,top: 12, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: Color(0xff082f49),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(
                              'Paling laris disekitar sini',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff082f49)
                              ),
                            ),)
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: (kelurahanDetailProvider.kelurahanDetail['top_merchants'] ?? []).length,
                        itemBuilder: (context, index) {
                          final merchant = kelurahanDetailProvider.kelurahanDetail['top_merchants'][index];
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MerchantDetailScreen(merchantId: merchant['merchant_id']),
                                ),
                              );
                            },
                            title: Text(merchant['merchant_name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xff082f49),
                                        borderRadius: BorderRadius.circular(4)
                                    ) ,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12,right: 12,top: 8,bottom: 8),
                                      child: Text (
                                        merchant['merchant_category'],
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      ),
                                    )
                                  )
                                )
                              ],
                            ),
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
                                              'assets/img/pchmerchant.jpg',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                      )
                                      :
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundImage:
                                        AssetImage('assets/img/placeholderimg.png'),
                                      )
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ),
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(top: 0, left: 16),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('On development'))
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/img/logomaps.png',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 8),
                    Text('Buka di maps')
                  ],
                ),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    )
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
              child: Text(
                  'UMKM Sekitar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  )
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:16, right: 4),
                    child: ChoiceChip(
                      label: Text('All'),
                      selected: selectedCategory == null,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = null;
                        });
                      },
                    ),
                  ),
                  ...categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? category : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredMerchants.length,
              itemBuilder: (context, index) {
                final merchant = filteredMerchants[index];
                return Padding(
                  padding: EdgeInsets.only( left: 0, right: 0),
                  child: ListTile(
                    title: Text(merchant['merchant_name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${merchant['merchant_category']}'),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Color(0xfff59e0b),
                            ),
                            const SizedBox(width: 4),
                            Text(merchant['merchant_rating'].toString())
                          ],
                        )
                      ],
                    ),
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
                            return Text(
                              // error.toString(),
                              'error',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            );
                          },
                        )
                            :
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage:
                          AssetImage('assets/img/placeholderimg.png'),
                        )
                    ),
                    trailing: merchant['merchant_phone'] != null && merchant['merchant_phone'].isNotEmpty
                        ? GestureDetector(
                          onTap: () {
                            final Uri phoneNumber = Uri.parse('https://wa.me/${merchant['merchant_phone']}');
                            launchUrl(phoneNumber);
                          },
                          child: Image.asset(
                            'assets/img/whatsappicon.png',
                            width: 24,
                            height: 24,
                          ),
                        )
                        : null,
                    onTap: () {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text(merchant['merchant_id'].toString()))
                      // );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MerchantDetailScreen(merchantId: merchant['merchant_id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
