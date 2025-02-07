import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:money_transfer/config/routes/custom_push_navigators.dart';
import 'package:money_transfer/core/utils/assets.dart';
import 'package:money_transfer/features/home/screens/comming_soon_screen.dart';
import 'package:money_transfer/features/home/widgets/add_send_funds_container.dart';
import 'package:money_transfer/widgets/height_space.dart';
import 'package:money_transfer/features/home/widgets/payment_containers.dart';
import 'package:provider/provider.dart';

import 'package:money_transfer/core/utils/color_constants.dart';
import 'package:money_transfer/core/utils/global_constants.dart';
import 'package:money_transfer/features/auth/services/auth_service.dart';
import 'package:money_transfer/features/home/screens/send_money_screen.dart';
import 'package:money_transfer/features/home/services/home_service.dart';
import 'package:money_transfer/features/transactions/screens/transaction_details_screen.dart';
import 'package:money_transfer/features/transactions/widgets/transactions_card.dart';
import 'package:money_transfer/features/transactions/models/transactions.dart';
// import 'package:money_transfer/features/auth/providers/user_provider.dart';
import 'package:money_transfer/widgets/circular_loader.dart';
import 'package:money_transfer/widgets/custom_button.dart';

import 'chart.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home-screens';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService homeService = HomeService();  // device notifications
  final AuthService authService = AuthService();
  List<Transactions> transactions = [];
  late Future _future;
  final ScrollController scrollController = ScrollController();

  // prepare string to fetch data from bybit
  String bybitUsername = "";

  getAllTransactions() async {
    transactions = await homeService.getAllTransactions(
      context: context,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void checkIfUserHasPin() {
    homeService.checkIfUserHasSetPin(context);
  }

  obtainTokenAndUserData() async {
    await authService.obtainTokenAndUserData(context);
  }

  getCreditNotifications() {
    homeService.creditNotification(
        context: context,
        onSuccess: () {
          Future.delayed(const Duration(seconds: 6), () {
            deleteNotification();
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          });
        });
  }

  deleteNotification() {
    homeService.deleteNotification(context: context);
  }

  @override
  void initState() {
    super.initState();

    fetchBybitUsername();

    // checkIfUserHasPin();
    obtainTokenAndUserData();
    _future = getAllTransactions();
    Future.delayed(const Duration(seconds: 5), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  // parsing username headlessly with built-in webViewController
  Future<void> fetchBybitUsername() async {
    try {
      final browser = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse("https://www.bybit.com"))),
        onLoadStop: (controller, url) async {
          String? username = await controller.evaluateJavascript(
            source: "document.querySelector('.user-info-selector')?.innerText;",
          );
          if (username != null && username.isNotEmpty) {
            setState(() {
              bybitUsername = username;
            });
          }
        },
      );
      print("Updated bybitUsername: $bybitUsername");
      await browser.run();
    } catch (e) {
      print('Error parsing Bybit username: \$e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  List<String> paymentIcons = [
    mobileIcon,
    budgetIcon,
    electricityIcon,
    wifiIcon,
    billsIcon,
    moreIcon,
  ];
  List<String> paymentText = [
    "Airtime",
    "Budget",
    "Electricity",
    "Data",
    "Bills",
    "More",
  ];

  // currency exchange UI

  List<String> currencies = ['NGN', 'RUB', 'USD', 'EUR', 'GBP', 'JPY'];
  String fromCurrency = 'NGN';
  String toCurrency = 'RUB';
  double conversionRate = 0.25; // Example conversion rate from NGN to RUB
  TextEditingController amountController = TextEditingController();

  void showCurrencyConverter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Currency Converter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount in \$fromCurrency',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: fromCurrency,
                      onChanged: (String? newValue) {
                        setState(() {
                          fromCurrency = newValue!;
                        });
                      },
                      items: currencies.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () {
                        setState(() {
                          String temp = fromCurrency;
                          fromCurrency = toCurrency;
                          toCurrency = temp;
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: toCurrency,
                      onChanged: (String? newValue) {
                        setState(() {
                          toCurrency = newValue!;
                        });
                      },
                      items: currencies.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    double amount = double.tryParse(amountController.text) ?? 0;
                    double convertedAmount = amount * conversionRate;
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(
                            title: const Text('Conversion Result'),
                            content: Text(
                                '$amount \$fromCurrency = $convertedAmount \$toCurrency at a rate of $conversionRate'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('Convert'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void createAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Create an alert"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // condition dropdown
                  DropdownButtonFormField(
                    decoration: InputDecoration(labelText: "Condition"),
                      items: [
                        DropdownMenuItem(value: "≥", child: Text("≥")),
                        DropdownMenuItem(value: "≤", child: Text("≤")),
                      ],
                      onChanged: (value) {}
                  ),
                  SizedBox(height: 16),
                  // rate number input
                  TextField(
                    decoration: InputDecoration(
                        labelText: "Rate", hintText: "1644.12"
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  // notifications
                  Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
                  CheckboxListTile(
                    title: Text("E-mail"),
                    value: false,
                    onChanged: (value) {},
                  ),
                  CheckboxListTile(
                    title: Text(
                        "App notifications"),
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              )
            ),
              actions: [
              TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
              ),
              ElevatedButton(
              onPressed: () {},
              child: Text("Create"),
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: value20),
          child: Column(
            children: [
              Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: heightValue15,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: heightValue25,
                                    backgroundColor: whiteColor,
                                    backgroundImage:
                                        const AssetImage(gradientCircle),
                                    child: Center(
                                        child: Text(
                                      bybitUsername,
                                      style: TextStyle(
                                          color: secondaryAppColor,
                                          fontSize: heightValue25,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                  SizedBox(
                                    width: value10,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hi, ${bybitUsername}",
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: heightValue18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "@ ${bybitUsername}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: heightValue15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Image.asset(
                                "assets/icons/notification.png",
                                height: heightValue30,
                                color: whiteColor,
                              )
                            ],
                          ),
                          SizedBox(
                            height: heightValue10,
                          ),
                          // graph here
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // first dropdown
                              ElevatedButton(
                                onPressed: () => showCurrencyConverter(context),
                                child: Text("Currency exchange", style: TextStyle(fontSize: 18)),
                              ),
                            ],
                          ),
                          Center(child: LineChartSample()),
                        ],
                      ),
                      HeightSpace(heightValue10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AddSendFundsContainers(
                            text: "Send",
                            icon: sendIcon,
                            onTap: () => namedNav(context, "/send-money"),
                          ),
                          AddSendFundsContainers(
                            text: "Alert",
                            icon: addAlert,
                            onTap: () => createAlert(context),
                          ),
                        ],
                      ),
                      HeightSpace(heightValue20),
                      const Divider(),
                      HeightSpace(heightValue20),
                      Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: heightValue25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      HeightSpace(heightValue10),
                      SizedBox(
                        height: heightValue130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: paymentIcons.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () => namedNav(
                                context,
                                CommingSoonScreen.route,
                              ),
                              child: PaymentContainers(
                                icon: paymentIcons[index],
                                color: whiteColor,
                                text: paymentText[index],
                              ),
                            );
                          },
                        ),
                      ),
                      HeightSpace(heightValue20),
                      Text(
                        "Transactions",
                        style: TextStyle(
                          fontSize: heightValue35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FutureBuilder(
                future: _future,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return transactions.isEmpty
                        ? Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: heightValue10,
                                  ),
                                  Image.asset(
                                    "assets/images/empty_list.png",
                                    height: heightValue150,
                                  ),
                                  Text(
                                    "You've not made any transactions",
                                    style: TextStyle(
                                      fontSize: heightValue18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: heightValue10,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: value60),
                                    child: CustomButton(
                                      buttonText: "Transfer Now",
                                      buttonColor: primaryAppColor,
                                      buttonTextColor: secondaryAppColor,
                                      borderRadius: heightValue30,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          SendMoneyScreen.route,
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => getAllTransactions(),
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: scrollController,
                                itemCount: transactions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final transactionData = transactions[index];
                                  List<String> getTrnxSummary(transactionData) {
                                    if (transactionData.trnxType == "Credit") {
                                      return [
                                        "From ${transactionData.fullNameTransactionEntity} Reference:${transactionData.reference}",
                                        "assets/icons/credit_icon.png"
                                      ];
                                    } else if (transactionData.trnxType ==
                                        "Debit") {
                                      return [
                                        "To ${transactionData.fullNameTransactionEntity} Reference:${transactionData.reference}",
                                        "assets/icons/debit_icon.png"
                                      ];
                                    } else if (transactionData.trnxType ==
                                        "Wallet Funding") {
                                      return [
                                        "You Funded Your Wallet. Reference:${transactionData.reference}",
                                        "assets/icons/add_icon.png"
                                      ];
                                    } else {
                                      return ["Hello"];
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      TransactionDetailsScreen.route,
                                      arguments: transactionData,
                                    ),
                                    child: TransactionsCard(
                                      transactionTypeImage:
                                          getTrnxSummary(transactionData)[1],
                                      transactionType: transactionData.trnxType,
                                      trnxSummary:
                                          getTrnxSummary(transactionData)[0],
                                      amount: transactionData.amount,
                                      amountColorBasedOnTransactionType:
                                          transactionData.trnxType == "Debit"
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                  }
                  return const Expanded(child: CircularLoader());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
