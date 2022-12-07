import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/user_model.dart';
import '../../view/util/constants.dart';
import '../../view/util/routs.dart';

enum TypeData {
  edit,
  create,
}

class HomeProv with ChangeNotifier {

  String img = '';

  // final scaffoldKEY = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();


  disposeController() {
    nameController.clear();
    phoneController.clear();
  }


  pickImage() async {
    final imageFromGallery =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFromGallery == null) {
      return;
    }
    final bytes = await imageFromGallery.readAsBytes();
    img = base64Encode(bytes);
    notifyListeners();
  }

  imageToNUll() {
    img = '';
  }

  onAddButtonPressed(CollectionReference products) async {
    final String name = nameController.text;
    final double? phone = double.tryParse(phoneController.text);

    if (img.isEmpty) {

      img=tempImg;
    }

    if (phone != null && img.isNotEmpty && name.isNotEmpty) {
      final model= Details(name: name, image: img, phone: phone,id:'temp',);
      final generatedID=await  products.add(model.toJson());
      model.id= generatedID.id;
      await products.doc(generatedID.id).update(model.toJson());

      disposeController();
      imageToNUll();
      Routes.pop();
    }
  }

  onUpdateButtonPressed(
      CollectionReference products, Details model) async {
    final String name = nameController.text;
    final double? phone = double.tryParse(phoneController.text);
    final id=model.id;

    if (phone != null && img.isNotEmpty && name.isNotEmpty) {
      final model=Details(name: name, image: img, phone: phone,id: id);
      await products
          .doc(id)
          .update(model.toJson());

      disposeController();
      imageToNUll();
      Routes.pop();
    }
  }

  Future<void> delete(String productId, CollectionReference products) async {
    await products.doc(productId).delete();


  }

  showSnakBar(String msg,BuildContext ctx) {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  checkOperation({TypeData? type, Details? model}) {
    if (type == TypeData.edit) {
      nameController.text = model!.name.toString();
      phoneController.text = model.phone.toString();
      img = model.image.toString();
    }
  }

  String nameConversion(double data) {
    return data.toInt().toString();
  }

  onSubmitButtonCheck(
      {required TypeData type,
        required CollectionReference products,
        Details? model}) {
    switch (type) {
      case TypeData.create:
        onAddButtonPressed(products);
        break;
      case TypeData.edit:
        onUpdateButtonPressed(products, model!);
    }
  }

  keyBoardHide(BuildContext ctx){
    FocusScopeNode currentFocus = FocusScope.of(ctx);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }
}
