import 'package:flutter/material.dart';


void main(){
  
  runApp(const myApp());
}

class myApp extends StatelessWidget{
  const myApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Helper(),
    );
  }
}

class Helper extends StatelessWidget {
  const Helper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          _buildActionButton(context, "Home"),
          _buildActionButton(context, "Tools"),
          _buildActionButton(context, "Help"),
        ],
      ),
      body: const Center(
        child: Text("Main Screen Text"),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to a new screen when the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SecondScreen(title: text),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
        shape: const BeveledRectangleBorder(),
      ),
      child: Text(text),
    );
  }
}

// This is the new screen that will "pop up"
class SecondScreen extends StatelessWidget {
  final String title;
  
  const SecondScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: 
        checkAndReturn(title) 
    );
  }
  Widget checkAndReturn(String title){
    if(title=="Home") return homeReturn();
    else if(title=="Tools") return toolsReturn();
    else return helpReturn();
  }
  Widget homeReturn(){
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: (){},child: Text("Admin Login"),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: (){},child: Text("Trainer Login"),),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: (){},child: Text("User Login"),),
          ),
        ],
      ),
    );
  }
  Widget toolsReturn(){
    return Center(
      child: Column(
        children: [
          ElevatedButton(onPressed: (){}, child: Text("Theme")),
        ],
      ),
    );
  }
  Widget helpReturn(){
    return Center(
      child: Column(
        children: [
          ElevatedButton(onPressed: (){}, child: Text("FAQs")),
        ],
      ),
    );
  }
}

class myAppState extends ChangeNotifier{

}