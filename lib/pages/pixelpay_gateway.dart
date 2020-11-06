import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:woosignal/models/response/tax_rate.dart';

class PixelPayGatewayPage extends StatefulWidget {
  PixelPayGatewayPage();

  @override
  _PixelPayGatewayPageState createState() =>
      _PixelPayGatewayPageState();
}

class _PixelPayGatewayPageState extends State<PixelPayGatewayPage> {
  WebViewPlusController _controller;
  double _height = 1000;
  TaxRate _taxRate = null;
  bool isLoading = true;
  String totalPrice = '';
  String keyID = '3753165478';
  String keyHash = '9078d41cb0713f7e28b174c14eaef324';
  String endpoint = 'https://ficohsa.pixelpay.app';

  @override
  void initState() {
    super.initState();

    CheckoutSession.getInstance.total(withFormat: false, taxRate: _taxRate).then((value) {
      print('totol ${value}');
      setState(() {
        totalPrice = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: storeLogo(height: 50),
        centerTitle: true,
      ),
      body: isLoading
      ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            showAppLoader(),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                trans(context, "One moment") + "...",
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
            )
          ],
        ),
      )
      : Center(
        child: Container(
          child: WebViewPlus(
            onWebViewCreated: (controller) {
              controller.loadString(r"""
           <!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>PixelPay Payment Gateway</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<script src="https://unpkg.com/@pixelpay/sdk"></script>
<script>
    PixelPay.setup('""" + keyID + r"""', '""" + keyHash + """', 'https://cors-anywhere.herokuapp.com/""" + endpoint + """');

    var order = PixelPay.newOrder();
    order.setOrderID('AC101');
    order.setAmount(""" + totalPrice + """)
    order.setFullName('John Doe')
    order.setEmail('example@gmail.com')

//    var card = PixelPay.newCard();
//    card.setCardNumber('4167441418762545')
//    card.setCvv('111')
//    card.setCardHolder('TEST CARD')
//    card.setExpirationDate('02/23')
//    order.addCard(card);
//
//    var billing = PixelPay.newBilling();
//    billing.setCity('San Pedro');
//    billing.setState('CR');
//    billing.setCountry('HN');
//    billing.setZip('21102');
//    billing.setAddress('Ave. Circunvalacion');
//    billing.setPhoneNumber('95852921');

    PixelPay.payOrder(order).then(function(response) {
        console.log(response);
        alert('ok');
    }).catch(function(err) {
        console.error('Error: ', err);
        alert('error');
    });
</script>
</body>
</html>
      """);
            },
            onPageFinished: (url) {
              _controller.getHeight().then((double height) {
                print("Height: " + height.toString());
                setState(() {
                  _height = height;
                });
              });
            },
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}