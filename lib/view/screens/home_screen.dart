import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebae_log/view/util/constants.dart';
import 'package:firebae_log/view/widgets/appbar.dart';
import 'package:firebae_log/view/widgets/floatbutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/auth_service.dart';
import '../../controller/provider/user_home_provider.dart';
import '../../model/user_model.dart';
import 'login_screen.dart';


class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    final CollectionReference products =
    FirebaseFirestore.instance.collection(uniqueEmail);
    return StreamBuilder<User?>(
      stream: context.watch<AuthService>().stream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return  ScreenLogin();
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Welcome'),
            centerTitle: true,
            actions: [
              IconButton(
                  onPressed: () async {
                    await context.read<AuthService>().signOut(context);
                  },
                  icon: const Icon(Icons.logout))
            ],
            flexibleSpace: const StyledAppBar(),
          ),
          body: StreamBuilder(
            stream: products.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                final newList=streamSnapshot.data!.docs.map((e) {
                  return Details.fromJson(e.data() as Map<String,dynamic>);
                }).toList();
                return ListView.builder(
                  // itemCount: streamSnapshot.data!.docs.length,
                  // itemBuilder: (context, index) {
                  //   final DocumentSnapshot documentSnapshot =
                  //       streamSnapshot.data!.docs[index];
                  itemCount: newList.length,
                  itemBuilder: (context, index) {

                    final newValue=newList[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) {
                              return BottomSheetBody(
                                products: products,
                                type: TypeData.edit,
                                model: newValue,
                              );
                            },
                          );
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: MemoryImage(const Base64Decoder()
                              .convert(newValue.image.toString())),
                        ),
                        title: Text(newValue.name.toString()),
                        subtitle: Text(context
                            .read<HomeProv>()
                            .nameConversion(newValue.phone!.toDouble())),
                        //  subtitle: Text(documentSnapshot['Phone'].toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context
                                .read<HomeProv>()
                                .delete(newValue.id.toString(), products);
                            context.read<HomeProv>().showSnakBar(
                                'You have successfully deleted a Field',
                                context);
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) {
                  return BottomSheetBody(
                    products: products,
                    type: TypeData.create,
                  );
                },
              );
            },
            child: const FloatButton(),
          ),
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}

class BottomSheetBody extends StatefulWidget {
  const BottomSheetBody({
    Key? key,
    required this.products,
    required this.type,
    this.model,
  }) : super(key: key);
  final TypeData type;
  final CollectionReference<Object?> products;
  final Details? model;

  @override
  State<BottomSheetBody> createState() => _BottomSheetBodyState();
}

class _BottomSheetBodyState extends State<BottomSheetBody> {
  @override
  void initState() {
    context.read<HomeProv>().checkOperation(
        model : widget.model, type: widget.type);
    super.initState();
  }
  final formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext bcontext) {
    final MediaQueryData mediqurydata = MediaQuery.of(bcontext);
    return Padding(
      padding: mediqurydata.viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 30),
          child: Form(
            key:formKey ,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<HomeProv>(
                  builder: (context, value, _) => GestureDetector(
                    child: value.img.isNotEmpty
                        ? CircleAvatar(
                      radius: 30,
                      backgroundImage: MemoryImage(
                          const Base64Decoder().convert(value.img)),
                    )
                        : const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/img_avatar.png'),
                    ),
                    onTap: () {
                      bcontext.read<HomeProv>().pickImage();
                    },
                  ),
                ),
                kHight10,
                TextFormField(
                  controller:  bcontext.read<HomeProv>().nameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.contact_page,color: Colors.deepOrangeAccent,),
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'you should enter name';
                    }
                    return null;
                  },
                ),
                kHight10,
                TextFormField(
                  controller:  bcontext.read<HomeProv>().phoneController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_android,color: Colors.deepOrangeAccent,),
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return 'Phone number should not be empty';
                    }
                    return null;
                  },
                ),
                kHight10,
                ElevatedButton(
                  onPressed: ()async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    bcontext.read<HomeProv>().keyBoardHide(bcontext);
                    await bcontext.read<HomeProv>().onSubmitButtonCheck(
                        type: widget.type,
                        products: widget.products,
                        model: widget.model);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.deepOrange),
                  child: Text(widget.type == TypeData.create ? 'Add' : 'Update'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

