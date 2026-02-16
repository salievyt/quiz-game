import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/ui/categories.dart';
class Game extends StatefulWidget {
  int ID;
  Game({super.key, required this.ID});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {

  bool _isMute = true;


  void _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return CupertinoAlertDialog(
            title: Text("Вы точно хотите выйте из игры?"),
            content: Container(
              child: Text("Ваш прогресс будет потерян!"),
            ),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(context);
              }, child: Text("Нет")),
              TextButton(onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              }, child: Text("Да", style: TextStyle(color: Colors.red),))
            ]
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            _isMute = !_isMute;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30)
        ),
        backgroundColor: Colors.green,
        child: Icon(_isMute ? Icons.volume_off : Icons.volume_up, color: Colors.white,),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Game"),
        centerTitle: true,
        leading: IconButton(onPressed: (){
            _showAlertDialog(context);
          },
          icon: Icon(Icons.arrow_back_ios_new)
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ID Игры: ${widget.ID}", style: TextStyle(fontSize: 20),)
            ],
          )
        ],
      )
    );
  }
}
