import 'package:flutter/material.dart';

import 'game.dart';
class Categories extends StatefulWidget {
  String category;
  String image;
  String desc;
  int ID;
  Categories({super.key, required this.category, required this.image, required this.desc, required this.ID});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.category, style: TextStyle(fontSize: 22)),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }
          , icon: Icon(Icons.arrow_back_ios_new)
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Image.asset(widget.image),
            SizedBox(height: 12,),
            Text(widget.desc, style: TextStyle(fontSize: 18),),
            SizedBox(height: 12,),
            ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Game(ID: widget.ID,)),
                  );
                },
                child: Text("Начать играть", style: TextStyle(fontSize: 18),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7ED421),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 60)
                )
            )
          ],
        ),
      )
    );
  }
}
