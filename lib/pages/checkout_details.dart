//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:label_storemax/app_state_options.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/models/billing_details.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/customer_address.dart';
import 'package:label_storemax/widgets/buttons.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:label_storemax/app_country_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart' as global;

class CheckoutDetailsPage extends StatefulWidget {
  CheckoutDetailsPage();

  @override
  _CheckoutDetailsPageState createState() => _CheckoutDetailsPageState();
}

class _CheckoutDetailsPageState extends State<CheckoutDetailsPage> {
  _CheckoutDetailsPageState();

  bool _valDifferentShippingAddress = false;
  bool _isAddAddress = false;
  int activeTabIndex = 0;
  String newAddress;
  List addresses;
  String tab;

  // BILLING TEXT CONTROLLERS
  TextEditingController _txtBillingFirstName;
  TextEditingController _txtBillingLastName;
  TextEditingController _txtBillingAddressLine;
  TextEditingController _txtBillingCity;
  TextEditingController _txtBillingPostalCode;
  TextEditingController _txtBillingEmailAddress;

  TextEditingController _txtShippingFirstName;
  TextEditingController _txtShippingLastName;
  TextEditingController _txtShippingAddressLine;
  TextEditingController _txtShippingCity;
  TextEditingController _txtShippingPostalCode;
  TextEditingController _txtShippingEmailAddress;

  String _strBillingCountry;
  String _strBillingState;

  String _strShippingCountry;
  String _strShippingState;

  var valRememberDetails = true;
  Widget activeTab;

//AQUI NO CAPTURAR MAS QUE LA DIRECCION Y ALMACENARLA EN LA BASE DE DATOS LOCAL PARA LUEGO MOSTRAR
//AQUI MISMO CON IF, SI HAY DIRECCIÓN Q SALGA PARA SELECCIONARLA O AGREGAR OTRA

  Widget tabShippingDetails() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _valDifferentShippingAddress
              ? Divider(
                  height: 0,
                )
              : null,
          Flexible(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: wsTextEditingRow(
                    context,
                    heading: trans(context, "Address Line"),
                    controller: _txtShippingAddressLine,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    "HONDURAS",
                    style: TextStyle(fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    ((global.base_url == 'https://presstofoods.com/dev/')
                        ? 'SAN PEDRO SULA'
                        : 'TEGUCIGALPA'),
                    style: TextStyle(fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ].where((e) => e != null).toList(),
      ),
    );
  }

