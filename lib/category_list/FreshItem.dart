import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:groceryapp/category_list/kTransparentImage.dart';
import 'package:groceryapp/product_details/ProductDetails.dart';
import 'package:groceryapp/products/ProductAttribute.dart';
import 'package:groceryapp/products/ProductModel.dart';
import 'package:groceryapp/util/AppColors.dart';
import 'package:groceryapp/util/Consts.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:cached_network_image/cached_network_image.dart';

import '../util/Util.dart';
import 'package:http/http.dart' as http;

class FreshItem extends StatefulWidget {
  final String deviceId;
  final ProductModel itemProduct;
  final ProductAttribute pr;
  final bool isAgent;
  final Function() notifyCart;

  const FreshItem(
      {Key key,
      this.itemProduct,
      this.pr,
      List<ProductAttribute> item1,
      this.isAgent,
      this.notifyCart,
      this.deviceId})
      : super(key: key);
  @override
  _FreshItemState createState() => _FreshItemState();
}

class _FreshItemState extends State<FreshItem> {
  ProductModel item;
  List<ProductAttribute> pr;
  bool isAgent;
  String deviceId;
  double selectPrice;
  double distributorPrice;
  double productPrice;
  @override
  void initState() {
    // TODO: implement initState
    deviceId = widget.deviceId;
    item = widget.itemProduct;
    pr = widget.itemProduct.productAttribute;
    print("Pr..." + pr.toString());
    isAgent = widget.isAgent != null ? widget.isAgent : false;
    //print("Iteam..." + item.toString());
    super.initState();
  }

  _handleAddCart(ProductModel itemProduct) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id');

    if (user_id == null) {
      user_id = '';
    }

    print(user_id);

    var requestParam = "?";
    requestParam += "user_id=" + user_id;
    requestParam += "&device_id=" + deviceId.toString();
    requestParam += "&product_id=" + itemProduct.productId;
    requestParam += "&name=" + itemProduct.productTitle.trim();
    requestParam += "&price=" + itemProduct.productPrice;
    requestParam += "&quantity=1";
    //print(Uri.parse(Consts.ADD_CART + requestParam));
    final http.Response response = await http.get(
      Uri.parse(Consts.ADD_CART + requestParam),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      var serverCode = responseData['code'];
      if (serverCode == "200") {
        debugPrint(response.body);
        if (user_id == '') {
          prefs.setString("user_id", responseData['user_id'].toString());
          prefs.setString("usertype", responseData['user_type'].toString());
        }
        widget.notifyCart();
      }

      var serverMessage = responseData['message'];
      showCustomToast(serverMessage);
    } else {}
  }

  void gotoDetails() async {
    var openCart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetails(
          itemProduct: item,
          isAgent: isAgent,
        ),
      ),
    );

    if (openCart != null && openCart == "refresh cart") {
      debugPrint("Returned data $openCart");
      widget.notifyCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    // var size=MediaQuery.of(context).size.width/2 -50;
    // print(size);
    // print("Fresh..1." + widget.itemProduct.productType.toString());
    // print("Fresh..11." + widget.itemProduct.productAttribute.toString());
    var productAt = widget.itemProduct.productAttribute;
    //print("ff.." + productAt.length.toString());
    //List<ProductAttribute> productAttr = [];
    if (productAt.length > 0) {
      //ProductAttribute pr = ProductAttribute();
      for (int p = 0; p < productAt.length; p++) {
        var pa = productAt[0];
        // print("Pa..." + pa.name.toString());
        // productAttr.add(pa);
        // print("Pa..." + productAttr.toString());
      }
    }
    //ProductAttribute productAttribute = widget.pr;
    //print("dfdsf" + productAttribute.toString());
    if (widget.itemProduct.productType == "variable") {
      selectPrice = double.parse(
          widget.itemProduct.productAttribute[0].productPrice.toString());
    } else {
      selectPrice = double.parse(widget.itemProduct.productPrice);
    }

    if (widget.itemProduct.productType == "variable") {
      distributorPrice = double.parse(widget
          .itemProduct.productAttribute[0].productDistributorPrice
          .toString());
      productPrice = double.parse(
          widget.itemProduct.productAttribute[0].productPrice.toString());
    } else {
      distributorPrice =
          double.parse(widget.itemProduct.productDistributorPrice.toString());
      productPrice = double.parse(widget.itemProduct.productPrice.toString());
    }
    return InkWell(
      onTap: () {
        //print("Iteam in fresh..." + item.productTitle.toString());
        //print("Iteam in fresh..." + item.toString());
        gotoDetails();
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140.0,
              width: MediaQuery.of(context).size.width / 2 - 90,
              // child: FadeInImage(
              //   placeholder: MemoryImage(kTransparentImage),
              //   image: NetworkImage(widget.itemProduct.productImage.toString()),
              // ),
              // Image(
              //   image: CachedNetworkImageProvider(
              //       widget.itemProduct.productImage.toString()),
              //   //fit: BoxFit.cover,
              // )
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage(widget.itemProduct.productImage.toString()),
                fit: BoxFit.contain,
              )),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(25.0),
              //   child: Image.network(
              //     widget.itemProduct.productImage.toString(),
              //     //item.productImage,
              //     height: 140.0,
              //     width: MediaQuery.of(context).size.width / 2 - 90,
              //     fit: BoxFit.contain,
              //     errorBuilder: (BuildContext context, Object exception,
              //         StackTrace stackTrace) {
              //       return Container();
              //     },
              //     loadingBuilder: (BuildContext context, Widget child,
              //         ImageChunkEvent loadingProgress) {
              //       if (loadingProgress == null) return child;
              //       return Container(
              //         height: 120.0,
              //         width: MediaQuery.of(context).size.width / 2 - 50,
              //         child: Center(
              //           child: SizedBox(
              //             height: 20,
              //             width: 20,
              //             child: CircularProgressIndicator(
              //               valueColor: new AlwaysStoppedAnimation<Color>(
              //                 Colors.grey,
              //               ),
              //               strokeWidth: 2,
              //               value: loadingProgress.expectedTotalBytes != null
              //                   ? loadingProgress.cumulativeBytesLoaded /
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
              height: 0,
            ),
            Center(
              child: Text(
                widget.itemProduct.productTitle,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  "\u20B9 ${isAgent ? (item.productType == "variable" ? distributorPrice : distributorPrice) : (item.productType == "variable" ? productPrice : productPrice)}",
                  //"\u20B9 ${isAgent ? (item.productType == "variable" ? distributorPrice : item.productDistributorPrice) : (item.productType == "variable" ? productPrice : item.productPrice)}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.productPriceColor,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "\u20B9 ${selectPrice.toString()}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.productRegularColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8.0,
                ),
                child: InkWell(
                  onTap: () => {gotoDetails()},
                  child: Text(
                    "Buy Now",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
