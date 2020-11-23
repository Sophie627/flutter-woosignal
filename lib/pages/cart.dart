//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/shared_pref/sp_auth.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/models/cart.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;

class CartPage extends StatefulWidget {
  CartPage();

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  _CartPageState();

  bool _isLoading = false;
  bool _isCartEmpty = false;
  List<CartLineItem> _cartLines;
  TextEditingController couponController = new TextEditingController();
  String _couponResultTitle = '';
  String _couponResultSubtitle = '';
  String _couponResultTailing = '';
  String _couponType = '';
  double _couponAmount = 0;
  String _couponCode = '';
  double _couponTotalPrice = 0;
  List feeResult = [];
  bool _isCalculating = true;
  double discount = 0;

  @override
  void initState() {
    super.initState();
    _cartLines = [];
    _isLoading = true;
    _cartCheck();
  }

  getFee() async {
    setState(() {
      _isCalculating = true;
    });
    await Cart.getInstance.getCartFees().then((value) async {
      print(value);
      setState(() {
        feeResult = value;
        _isCalculating = false;
      });
      feeResult.forEach((element) {
        setState(() {
          discount += element['amount'];
        });
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('discount', discount.toString());
      print('feeResult $feeResult');
    });
  }
  _cartCheck() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('coupon', '0');
    List<CartLineItem> cart = await Cart.getInstance.getCart();


    if (cart.length <= 0) {
      setState(() {
        _isLoading = false;
        _isCartEmpty = (cart.length <= 0) ? true : false;
      });
      return [];
    }

    List<Map<String, dynamic>> cartJSON = cart.map((c) => c.toJson()).toList();

    List<dynamic> cartRes =
        await appWooSignal((api) => api.cartCheck(cartJSON));
    if (cartRes.length <= 0) {
      Cart.getInstance.saveCartToPref(cartLineItems: []);
      setState(() {
        _isCartEmpty = true;
        _isLoading = false;
      });
      return;
    }
    _cartLines = cartRes.map((json) => CartLineItem.fromJson(json)).toList();
    couponCalculate();
    getFee();
    if (_cartLines.length > 0) {
      Cart.getInstance.saveCartToPref(cartLineItems: _cartLines);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _actionProceedToCheckout() async {
    List<CartLineItem> cartLineItems = await Cart.getInstance.getCart();
    if (_isLoading == true) {
      return;
    }
    if (cartLineItems.length <= 0) {
      showEdgeAlertWith(context,
          title: trans(context, "Cart"),
          desc: trans(context,
              trans(context, "You need items in your cart to checkout")),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.shopping_cart);
      return;
    }
    if (!cartLineItems.every(
        (c) => c.stockStatus == 'instock' || c.stockStatus == 'onbackorder')) {
      showEdgeAlertWith(context,
          title: trans(context, "Cart"),
          desc: trans(context, trans(context, "There is an item out of stock")),
          style: EdgeAlertStyle.WARNING,
          icon: Icons.shopping_cart);
      return;
    }
    CheckoutSession.getInstance.initSession();
    CustomerAddress sfCustomerAddress =
        await CheckoutSession.getInstance.getBillingAddress();
    if (sfCustomerAddress != null) {
      CheckoutSession.getInstance.billingDetails.billingAddress =
          sfCustomerAddress;
      CheckoutSession.getInstance.billingDetails.shippingAddress =
          sfCustomerAddress;
    }
    if (use_wp_login == true && !(await authCheck())) {
      UserAuth.instance.redirect = "/checkout";
      Navigator.pushNamed(context, "/account-landing");
      return;
    }
    Navigator.pushNamed(context, "/checkout");
  }

  actionIncrementQuantity({CartLineItem cartLineItem}) {
    if (cartLineItem.isManagedStock &&
        cartLineItem.quantity + 1 > cartLineItem.stockQuantity) {
      showEdgeAlertWith(
        context,
        title: trans(context, "Cart"),
        desc: trans(context, trans(context, "Maximum stock reached")),
        style: EdgeAlertStyle.WARNING,
        icon: Icons.shopping_cart,
      );
      return;
    }
    Cart.getInstance
        .updateQuantity(cartLineItem: cartLineItem, incrementQuantity: 1);
    cartLineItem.quantity += 1;
    setState(() {});
    couponCalculate();
    getFee();
  }

  actionDecrementQuantity({CartLineItem cartLineItem}) {
    if (cartLineItem.quantity - 1 <= 0) {
      return;
    }
    Cart.getInstance
        .updateQuantity(cartLineItem: cartLineItem, incrementQuantity: -1);
    cartLineItem.quantity -= 1;
    setState(() {});
    couponCalculate();
    getFee();

  }

  actionRemoveItem({int index}) {
    Cart.getInstance.removeCartItemForIndex(index: index);
    _cartLines.removeAt(index);
    showEdgeAlertWith(
      context,
      title: trans(context, "Updated"),
      desc: trans(context, "Item removed"),
      style: EdgeAlertStyle.WARNING,
      icon: Icons.remove_shopping_cart,
    );
    if (_cartLines.length == 0) {
      _isCartEmpty = true;
    }
    setState(() {});
    couponCalculate();
    getFee();

  }

  void _clearCart() {
    Cart.getInstance.clear();
    _cartLines = [];
    showEdgeAlertWith(context,
        title: trans(context, "Success"),
        desc: trans(context, "Cart cleared"),
        style: EdgeAlertStyle.SUCCESS,
        icon: Icons.delete_outline);
    _isCartEmpty = true;
    setState(() {});
    couponCalculate();
    getFee();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(trans(context, "Shopping Cart"),
            style: Theme.of(context).appBarTheme.textTheme.headline6),
        textTheme: Theme.of(context).textTheme,
        elevation: 1,
        actions: <Widget>[
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Align(
              child: Padding(
                child: Text(trans(context, "Clear Cart"),
                    style: Theme.of(context).primaryTextTheme.bodyText1),
                padding: EdgeInsets.only(right: 8),
              ),
              alignment: Alignment.centerLeft,
            ),
            onTap: _clearCart,
          )
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: ListTile(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,

                title: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    hintText: 'Código Cupón',
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                trailing: Container(
                  width: 130.0,
                  height: 40.0,
                  child: wsPrimaryButton(
                    context,
                    title: "Aplicar Cupón",
                    action: _onCuponAction,
                  ),
                ),
              ),
            ),
            _isCartEmpty
                ? Expanded(
                    child: FractionallySizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(
                            Icons.shopping_cart,
                            size: 100,
                            color: Colors.black45,
                          ),
                          Padding(
                            child: Text(trans(context, "Empty Basket"),
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyText2),
                            padding: EdgeInsets.only(top: 10),
                          )
                        ],
                      ),
                      heightFactor: 0.5,
                      widthFactor: 1,
                    ),
                  )
                : (_isLoading
                    ? Expanded(child: showAppLoader())
                    : Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _cartLines.length,
                            itemBuilder: (BuildContext context, int index) {
                              CartLineItem cartLineItem = _cartLines[index];
                              return wsCardCartItem(
                                context,
                                cartLineItem: cartLineItem,
                                actionIncrementQuantity: () =>
                                    actionIncrementQuantity(
                                        cartLineItem: cartLineItem),
                                actionDecrementQuantity: () =>
                                    actionDecrementQuantity(
                                        cartLineItem: cartLineItem),
                                actionRemoveItem: () =>
                                    actionRemoveItem(index: index),
                              );
                            }),
                        flex: 3,
                      )),
            ListTile(
              title: Text(_couponResultTitle,
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
              subtitle: Text(_couponResultSubtitle,
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
              trailing: Text(_couponResultTailing,
                style: Theme.of(context).primaryTextTheme.bodyText2,
              ),
            ),
            Divider(
              color: Colors.black45,
            ),
            _isCalculating
            ? Padding(
              padding: EdgeInsets.only(bottom: 15, top: 15),
              child: Center(child: Text('Calculating...')),
            )
            : Column(
              children: List.generate(feeResult.length + 1, (index) {
                if (index < feeResult.length) {
                  return wsRow2Text(context,
                    text1: feeResult[index]['name'],
                    text2: '-L ' + (-feeResult[index]['amount']).toStringAsFixed(2),
                  );
                } else {
                  return new Padding(
                    padding: EdgeInsets.only(bottom: 15, top: 15),
                    child: wsRow2Text(context,
                      text1: trans(context, "Total"),
                      text2: 'L ' + (_couponTotalPrice + discount).toStringAsFixed(2),
                    ),
                  );
                }
              }),
            ),

//            FutureBuilder<String>(
//              future: Cart.getInstance.getTotal(withFormat: true),
//              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//                switch (snapshot.connectionState) {
//                  case ConnectionState.waiting:
//                    return Text("");
//                  default:
//                    if (snapshot.hasError)
//                      return Text("");
//                    else
//                      print('total ${snapshot.data}');
//                      return new Padding(
//                        child: wsRow2Text(context,
//                            text1: trans(context, "Total"),
//                            text2: (_isLoading ? "" : snapshot.data)),
//                        padding: EdgeInsets.only(bottom: 15, top: 15),
//                      );
//                }
//              },
//            ),
            wsPrimaryButton(
              context,
              title: trans(context, "PROCEED TO CHECKOUT"),
              action: _actionProceedToCheckout,
            ),
          ],
        ),
      ),
    );
  }

  couponCalculate() async {
    final prefs = await SharedPreferences.getInstance();
    switch(_couponType) {
      case '': {
        setState(() {
          _couponResultTitle = '';
          _couponResultSubtitle = '';
          _couponResultTailing = '';
          _couponTotalPrice = getCartTotalPrice();
        });
        prefs.setString('coupon', '0');
      }
      break;

      case 'wrong': {
        setState(() {
          _couponResultTitle = 'CUPÓN';
          _couponResultSubtitle = 'Coupon Code Wrong!';
          _couponResultTailing = '';
          _couponTotalPrice = getCartTotalPrice();
        });
        prefs.setString('coupon', '0');
      }
      break;

      case 'fixed_cart': {
        setState(() {
          _couponResultTitle = 'CUPÓN';
          _couponResultSubtitle = _couponCode;
          _couponResultTailing = '-L ' + _couponAmount.toString();
          _couponTotalPrice = getCartTotalPrice() - _couponAmount;
        });
        prefs.setString('coupon', _couponAmount.toString());
      }
      break;

      case 'fixed_product': {
        setState(() {
          _couponResultTitle = 'CUPÓN';
          _couponResultSubtitle = _couponCode;
          _couponResultTailing = '-L ' + (_couponAmount * getCartQuentity()).toString();
          _couponTotalPrice = getCartTotalPrice() - _couponAmount * getCartQuentity();
        });
        prefs.setString('coupon', (_couponAmount * getCartQuentity()).toString());
      }
      break;

      case 'percent': {
        setState(() {
          _couponResultTitle = 'CUPÓN';
          _couponResultSubtitle = _couponCode;
          _couponResultTailing = '-L ' + (_couponAmount * getCartTotalPrice() / 100).toString();
          _couponTotalPrice = getCartTotalPrice() - _couponAmount * getCartTotalPrice() / 100;
        });
        prefs.setString('coupon', (_couponAmount * getCartTotalPrice() / 100).toString());
      }
      break;

      default: {
        //statements;
      }
      break;
    }
  }

  _onCuponAction() async {
    print(couponController.text);
    print('cartline ${_cartLines[0].quantity}');
    String code = couponController.text;
    setState(() {
      _couponCode = code;
    });
    if (code == '') return;
    var url = global.base_url + 'wp-json/api/flutter/get_coupons';
    print('url: ${url}');
    var response = await http.get(url);
    bool isCodeValid = false;

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      jsonResponse.forEach((element) {
        print('code ${code}');
        print('elementcode ${element['code']}');
        print(element['code'] == code);
        if (element['code'] == code) {
          isCodeValid = true;
          var now = new DateTime.now();
          if (DateTime.parse(element['expiry_date']).isAfter(now)) {
            setState(() {
              _couponType = element['type'];
              _couponAmount = double.parse(element['amount']);
            });
          } else {
            print('This code is expired!');
          }
        }
      });
      if (!isCodeValid) {
        print('Coupon Code Wrong!');
        setState(() {
          _couponType = 'wrong';
          _couponAmount = 0;
//          _couponResultTitle = 'CUPÓN';
//          _couponResultSubtitle = 'Coupon Code Wrong!';
//          _couponResultTailing = '';
        });
      }
    } else {
      print('Coupon Code Wrong!');
      setState(() {
        _couponType = 'wrong';
        _couponAmount = 0;
//        _couponResultTitle = 'CUPÓN';
//        _couponResultSubtitle = 'Coupon Code Wrong!';
//        _couponResultTailing = '';
      });
    }
    couponCalculate();
    getFee();

  }

  int getCartQuentity() {
    int quentities = 0;
    _cartLines.forEach((element) {
      quentities += element.quantity;
    });

    return quentities;
  }

  double getCartTotalPrice() {
    double total = 0;
    _cartLines.forEach((element) {
      total += double.parse(element.subtotal) * element.quantity;
    });

    return total;
  }
}
