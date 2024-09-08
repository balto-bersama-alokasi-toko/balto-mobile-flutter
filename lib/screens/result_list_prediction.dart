import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/kelurahan_detail_provider.dart';
import 'kelurahan_detail_screen.dart';

class ResultPredictionListScreen extends StatefulWidget {
  final List<dynamic> locations;
  final String? businessType;
  final String? businessNote;
  final String? monthlyIncomeTarget;
  final String? preferredPublicPlace;

  ResultPredictionListScreen({
    required this.locations,
    this.businessType,
    this.businessNote,
    this.monthlyIncomeTarget,
    this.preferredPublicPlace
  });

  @override
  State<ResultPredictionListScreen> createState() => _ResultPredictionListScreenState();
}

class _ResultPredictionListScreenState extends State<ResultPredictionListScreen> {

  bool _isLoading = false;

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

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }


  Future<void> _navigateToDetail(
      int kelurahanId,
      String kelurahanName,
      double kelurahanRating,
      int kelurahanPopulation,
      double kelurahanTransaction,
  ) async {
    _showLoading();
    final kelurahanDetailProvider = Provider.of<KelurahanDetailProvider>(context, listen: false);
    await kelurahanDetailProvider.fetchKelurahanDetail(kelurahanId);
    _hideLoading();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KelurahanDetailScreen(
          kelurahanName: kelurahanName,
          kelurahanRating: kelurahanRating,
          kelurahanPopulation: kelurahanPopulation,
          kelurahanTransaction: kelurahanTransaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star Location Prediction'),
        actions: [
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('On Development'))
                );
              }, 
              icon: Icon(Icons.map)
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/tangsel.jpg'),
                          fit: BoxFit.cover
                        ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serpong, Tangerang Selatan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.storefront,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${widget.businessType}',
                                        style: TextStyle(
                                            color: Colors.white
                                        ),
                                      ),
                                      Text(
                                          '${widget.businessNote} ',
                                          style: TextStyle(
                                              color: Colors.white
                                          )
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 4),
                            // Text('Target Pendapatan per Bulan: ${widget.monthlyIncomeTarget}'),
                            // Text('Preferensi Tempat: ${widget.preferredPublicPlace}'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.locations.length,
                  itemBuilder: (context, index) {
                    List<dynamic> sortedLocations = List.from(widget.locations);
                    sortedLocations.sort((a, b) => (b['kelurahan_rating']).compareTo(a['kelurahan_rating']));
                    // final location = widget.locations[index];
                    final location = sortedLocations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xffdbeafe),
                        child: Icon(
                          Icons.share_location_outlined,
                          size: 24,
                        ),
                      ),
                      title: Text(location['kelurahan_name']),
                      subtitle: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star_rate_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(child: Text('${location['kelurahan_rating'].toStringAsFixed(2)}')),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.account_balance_wallet,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              // Expanded(child: Text('Rp ' + formatNumber(int.parse(location['kelurahan_transaksi'].toString()))))
                              Expanded(child: Text('Rp ' + formatNumberTransaksi(location['kelurahan_transaksi'].toInt().toString())))
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.people,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(child: Text( formatNumber(int.parse(location['kelurahan_population'].toString())) + ' penduduk'))
                            ],
                          )
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.bookmark_border_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('On Development'),)
                          );
                        },
                      ),
                      onTap: () async {
                        _navigateToDetail(
                          location['kelurahan_id'],
                          location['kelurahan_name'],
                          location['kelurahan_rating'],
                          location['kelurahan_population'],
                          location['kelurahan_transaksi'] ,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )
    );
  }
}
