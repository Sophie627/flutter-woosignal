import 'dart:async';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/pages/home.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import 'checkout_confirmation.dart';
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
  bool isChecking = true;

  String totalPrice = '';
  String orderID;

  String result = '';
  String title = '';
  AlertType type;
  Timer _timer;

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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
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
    order.setOrderID('AE10111');
    order.setAmount(""" + totalPrice + """)
    order.setFullName('""" + CheckoutSession.getInstance.billingDetails.billingAddress.firstName + ' ' + CheckoutSession.getInstance.billingDetails.billingAddress.lastName + """')
    order.setEmail('"""+ CheckoutSession.getInstance.billingDetails.billingAddress.emailAddress + """')

    var card = PixelPay.newCard();
    card.setCardNumber('""" + CheckoutSession.getInstance.paymentCard.replaceAll(' ', '') + """')
    card.setCvv(""" + CheckoutSession.getInstance.paymentCVVCode + """)
    card.setCardHolder('""" + CheckoutSession.getInstance.paymentCardHolderName + """')
    card.setExpirationDate('""" + CheckoutSession.getInstance.paymentExpiryDate + """')
    order.addCard(card);

    var billing = PixelPay.newBilling();
    billing.setCity('""" + CheckoutSession.getInstance.billingDetails.billingAddress.city + """');
    billing.setState('FM');
    billing.setCountry('HN');
    billing.setAddress('""" + CheckoutSession.getInstance.billingDetails.billingAddress.addressLine + """');
    billing.setPhoneNumber('22396410');
    order.addBilling(billing);

    PixelPay.payOrder(order).then(function(response) {
        console.log(response);
        window.Print.postMessage('Transaction ID: ' + response.data.transaction_id);
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
                  print('Page finished loading');
                  _timer = Timer.periodic(new Duration(seconds: 7), (timer) {
                    setState(() {
                      isChecking = false;
                      if (result == '') {
                        result = 'Check your information again...';
                        title = 'Error';
                        type = AlertType.error;
                      }
                    });
                    showAlert(context, title, result, type);
                    _timer.cancel();
                  });
                },
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: Set.from([
                  JavascriptChannel(
                      name: 'Print',
                      onMessageReceived: (JavascriptMessage message) {
                        print(message.message);
                        setState(() {
                          if (message.message == 'error') {
                            result = 'Please check your information and try again';
                            title = 'Warning';
                            type = AlertType.warning;
                          } else {
                            result = 'Total Price: L' + totalPrice + '\n' + message.message;
                            title = 'Success';
                            type = AlertType.success;
                          }
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

  showAlert(context, title, desc, type) {
    Alert(
      closeFunction: () {
        alertAction(type);
      },
      context: context,
      type: type,
      title: title,
      desc: desc,
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            alertAction(type);
          },
          width: 120,
        )
      ],
    ).show();
  }

  alertAction(type) {
    if (type == AlertType.success) {
      Cart.getInstance.clear();
      Navigator.push (
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.popUntil(context, ModalRoute.withName('/checkout'));
    }
  }
}