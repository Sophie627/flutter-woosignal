import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class PixelPayGatewayPage extends StatefulWidget {
  PixelPayGatewayPage();

  @override
  _PixelPayGatewayPageState createState() =>
      _PixelPayGatewayPageState();
}

class _PixelPayGatewayPageState extends State<PixelPayGatewayPage> {
  WebViewPlusController _controller;
  double _height = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PixelPay Gateway'),
        centerTitle: true,
      ),
      body: Center(
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
    PixelPay.setup('3753165478', '9078d41cb0713f7e28b174c14eaef324', 'https://cors-anywhere.herokuapp.com/https://ficohsa.pixelpay.app');

    var order = PixelPay.newOrder();
    order.setOrderID('AC101');
    order.setAmount(1)
    order.setFullName('John Doe')
    order.setEmail('example@gmail.com')

//    var card = PixelPay.newCard();
//    card.setCardNumber("4167441418762545")
//    card.setCvv("111")
//    card.setCardHolder("TEST CARD")
//    card.setExpirationDate("02/23")
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