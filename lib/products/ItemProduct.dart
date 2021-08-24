import 'dart:convert';

import 'package:groceryapp/login/LoginScreen.dart';

import '../products/ProductModel.dart';
import '../util/AppColors.dart';
import '../util/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../product_details/ProductDetails.dart';
import '../util/Consts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemProduct extends StatefulWidget {
  final ProductModel itemProduct;
  final bool isAgent;
  final Function() notifyCart;

  const ItemProduct({
    Key key,
    this.itemProduct,
    this.isAgent,
    this.notifyCart,
  }) : super(key: key);
  @override
  _ItemProductState createState() => _ItemProductState();
}

class _ItemProductState extends State<ItemProduct> {
  bool isAgent;
  bool isWish;
  ProductModel itemProduct;
  var requestParam;
  String deviceID;

  @override
  initState() {
    deviceID = '';

    initPlatformState();
    itemProduct = widget.itemProduct;
    isWish = itemProduct.isInWishList == 1 ? true : false;
    isAgent = widget.isAgent;
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }
    debugPrint("Please device id ${deviceId}");

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      deviceID = deviceId;
      print("deviceId->$deviceID");
    });
  }

  wishAdd(bool isWish, ProductModel itemProduct) async {
    print(isWish);
    var addwis = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');
    if (user_id == null) {
      user_id = '';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else {
      if (isWish) {
        addwis = "add";
      } else {
        addwis = "remove";
      }
      requestParam = "?";
      requestParam += "user_id=" + user_id;
      requestParam += "&device_id=" + deviceID.toString();
      requestParam += "&product_id=" + itemProduct.productId;
      requestParam += "&action=" + addwis;
      print(Consts.ADD_TO_WISHLIST + requestParam);
      final http.Response response = await http.get(
        Uri.parse(Consts.ADD_TO_WISHLIST + requestParam),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var serverCode = responseData['code'];
        var serverMessage = responseData['message'];
        if (serverCode == "200") {
          showCustomToast(serverMessage);
          if (user_id == '') {
            prefs.setString("user_id", responseData['user_id'].toString());
            prefs.setString("usertype", responseData['user_type'].toString());
          }
          setState(() {
            widget.itemProduct.isInWishList = isWish ? 1 : 0;
          });
        } else {
          showCustomToast(serverMessage);
        }
      } else {
        showCustomToast(Consts.SERVER_NOT_RESPONDING);
      }
    }
  }

  _handleAddCart(ProductModel itemProduct) async {
    // print("cart click in itemProduct" + itemProduct.productId.toString());
    // print("cart click in itemProduct" + itemProduct.productTitle.toString());
    // print("cart click in itemProduct" +
    //     itemProduct.productAttribute[0].productPrice.toString());
    // print("cart click in itemProduct" +
    //     itemProduct.productAttribute[0].productRegularPrice.toString());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');

    if (user_id != null) {
      // user_id = '';

      print('user_id' + user_id);
      var productPrice = (itemProduct.productType == "variable")
          ? itemProduct.productAttribute[0].productPrice
          : itemProduct.productPrice;

      var regularPrice = (itemProduct.productType == "variable")
          ? itemProduct.productAttribute[0].productRegularPrice
          : itemProduct.productRegularPrice;

      var requestParam = "?";
      requestParam += "user_id=" + user_id;
      // requestParam += "&device_id=" + deviceID.toString();
      requestParam += "&product_id=" + itemProduct.productId;
      requestParam += "&name=" + itemProduct.productTitle.trim();
      requestParam += "&price=" + productPrice;
      //print('requestParam' + requestParam.toString());
      requestParam += "&regular_price=" + regularPrice;
      requestParam += "&quantity=1";
      //print('requestParam' + requestParam.toString());
      print(Uri.parse(Consts.ADD_CART + requestParam));
      final http.Response response = await http.get(
        Uri.parse(Consts.ADD_CART + requestParam),
      );
      //print("cart click in itemProduct..." + response.statusCode.toString());
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        var serverCode = responseData['code'];
        if (serverCode == "200") {
          if (user_id == '') {
            prefs.setString("user_id", responseData['user_id'].toString());
            prefs.setString("usertype", responseData['user_type'].toString());
          }
          widget.notifyCart();
        }

        var serverMessage = responseData['message'];
        showCustomToast(serverMessage);
      } else {}
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  _gotoDetail() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(
          itemProduct: itemProduct,
          isAgent: isAgent,
        ),
      ),
    );

    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data detail page $openCart");
      widget.notifyCart();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print("itemProduct..0." + itemProduct.productTitle.toString());
    // print("itemProduct..0." + itemProduct.productType.toString());
    // print("itemProduct..0." + itemProduct.brandDetails.length.toString());
    return InkWell(
      onTap: () {
        _gotoDetail();
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0XFFf9f7f7),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0XFFf9f7f7),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                        height: 100.0,
                        width: 100.0,
                        child: Image(
                          image: CachedNetworkImageProvider(
                              itemProduct.productImage.toString()),
                          //fit: BoxFit.cover,
                        )
                        // decoration: BoxDecoration(
                        //     image: DecorationImage(
                        //         image: NetworkImage(itemProduct.productImage))),

                        // child: ClipRRect(
                        //   borderRadius: BorderRadius.circular(30.0),
                        //   child: Image.network(
                        //     itemProduct.productImage,
                        //     height: 100.0,
                        //     width: 100.0,
                        //     errorBuilder: (BuildContext context, Object exception,
                        //         StackTrace stackTrace) {
                        //       return Container();
                        //     },
                        //     loadingBuilder: (BuildContext context, Widget child,
                        //         ImageChunkEvent loadingProgress) {
                        //       if (loadingProgress == null) return child;
                        //       return Container(
                        //         height: 100.0,
                        //         width: 100.0,
                        //         child: Center(
                        //           child: SizedBox(
                        //             height: 20,
                        //             width: 20,
                        //             child: CircularProgressIndicator(
                        //               valueColor:
                        //                   new AlwaysStoppedAnimation<Color>(
                        //                 Colors.grey,
                        //               ),
                        //               strokeWidth: 2,
                        //               value: loadingProgress.expectedTotalBytes !=
                        //                       null
                        //                   ? loadingProgress
                        //                           .cumulativeBytesLoaded /
                        //                       loadingProgress.expectedTotalBytes
                        //                   : null,
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        // ),
                        ),
                    SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemProduct.productTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0XFF0D0D0D),
                              ),
                              softWrap: true,
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Row(
                              children: [
                                Text(
                                  "\u20B9 ${isAgent ? (itemProduct.productType == "variable" ? itemProduct.productAttribute[0].productDistributorPrice : itemProduct.productDistributorPrice) : (itemProduct.productType == "variable" ? itemProduct.productAttribute[0].productPrice : itemProduct.productPrice)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.productPriceColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "\u20B9 ${(itemProduct.productType == "variable" ? itemProduct.productAttribute[0].productRegularPrice : itemProduct.productRegularPrice)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.productRegularColor,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            // Text(
                            //   "${itemProduct.brandName}",
                            //   style: TextStyle(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w700,
                            //     color: Color(0XFF0D0D0D),
                            //   ),
                            //   softWrap: true,
                            // ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // _productListwish
                                  InkWell(
                                    onTap: () => {
                                      print("item Click"),
                                      // if(isWish==true){
                                      setState(
                                        () {
                                          isWish = !isWish;
                                        },
                                      ),
                                      wishAdd(isWish, itemProduct),

                                      // wishAdd(),
                                    },
                                    child: itemProduct.isInWishList == 1
                                        ? Image.asset(
                                            "images/ic_wishlistActive.png",
                                            height: 25,
                                          )
                                        : Image.asset(
                                            "images/ic_wishlist.png",
                                            height: 25,
                                          ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () => {_handleAddCart(itemProduct)},
                                    child: Image.asset(
                                      "images/busket.png",
                                      height: 25,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   right: 15,
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 15.0),
            //     child: Container(
            //       height: 50,
            //       width: 50,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: AppColors.appMainColor,
            //       ),
            //       child: Icon(
            //         Icons.shop,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
