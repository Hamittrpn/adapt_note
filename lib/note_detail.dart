import 'package:adapt_note/models/category.dart';
import 'package:adapt_note/models/note.dart';
import 'package:adapt_note/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

class NoteDetail extends StatefulWidget {
  String title;
  Note editingNote;
  NoteDetail({this.title, this.editingNote});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;
  var formKey = GlobalKey<FormState>();
  List<Category> allCategories;
  DatabaseHelper databaseHelper;
  int categoryID = 1;
  String noteTitle, noteContent;
  double difLevel;
  @override
  void initState() {
    super.initState();
    allCategories = List<Category>();
    databaseHelper = DatabaseHelper();
    difLevel = widget.editingNote != null
        ? widget.editingNote.notePriority.toDouble()
        : 2;
    databaseHelper.getCategories().then((categoryMapList) {
      for (Map mapItem in categoryMapList) {
        allCategories.add(Category.fromMap(mapItem));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: allCategories.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        margin: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField(
                            items: generateCategoryItem(),
                            value: widget.editingNote != null
                                ? widget.editingNote.categoryID
                                : 1,
                            onChanged: (selectedCategoryID) {
                              setState(() {
                                categoryID = selectedCategoryID;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Note Title",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        initialValue: widget.editingNote != null
                            ? widget.editingNote.noteTitle
                            : "",
                        // ignore: missing_return
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Note content cannot be empty!";
                          }
                        },
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16.0),
                          hintText: "Please write title",
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (text) {
                          noteTitle = text;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Note Content",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        initialValue: widget.editingNote != null
                            ? widget.editingNote.noteContent
                            : "",
                        onSaved: (text) {
                          noteContent = text;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          contentPadding: new EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16.0),
                          hintText: "Please write content",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Priority",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Slider.adaptive(
                        value: difLevel,
                        activeColor: _setPriorityActiveColor(),
                        onChanged: (double newValue) {
                          setState(() => difLevel = newValue);
                        },
                        min: 1,
                        max: 3,
                        divisions: 2,
                        label: checkPriorityLevel(),
                      ),
                      buildTextWithIcon(),
                      Center(
                        child: ButtonTheme(
                          height: 53,
                          minWidth: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Colors.deepOrange),
                                  borderRadius: BorderRadius.circular(100)),
                              color: Colors.grey.shade200,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.deepOrange,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTextWithIcon() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width,
      child: ProgressButton.icon(iconedButtons: {
        ButtonState.idle: IconedButton(
            text: "Save",
            icon: Icon(Icons.save, color: Colors.white),
            color: Colors.deepOrange.shade500),
        ButtonState.loading:
            IconedButton(text: "Loading", color: Colors.deepPurple.shade700),
        ButtonState.fail: IconedButton(
            text: "Failed",
            icon: Icon(Icons.cancel, color: Colors.white),
            color: Colors.red.shade300),
        ButtonState.success: IconedButton(
            text: "Success",
            icon: Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            color: Colors.green.shade400)
      }, onPressed: onPressedIconWithText, state: stateTextWithIcon),
    );
  }

  void onPressedIconWithText() {
    switch (stateTextWithIcon) {
      case ButtonState.idle:
        if (formKey.currentState.validate()) {
          formKey.currentState.save();

          var now = DateTime.now();
          if (widget.editingNote == null) {
            databaseHelper
                .addNote(Note(
                    categoryID: categoryID,
                    noteTitle: noteTitle,
                    noteContent: noteContent,
                    noteDate: now.toString(),
                    notePriority: difLevel.toInt()))
                .then((savedNoteID) {
              if (savedNoteID != 0) {
                setState(() {
                  stateTextWithIcon = ButtonState.success;
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context);
                  });
                });
              } else {
                setState(() {
                  stateTextWithIcon = ButtonState.fail;
                });
              }
            });
          } else {
            databaseHelper
                .updateNote(Note.withID(
                    noteID: widget.editingNote.noteID,
                    categoryID: categoryID,
                    noteTitle: noteTitle,
                    noteContent: noteContent,
                    noteDate: now.toString(),
                    notePriority: difLevel.toInt()))
                .then((updatedID) {
              if (updatedID != 0) {
                setState(() {
                  stateTextWithIcon = ButtonState.success;
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context);
                  });
                });
              } else {
                setState(() {
                  stateTextWithIcon = ButtonState.fail;
                });
              }
            });
          }
        }

        break;
      case ButtonState.loading:
        break;
      case ButtonState.success:
        stateTextWithIcon = ButtonState.idle;
        break;
      case ButtonState.fail:
        stateTextWithIcon = ButtonState.idle;
        break;
    }
    setState(() {
      stateTextWithIcon = stateTextWithIcon;
    });
  }

  List<DropdownMenuItem<int>> generateCategoryItem() {
    return allCategories
        .map((category) => DropdownMenuItem<int>(
              value: category.categoryID,
              child: Text(
                category.categoryName,
                style: TextStyle(fontSize: 16),
              ),
            ))
        .toList();
  }

  String checkPriorityLevel() {
    if (difLevel < 2) {
      return "Low";
    } else if (difLevel >= 2 && difLevel < 3) {
      return "Medium";
    } else {
      return "High";
    }
  }

  Color _setPriorityActiveColor() {
    if (difLevel < 2) {
      return Colors.green;
    } else if (difLevel >= 2 && difLevel < 3) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }
}
