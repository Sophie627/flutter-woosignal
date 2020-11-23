import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/pages/home_menu.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'checkout_confirmation.dart';
import 'global.dart' as global;

class CreditCardInputPage extends StatefulWidget {

  final bool isCheckout;
  final int index;
  final String cardNumber;
  final String expiryDate;
  final String cvvCode;
  final String cardHolderName;

  CreditCardInputPage({Key key,
    this.isCheckout = true,
    this.index = -1,
    this.cardHolderName = '',
    this.expiryDate = '',
    this.cardNumber = '',
    this.cvvCode = '',
  }) : super(key: key);

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
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      cardNumber = widget.cardNumber;
      expiryDate = widget.expiryDate;
      cardHolderName = widget.cardHolderName;
      cvvCode = widget.cvvCode;
    });
  }

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
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  expiryDate: expiryDate,
                  cardNumber: cardNumber,
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
                child: Text(widget.index == -1 ? 'Add Credit Card' : 'Update Credit Card',
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
    var key = 'cardNumber';
    final prefs = await SharedPreferences.getInstance();
    final cardNumberList = prefs.getStringList(key) ?? ['no Card'];
    return cardNumberList;
  }

  _saveCardNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listCardNumber = [];

    var key_cardNumber = 'cardNumber';

    _getCardNumbers().then((value) async {
      if (widget.index != -1) {
        listCardNumber = value;
        listCardNumber[widget.index] = cardNumber;
        await prefs.setStringList(key_cardNumber, listCardNumber);
        return;
      } else {
        if (value.length > 0) {

          if (value[0] == 'no Card') {
            listCardNumber.add(cardNumber);
            await prefs.setStringList(key_cardNumber, listCardNumber);
            return;
          }
        }
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
        'expiryDate';
    final prefs = await SharedPreferences.getInstance();
    final expiryDateList = prefs.getStringList(key) ?? ['no Card'];
    return expiryDateList;
  }

  _saveExpiryDates() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listExpiryDate = [];

    var key_expiryDate =
        'expiryDate';

    _getExpiryDates().then((value) async {
      if (widget.index != -1) {
        listExpiryDate = value;
        listExpiryDate[widget.index] = expiryDate;
        await prefs.setStringList(key_expiryDate, listExpiryDate);
        return;
      } else {
        if (value.length > 0) {

          if (value[0] == 'no Card') {
            listExpiryDate.add(expiryDate);
            await prefs.setStringList(key_expiryDate, listExpiryDate);
            return;
          }
        }
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
        'cardHolderName';
    final prefs = await SharedPreferences.getInstance();
    final cardHolderNameList = prefs.getStringList(key) ?? ['no Card'];
    return cardHolderNameList;
  }

  _saveCardHolderNames() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listCardHolderName = [];

    var key_cardHolderName =
        'cardHolderName';

    _getCardHolderNames().then((value) async {
      if (widget.index != -1) {
        listCardHolderName = value;
        listCardHolderName[widget.index] = cardHolderName;
        await prefs.setStringList(key_cardHolderName, listCardHolderName);
        return;
      } else {
        if (value.length > 0) {

          if (value[0] == 'no Card') {
            listCardHolderName.add(cardHolderName);
            await prefs.setStringList(key_cardHolderName, listCardHolderName);
            return;
          }
        }
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
        'cvvCode';
    final prefs = await SharedPreferences.getInstance();
    final cvvCodeList = prefs.getStringList(key) ?? ['no Card'];
    return cvvCodeList;
  }

  _saveCVVCodes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listCVVCodes = [];

    var key_cvvCode =
        'cvvCode';

    _getCVVCodes().then((value) async {
      if (widget.index != -1) {
        listCVVCodes = value;
        listCVVCodes[widget.index] = cvvCode;
        await prefs.setStringList(key_cvvCode, listCVVCodes);
        return;
      } else {
        if (value.length > 0) {

          if (value[0] == 'no Card') {
            listCVVCodes.add(cvvCode);
            await prefs.setStringList(key_cvvCode, listCVVCodes);
            return;
          }
        }
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


    if (widget.isCheckout) {
      Navigator.push (
        context,
        MaterialPageRoute(builder: (context) => CheckoutConfirmationPage()),
      );
    } else {
      Navigator.push (
        context,
        MaterialPageRoute(builder: (context) => HomeMenuPage()),
      );
    }
  }
}
