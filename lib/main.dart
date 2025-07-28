import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(MaterialApp(home: homepage(), debugShowCheckedModeBanner: false));
}

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> with TickerProviderStateMixin {
  // State değişkenleri
  TextEditingController trackingController = TextEditingController();
  bool isLoading = false;
  bool showResult = false;
  bool showWarning = false;
  String warningMessage = '';

  @override
  void initState() {
    super.initState();

    trackingController.text = '#';
  }

  @override
  void dispose() {
    trackingController.dispose();
    super.dispose();
  }

  bool validateTrackingNumber(String input) {
    final regex = RegExp(r'^#\d{10}$');
    return regex.hasMatch(input);
  }

  void handleSearch() {
    final inputValue = trackingController.text;

    if (inputValue.isEmpty || inputValue == '#') {
      setState(() {
        showWarning = true;
        warningMessage = 'Lütfen takip numarasını doldurunuz';
      });
      return;
    }

    if (!validateTrackingNumber(inputValue)) {
      setState(() {
        showWarning = true;
        warningMessage = 'Geçerli format: #1234567890';
      });
      return;
    }

    setState(() {
      showWarning = false;
      isLoading = true;
      showResult = false;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
          showResult = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: content());
  }

  Widget content() {
    return Column(
      children: [
        Container(
          height: 236,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Image.asset("assets/asset1.jpg", height: 170),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text("Kargo Takibi", style: TextStyle(fontSize: 30)),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: body()),
      ],
    );
  }

  Widget body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text("Takip numarası", style: TextStyle(fontSize: 16)),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              Container(
                height: 60,
                width: 310,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: TextField(
                  controller: trackingController,
                  maxLength: 11, // # + 10 rakam[4]

                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    TrackingNumberFormatter(), // Özel formatter
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    hintText: "örn : #1234567890",
                    counterText: "", // Karakter sayacını gizle
                  ),
                  onChanged: (value) {
                    // Uyarı varsa temizle
                    if (showWarning) {
                      setState(() {
                        showWarning = false;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                  onTap: handleSearch,
                  child: Icon(Icons.search, size: 40),
                ),
              ),
            ],
          ),
        ),

        if (showWarning)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 5),
            child: Text(
              warningMessage,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        SizedBox(height: 20),

        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Lottie.asset(
                'assets/animations/loading.json', // Lottie animasyon dosyanız[5][6]
                width: 300,
                height: 300,
                repeat: true,
              ),
            ),
          ),

        // Sonuç alanı
        if (showResult && !isLoading)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 31, 0),
              child: Column(
                children: [
                  ResultWidget(
                    onClose: () {
                      setState(() {
                        showResult = false;
                      });
                    },
                  ),
                  Expanded(child: CargoTrackingStepper()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class TrackingNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    if (!newText.startsWith('#')) {
      newText = '#${newText.replaceAll(RegExp(r'[^0-9]'), '')}';
    } else {
      // # sonrasında sadece rakamları al
      String numbers = newText.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      newText = '#$numbers';
    }

    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class ResultWidget extends StatelessWidget {
  final VoidCallback onClose;
  const ResultWidget({required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("result:", style: TextStyle(fontSize: 20)),
        Spacer(),
        GestureDetector(onTap: onClose, child: Icon(Icons.close, size: 25)),
      ],
    );
  }
}

class CargoTrackingStepper extends StatefulWidget {
  const CargoTrackingStepper({super.key});

  @override
  State<CargoTrackingStepper> createState() => _CargoTrackingStepperState();
}

class _CargoTrackingStepperState extends State<CargoTrackingStepper> {
  int currentStep = 0;

  final List<Map<String, String>> stepsData = [
    {
      "title": "Order Placed",
      "date": "2021/5/20 11:35 AM",
      "desc": "Order Created !!",
    },
    {
      "title": "Dispatch in Progress",
      "date": "2021/5/20 4:20 PM",
      "desc": "Parcel Ready To Dispatch !!",
    },
    {
      "title": "Ready For Pickup",
      "date": "2021/5/21 10:30 AM",
      "desc": "Parcel Sorted !!",
    },
    {
      "title": "In Transit",
      "date": "2021/5/21 4:20 PM",
      "desc": "Parcel Arrived At Delivery Hub !!",
    },
    {"title": "Out For Delivery", "date": "", "desc": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Stepper(
      type: StepperType.vertical,
      currentStep: currentStep,
      onStepTapped: (step) {
        setState(() {
          currentStep = step;
        });
      },
      controlsBuilder: (context, details) => const SizedBox.shrink(),
      steps: List.generate(stepsData.length, (index) {
        final step = stepsData[index];
        final isLast = index == stepsData.length - 1;
        return Step(
          title: Text(
            step["title"]!,
            style: TextStyle(
              color: isLast ? Colors.blue : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content:
              step["date"]!.isNotEmpty
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step["date"]!,
                        style: TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      Text(
                        step["desc"]!,
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
          isActive: currentStep == index,
          state:
              currentStep > index
                  ? StepState.complete
                  : currentStep == index
                  ? StepState.editing
                  : StepState.indexed,
        );
      }),
    );
  }
}
