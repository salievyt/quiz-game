import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz/ui/categories.dart';
import 'package:my_progress_bar/progress_bar.dart';

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

  int progress = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Игра"),
        centerTitle: true,
        leading: IconButton(onPressed: (){
            _showAlertDialog(context);
          },
          icon: Icon(Icons.arrow_back_ios_new)
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: HorizontalProgressBar(
                  maxValue: 12,
                  currentPosition: progress.toDouble(),
                  onChanged: (val){},
                  progressColor: Color(0xFF7ED421),
                  thumbColor: Color(0xFF7ED421),
                  trackHeight: 10,
                  bufferedPosition: 12,
                  bufferedColor: Color(0xFFEBEBEB),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Color(0xFF7ED421),
                  child: Text("${progress}", style: TextStyle(color: Colors.white, fontSize: 18),),
                )
              ],
            ),
            SizedBox(height: 40,),
            Image.asset("assets/images/game.png"),
            SizedBox(height: 12,),
            Flexible(
              child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse dapibus accumsan tincidunt. Cras ut lacus.", style: TextStyle(fontSize: 18), ),),
            SizedBox(height: 62,),
            ElevatedButton(
                onPressed: (){
                  if (progress < 12){
                    setState(() {
                      progress++;
                    });
                  } else if (progress == 12){
                    setState(() {
                      progress = 0;
                    });
                  }
                },
                child: Text("Повысить прогресс", style: TextStyle(fontSize: 18),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7ED421),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: Size(double.infinity, 60)
                )
            ),
            SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("ID Игры: ${widget.ID}", style: TextStyle(fontSize: 20),)
              ],
            )
          ],
        ),
      )
    );
  }
}
