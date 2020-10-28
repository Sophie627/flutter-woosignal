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
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/labelconfig.dart';
import 'package:label_storemax/widgets/menu_item.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressPage extends StatefulWidget {
  AddressPage();

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  _AddressPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Direccion",
            style: Theme.of(context).primaryTextTheme.headline6),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: storeLogo(),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FutureBuilder<String>(
                      future: _getBillingAddress(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return createBillingAddressView(context, snapshot);
                      }),
                  FutureBuilder<String>(
                      future: _getShippingAddress(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return createShippingAddressView(context, snapshot);
                      }),
                  Container(
                    child: wsMenuItem(
                      context,
                      title: "Crear nuevo",
                      leading: Icon(Icons.add_location),
                      action: _addAddress,
                    ),
                  ),
                  Column()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<String> _getBillingAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final addressJson = prefs.getString("billingAddress") ?? 'noAddress';
    print(addressJson);
    return addressJson;
  }

  static Future<String> _getShippingAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final addressJson = prefs.getString("shippingAddress") ?? 'noAddress';
    print(addressJson);
    return addressJson;
  }

  Widget createBillingAddressView(
      BuildContext context, AsyncSnapshot snapshot) {
    var values = snapshot.data == 'noAddress' ? [{'first_name': 'noAddress'}] : jsonDecode(snapshot.data);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 30.0,
        ),
        Text('Billing Address'),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: values == null ? 0 : values.length,
          itemBuilder: (BuildContext context, int index) {
            print(values.length);
            var value = Map<String, dynamic>.from(values[index]);
            return Container(
              height: 30.0,
              child: Text(value['first_name']),
            );
          },
        )
      ],
    );
  }

  Widget createShippingAddressView(
      BuildContext context, AsyncSnapshot snapshot) {
    var values = snapshot.data == 'noAddress' ? [{'first_name': 'noAddress'}] : jsonDecode(snapshot.data);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 30.0,
        ),
        Text('Billing Address'),
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: values == null ? 0 : values.length,
          itemBuilder: (BuildContext context, int index) {
            print(values.length);
            var value = Map<String, dynamic>.from(values[index]);
            return Container(
              height: 30.0,
              child: Text(value['first_name']),
            );
          },
        )
      ],
    );
  }

  _addAddress() {}
}
