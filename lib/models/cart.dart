//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'dart:convert';

import 'package:label_storemax/helpers/shared_pref.dart';
import 'package:label_storemax/models/cart_line_item.dart';
import 'package:label_storemax/models/checkout_session.dart';
import 'package:label_storemax/models/shipping_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woosignal/models/response/shipping_method.dart';
import 'package:woosignal/models/response/tax_rate.dart';
import '../pages/global.dart' as global;
import 'package:http/http.dart' as http;

import '../helpers/tools.dart';

class Cart {
  String _keyCart = "CART_SESSION";

  Cart._privateConstructor();
  static final Cart getInstance = Cart._privateConstructor();

  Future getCartFees() async {
    String productIDs = '';
    String productQuantity = '';
    List<CartLineItem> cartLineItems = [];
    SharedPref sharedPref = SharedPref();
    String currentCartArrJSON = (await sharedPref.read(_keyCart) as String);
    if (currentCartArrJSON == null) {
      cartLineItems = List<CartLineItem>();
    } else {
      cartLineItems = (jsonDecode(currentCartArrJSON) as List<dynamic>)
          .map((i) => CartLineItem.fromJson(i))
          .toList();
    }
    cartLineItems.forEach((element) {
      productIDs += element.productId.toString() + ',';
      productQuantity += element.quantity.toString() + ',';
    });

    var url = global.base_url + 'wp-json/api/flutter/get_discount?product_id=${productIDs}&product_quantity=${productQuantity}';
    print('url');
    print(url);
    var response = await http.get(url);
    return jsonDecode(response.body);
  }

  Future<List<CartLineItem>> getCart() async {
    List<CartLineItem> cartLineItems = [];
    SharedPref sharedPref = SharedPref();
    String currentCartArrJSON = (await sharedPref.read(_keyCart) as String);
    if (currentCartArrJSON == null) {
      cartLineItems = List<CartLineItem>();
    } else {
      cartLineItems = (jsonDecode(currentCartArrJSON) as List<dynamic>)
          .map((i) => CartLineItem.fromJson(i))
          .toList();
    }
    return cartLineItems;
  }

  void addToCart({CartLineItem cartLineItem}) async {
    List<CartLineItem> cartLineItems = await getCart();

    if (cartLineItem.variationId != null) {
      if (cartLineItems.firstWhere(
              (i) => (i.productId == cartLineItem.productId &&
                  i.variationId == cartLineItem.variationId),
              orElse: () => null) !=
          null) {
        return;
      }
    } else {
      var firstCartItem = cartLineItems.firstWhere(
          (i) => i.productId == cartLineItem.productId,
          orElse: () => null);
      if (firstCartItem != null) {
        return;
      }
    }
    cartLineItems.add(cartLineItem);

    saveCartToPref(cartLineItems: cartLineItems);
  }

  Future<String> getTotal({bool withFormat}) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartLineItem> cartLineItems = await getCart();
    double total = 0;
    cartLineItems.forEach((cartItem) {
      total += (parseWcPrice(cartItem.total) * cartItem.quantity);
    });
    total -= double.parse(prefs.getString('coupon'));
    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: total);
    }
    return total.toStringAsFixed(2);
  }

  Future<String> getSubtotal({bool withFormat}) async {
    final prefs = await SharedPreferences.getInstance();
    print('prefs ${prefs.getString('coupon')}');
    List<CartLineItem> cartLineItems = await getCart();
    double subtotal = 0;
    cartLineItems.forEach((cartItem) {
      subtotal += (parseWcPrice(cartItem.subtotal) * cartItem.quantity);
    });
    subtotal -= double.parse(prefs.getString('coupon'));
    if (withFormat != null && withFormat == true) {
      return formatDoubleCurrency(total: subtotal);
    }
    return subtotal.toStringAsFixed(2);
  }

  void updateQuantity(
      {CartLineItem cartLineItem, int incrementQuantity}) async {
    List<CartLineItem> cartLineItems = await getCart();
    List<CartLineItem> tmpCartItem = new List<CartLineItem>();
    cartLineItems.forEach((cartItem) {
      if (cartItem.variationId == cartLineItem.variationId &&
          cartItem.productId == cartLineItem.productId) {
        if ((cartItem.quantity + incrementQuantity) > 0) {
          cartItem.quantity += incrementQuantity;
        }
      }
      tmpCartItem.add(cartItem);
    });
    saveCartToPref(cartLineItems: tmpCartItem);
  }

  Future<String> cartShortDesc() async {
    List<CartLineItem> cartLineItems = await getCart();
    var tmpShortItemDesc = [];
    cartLineItems.forEach((cartItem) {
      tmpShortItemDesc
          .add(cartItem.quantity.toString() + " x | " + cartItem.name);
    });
    return tmpShortItemDesc.join(",");
  }

  void removeCartItemForIndex({int index}) async {
    List<CartLineItem> cartLineItems = await getCart();
    cartLineItems.removeAt(index);
    saveCartToPref(cartLineItems: cartLineItems);
  }

  void clear() {
    SharedPref sharedPref = SharedPref();
    List<CartLineItem> cartLineItems = new List<CartLineItem>();
    String jsonArrCartItems =
        jsonEncode(cartLineItems.map((i) => i.toJson()).toList());
    sharedPref.save(_keyCart, jsonArrCartItems);
  }

  void saveCartToPref({List<CartLineItem> cartLineItems}) {
    SharedPref sharedPref = SharedPref();
    String jsonArrCartItems =
        jsonEncode(cartLineItems.map((i) => i.toJson()).toList());
    sharedPref.save(_keyCart, jsonArrCartItems);
  }

  Future<String> taxAmount(TaxRate taxRate) async {
    double subtotal = 0;
    double shippingTotal = 0;

    List<CartLineItem> cartItems = await Cart.getInstance.getCart();

    if (cartItems.every((c) => c.taxStatus == 'none')) {
      return "0";
    }
    List<CartLineItem> taxableCartLines =
        cartItems.where((c) => c.taxStatus == 'taxable').toList();
    double cartSubtotal = 0;

    if (taxableCartLines.length > 0) {
      cartSubtotal = taxableCartLines
          .map<double>((m) => parseWcPrice(m.subtotal))
          .reduce((a, b) => a + b);
    }

    subtotal = cartSubtotal;

    ShippingType shippingType = CheckoutSession.getInstance.shippingType;

    if (shippingType != null) {
      switch (shippingType.methodId) {
        case "flat_rate":
          FlatRate flatRate = (shippingType.object as FlatRate);
          if (flatRate.taxable != null && flatRate.taxable) {
            shippingTotal += parseWcPrice(
                shippingType.cost == null || shippingType.cost == ""
                    ? "0"
                    : shippingType.cost);
          }
          break;
        case "local_pickup":
          LocalPickup localPickup = (shippingType.object as LocalPickup);
          if (localPickup.taxable != null && localPickup.taxable) {
            shippingTotal += parseWcPrice(
                (localPickup.cost == null || localPickup.cost == ""
                    ? "0"
                    : localPickup.cost));
          }
          break;
        default:
          break;
      }
    }

    double total = 0;
    if (subtotal != 0) {
      total += ((parseWcPrice(taxRate.rate) * subtotal) / 100);
    }
    if (shippingTotal != 0) {
      total += ((parseWcPrice(taxRate.rate) * shippingTotal) / 100);
    }
    return (total).toStringAsFixed(2);
  }
}
