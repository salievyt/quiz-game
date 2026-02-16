import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quiz/data/GameData.dart';
import 'categories.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Quizzy", style: TextStyle(fontSize: 26,fontFamily: GoogleFonts.sen().fontFamily, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child:
          ListView.separated(
              itemCount: Gamedata().getGameNames().length,
              separatorBuilder: (context,index) => Divider(
                radius: BorderRadius.circular(14),
                indent: 10,
                endIndent: 10,
                height: 2,
              ),
              itemBuilder: (context,index){
                return ListTile(
                  title: Text(Gamedata().getGameNames()[index]),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(Gamedata().getIcons()[index]),
                  ),
                  trailing: Icon(Icons.navigate_next),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Categories(category: Gamedata().getGameNames()[index], image: Gamedata().getImagesLocal()[index], desc: Gamedata().getDescriptions()[index], ID: Gamedata().getGameIds()[index],)),
                    );
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
