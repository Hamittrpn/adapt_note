import 'dart:io';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:adapt_note/models/category.dart';
import 'package:adapt_note/note_detail.dart';
import 'package:adapt_note/utils/database_helper.dart';
import 'package:flutter/material.dart';

import 'models/note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NoteList(),
    );
  }
}

class NoteList extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Adapt Note"),
        ),
      ),
      floatingActionButton: FabCircularMenu(
          fabOpenColor: Colors.red,
          fabOpenIcon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          fabCloseIcon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.category_outlined,
                  size: 40,
                  color: Colors.white,
                ),
                tooltip: "Add Category",
                onPressed: () {
                  addCategoryDialog(context);
                }),
            IconButton(
              icon: Icon(
                Icons.add_circle_rounded,
                size: 40,
                color: Colors.white,
              ),
              tooltip: "Add Note",
              onPressed: () => _goToDetailPage(context),
            )
          ]),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       onPressed: () {
      //         addCategoryDialog(context);
      //       },
      //       tooltip: "AddCategory",
      //       heroTag: "Add Category",
      //       child: Icon(Icons.category_outlined),
      //       mini: true,
      //     ),
      //     FloatingActionButton(
      //       onPressed: () => _goToDetailPage(context),
      //       tooltip: "Add Note",
      //       heroTag: "AddNote",
      //       child: Icon(Icons.add),
      //     ),
      //   ],
      // ),
      body: Notes(),
    );
  }

  void addCategoryDialog(BuildContext context) {
    var formKey = GlobalKey<FormState>();

    String newCategoryName;
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
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (value) {
                      newCategoryName = value;
                    },
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      contentPadding: EdgeInsets.fromLTRB(10, 2, 5, 0),
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
                    onPressed: () {
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        databaseHelper
                            .addCategory(
                                Category(categoryName: newCategoryName))
                            .then((categoryID) {
                          if (categoryID > 0) {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                              content: Text("Category added"),
                              duration: Duration(seconds: 2),
                            ));
                          }
                        });
                        Navigator.pop(context);
                      }
                    },
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
  }

  _goToDetailPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  title: "New Note",
                )));
  }
}

class Notes extends StatefulWidget {
  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  List<Note> allNotes;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    super.initState();
    allNotes = List<Note>();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: databaseHelper.getNoteList(),
      builder: (context, AsyncSnapshot<List<Note>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          allNotes = snapshot.data;
          sleep(Duration(milliseconds: 500));
          return ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 6.0, left: 6.0, right: 16.0, bottom: 6.0),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          allNotes[index].noteTitle,
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: Icon(
                          Icons.circle,
                          size: 16,
                          color:
                              _setPriorityColor(allNotes[index].notePriority),
                        ),
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                    height: 45,
                                    width: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Category",
                                                style: TextStyle(
                                                    color: Colors.red.shade900,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 0, 0),
                                                child: Text(
                                                  allNotes[index].categoryTitle,
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        VerticalDivider(
                                          thickness: 1,
                                          color: Colors.black26,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "Create Date",
                                                style: TextStyle(
                                                    color: Colors.red.shade900,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 5, 0, 0),
                                                child: Text(
                                                  databaseHelper.dateFormat(
                                                      DateTime.parse(
                                                          allNotes[index]
                                                              .noteDate)),
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                                Divider(
                                  thickness: 1,
                                  color: Colors.black26,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    "Content",
                                    style: TextStyle(
                                        color: Colors.red.shade900,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 5, 0, 10),
                                  child: Text(
                                    allNotes[index].noteContent,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                ButtonBar(
                                  buttonPadding: EdgeInsets.all(0),
                                  alignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                        onPressed: () =>
                                            _deleteNote(allNotes[index].noteID),
                                        tooltip: "Delete",
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.redAccent,
                                        )),
                                    IconButton(
                                        onPressed: () {
                                          _goToDetailPage(
                                              context, allNotes[index]);
                                        },
                                        tooltip: "Update",
                                        icon: Icon(Icons.edit,
                                            color: Colors.green)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        } else {
          return Center(
            child: Text(
              "Loading...",
              style: TextStyle(color: Colors.deepOrange),
            ),
          );
        }
      },
    );
  }

  _goToDetailPage(BuildContext context, Note note) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  title: "Edit Note",
                  editingNote: note,
                )));
  }

  Color _setPriorityColor(int notePriority) {
    switch (notePriority) {
      case 1:
        return Colors.green.shade400;
        break;
      case 2:
        return Colors.yellow.shade800;
        break;
      case 3:
        return Colors.redAccent.shade700;
        break;
    }
  }

  _deleteNote(int noteID) {
    databaseHelper.deleteNote(noteID).then((deletedNoteId) {
      if (deletedNoteId != 0) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Note successfuly deleted"),
        ));

        setState(() {});
      }
    });
  }
}
