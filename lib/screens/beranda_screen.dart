import 'package:balto/components/card_umkm_category_around.dart';
import 'package:balto/providers/location_around_provider.dart';
import 'package:balto/providers/location_prediction_provider.dart';
import 'package:balto/screens/result_list_prediction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'merchant_category.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationAroundProvider>(context, listen: false).fetchLocations(selectedFilter);
    });
    _controllerMontylyTargetIncome.addListener(_formatMonthlyIncome);
  }

  void _formatMonthlyIncome() {
    final value = _controllerMontylyTargetIncome.text;
    if (value.isEmpty) return;

    final newValue = value.replaceAll('.', '');
    if (int.tryParse(newValue) != null) {
      _controllerMontylyTargetIncome.removeListener(_formatMonthlyIncome);
      final formattedValue = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(int.parse(newValue));
      _controllerMontylyTargetIncome.value = TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
      _controllerMontylyTargetIncome.addListener(_formatMonthlyIncome);
    }
  }

  @override
  void dispose() {
    _controllerMontylyTargetIncome.dispose();
    super.dispose();
  }


  final List<String> filters = ['Market', 'Mall', 'Transportation Hub', 'Gas/SPBU', 'Residences', 'Mosques', 'Churches', 'Medical Services', 'Temporary Accomodations', 'Parks', 'Academic Institutions', 'Unclassified', 'Offices', 'Tourist'];
  String selectedFilter = 'Market';


  String? businessType;
  String? businessNote;
  String? monthlyIncomeTarget;
  String? preferredPublicPlace;
  TextEditingController _controllerMontylyTargetIncome = TextEditingController();

  final Map<String, List<String>> businessOptions = {
    'Makanan & Minuman': ['Kafe & Minuman', 'Restoran Umum', 'Warung', 'Roti, Kue, dan Cemilan lainnya', 'Regional'],
    'Barang Sehari-hari': ['Retail', 'Apotek & Produk Kesehatan lainnya'],
    'Jasa' : ['Printing', 'Photo', 'Jasa', 'Otomotif', 'Kosmetik', 'Kebersihan'],
    'Entertainment': ['Olahraga', 'Entertainment'],
    'Peralatan dan Perlengkapan Jangka Panjang' : ['Peralatan & Barang Elektronik', 'Materials', 'Optician', 'Clothing'],
    'Others' : ['Properti']
  };

  List<String> get businessNotes {
    if (businessType != null) {
      return businessOptions[businessType!]!;
    } else {
      return businessOptions.values.expand((notes) => notes).toSet().toList();
    }
  }

  final List<String> incomeTargets = ['< Rp10.000.000', 'Rp10.000.000 - Rp50.000.000', 'Rp50.000.000 - 200.000.000', '>200.000.000'];
  final List<String> publicPlaces = ['Supermarket/Minimarket', 'Mall', 'Transportasi', 'Stasiun KRL', 'Stasiun MRT/LRT', 'Terminal bus', 'SPBU', 'Taman', 'Masjid', 'Gereja', 'Sekolah', 'Rumah Sakit', 'Komunitas', 'Perumahan/Komplek', 'Hotel', 'Kantor'];

  void showBottomSheetOptions(BuildContext context, List<String> options, String fieldType,{String? title, String? subtitle}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
              maxChildSize: 0.88,
              minChildSize: 0.3,
              expand: false,
              builder: (BuildContext context, ScrollController scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            title,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            subtitle,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Color(0xffdbeafe),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'Pilihan ini akan membantu kami menyesuaikan layanan dan informasi yang lebih relevan untuk Anda',
                          style: TextStyle(
                              color: Color(0xff0c4a6e),
                              fontSize: 14.0
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(options[index]),
                              onTap: () {
                                setState(() {
                                  if (fieldType == 'businessType') {
                                    businessType = options[index];
                                    businessNote = null;
                                  } else if (fieldType == 'businessNote') {
                                    businessNote = options[index];
                                    businessType = businessOptions.entries.firstWhere(
                                          (entry) => entry.value.contains(options[index]),
                                    ).key;
                                  } else if (fieldType == 'monthlyIncomeTarget') {
                                    monthlyIncomeTarget = options[index];
                                  } else if (fieldType == 'preferredPublicPlace') {
                                    preferredPublicPlace = options[index];
                                  }
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  void showMonthlyIncomeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Wrap(
            children: [
              Text(
                'Target Pendapatan per bulan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _controllerMontylyTargetIncome,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  setState(() {
                    monthlyIncomeTarget = value;
                  });
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value.replaceAll('.', '')) == null) {
                    return 'Masukkan jumlah yang benar';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Masukkan pendapatan bulanan',
                  prefixIcon: Icon(Icons.wallet),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }



  void _submitData() async {
    final data = {
      'kategori': businessType ?? '',
      'sub_kategori': businessNote ?? '',
      'target_penghasilan': monthlyIncomeTarget ?? '',
    };

    final locationProvider = Provider.of<LocationPredictionProvider>(context, listen: false);
    await locationProvider.fetchPredictionLocations(data);

    if (!locationProvider.isLoading) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPredictionListScreen(
              locations: locationProvider.locations,
              businessType: businessType,
              businessNote: businessNote,
              monthlyIncomeTarget: monthlyIncomeTarget,
              preferredPublicPlace: preferredPublicPlace,
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    final locationAroundProvider = Provider.of<LocationAroundProvider>(context);
    final locationPredictionProvider = Provider.of<LocationPredictionProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background SVG Images
          Positioned(
            child: SvgPicture.asset(
              'assets/img/greenbg.svg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: SvgPicture.asset(
              'assets/img/bluebg.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Main Content
          SingleChildScrollView(
            child: Column(
              children: [
                // SafeArea for AppBar content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24, right: 12, top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'assets/img/completewhitebalto.svg',
                          height: 40,
                        ),
                        IconButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('On development'))
                            );
                          },
                          icon: Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Color(0xffe2e8f0), width: 1)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        children: [
                          TextField(
                            enabled: false,
                            decoration: InputDecoration(
                                hintText: 'Serpong, Tangerang Selatan',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.share_location_rounded),
                                border: OutlineInputBorder()
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Business input
                          GestureDetector(
                            onTap: () => showBottomSheetOptions(
                                context,
                                businessOptions.keys.toList(),
                                'businessType',
                                title: 'Jenis Usaha',
                                subtitle: 'Silakan pilih jenis usaha yang paling sesuai dengan bisnis Anda dari opsi yang tersedia.'
                            ),
                            child: AbsorbPointer(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: businessType,
                                decoration: InputDecoration(
                                  labelText: 'Jenis Usaha',
                                  prefixIcon: Icon(
                                    Icons.category_outlined,
                                    size: 20,
                                  )
                                ),
                                items: businessOptions.keys.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (newValue) {  },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Keterangan Bisnis
                          GestureDetector(
                            onTap: () => showBottomSheetOptions(
                                context,
                                businessNotes,
                                'businessNote',
                                title: 'Keterangan Usaha',
                                subtitle: 'Silahkan pilih keterangan usaha yang dianggap paling sesuai dengan jenis usaha Anda.'
                            ),
                            child: AbsorbPointer(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: businessNote,
                                decoration: InputDecoration(
                                    labelText: 'Keterangan Usaha',
                                    prefixIcon: Icon(
                                      Icons.store,
                                      size: 20,
                                    )
                                ),
                                items: businessNotes.map((String note) {
                                  return DropdownMenuItem<String>(
                                    value: note,
                                    child: Text(note, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (newValue) {  },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Monthly Income
                          TextField(
                            controller: _controllerMontylyTargetIncome,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                monthlyIncomeTarget = value.replaceAll('.', '');
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Target Pendapatan per bulan',
                              prefixText: 'Rp ',
                              prefixIcon: Icon(Icons.wallet),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Public places
                          GestureDetector(
                            onTap: () => showBottomSheetOptions(
                                context,
                                publicPlaces,
                                'preferredPublicPlace',
                                title: 'Select Preferred Public Place',
                                subtitle: 'Choose your preferred public place',
                            ),
                            child: AbsorbPointer(
                              child: DropdownButtonFormField<String>(
                                value: preferredPublicPlace,
                                isExpanded: true,
                                decoration: InputDecoration(
                                    labelText: 'Preferensi Tempat (Acuan)',
                                    prefixIcon: Icon(
                                      Icons.business,
                                      size: 20,
                                    )
                                ),
                                items: publicPlaces.map((String place) {
                                  return DropdownMenuItem<String>(
                                    value: place,
                                    child: Text(place, overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (newValue) {  },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // button
                          SizedBox(
                            width: double.infinity  ,
                            child: ElevatedButton(
                                onPressed: _submitData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(vertical: 16)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      locationPredictionProvider.isLoading
                                        ? CircularProgressIndicator()
                                        : Text('Temukan Star Location'), Icon(Icons.arrow_forward_rounded)
                                    ],
                                  ),
                                )
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                ),
                const SizedBox(height: 20),
                // Mau buka UMKM
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Color(0xffe2e8f0), width: 1)
                    ),
                    child:Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mau buka UMKM?',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Buka dengan mudah bersama Balto!'
                                  )
                                ],
                              )
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            decoration: BoxDecoration(
                              color: Color(0xffdbeafe),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Segera Hadir',
                              style: TextStyle(
                                  color: Color(0xff0c4a6e),
                                  fontSize: 14.0
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Lokasi strategis sekitar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lokasi strategis di sekitar',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //         SnackBar(content: Text('On development'))
                      //     );
                      //   },
                      //   child: Text(
                      //     'Lihat Semua',
                      //     style: TextStyle(
                      //       color: Colors.blue,
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    spacing: 8,
                    children: filters.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        onSelected: (isSelected) {
                          setState(() {
                            selectedFilter = filter;
                            locationAroundProvider.fetchLocations(filter);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 4),
                locationAroundProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : locationAroundProvider.kelurahans.isEmpty
                    ? Center(child: Text('No Data'))
                    : SizedBox(
                  height: 180,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: locationAroundProvider.kelurahans.length,
                      itemBuilder: (context, index) {
                        final kelurahan = locationAroundProvider.kelurahans[index];
                        return Padding(
                          padding: EdgeInsets.only(
                              left: index == 0? 16 : 4,
                              right: index == locationAroundProvider.kelurahans.length -1 ? 16: 0
                          ),
                          child: Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(color: Color(0xffe2e8f0), width: 1)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FadeInImage.assetNetwork(
                                    height: 120,
                                    width: 200,
                                    placeholder: 'assets/img/placeholderimg.png',
                                    image: kelurahan['kelurahan_url_photo'],
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) {
                                      return Text(
                                        error.toString(),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, top: 8, right: 0),
                                  child: Text(
                                    kelurahan['kelurahan_name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }
                  ),
                ),
                const SizedBox(height: 20),
                // UMKM Sekitar
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UMKM di sekitar',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Restauran umum & Apotek
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Restoran umum',
                                imagePath: 'assets/img/makanminumic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Apotek & kesehatan',
                                imagePath: 'assets/img/reatailkesehatanic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Olahraga & Printing
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Olahraga',
                                imagePath: 'assets/img/sportentertainmentic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Printing',
                                imagePath: 'assets/img/printeric.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Clothing & Properti
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Pakaian',
                                imagePath: 'assets/img/clothic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Properti',
                                imagePath: 'assets/img/perlatanotheric.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Retail & Jasa
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MerchantCategoryScreen(category: 'retail'),
                                    ),
                                  );
                                },
                                title: 'Retail',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MerchantCategoryScreen(category: 'jasa'),
                                    ),
                                  );
                                },
                                title: 'Jasa',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Entertainment & Transportation
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Entertainment',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Transportation',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Foto & Barang Elektornik
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Foto',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Barang Elektronik',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Materials dan Kebersihan
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Materials',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Kebersihan',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Kosmetik dan Otomotif
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Kosmetik',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Otomotif',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Optik & Kafe dan Minuman
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Optik',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Kafe & Minuman',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Warung & regional
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Warung',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Regional',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Roti,Kue, & Unclassified
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Roti, kue, camilan',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Unclassified',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Others
                      Row(
                        children: [
                          Expanded(
                              child: CardUmkmCategoryAround(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('On development'))
                                  );
                                },
                                title: 'Lainnya',
                                imagePath: 'assets/img/curcleic.png',
                              )
                          ),
                          const SizedBox(width: 4),
                          // Expanded(
                          //     child: CardUmkmCategoryAround(
                          //       onTap: () {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //             SnackBar(content: Text('On development'))
                          //         );
                          //       },
                          //       title: 'Unclassified',
                          //       imagePath: 'assets/img/perlatanotheric.png',
                          //     )
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
