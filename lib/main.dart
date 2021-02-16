import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NoteList(),
    );
  }
}

class NoteList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Adapt Note"),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text(
                        "Add Category",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.center,
                      ),
                      children: [
                        Form(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Category Name",
                                contentPadding:
                                    EdgeInsets.fromLTRB(10, 2, 5, 0),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value.length < 3) {
                                  return "Category name cannot be shorter than 3 letters!";
                                }
                              },
                            ),
                          ),
                        ),
                        ButtonBar(
                          children: [
                            RaisedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              color: Colors.white,
                              elevation: 0,
                              child: (Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black87),
                              )),
                            ),
                            RaisedButton(
                              onPressed: () {},
                              color: Colors.deepOrange,
                              child: (Text(
                                "Save",
                                style: TextStyle(color: Colors.white),
                              )),
                            ),
                          ],
                        )
                      ],
                    );
                  });
            },
            tooltip: "Add Category",
            child: Icon(Icons.category_outlined),
            mini: true,
          ),
          FloatingActionButton(
            onPressed: () {},
            tooltip: "Add Note",
            child: Icon(Icons.note_add),
          ),
        ],
      ),
      body: Container(),
    );
  }
}
