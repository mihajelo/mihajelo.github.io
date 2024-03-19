import 'package:flutter/material.dart';
import 'package:pay/pay.dart';

class GPayPage extends StatelessWidget {
  // Payment items that you are charging for
  static const _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPay'),
      ),
      body: Center(
        child: Column(
          children: [
            GooglePayButton(
              paymentConfigurationAsset: 'assets/gpay.json',
              paymentItems: _paymentItems,
              width: 200,
              height: 50,
              type: GooglePayButtonType.pay,
              margin: const EdgeInsets.only(top: 15.0),
              onPaymentResult: onGooglePayResult,
              loadingIndicator: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Text('Hello World'),
          ],
        ),
      ),
    );
  }

  void onGooglePayResult(paymentResult) {
    // Process payment result
    print(paymentResult);
  }
}
