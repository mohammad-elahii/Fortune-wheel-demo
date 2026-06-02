import 'package:flutter/material.dart';

var startAlignment = Alignment.topLeft;
var endAlignment = Alignment.bottomRight;

class GradientContainer extends StatelessWidget {
  const GradientContainer({super.key});

  @override
  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan, Colors.greenAccent],
          begin: startAlignment,
          end: endAlignment,
        ),
      ),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Hello world!",
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),

            TextButton(onPressed:(){} ,child: Text("Click to Spin"),),
          ],
        ),
      ),
    );
  }
}
