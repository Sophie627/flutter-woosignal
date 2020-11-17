//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/shared_pref/sp_auth.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/pages/address.dart';
import 'package:label_storemax/pages/checkout_details.dart';
import 'package:label_storemax/pages/checkout_payment_type.dart';
import 'package:label_storemax/widgets/menu_item.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:wp_json_api/wp_json_api.dart';
import 'global.dart' as global;
import '../widgets/woosignal_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeMenuPage extends StatefulWidget {
  HomeMenuPage();

  @override
  _HomeMenuPageState createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {
  _HomeMenuPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          trans(context, "Menu"),
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            storeLogo(height: 100),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  (use_wp_login
                      ? wsMenuItem(
                          context,
                          title: trans(context, "Profile"),
                          leading: Icon(Icons.account_circle),
                          action: _actionProfile,
                        )
                      : Container()),
                  wsMenuItem(
                    context,
                    title: trans(context, "Cart"),
                    leading: Icon(Icons.shopping_cart),
                    action: _actionCart,
                  ),
                  wsMenuItem(
                    context,
                    title: "Direccion",
                    leading: Icon(Icons.home),
                    action: _actionAddress,
                  ),
                  wsMenuItem(
                    context,
                    title: "Tarjeta de crédito",
                    leading: Icon(Icons.credit_card),
                    action: _actionCreditCard,
                  ),
                  wsMenuItem(
                    context,
                    title: (global.base_url == "https://presstofoods.com/")
                        ? "SAP, Cambiar ciudad a: TGU"
                        : "TGU, Cambiar ciudad a: SAP",
                    leading: Icon(Icons.compare_arrows),
                    action: _changeCity,
                  ),
                  wsMenuItem(
                    context,
                    title: trans(context, "About Us"),
                    leading: Icon(Icons.account_balance),
                    action: _actionAboutUs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _actionCart() {
    Navigator.pushNamed(context, "/cart");
  }

  void _actionAboutUs() {
    Navigator.pushNamed(context, "/about");
  }

  void _actionCreditCard() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CheckoutPaymentTypePage(
          isCheckout: false,
        )));
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => CreditCardPage()));
  }

  void _actionAddress() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CheckoutDetailsPage(
          isCheckout: false,
        )));
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => AddressPage()));
  }

  void _actionProfile() async {
    if (use_wp_login == true && !(await authCheck())) {
      UserAuth.instance.redirect = "/account-detail";
      Navigator.pushNamed(context, "/account-landing");
      return;
    }
    Navigator.pushNamed(context, "/account-detail");
  }

  void _changeCity() {
    global.base_url = (global.base_url == 'https://presstofoods.com/')
        ? 'https://presstofoods.com/tgu/'
        : 'https://presstofoods.com/';
    var key = (global.base_url == 'https://presstofoods.com/')
        ? 'SAP_loggedIn'
        : 'TGU_loggedIn';
    app_key = (key == 'SAP_loggedIn')
        ? "app_961e365f250f092f7f5769d6c3b9fb027b2b1bac9fb9d65549f823541ab6"
        : "app_ac307452d5ab50f5129996fb23563db6b14055521f5e0a2c8bb6b0b8669a";
    if (use_wp_login == true) {
      WPJsonAPI.instance.initWith(
          baseUrl: app_base_url,
          shouldDebug: app_debug,
          wpJsonPath: app_wp_api_path);
    }
    print(key);
    _getLogInSession(key).then((value) {
      print(value);
      (value)
          ? navigatorPush(context, routeName: '/home')
          : navigatorPush(context, routeName: '/account-landing');
    });
  }

  static Future<bool> _getLogInSession(key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(key) ?? false;
    print(value);
    if (value)
      return Future.value(true);
    else
      return Future.value(false);
  }
}
