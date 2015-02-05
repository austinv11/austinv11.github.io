// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:html';
import 'dart:math' show Random; //show only imports a certain class
import 'dart:convert' show JSON;
import 'dart:async' show Future;//A way to get a value from the future

ButtonElement genButton; //Button variable
SpanElement badgeNameElement;//Span variable
final String TREASURE_KEY = 'pirateName';//Key for saving key-value pairs in local storage

void main() {
  InputElement inputField = querySelector('#inputName');
  inputField.onInput.listen(updateBadge);
//  querySelector('#inputName').onInput.listen(updateBadge);//Selects the inputName DOM object then selects the onInput event stream and then registers the callback function 'updateBadge'
  genButton = querySelector('#generateButton');//Sets the button to equal a DOM object
  genButton.onClick.listen(generateBadge);//Registers an onClick listener
  badgeNameElement = querySelector('#badgeName');
  setBadgeName(getBadgeNameFromStorage());
  PirateName.readyThePirates()//Uses inline function defining
      .then((_) {//Underscores mean the param is ignored
        //on success
        inputField.disabled = false; //enable
        genButton.disabled = false;  //enable
        setBadgeName(getBadgeNameFromStorage());
      })
      .catchError((arrr) {
        print('Error initializing pirate names: $arrr');
        badgeNameElement.text = 'Arrr! No names.';
      });
}

void updateBadge(Event e) {
  String inputName = (e.target as InputElement).value;//Gets the badge name from the event (casted to an InputElement) text value
  setBadgeName(new PirateName(firstName: inputName));
    if (inputName.trim().isEmpty) {
      genButton..disabled = false //Cascade operators let you interact with an object more than once
               ..text = 'Aye! Gimme a name!';
    } else {
      genButton..disabled = true
               ..text = 'Arrr! Write yer name!';
    }
}

void setBadgeName(PirateName newName) {
  if (newName == null) {
      return;
    }
  querySelector('#badgeName').text = newName.pirateName;//Sets the badge text
  window.localStorage[TREASURE_KEY] = newName.jsonString;//Saves value to local storage (which only persists between windows, not restarts)
}

void generateBadge(Event e) {//Generates badge name onClick
  setBadgeName(new PirateName());
}

PirateName getBadgeNameFromStorage() {
  String storedName = window.localStorage[TREASURE_KEY];
  if (storedName != null) {
    return new PirateName.fromJSON(storedName);
  } else {
    return null;
  }
}


class PirateName { //Declares a class

  static final Random indexGen = new Random(); //Supports static and final
  String _firstName;
  String _appellation;
  static List<String> names = [];//Lists are arrays
  static List<String> appellations = [];

  PirateName({String firstName, String appellation}) {//Class constructor
      if (firstName == null) {
        _firstName = names[indexGen.nextInt(names.length)];//Gets the next random int with the array length as the max possible
      } else {
        _firstName = firstName;
      }
      if (appellation == null) {
        _appellation = appellations[indexGen.nextInt(appellations.length)];
      } else {
        _appellation = appellation;
      }
    }

  PirateName.fromJSON(String jsonString) {//Named constructor
      Map storedName = JSON.decode(jsonString);//Decodes json to a map
      _firstName = storedName['f'];
      _appellation = storedName['a'];
    }

  String get pirateName => _firstName.isEmpty ? '' : '$_firstName the $_appellation'; //A getter for the priate name
  // => expr; syntax is a shorthand for { return expr; }.

  String toString() => pirateName;//Overrides the default toString()

  String get jsonString => JSON.encode({"f": _firstName, "a": _appellation}); //Encodes a mad to json

  static Future readyThePirates() {
      var path = 'piratenames.json';
      return HttpRequest.getString(path)//Performs a GET request to the priatenames.json file
          .then(_parsePirateNamesFromJSON);//Then gives sets a call back function
    }

  static _parsePirateNamesFromJSON(String jsonString) {
      Map pirateNames = JSON.decode(jsonString);
      names = pirateNames['names'];
      appellations = pirateNames['appellations'];
    }
}