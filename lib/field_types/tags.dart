import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:textfield_tags/textfield_tags.dart';

class FieldTypeTags extends FieldType {
  final String hint;
  final TextStyle listStyle;
  final int maxTagsInList;

  FieldTypeTags({this.hint = "", this.maxTagsInList = 0, this.listStyle = const TextStyle(fontSize: 12, color: Colors.white)});

  @override
  getEditContent(BuildContext context, DocumentSnapshot? _object, Map<String, dynamic> values, ColumnModule column) {
    TextfieldTagsController<String> _controller = TextfieldTagsController();
    var value;
    if (_object != null && hasField(_object, column.field)) {
      value = _object.get(column.field);
    }

    List<String> valueString = [];
    if (value is String) {
      value = value.split(",");
    }

    if (value is List) {
      for (var v in value) {
        valueString.add(v.toString());
      }
    }
    //return SizedBox.shrink();
    double _distanceToField = MediaQuery.of(context).size.width;

    _controller.addListener(
      () {
        updateData(context, column, _controller.getTags);
      },
    );

    return TextFieldTags<String>(
      textfieldTagsController: _controller,
      initialTags: valueString,
      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      validator: (String tag) {
        if (_controller.getTags?.contains(tag) ?? false) {
          return 'La etiqueta $tag ya existe';
        }

        return null;
      },
      inputFieldBuilder: (context, textFieldTagValues) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            controller: textFieldTagValues.textEditingController,
            focusNode: textFieldTagValues.focusNode,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 3.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 3.0,
                ),
              ),
              hintText:  /*_controller.hasTags ? '' :*/ hint,
              errorText: textFieldTagValues.error,
              prefixIconConstraints: BoxConstraints(maxWidth: _distanceToField * 0.74),
              prefixIcon: textFieldTagValues.tags.isNotEmpty
                  ? SingleChildScrollView(
                      controller: textFieldTagValues.tagScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                            children: textFieldTagValues.tags.map((String tag) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: Theme.of(context).primaryColor),
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$tag', style: const TextStyle(color: Colors.white)),
                                const SizedBox(width: 4.0),
                                InkWell(
                                  child: const Icon(
                                    Icons.cancel,
                                    size: 14.0,
                                    color: Color.fromARGB(255, 233, 233, 233),
                                  ),
                                  onTap: () {
                                    textFieldTagValues.onTagRemoved(tag);
                                  },
                                )
                              ],
                            ),
                          );
                        }).toList()),
                      ),
                    )
                  : null,
            ),
            onEditingComplete: () {
              print("on editing complete");
            },
            onChanged: textFieldTagValues.onTagChanged,
            onSubmitted: textFieldTagValues.onTagSubmitted,
          ),
        );
      },
      /*
      inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
        return ((context, sc, tags, onTagDelete) {
          
        });
      },
      */
    );

    /*
        tagsStyler: TagsStyler(
            tagTextStyle: TextStyle(fontWeight: FontWeight.normal),
            tagDecoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
            tagCancelIcon: Icon(Icons.cancel, size: 18.0, color: Colors.blue[900]),
            tagPadding: const EdgeInsets.all(6.0)),
            
        tagsDistanceFromBorderEnd: 10,
        textFieldStyler: TextFieldStyler(helperText: "Introduzca etiquetas separadas por espacio o coma", hintText: hint),
        onTag: (tag) {
          print("new tag $tag");
          valueString.add(tag);
          updateData(context, column, valueString);
        },
        onDelete: (tag) {
          valueString.remove(tag);
          updateData(context, column, valueString);
        },        
        validator: (tag) {
          return null;
        }
    );*/
  }

  @override
  getListContent(BuildContext context, DocumentSnapshot _object, ColumnModule column) {
    if (_object.hasFieldAdm(column.field)) {
      var value = _object.get(column.field);
      List<String> valueString = [];
      if (value is String) {
        value = value.split(",");
      }
      if (value is List) {
        for (var v in value) {
          valueString.add(v.toString());
        }
      }

      if (value is List) {
        if (maxTagsInList > 0) {
          value = value.take(maxTagsInList);
        }
        return Wrap(
            spacing: 5.0,
            children: value
                .map<Widget>((e) => Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(5))),
                      padding: EdgeInsets.all(6),
                      child: Text(e, style: listStyle),
                    ))
                .toList());
      }
    }

    return SizedBox.shrink();
  }
}
