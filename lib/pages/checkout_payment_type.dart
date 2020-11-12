//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/pages/credit_card_input.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;

class CheckoutPaymentTypePage extends StatefulWidget {
  CheckoutPaymentTypePage();

  @override
  _CheckoutPaymentTypePageState createState() =>
      _CheckoutPaymentTypePageState();
}

class _CheckoutPaymentTypePageState extends State<CheckoutPaymentTypePage> {
  _CheckoutPaymentTypePageState();
  List<String> listCardNumber = [];
  List<String> listExpiryDate = [];
  List<String> listCVVCode = [];
  List<String> listCardHolderName = [];
  bool isLoading = true;

  static Future<List<String>> _getExpiryDates() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_expiryDate';
    final prefs = await SharedPreferences.getInstance();
    final expiryDateList = prefs.getStringList(key) ?? ['no Card'];
    return expiryDateList;
  }

  static Future<List<String>> _getCardHolderNames() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cardHolderName';
    final prefs = await SharedPreferences.getInstance();
    final cardHolderNameList = prefs.getStringList(key) ?? ['no Card'];
    return cardHolderNameList;
  }

  static Future<List<String>> _getCVVCodes() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cvvCode';
    final prefs = await SharedPreferences.getInstance();
    final cvvCodeList = prefs.getStringList(key) ?? ['no Card'];
    return cvvCodeList;
  }

  static Future<List<String>> _getCardNumbers() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cardNumber';
    final prefs = await SharedPreferences.getInstance();
    final cardNumberList = prefs.getStringList(key) ?? ['no Card'];
    return cardNumberList;
  }

  @override
  void initState() {
    super.initState();

    if (CheckoutSession.getInstance.paymentType == null) {
      if (getPaymentTypes() != null && getPaymentTypes().length > 0) {
        CheckoutSession.getInstance.paymentType = getPaymentTypes().first;
      }
    }

    _getCardNumbers().then((value) {
      print('cardnumber ${value}');
      setState(() {
        listCardNumber = value;
        isLoading = false;
      });
    });

    _getExpiryDates().then((value) {
      print('expiryDate ${value}');
      setState(() {
        listExpiryDate = value;
        isLoading = false;
      });
    });

    _getCVVCodes().then((value) {
      print('cvvCode ${value}');
      setState(() {
        listCVVCode = value;
        isLoading = false;
      });
    });

    _getCardHolderNames().then((value) {
      print('cardHolderName ${value}');
      setState(() {
        listCardHolderName = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(trans(context, "Payment Method"),
            style: Theme.of(context).primaryTextTheme.headline6),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                  child: Text("Select or add Credit Card",
                    style: Theme.of(context).primaryTextTheme.bodyText2,
                  ),
                ),
                Padding(
                  child: Center(
                    child: Image(
                        image: AssetImage("assets/images/credit_cards.png"),
                        fit: BoxFit.fitHeight,
                        height: 100),
                  ),
                  padding: EdgeInsets.only(top: 0),
                ),
                SizedBox(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: isLoading
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
                          : ListView.separated(
                            itemCount: listCardNumber.length,
                            itemBuilder: (BuildContext context, int index) {
                              if(listCardNumber[index] == 'no Card') {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 8, right: 8),
                                  child: Center(
                                    child: Text('No saved Card',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .subtitle1),
                                  ),
                                );
                              } else {
                                return ListTile(
                                  contentPadding: EdgeInsets.only(
                                      top: 10, bottom: 10, left: 8, right: 8),
                                  leading: Image(
                                      image: AssetImage("assets/images/" +
                                          getPaymentTypes()[0].assetImage),
                                      width: 0,
                                      fit: BoxFit.contain,
                                      alignment: Alignment.center),
                                  title: Text(secretCardNumber(listCardNumber[index]),
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .subtitle1),
                                  selected: true,
                                  trailing:
                                  (CheckoutSession.getInstance.paymentCard ==
                                      listCardNumber[index]
                                      ? Icon(Icons.check)
                                      : null),
                                  onTap: () {
                                    CheckoutSession.getInstance.paymentCard = listCardNumber[index];
                                    CheckoutSession.getInstance.paymentExpiryDate = listExpiryDate[index];
                                    CheckoutSession.getInstance.paymentCVVCode = listCVVCode[index];
                                    CheckoutSession.getInstance.paymentCardHolderName = listCardHolderName[index];
                                    Navigator.pop(context);
                                  },
                                );
                              }
                            },
                            separatorBuilder: (cxt, i) => Divider(
                              color: Colors.black12,
                            ),
                          ),
                        ),
                        Container(
                          height: 50.0,
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.push (
                                context,
                                MaterialPageRoute(builder: (context) => CreditCardInputPage()),
                              );
                            },
                            child: Text('Add another Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        wsLinkButton(
                          context,
                          title: trans(context, "CANCEL"),
                          action: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: wsBoxShadow(),
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  height: (constraints.maxHeight - constraints.minHeight) * 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
