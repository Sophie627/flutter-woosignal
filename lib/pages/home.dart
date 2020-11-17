//  Label StoreMAX
//
//  Created by Anthony Gordon.
//  2020, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:label_storemax/helpers/tools.dart';
import 'package:label_storemax/pages/browse_category.dart';
// import 'package:label_storemax/pages/browse_category.dart';
import 'package:label_storemax/widgets/app_loader.dart';
import 'package:label_storemax/widgets/cart_icon.dart';
import 'package:label_storemax/widgets/woosignal_ui.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:woosignal/models/response/product_category.dart' as WS;
import 'global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  List _categories = [];
  List _categoriesToShow = [];
  bool _isLoading;
  final GlobalKey _key = GlobalKey();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List _topCategories = [];

  @override
  void initState() {
    super.initState();

    _saveSession();
    _isLoading = true;
    _categoriesToShow = [];
    _home();

    print("categories ${_categoriesToShow}");
  }

  _home() async {
    await _fetchCategories();
    setState(() {
      _categoriesToShow = _topCategories;
      _isLoading = false;
    });
  }

  _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    var value =
        (global.base_url == 'https://presstofoods.com/') ? 'SAP' : 'TGU';
    print('LastCity: $value');
    prefs.setString('lastCity', value);
  }

  _fetchCategories() async {
    var url = global.base_url + 'wp-json/api/flutter/get_categories';
    print('url');
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      _categories = jsonResponse[0];
      print(_categories.length);
      var parentID = 0;
      if (global.base_url == 'https://presstofoods.com/') {
        parentID = 238;
      } else {
        parentID = 235;
      }
      _categories.forEach((category) {
        if (category['parent'] == parentID) {
          _topCategories.add(category);
        }
      });
    }

    print(_categories[5]['image']);
  }

  void _onRefresh() async {
    // monitor network fetch
    _categories = [];
    _topCategories = [];
    await _fetchCategories();
    setState(() {
      _categoriesToShow = _topCategories;
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    _categories = [];
    _topCategories = [];
    await _fetchCategories();
    setState(() {
      _categoriesToShow = _topCategories;
    });
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Container(
          child: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Navigator.pushNamed(context, "/home-menu"),
          ),
          margin: EdgeInsets.only(left: 0),
        ),
        title: storeLogo(height: 50),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.search,
              color: Colors.black,
              size: 35,
            ),
            onPressed: () => Navigator.pushNamed(context, "/home-search")
                .then((value) => _key.currentState.setState(() {})),
          ),
          wsCartIcon(context, key: _key),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: safeAreaDefault(),
        child: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  ((global.base_url == 'https://presstofoods.com/')
                      ? 'SAN PEDRO SULA'
                      : 'TEGUCIGALPA'),
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              (_isLoading
                  ? Expanded(child: showAppLoader())
                  : Expanded(
                      child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: false,
                        header: WaterDropHeader(),
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = Text('Pull up load');
                            } else if (mode == LoadStatus.loading) {
                              body = CupertinoActivityIndicator();
                            } else if (mode == LoadStatus.failed) {
                              body = Text("Load Failed!Click retry!");
                            } else if (mode == LoadStatus.canLoading) {
                              body = Text("release to load more");
                            } else {
                              body = Text("No more Data");
                            }
                            return Container(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: GridView.builder(
                            itemCount: _categoriesToShow.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemBuilder: (ctx, index) {
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.0),
                                    child: InkWell(
                                        onTap: () {
                                          var _subCategories = [];
                                          _categories.forEach((category) {
                                            if (category['parent'] ==
                                                _categoriesToShow[index]
                                                    ['id']) {
                                              _subCategories.add(category);
                                            }
                                          });
                                          if (_subCategories.length != 0) {
                                            setState(() {
                                              print('ok');
                                              _categoriesToShow =
                                                  _subCategories;
                                            });
                                          } else {
                                            print(
                                                _categoriesToShow[index]['id']);
                                            WS.Image image = WS.Image(
                                                id: _categoriesToShow[index]
                                                    ['id'],
                                                src: _categoriesToShow[index]
                                                    ['image'],
                                                alt: _categoriesToShow[index]
                                                    ['name']);
                                            WS.ProductCategory productCategory =
                                                WS.ProductCategory(
                                                    id:
                                                        _categoriesToShow[index]
                                                            ['id'],
                                                    name:
                                                        _categoriesToShow[index]
                                                            ['name'],
                                                    slug:
                                                        _categoriesToShow[index]
                                                            ['slug'],
                                                    parent:
                                                        _categoriesToShow[index]
                                                            ['parent'],
                                                    image: image,
                                                    description:
                                                        _categoriesToShow[index]
                                                            ['name'],
                                                    display:
                                                        _categoriesToShow[index]
                                                            ['name'],
                                                    menuOrder:
                                                        _categoriesToShow[index]
                                                            ['id'],
                                                    count: 5);
                                            // Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BrowseCategoryPage(
                                                            productCategory:
                                                                productCategory)));
                                          }
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Container(
                                              child: ClipRRect(
                                                child: Image.network(
                                                  _categoriesToShow[index]
                                                      ['image'],
                                                  height: 120.0,
                                                  width: 150.0,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10.0,
                                            ),
                                            Text(
                                              _categoriesToShow[index]['name'],
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ],
                                        )),
                                  ),
                                ],
                              );
                            }),
                      ),
                      flex: 1,
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: (_isLoading
          ? (Container())
          : ((_categoriesToShow[0]['parent'] == 238 ||
                  _categoriesToShow[0]['parent'] == 235)
              ? (Container())
              : (FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _categoriesToShow = _topCategories;
                    });
                  },
                  child: Icon(Icons.arrow_back),
                  backgroundColor: Colors.grey,
                )))),
    );
  }
}
