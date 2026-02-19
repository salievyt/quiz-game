import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/data/GameData.dart';
import 'package:quiz/ui/game/speedrun.dart';
import '../utils/categories.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F9FB),
        title: Text("Quizzy", style: TextStyle(fontSize: 26,fontFamily: GoogleFonts.sen().fontFamily, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child:
          ListView.separated(
              itemCount: GameData().getGameNames().length,
              separatorBuilder: (context,index) => Divider(
                radius: BorderRadius.circular(14),
                indent: 10,
                endIndent: 10,
                height: 2,
              ),
              itemBuilder: (context,index){
                return ListTile(
                  title: Text(GameData().getGameNames()[index]),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(GameData().getIcons()[index]),
                  ),
                  trailing: Icon(Icons.navigate_next),
                  onTap: (){
                    if (index == 8){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Speedrun()));
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Categories(category: GameData().getGameNames()[index], image: GameData().getImagesLocal()[index], desc: GameData().getDescriptions()[index], ID: GameData().getGameIds()[index],)),
                      );
                    }
                  },
                );
              }
            )
          ),
        ],
      ),
    );
  }
}
