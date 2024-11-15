import 'package:flutter/material.dart';
import 'package:sqf_lite_working_practice/data/local/db_helper.dart';

class MyWidget extends StatefulWidget {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance; // Corrected: Use getter for DbHelper instance
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: widget.allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: widget.allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title:
                      Text(widget.allNotes[index][DbHelper.COLUMN_NOTE_TITLE]),
                  subtitle:
                      Text(widget.allNotes[index][DbHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                widget.titleController.text =
                                    widget.allNotes[index]
                                        [DbHelper.COLUMN_NOTE_TITLE];
                                widget.descController.text = widget
                                    .allNotes[index][DbHelper.COLUMN_NOTE_DESC];
                                return getBottomSheetWidget(
                                    isUpdate: true,
                                    sno: widget.allNotes[index]
                                        [DbHelper.COLUMN_NOTE_SNO]);
                              },
                            );
                          },
                          child: const Icon(Icons.edit),
                        ),
                        InkWell(
                          onTap: () async {
                            bool check = await widget.dbRef!.deleteNote(
                                sno: widget.allNotes[index]
                                    [DbHelper.COLUMN_NOTE_SNO]);
                            if (check) {
                              widget.getNotes();
                            }
                          },
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text('No Notes Yet!'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String errorMsg = "";
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                child: Column(
                  children: [
                    const Text(
                      "Add Note",
                      style: TextStyle(fontSize: 25),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: widget.titleController,
                      decoration: InputDecoration(
                        hintText: "Enter title here",
                        label: Text('Title'),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: widget.descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter description here",
                        label: const Text('Desc'),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              var title = widget.titleController.text;
                              var desc = widget.descController.text;

                              if (title.isNotEmpty && desc.isNotEmpty) {
                                bool check = await widget.dbRef!
                                    .addNote(mTitle: title, mDesc: desc);
                                if (check) {
                                  widget.getNotes();
                                }
                                Navigator.pop(context);
                              } else {
                                errorMsg =
                                    "Please fill all the required blanks";
                                setState(() {});
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            child: const Text('Add Note',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        Text(errorMsg),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
