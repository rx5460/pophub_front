import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pophub/model/goods_model.dart';
import 'package:pophub/model/popup_model.dart';
import 'package:pophub/model/user.dart';
import 'package:pophub/notifier/GoodsNotifier.dart';
import 'package:pophub/notifier/UserNotifier.dart';
import 'package:pophub/screen/custom/custom_title_bar.dart';
import 'package:pophub/screen/goods/goods_list.dart';
import 'package:pophub/screen/goods/goods_view.dart';
import 'package:pophub/utils/api/goods_api.dart';
import 'package:pophub/utils/log.dart';
import 'package:pophub/utils/utils.dart';
import 'package:provider/provider.dart';

class GoodsCreatePage extends StatefulWidget {
  final String mode;
  final PopupModel popup;
  final GoodsModel? goods;

  final String? productId;

  const GoodsCreatePage({
    super.key,
    this.mode = "add",
    this.goods,
    required this.popup,
    this.productId,
  });

  @override
  _GoodsCreatePageState createState() => _GoodsCreatePageState();
}

class _GoodsCreatePageState extends State<GoodsCreatePage> {
  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.goods != null) {
      _nameController.text = widget.goods?.productName ?? '';
      _priceController.text = widget.goods?.price.toString() ?? '0';
      _quantityController.text = widget.goods?.quantity.toString() ?? '0';
      _descriptionController.text = widget.goods?.description ?? '';

      if (widget.goods != null) {
        Provider.of<GoodsNotifier>(context, listen: false).productName =
            widget.goods?.productName ?? '';
        Provider.of<GoodsNotifier>(context, listen: false).price =
            widget.goods?.price ?? 0;
        Provider.of<GoodsNotifier>(context, listen: false).quantity =
            widget.goods?.quantity ?? 0;
        Provider.of<GoodsNotifier>(context, listen: false).description =
            widget.goods?.description ?? '';

        Provider.of<GoodsNotifier>(context, listen: false).images = widget
                .goods!.image
                ?.map((imageUrl) => {'type': 'url', 'data': imageUrl})
                .toList() ??
            [];
      }
    }
  }

  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      if (Provider.of<GoodsNotifier>(context, listen: false).images.length <
          5) {
        final XFile? pickedImage =
            await _picker.pickImage(source: ImageSource.gallery);

        if (pickedImage != null && mounted) {
          Provider.of<GoodsNotifier>(context, listen: false)
              .addImage({'type': 'file', 'data': File(pickedImage.path)});
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(('warning').tr()),
                content: Text(('up_to_5_photos_can_be_registered').tr()),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(('check').tr()),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      Logger.debug('Error picking image: $e');
    }
  }

  Future<void> goodsAdd(GoodsNotifier goods) async {
    goods.userName = User().userName;
    final data = await GoodsApi.postGoodsAdd(goods, widget.popup.id.toString());

    if (!data.toString().contains("fail") && mounted) {
      showAlert(context, ('success').tr(), ('goods_have_been_registered').tr(),
          () {
        Navigator.of(context).pop();

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => UserNotifier())
                        ],
                        child: GoodsList(
                          popup: widget.popup,
                        ))));
      });
    } else {}
  }

  bool _validateInputs() {
    if (_nameController.text.isEmpty) {
      _showValidationDialog(('please_enter_the_product_name').tr());
      return false;
    }
    if (_priceController.text.isEmpty) {
      _showValidationDialog(('please_enter_the_price_of_the_goods').tr());
      return false;
    }
    if (_quantityController.text.isEmpty) {
      _showValidationDialog(('please_enter_the_quantity_of_goods').tr());
      return false;
    }
    if (_descriptionController.text.isEmpty) {
      _showValidationDialog(('please_enter_a_product_description').tr());
      return false;
    }
    return true;
  }

  void _showValidationDialog(String message) {
    showAlert(context, ('failure').tr(), message, () {
      Navigator.of(context).pop();
    });
  }

  Future<void> goodsModify(GoodsNotifier goods) async {
    final data =
        await GoodsApi.putGoodsModify(goods, widget.productId.toString());

    if (!data.toString().contains("fail") && mounted) {
      showAlert(context, ('success').tr(),
          ('goods_modifications_have_been_completed').tr(), () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoodsDetail(
              goodsId: widget.productId.toString(),
              popup: widget.popup,
            ),
          ),
        ).then((value) {
          if (mounted) {
            setState(() {});
          }
        });
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    // Size screenSize = MediaQuery.of(context).size;
    // double screenWidth = screenSize.width;
    // double screenHeight = screenSize.height;
    return Scaffold(
      appBar: CustomTitleBar(
          titleName: widget.mode == "modify"
              ? ('edit_goods').tr()
              : ('add_goods_1').tr()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<GoodsNotifier>(
          builder: (context, goods, child) {
            return ListView(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: OutlinedButton(
                          onPressed: () => _pickImage(),
                          child: const Icon(Icons.add),
                        ),
                      ),
                      ...goods.images
                          .map((image) => Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: image['type'] == 'file'
                                        ? Image.file(
                                            image['data'],
                                            width: 60,
                                            height: 60,
                                          )
                                        : Image.network(
                                            image['data'],
                                            width: 60,
                                            height: 60,
                                          ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => goods.removeImage(image),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  ('goods_name').tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: ('labelText_3').tr()),
                  onChanged: (value) => goods.productName = value,
                ),
                const SizedBox(height: 20),
                Text(
                  ('labelText_4').tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: ('labelText_4').tr()),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  onChanged: (value) {
                    if (value != "") {
                      goods.price = int.parse(value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  ('labelText_5').tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: ('labelText_5').tr()),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1000),
                  ],
                  onChanged: (value) => goods.quantity = int.parse(value),
                ),
                const SizedBox(height: 20),
                Text(
                  ('goods_description').tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                      labelText: ('labelText_6').tr(),
                      alignLabelWithHint: true),
                  maxLines: 4,
                  onChanged: (value) => goods.description = value,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: OutlinedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        if (widget.mode == "modify") {
                          goodsModify(goods);
                        } else if (widget.mode == "add") {
                          goodsAdd(goods);
                        }
                      }
                    },
                    child: Text(('complete').tr()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
