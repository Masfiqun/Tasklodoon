import 'package:flutter/material.dart';
import 'package:to_do_app/components/dialog_box.dart';
import 'package:to_do_app/components/todo_list.dart';
import 'package:to_do_app/data/database.dart';
import 'package:hive/hive.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

//reference the hive box
  final _mybox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState(){

//if this is the 1st time ever opening the app, then create default data
  if(_mybox.get("TODOLIST") == null){
    db.createInitialData();
  }else{
//data already exists
    db.loadData();
  }
    super.initState();
  }

//text controller
  final _controller = TextEditingController();


  void checkBoxChanged(bool? value, int index){
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDtaBase();
  }

  //save new task
  void saveNewTask(){
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDtaBase();
  }

//create a new task
  void createNewTask() {
    showDialog(
      context: context, 
      builder: (context){
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancle: () => Navigator.of(context).pop(),
        );
      }
    );
  }


  //delete task
  void deleteTask(int index){
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDtaBase();
  }


  

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('To-Do list', style: TextStyle(color: Colors.tealAccent),),
          elevation: 0,
          backgroundColor: Colors.deepPurple,        
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: createNewTask,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.tealAccent,
          child: Icon(Icons.add),
          ),
      
        body: ListView.builder(
          itemCount: db.toDoList.length,
          itemBuilder: (context, index) {
            return ToDoList(
              taskName: db.toDoList[index][0], 
              taskCompleted: db.toDoList[index][1], 
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => deleteTask(index),
            );
          },
        ),
      ),
    );
  }

  
}