  Widget tabBillingDetails() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _valDifferentShippingAddress
              ? Divider(
                  height: 0,
                )
              : null,
          Flexible(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: wsTextEditingRow(
                    context,
                    heading: trans(context, "First Name"),
                    controller: _txtBillingFirstName,
                    shouldAutoFocus: true,
                  ),
                ),
                Flexible(
                  child: wsTextEditingRow(
                    context,
                    heading: trans(context, "Last Name"),
                    controller: _txtBillingLastName,
                  ),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: wsTextEditingRow(context,
                      heading: trans(context, "Email address"),
                      keyboardType: TextInputType.emailAddress,
                      controller: _txtBillingEmailAddress),
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: wsTextEditingRow(
                    context,
                    heading: trans(context, "Address Line"),
                    controller: _txtBillingAddressLine,
                  ),
                ),
                // Flexible(
                //   child: wsTextEditingRow(
                //     context,
                //     heading: trans(context, "Postal code"),
                //     controller: _txtBillingPostalCode,
                //   ),
                // ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    "HONDURAS",
                    style: TextStyle(fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    ((global.base_url == 'https://presstofoods.com/dev/')
                        ? 'SAN PEDRO SULA'
                        : 'TEGUCIGALPA'),
                    style: TextStyle(fontSize: 17.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ].where((e) => e != null).toList(),
      ),
    );
  }

  Widget selectAddress() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Text(
            "Select Address",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListTile(
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Address',
                border: new UnderlineInputBorder(
                  borderSide: new BorderSide(color: Colors.black),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  newAddress = value;
                });
              },
            ),
            trailing: Container(
              width: 130.0,
              height: 40.0,
              child: RaisedButton(
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                  ),
                ),
                onPressed: _saveAddresses,
              ),
            ),
          ),
          FutureBuilder<String>(
            future: _getAddresses(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (!snapshot.hasData) {
                return Text('No Address');
              } else {
                if (snapshot.data == 'no Address') {
                  return Text('No Address');
                } else {
                  var addresses = jsonDecode(snapshot.data);
                  return Flexible(
                    child: ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: EdgeInsets.only(bottom: 5.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: Colors.grey[300],
                                  ),
                                  height: 40.0,
                                  // color: Colors.blueAccent,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            addresses[index],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 17.0),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(right: 10.0),
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.publish,
                                              color: Colors.blue,
                                            ),
                                            onTap: () => _publishAddress(index),
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(right: 15.0),
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onTap: () => _removeAddress(index),
                                          ))
                                    ],
                                  )));
                        }),
                  );
                }
              }
            },
          )
        ],
      ),
    );
  }

  Widget selectAddresses() {
    return Center(
      child: Container(
        child: Column(
          children: [
            Text('Select Address',
              style: Theme.of(context).primaryTextTheme.headline6,
            ),
            SizedBox(
              height: 40.0,
            ),
            Text('Billing Address: Test Billing Address',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
            SizedBox(
              height: 40.0,
            ),
            Text('Shipping 1: Test Shipping Address 1',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
            SizedBox(
              height: 5.0,
            ),
            Text('Shipping 2: Test Shipping Address 2',
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
            SizedBox(
              height: 40.0,
            ),
            Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    _isAddAddress = true;
                  });
                },
                child: Text('Add an Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    newAddress = '';
    _getAddresses().then((value) => addresses = jsonDecode(value));
    tab = 'billing';

    // SHIPPING
    _txtShippingFirstName = TextEditingController();
    _txtShippingLastName = TextEditingController();
    _txtShippingAddressLine = TextEditingController();
    _txtShippingCity = TextEditingController();
    _txtShippingPostalCode = TextEditingController();
    _txtShippingEmailAddress = TextEditingController();

    // BILLING
    _txtBillingFirstName = TextEditingController();
    _txtBillingLastName = TextEditingController();
    _txtBillingAddressLine = TextEditingController();
    _txtBillingCity = TextEditingController();
    _txtBillingPostalCode = TextEditingController();
    _txtBillingEmailAddress = TextEditingController();

    if (CheckoutSession.getInstance.billingDetails.billingAddress == null) {
      CheckoutSession.getInstance.billingDetails.initSession();
      CheckoutSession.getInstance.billingDetails.shippingAddress.initAddress();
      CheckoutSession.getInstance.billingDetails.billingAddress.initAddress();
    }
    BillingDetails billingDetails = CheckoutSession.getInstance.billingDetails;
    _txtBillingFirstName.text = billingDetails.billingAddress.firstName;
    _txtBillingLastName.text = billingDetails.billingAddress.lastName;
    _txtBillingAddressLine.text = billingDetails.billingAddress.addressLine;
    _txtBillingCity.text = billingDetails.billingAddress.city;
    _txtBillingPostalCode.text = billingDetails.billingAddress.postalCode;
    _txtBillingEmailAddress.text = billingDetails.billingAddress.emailAddress;
    _strBillingCountry = billingDetails.billingAddress.country;
    _strBillingState = billingDetails.billingAddress.state;

    _txtShippingFirstName.text = billingDetails.shippingAddress.firstName;
    _txtShippingLastName.text = billingDetails.shippingAddress.lastName;
    _txtShippingAddressLine.text = billingDetails.shippingAddress.addressLine;
    _txtShippingCity.text = billingDetails.shippingAddress.city;
    _txtShippingPostalCode.text = billingDetails.shippingAddress.postalCode;
    _txtShippingEmailAddress.text = billingDetails.shippingAddress.emailAddress;
    _strShippingCountry = billingDetails.shippingAddress.country;
    _strShippingState = billingDetails.shippingAddress.state;

    _valDifferentShippingAddress =
        CheckoutSession.getInstance.shipToDifferentAddress;
    valRememberDetails = billingDetails.rememberDetails ?? true;
    _sfCustomerAddress();
  }

  _sfCustomerAddress() async {
    CustomerAddress sfCustomerBillingAddress =
        await CheckoutSession.getInstance.getBillingAddress();
    if (sfCustomerBillingAddress != null) {
      CustomerAddress customerAddress = sfCustomerBillingAddress;
      _txtBillingFirstName.text = customerAddress.firstName;
      _txtBillingLastName.text = customerAddress.lastName;
      _txtBillingAddressLine.text = customerAddress.addressLine;
      _txtBillingCity.text = customerAddress.city;
      _txtBillingPostalCode.text = customerAddress.postalCode;
      _txtBillingEmailAddress.text = customerAddress.emailAddress;
      _strBillingState = customerAddress.state;
      _strBillingCountry = customerAddress.country;
    }

    CustomerAddress sfCustomerShippingAddress =
        await CheckoutSession.getInstance.getShippingAddress();
    if (sfCustomerShippingAddress != null) {
      CustomerAddress customerAddress = sfCustomerShippingAddress;
      _txtShippingFirstName.text = customerAddress.firstName;
      _txtShippingLastName.text = customerAddress.lastName;
      _txtShippingAddressLine.text = customerAddress.addressLine;
      _txtShippingCity.text = customerAddress.city;
      _txtShippingPostalCode.text = customerAddress.postalCode;
      _txtShippingEmailAddress.text = customerAddress.emailAddress;
      _strShippingCountry = customerAddress.country;
      _strShippingState = customerAddress.state;
    }
  }

  _showSelectCountryModal(String type) {
    wsModalBottom(
      context,
      title: trans(context, "Select a country"),
      bodyWidget: ListView.separated(
        itemCount: appCountryOptions.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, String> strName = appCountryOptions[index];

          return InkWell(
            child: Container(
              child: Text(strName["name"],
                  style: Theme.of(context).primaryTextTheme.bodyText1),
              padding: EdgeInsets.only(top: 25, bottom: 25),
            ),
            splashColor: Colors.grey,
            highlightColor: Colors.black12,
            onTap: () => setState(() {
              if (type == "shipping") {
                _strShippingCountry = strName["name"];
                activeTab = tabShippingDetails();
                tab = 'shipping';
                Navigator.of(context).pop();
                if (strName["code"] == "US") {
                  _showSelectStateModal(type);
                } else {
                  _strShippingState = "";
                }
              } else if (type == "billing") {
                _strBillingCountry = strName["name"];
                Navigator.of(context).pop();
                activeTab = tabBillingDetails();
                tab = 'billing';
                if (strName["code"] == "US") {
                  _showSelectStateModal(type);
                } else {
                  _strBillingState = "";
                }
              }
            }),
          );
        },
        separatorBuilder: (cxt, i) => Divider(
          height: 0,
          color: Colors.black12,
        ),
      ),
    );
  }

  _showSelectStateModal(String type) {
    wsModalBottom(
      context,
      title: trans(context, "Select a state"),
      bodyWidget: ListView.separated(
        itemCount: appStateOptions.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, String> strName = appStateOptions[index];

          return InkWell(
            child: Container(
              child: Text(
                strName["name"],
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
              padding: EdgeInsets.only(top: 25, bottom: 25),
            ),
            splashColor: Colors.grey,
            highlightColor: Colors.black12,
            onTap: () => setState(() {
              if (type == "shipping") {
                _strShippingState = strName["name"];
                Navigator.of(context).pop();
                activeTab = tabShippingDetails();
                tab = 'shipping';
              } else if (type == "billing") {
                _strBillingState = strName["name"];
                Navigator.of(context).pop();
                activeTab = tabBillingDetails();
                tab = 'billing';
              }
            }),
          );
        },
        separatorBuilder: (cxt, i) => Divider(
          height: 0,
          color: Colors.black12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          trans(context, "Billing & Shipping Details"),
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        centerTitle: true,
      ),
      body: _isAddAddress
      ? SafeArea(
        minimum: safeAreaDefault(),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _valDifferentShippingAddress
                            ? Padding(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Flexible(
                                      child: InkWell(
                                        child: Container(
                                          width: double.infinity,
                                          child: Text(
                                            trans(context, "Billing Details"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .copyWith(
                                                    color: activeTabIndex == 0
                                                        ? Colors.white
                                                        : Colors.black),
                                            textAlign: TextAlign.center,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: activeTabIndex == 0
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 4),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            activeTabIndex = 0;
                                            activeTab = tabBillingDetails();
                                            tab = 'billing';
                                          });
                                        },
                                      ),
                                    ),
                                    Flexible(
                                      child: InkWell(
                                        child: Container(
                                          width: double.infinity,
                                          child: Text(
                                            trans(context, "Shipping Address"),
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle1
                                                .copyWith(
                                                    color: activeTabIndex == 1
                                                        ? Colors.white
                                                        : Colors.black),
                                            textAlign: TextAlign.center,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: activeTabIndex == 1
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            activeTabIndex = 1;
                                            activeTab = tabShippingDetails();
                                            tab = 'shipping';
                                          });
                                        },
                                      ),
                                    )
                                  ].where((e) => e != null).toList(),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8),
                              )
                            : null,
                        activeTab ?? tabBillingDetails(),
                      ].where((e) => e != null).toList(),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: wsBoxShadow(),
                    ),
                    padding: EdgeInsets.all(8),
                  ),
                  height: (constraints.maxHeight - constraints.minHeight) * 0.4,
                ),
                selectAddress(),
                Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          trans(context, "Ship to a different address?"),
                          style: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                        Checkbox(
                          value: _valDifferentShippingAddress,
                          onChanged: _onChangeShipping,
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          trans(context, "Remember my details"),
                          style: Theme.of(context).primaryTextTheme.bodyText2,
                        ),
                        Checkbox(
                          value: valRememberDetails,
                          onChanged: (bool value) {
                            setState(() {
                              valRememberDetails = value;
                            });
                          },
                        )
                      ],
                    ),
                    wsPrimaryButton(context,
                        title: trans(context, "USE DETAILS"),
                        action: () => _useDetailsTapped()),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
      : selectAddresses(),
    );
  }

  _publishAddress(int index) {
    var address = addresses[index];
    print(tab);
    if (tab == 'billing') {
      setState(() {
        _txtBillingAddressLine.text = address;
      });
    } else if (tab == 'shipping') {
      setState(() {
        _txtShippingAddressLine.text = address;
      });
    }
  }

  _removeAddress(int index) async {
    print(index);
    final prefs = await SharedPreferences.getInstance();
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_address';
    addresses.removeAt(index);
    var value = jsonEncode(addresses);
    print(value);
    prefs.setString(key, value);
    setState(() {
      addresses = addresses;
    });
  }

  _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    var address = newAddress;
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_address';
    _getAddresses().then((String value) {
      if (value != "no Address") {
        addresses = jsonDecode(value);
        setState(() {
          addresses = addresses;
        });
      }
      if (!addresses.contains(address)) {
        print(addresses);
        print(address);
        addresses.add(address);
        var value = jsonEncode(addresses);
        prefs.setString(key, value);
      }
    });
  }

  static Future<String> _getAddresses() async {
    var key =
        ((global.base_url == 'https://presstofoods.com/dev/') ? 'SAP' : 'TGU') +
            '_address';
    final prefs = await SharedPreferences.getInstance();
    final addressJson = prefs.getString(key) ?? 'no Address';
    return addressJson;
  }

  _useDetailsTapped() {
    CustomerAddress customerBillingAddress = new CustomerAddress();
    customerBillingAddress.firstName = _txtBillingFirstName.text;
    customerBillingAddress.lastName = _txtBillingLastName.text;
    customerBillingAddress.addressLine = _txtBillingAddressLine.text;
    customerBillingAddress.city =
        ((global.base_url == 'https://presstofoods.com/dev/')
            ? 'SAN PEDRO SULA'
            : 'TEGUCIGALPA');
    customerBillingAddress.postalCode = "000000";
    customerBillingAddress.state = "111111";
    customerBillingAddress.country = "Honduras";
    customerBillingAddress.emailAddress = _txtBillingEmailAddress.text;

    if (!_valDifferentShippingAddress) {
      CheckoutSession.getInstance.billingDetails.shippingAddress =
          customerBillingAddress;

      CheckoutSession.getInstance.billingDetails.billingAddress =
          customerBillingAddress;

      if (valRememberDetails == true) {
        CheckoutSession.getInstance.saveBillingAddress();
      }
    } else {
      CustomerAddress customerShippingAddress = new CustomerAddress();
      customerShippingAddress.firstName = _txtBillingFirstName.text;
      customerShippingAddress.lastName = _txtBillingLastName.text;
      customerShippingAddress.addressLine = _txtShippingAddressLine.text;
      customerShippingAddress.city =
          ((global.base_url == 'https://presstofoods.com/dev/')
              ? 'SAN PEDRO SULA'
              : 'TEGUCIGALPA');
      customerShippingAddress.postalCode = "000000";
      customerShippingAddress.state = "111111";
      customerShippingAddress.country = "Honduras";
      customerShippingAddress.emailAddress = _txtBillingEmailAddress.text;

      if (customerShippingAddress.hasMissingFields()) {
        showEdgeAlertWith(context,
            title: trans(context, "Oops"),
            desc: trans(
              context,
              trans(context,
                  "Invalid shipping address, please check your shipping details"),
            ),
            style: EdgeAlertStyle.WARNING);
        return;
      }

      CheckoutSession.getInstance.billingDetails.billingAddress =
          customerBillingAddress;

      CheckoutSession.getInstance.billingDetails.shippingAddress =
          customerShippingAddress;

      if (valRememberDetails == true) {
        CheckoutSession.getInstance.saveBillingAddress();
        CheckoutSession.getInstance.saveShippingAddress();
      }
    }

    CheckoutSession.getInstance.billingDetails.rememberDetails =
        valRememberDetails;

    if (valRememberDetails != true) {
      CheckoutSession.getInstance.clearBillingAddress();
      CheckoutSession.getInstance.clearShippingAddress();
    }

    CheckoutSession.getInstance.shipToDifferentAddress =
        _valDifferentShippingAddress;

    CheckoutSession.getInstance.shippingType = null;
    Navigator.pop(context);
  }

  _onChangeShipping(bool value) async {
    _valDifferentShippingAddress = value;
    activeTabIndex = 1;
    if (value == true) {
      activeTab = tabShippingDetails();
    } else {
      activeTab = tabBillingDetails();
    }
    CustomerAddress sfCustomerShippingAddress =
        await CheckoutSession.getInstance.getShippingAddress();
    if (sfCustomerShippingAddress == null) {
      _txtShippingFirstName.text = "";
      _txtShippingLastName.text = "";
      _txtShippingAddressLine.text = "";
      _txtShippingCity.text = "";
      _txtShippingPostalCode.text = "";
      _txtShippingEmailAddress.text = "";
      _strShippingState = "";
      _strShippingCountry = "";
    }
    setState(() {});
  }
}
