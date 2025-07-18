import 'package:flutter/material.dart';
import 'package:to_do_app/components/dialog_box.dart';
import 'package:to_do_app/data/database.dart';
import 'package:hive/hive.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _mybox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    if (_mybox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }
    super.initState();
  }

  final _controller = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDtaBase();
  }

  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDtaBase();
  }

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancle: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDtaBase();
  }

  void clearAllTasks() {
    if (db.toDoList.isNotEmpty) {
      setState(() {
        db.toDoList.clear();
      });
      db.updateDtaBase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌈 Modern gradient background with lighter colors
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5DFB), Color(0xFF8DADF7), Color(0xFFBDE0FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 📝 Custom stylish header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tasklodoon',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: clearAllTasks,
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              // 📋 List of tasks with glassy cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: db.toDoList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: db.toDoList[index][1],
                            activeColor: Colors.cyanAccent,
                            checkColor: Colors.deepPurple.shade900,
                            onChanged: (value) => checkBoxChanged(value, index),
                          ),
                          title: AnimatedDefaultTextStyle(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              decoration: db.toDoList[index][1]
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: db.toDoList[index][1]
                                  ? Colors.redAccent
                                  : null,
                              decorationThickness: db.toDoList[index][1]
                                  ? 2
                                  : null,
                            ),
                            child: Text(db.toDoList[index][0]),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.pinkAccent.shade100),
                            onPressed: () => deleteTask(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // ➕ Modern floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Color(0xFF6D5DFB)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    );
  }
}
