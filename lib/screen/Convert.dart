import 'dart:convert';

import 'package:exam/utils/custom_images.dart';
import 'package:exam/utils/images_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Convert extends StatefulWidget {
  const Convert({super.key});

  @override
  State<Convert> createState() => _Convert();
}

class _Convert extends State<Convert> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  double? _usdValue;
  double? _jpyValue;
  double? _brlValue;
  double? _convertedAmount;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Future<void> _convert() async {
    const header = 'Hamlet and Giancarlo';
    const url = 'https://api.exchangerate-api.com/v4/latest/COP';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'consumer': header},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _usdValue = data['rates']['USD'];
          _jpyValue = data['rates']['JPY'];
          _brlValue = data['rates']['BRL'];
          _error = '';
          _calculateConversion();
          _resultController.text = _convertedAmount?.toStringAsFixed(2) ?? '';

        });
      } else {
        setState(() {
          _error = 'Error: We could not convert the value';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    }
  }

  void _calculateConversion() {

    double amountInCOP = double.tryParse(_controller.text) ?? 0;
    double conversionRate = 1.0;

    if (_selectedCountry == 'USA' && _usdValue != null) {
      conversionRate = _usdValue!;
    } else if (_selectedCountry == 'JPY' && _jpyValue != null) {
      conversionRate = _jpyValue!;
    } else if (_selectedCountry == 'BRL' && _brlValue != null) {
      conversionRate = _brlValue!;
    }

    setState(() {
      _convertedAmount = amountInCOP * conversionRate;
    });
  }

  String _selectedCountry = "USA";

  List<String> countries = [
    'USA',
    'JPY',
    'BRL',
  ];

  Map<String, String> _getSelectedConversionData() {
    String conversionRateText;
    String countryImagePath;

    switch (_selectedCountry) {
      case 'USA':
        conversionRateText = "1 COP = ${_usdValue ?? '-'} USD";
        countryImagePath = ImageConstant.img512pxUnitedSt;
        break;
      case 'JPY':
        conversionRateText = "1 COP = ${_jpyValue ?? '-'} JPY";
        countryImagePath = ImageConstant.imgJpn;
        break;
      case 'BRL':
        conversionRateText = "1 COP = ${_brlValue ?? '-'} BRL";
        countryImagePath = ImageConstant.imgBr;
        break;
      default:
        conversionRateText = "1 COP = ${_usdValue ?? '-'} USD";
        countryImagePath = ImageConstant.img512pxUnitedSt;
        break;
    }

    return {'rate': conversionRateText, 'imagePath': countryImagePath};
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> selectedConversionData = _getSelectedConversionData();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE4F6F0),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 40),
          Center(
            child: Container(
              width: size.width * 0.8,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Converter 2.0",
                    style: TextStyle(
                        color: Color(0xFF1F2261),
                        fontSize: 25,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  Text(
                    "Convert your pesos into yen, reals or dollars.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF808080),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700),
                  )
                ],
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.only(top: 50),
              width: size.width * .8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 13, bottom: 0),
                    child: Text(
                      "Amount",
                      style: TextStyle(
                        color: Color(0xFF989898),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomImageView(
                              imagePath: ImageConstant.imgCop,
                              height: 60,
                              width: 60,
                            ),
                            const Padding(
                              padding:
                                  EdgeInsets.only(left: 13, top: 9, bottom: 11),
                              child: Text(
                                "COP",
                              ),
                            ),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 13, bottom: 11, top: 9, right: 13),
                              child: TextField(
                                controller: _controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  hintText: 'Enter the amount in COP',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                ),
                              ),
                            ))
                          ],
                        ),
                      )),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 13),
                    child: Text(
                      "Converted Amount",
                      style: TextStyle(
                        color: Color(0xFF989898),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomImageView(
                              imagePath: selectedConversionData['imagePath'],
                              height: 50,
                              width: 50,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 13, top: 9, bottom: 11),
                              child: Text(
                                _selectedCountry,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: 200,
                                        child: ListView.builder(
                                          itemCount: countries.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title: Text(countries[index]),
                                              onTap: () {
                                                setState(() {
                                                  _selectedCountry =
                                                      countries[index];
                                                  _resultController.clear();

                                                });
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        ),
                                      );
                                    });
                              },
                              child: CustomImageView(
                                imagePath: ImageConstant.imgArrowdown,
                                height: 40,
                                width: 40,
                                margin: const EdgeInsets.only(
                                  left: 2,
                                  top: 10,
                                  bottom: 11,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 3, bottom: 11, top: 9, right: 13),
                              child: TextField(
                                controller: _resultController,
                                enabled: false,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal:
                                          16), // Ajusta el tamaño del TextField
                                ),
                              ),
                            ))
                          ],
                        ),
                      )),
                ],
              )),
          Container(
            width: size.width * 0.8,
            margin: const EdgeInsets.only(top: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Indicate how much it is",
                        style: TextStyle(
                          color: Color(0xFF989898),
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(selectedConversionData['rate']!)
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _convert();
                  },
                  child: const Text('Convert'),
                ),
              ],
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 6, left: 6),
        child: const Text(
          "Hamlet Pirazan and Giancarlo Cabrera",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey
          ),
        ),
      ),
    );
  }
}
