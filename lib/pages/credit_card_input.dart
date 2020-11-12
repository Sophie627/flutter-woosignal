import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout_confirmation.dart';
import 'global.dart' as global;

class CreditCardInputPage extends StatefulWidget {
  CreditCardInputPage({Key key}) : super(key: key);

  @override
  CreditCardInputPageState createState() =>
      CreditCardInputPageState();
}

class CreditCardInputPageState extends State<CreditCardInputPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: CreditCardForm(
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ),
            ),
            Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: RaisedButton(
                onPressed: () {
                  if(cardNumber != '') addCardAction();
//                  Navigator.push (
//                    context,
//                    MaterialPageRoute(builder: (context) => CreditCardInputPage()),
//                  );
                },
                child: Text('Add Credit Card',
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
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  static Future<List<String>> _getCardNumbers() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cardNumber';
    final prefs = await SharedPreferences.getInstance();
    final cardNumberList = prefs.getStringList(key) ?? ['no Card'];
    return cardNumberList;
  }

  _saveCardNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listCardNumber = [];

    var key_cardNumber =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cardNumber';

    _getCardNumbers().then((value) async {
      if (value[0] == 'no Card') {
        listCardNumber.add(cardNumber);
        await prefs.setStringList(key_cardNumber, listCardNumber);
        return;
      } else {
        if (value.indexOf(cardNumber) == -1) {
          value.add(cardNumber);
          listCardNumber = value;
          await prefs.setStringList(key_cardNumber, listCardNumber);
          return;
        }
      }
    });
  }

  static Future<List<String>> _getExpiryDates() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_expiryDate';
    final prefs = await SharedPreferences.getInstance();
    final expiryDateList = prefs.getStringList(key) ?? ['no Card'];
    return expiryDateList;
  }

  _saveExpiryDates() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listExpiryDate = [];

    var key_expiryDate =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_expiryDate';

    _getExpiryDates().then((value) async {
      if (value[0] == 'no Card') {
        listExpiryDate.add(expiryDate);
        await prefs.setStringList(key_expiryDate, listExpiryDate);
        return;
      } else {
        if (value.indexOf(expiryDate) == -1) {
          value.add(expiryDate);
          listExpiryDate = value;
          await prefs.setStringList(key_expiryDate, listExpiryDate);
          return;
        }
      }
    });
  }

  static Future<List<String>> _getCardHolderNames() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cardHolderName';
    final prefs = await SharedPreferences.getInstance();
    final cardHolderNameList = prefs.getStringList(key) ?? ['no Card'];
    return cardHolderNameList;
  }

  _saveCardHolderNames() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listCardHolderName = [];

    var key_cardHolderName =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cardHolderName';

    _getCardHolderNames().then((value) async {
      if (value[0] == 'no Card') {
        listCardHolderName.add(cardHolderName);
        await prefs.setStringList(key_cardHolderName, listCardHolderName);
        return;
      } else {
        if (value.indexOf(cardHolderName) == -1) {
          value.add(cardHolderName);
          listCardHolderName = value;
          await prefs.setStringList(key_cardHolderName, listCardHolderName);
          return;
        }
      }
    });
  }

  static Future<List<String>> _getCVVCodes() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cvvCode';
    final prefs = await SharedPreferences.getInstance();
    final cvvCodeList = prefs.getStringList(key) ?? ['no Card'];
    return cvvCodeList;
  }

  _saveCVVCodes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listCVVCodes = [];

    var key_cvvCode =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_cvvCode';

    _getCVVCodes().then((value) async {
      if (value[0] == 'no Card') {
        listCVVCodes.add(cvvCode);
        await prefs.setStringList(key_cvvCode, listCVVCodes);
        return;
      } else {
        if (value.indexOf(cvvCode) == -1) {
          value.add(cvvCode);
          listCVVCodes = value;
          await prefs.setStringList(key_cvvCode, listCVVCodes);
          return;
        }
      }
    });
  }

  void addCardAction() {
    _saveCardNumbers();
    _saveExpiryDates();
    _saveCVVCodes();
    _saveCardHolderNames();

    CheckoutSession.getInstance.paymentCard = cardNumber;
    CheckoutSession.getInstance.paymentExpiryDate = expiryDate;
    CheckoutSession.getInstance.paymentCVVCode = cvvCode;
    CheckoutSession.getInstance.paymentCardHolderName = cardHolderName;


    Navigator.push (
      context,
      MaterialPageRoute(builder: (context) => CheckoutConfirmationPage()),
    );
  }
}