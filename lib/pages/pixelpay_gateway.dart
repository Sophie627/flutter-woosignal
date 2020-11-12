import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'global.dart';

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
  bool isChecking = true;
  String result = '';

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 1.0,
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
    order.setOrderID('AD101');
    order.setAmount(1)
//    order.setAmount(""" + totalPrice + """)
    order.setFullName('John Doe')
    order.setEmail('example@gmail.com')

    var card = PixelPay.newCard();
    card.setCardNumber('4446850202391415')
    card.setCvv(186)
    card.setCardHolder('TEST CARD')
    card.setExpirationDate('0524')
    order.addCard(card);

    var billing = PixelPay.newBilling();
    billing.setCity('San Pedro');
    billing.setState('CR');
    billing.setCountry('HN');
    billing.setZip('21102');
    billing.setAddress('Ave. Circunvalacion');
    billing.setPhoneNumber('95852921');
    order.addBilling(billing);

    PixelPay.payOrder(order).then(function(response) {
        console.log(response);
        window.Print.postMessage(response.data.transaction_id);
    }).catch(function(err) {
        console.error('Error: ', err);
        window.Print.postMessage('error');
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
                javascriptChannels: Set.from([
                  JavascriptChannel(
                      name: 'Print',
                      onMessageReceived: (JavascriptMessage message) {
                        print(message.message);
                        setState(() {
                          isChecking = false;
                          result = message.message;
                        });
                      }
                  )
                ]),
              ),
            ),
            isChecking ? showAppLoader() : SizedBox(height: 0,),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                isChecking ? trans(context, "One moment") + "..." : result,
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
            )
          ],
        ),
      ),
    );
  }
}