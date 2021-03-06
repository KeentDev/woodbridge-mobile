import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'woodbridge-ui_components.dart';
import 'home_page.dart';

// Sibling Controllers
List<TextEditingController> _siblingsNameController = <TextEditingController>[
  TextEditingController()
];
List<TextEditingController> _siblingsAgeController = <TextEditingController>[
  TextEditingController()
];

// Sibling Focus
List<FocusNode> _siblingNameFocus = <FocusNode>[
  FocusNode()
];

List<FocusNode> _siblingAgeFocus = <FocusNode>[
  FocusNode()
];

// Sibling Fields
List<InputTextField> _siblingNameFields = <InputTextField>[
  InputTextField(
      label: "Sibling #1",
      controller: _siblingsNameController[0],
      onSaved: () {
        onSave(
          0,
          _siblingNameFields,
          _siblingAgeFields,
          _siblingsNameController,
          _siblingsAgeController,
          _siblingNameFocus,
          _siblingAgeFocus,
          "Sibling",
          "Age"
        );
      },
      focus: _siblingNameFocus[0],
  ),
];

List<InputTextField> _siblingAgeFields = <InputTextField>[
  InputTextField(
    label: "Age",
    controller: _siblingsAgeController[0],
    focus: _siblingAgeFocus[0],
  ),
];

// Assigned Controllers
List<TextEditingController> _assignedPickupController = <TextEditingController>[
  TextEditingController()
];
List<TextEditingController> _assignedRelationController = <TextEditingController>[
  TextEditingController()
];

// Assigned Focus
List<FocusNode> _assignedPickupFocus = <FocusNode>[
  FocusNode()
];

List<FocusNode> _assignedRelationFocus = <FocusNode>[
  FocusNode()
];

// Assigned Fields
List<InputTextField> _assignedPickupFields = <InputTextField>[
  InputTextField(
    label: "Assigned",
    controller: _assignedPickupController[0],
    onSaved: () {
      onSave(
        0,
        _assignedPickupFields,
        _assignedRelationFields,
        _assignedPickupController,
        _assignedRelationController,
        _assignedPickupFocus,
        _assignedRelationFocus,
        "Assigned",
        "Relationship"
      );
    },
    focus: _assignedPickupFocus[0],
  ),
];

List<InputTextField> _assignedRelationFields = <InputTextField>[
  InputTextField(
    label: "Relationship",
    controller: _assignedRelationController[0],
    focus: _assignedRelationFocus[0],
  ),
];

class EnrollStudent extends StatefulWidget {
  @override
  _EnrollStudentState createState() => _EnrollStudentState();
}

class _EnrollStudentState extends State<EnrollStudent> {
  List<String> sexLabels = ['Male', 'Female'];
  // Family
  List<String> titleLabels = ['Mr.', 'Mrs.', 'Dr.', 'Ms.', 'Arch.', 'Atty.', 'Engr.', 'Hon.', 'Other'];


  static bool _fatherHomeAddrSIsSame = false;
  static bool _motherHomeAddrSIsSame = false;

  final _activitiesController = TextEditingController();
  final _allergiesController = TextEditingController();
  DateTime _dateBirth;

  final _fatherBusAddrController = TextEditingController();
  final _fatherBusTelNumController = TextEditingController();
  final _fatherEmailAddrController = TextEditingController();
  // Family - Father
  final _fatherFnameController = TextEditingController();

  final _fatherHomeAddrController = TextEditingController();
  final _fatherLnameController = TextEditingController();
  final _fatherMiddleInitialController = TextEditingController();
  final _fatherMobileNumController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  String _fatherTitle;
  // Student
  final _fnameController = TextEditingController();

  int _genderRadio = -1;
  bool _hadAllergies = false;
  bool _hadMedications = false;
  bool _hadPriorSchooling = false;
  final _homeAddressController = TextEditingController();
  final _homeTelNumController = TextEditingController();
  bool _homeTelNumNA = false;
  final _legalGuardianController = TextEditingController();
  final _lnameController = TextEditingController();
  final _medicationNamesController = TextEditingController();
  final _medicationPurposesController = TextEditingController();
  final _middleInitialController = TextEditingController();
  List _month = ['Jan.', 'Feb.', 'Mar.', 'Apr.', 'May', 'June', 'July', 'Aug.', 'Sep.', 'Oct.',' Nov.', 'Dec.'];
  final _motherBusAddrController = TextEditingController();
  final _motherBusTelNumController = TextEditingController();
  final _motherEmailAddrController = TextEditingController();
  // Family - Mother
  final _motherFnameController = TextEditingController();

  final _motherHomeAddrController = TextEditingController();
  final _motherLnameController = TextEditingController();
  final _motherMiddleInitialController = TextEditingController();
  final _motherMobileNumController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  String _motherTitle;
  final _otherConcernsController = TextEditingController();
  final _placeOfBirthController = TextEditingController();
  final _prefferedToysController = TextEditingController();
  final _religionController = TextEditingController();
  final _schoolExpectationsController = TextEditingController();
  final _schoolHistoryController = TextEditingController();
  final _spendsHisDayController = TextEditingController();

  Future _selectDateBirth() async {
    _dateBirth = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2000),
      lastDate: (new DateTime.now()).add(new Duration(hours: 1))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Enroll New Student')
      ),
      bottomNavigationBar: BottomAppBar(
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(),
          StadiumBorder(side: BorderSide())
        ),
        color: Colors.white,
        notchMargin: 5.0,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
          child: accentCtaButton(
            label: 'SUBMIT',
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context) => HomePage(
                child: Avatar(
                  backgroundColor: Colors.indigo,
                  maxRadius: 40.0,
                  minRadius: 20.0,
                  fontSize: 20.0,
                  initial: "KG"
                ),
                firstName: 'Keanu Kent',
                lastName: 'Gargar',
                heroTag: 'keanu',
              ));
              Navigator.push(context, route);
            },
          ),
        )
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          alignment: AlignmentDirectional.topCenter,
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              alignment: AlignmentDirectional.topStart,
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Student's Basic Information",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                  Form(
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        InputTextField(label: "First Name", controller: _fnameController),
                        InputTextField(label: "Middle Initial", controller: _middleInitialController),
                        InputTextField(label: "Last Name", controller: _lnameController),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          child: InputRadioButton(radioValue: _genderRadio, radioValueLabels: sexLabels, label: 'Sex', direction: 'row'),
                        ),
                        InputTextField(label: "Home Address", controller: _homeAddressController),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _homeTelNumController,
                                  style: TextStyle(
                                    color: _homeTelNumNA ? Colors.black38 : Colors.black87
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Home Telephone Number',
                                    labelText: 'Home Telephone Number',
                                  ),
                                  enabled: !_homeTelNumNA
                                ),
                              ),
                              Flexible(
                                flex: 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Row(
                                    children: <Widget>[
                                      Checkbox(
                                        value: _homeTelNumNA,
                                        onChanged: (bool value) {
                                          setState(() {
                                            _homeTelNumNA = !_homeTelNumNA;
                                          });
                                        },
                                      ),
                                      Text('N/A')
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Date of Birth: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0,
                                      color: Colors.black54
                                  )
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                                      color: Color.fromRGBO(0, 0, 0, .03)
                                    ),
                                    child: Text(
                                      _dateBirth == null ? 'Please select date' : '${_month[_dateBirth.month - 1]} ${_dateBirth.day.toString()}, ${_dateBirth.year.toString()}',
                                      style: _dateBirth == null ? TextStyle(fontSize: 16.0, color: Colors.black38, fontWeight: FontWeight.w600) : TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 1.0),
                                    child: OutlineButton(
                                      onPressed: () { _selectDateBirth(); },
                                      borderSide: BorderSide(
                                        color: _dateBirth == null ? Colors.blueAccent : Colors.black12
                                      ),
                                      child: Text(
                                        _dateBirth == null ? 'Select Date' : 'Change Date',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: _dateBirth == null ? Colors.blueAccent : Colors.black54
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ),
                        InputTextField(label: "Place of Birth", controller: _placeOfBirthController),
                        InputTextField(label: "Religion", controller: _religionController),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Has your child had prior schooling?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.0,
                                      color: Colors.black54
                                  )
                                ),
                              ),
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    flex: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 32.0),
                                      child: Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: _hadPriorSchooling,
                                            onChanged: (bool value) {
                                              setState(() {
                                                _hadPriorSchooling = !_hadPriorSchooling;
                                              });
                                            },
                                          ),
                                          Text('YES')
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _schoolHistoryController,
                                      style: TextStyle(
                                        color: !_hadPriorSchooling ? Colors.black38 : Colors.black87
                                      ),
                                      decoration: InputDecoration(
                                          hintText: 'School History',
                                          labelText: 'If so, what school?'
                                      ),
                                      enabled: _hadPriorSchooling,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Family Background",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                  Form(
                    autovalidate: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              margin: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                "Father",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            InputTextField(label: "Father's First Name", controller: _fatherFnameController),
                            InputTextField(label: "Father's Middle Initial", controller: _fatherMiddleInitialController),
                            InputTextField(label: "Father's Last Name", controller: _fatherLnameController),
                            CustomFormField(
                              fieldTitle: "Father's Title",
                              child: InputDropdownButton(dropdownValueLabels: titleLabels, dropdownValue: _fatherTitle)
                            ),
                            ReactiveInputTextField(
                              controller: _fatherHomeAddrController,
                              conditionalControl: _fatherHomeAddrSIsSame,
                              label: 'Home Address',
                              conditionalLabel: 'same as student',
                              onChange: ((value) {
                                setState(() {
                                  _fatherHomeAddrSIsSame = !_fatherHomeAddrSIsSame;
                                  if(value){
                                    _fatherHomeAddrController.text = _homeAddressController.text;
                                  }else {
                                    _fatherHomeAddrController.clear();
                                  }
                                });
                              }),
                            ),
                            InputTextField(label: "Father's Occupation", controller: _fatherOccupationController),
                            InputTextField(label: "Business Address", controller: _fatherBusAddrController),
                            InputTextField(label: "Business Tel. #", controller: _fatherBusTelNumController),
                            InputTextField(label: "Mobile #", controller: _fatherMobileNumController),
                            InputTextField(label: "Email Address", controller: _fatherEmailAddrController),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              alignment: AlignmentDirectional.topStart,
                              margin: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                "Mother",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                            InputTextField(label: "Mother's First Name", controller: _motherFnameController),
                            InputTextField(label: "Mother's Middle Initial", controller: _motherMiddleInitialController),
                            InputTextField(label: "Mother's Last Name", controller: _motherLnameController),
                            CustomFormField(
                                fieldTitle: "Mother's Title",
                                child: InputDropdownButton(dropdownValueLabels: titleLabels, dropdownValue: _motherTitle)
                            ),
                            ReactiveInputTextField(
                              controller: _motherHomeAddrController,
                              conditionalControl: _motherHomeAddrSIsSame,
                              label: 'Home Address',
                              conditionalLabel: 'same as student',
                              onChange: ((value) {
                                setState(() {
                                  _motherHomeAddrSIsSame = !_motherHomeAddrSIsSame;
                                  if(value){
                                    _motherHomeAddrController.text = _homeAddressController.text;
                                  }else {
                                    _motherHomeAddrController.clear();
                                  }
                                });
                              }),
                            ),
                            InputTextField(label: "Mother's Occupation", controller: _motherOccupationController),
                            InputTextField(label: "Business Address", controller: _motherBusAddrController),
                            InputTextField(label: "Business Tel. #", controller: _motherBusTelNumController),
                            InputTextField(label: "Mobile #", controller: _motherMobileNumController),
                            InputTextField(label: "Email Address", controller: _motherEmailAddrController),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Form(
                    autovalidate: true,
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        CustomFormField(
                          fieldTitle: "Does your child have any siblings?",
                          child: SingleChildScrollView(
                            child: Flex(
                              direction: Axis.horizontal,
                              children: <Widget>[
                                Flexible(
                                  flex: 3,
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: _siblingNameFields
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: _siblingAgeFields,
                                  ),
                                )
                              ],
                            )
                          )
                        ),
                        InputTextField(label: "Who is your child's legal guardian?", controller: _legalGuardianController),
                        CustomFormField(
                          fieldTitle: "Who is/are assigned to pick your child up from the school?",
                          child: SingleChildScrollView(
                                child: Flex(
                                  direction: Axis.horizontal,
                                  children: <Widget>[
                                    Flexible(
                                      flex: 3,
                                      child: Flex(
                                          direction: Axis.vertical,
                                          children: _assignedPickupFields
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Flex(
                                        direction: Axis.vertical,
                                        children: _assignedRelationFields,
                                      ),
                                    )
                                  ],
                                )
                            )
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Health and History",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                  Form(
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      'Is your child currently under any medication(s)?',
                                      softWrap: true,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16.0,
                                          color: Colors.black54
                                      )
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: _hadMedications,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _hadMedications = !_hadMedications;
                                              if(!value){
                                                _medicationNamesController.clear();
                                                _medicationPurposesController.clear();
                                              }
                                            });
                                          },
                                        ),
                                        Text('YES')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              TextFormField(
                                controller: _medicationNamesController,
                                style: TextStyle(
                                    color: !_hadMedications ? Colors.black38 : Colors.black87
                                ),
                                decoration: InputDecoration(
                                    hintText: 'Medications...',
                                    labelText: 'If so, please specify medications'
                                ),
                                enabled: _hadMedications,
                              ),
                              TextFormField(
                                controller: _medicationPurposesController,
                                style: TextStyle(
                                    color: !_hadMedications ? Colors.black38 : Colors.black87
                                ),
                                decoration: InputDecoration(
                                    hintText: 'Purposes...',
                                    labelText: 'If so, please specify purposes'
                                ),
                                enabled: _hadMedications,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    'Does your child have any allergies?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.0,
                                        color: Colors.black54
                                    )
                                ),
                              ),
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    flex: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 32.0),
                                      child: Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: _hadAllergies,
                                            onChanged: (bool value) {
                                              setState(() {
                                                _hadAllergies = !_hadAllergies;
                                                if(!value){
                                                  _allergiesController.clear();
                                                }
                                              });
                                            },
                                          ),
                                          Text('YES')
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: TextFormField(
                                      controller: _allergiesController,
                                      style: TextStyle(
                                          color: !_hadAllergies ? Colors.black38 : Colors.black87
                                      ),
                                      decoration: InputDecoration(
                                          hintText: 'Seafood, peanuts, etc...',
                                          labelText: 'If so, please specify'
                                      ),
                                      enabled: _hadAllergies,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Other Information",
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ),
                  Form(
                    child: Flex(
                      direction: Axis.vertical,
                      children: <Widget>[
                        InputTextField(label: "What activities interest your child", controller: _activitiesController),
                        InputTextField(label: "What toys do your child prefer to play with", controller: _prefferedToysController),
                        InputTextField(label: "How does your child usually spend his day", controller: _spendsHisDayController),
                        InputTextField(label: "What do you expect your child to gain from his school experience", controller: _schoolExpectationsController),
                        InputTextField(label: "What other concerns do we need to know regarding your child", controller: _otherConcernsController),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}

class InputTextField extends StatelessWidget {
  InputTextField({
    this.label,
    this.controller,
    this.inputFormatter,
    this.onSaved,
    this.focus
  });

  final TextEditingController controller;
  final FocusNode focus;
  final List<TextInputFormatter> inputFormatter;
  final String label;
  final onSaved;
  final double _verticalSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    if(focus != null){
      this.focus.addListener(() {
        if(!focus.hasFocus){
          onSaved();
        }
      });
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: _verticalSpacing),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatter,
        focusNode: focus,
        decoration: InputDecoration(
          hintText: label,
          labelText: label,
          hintMaxLines: 2
        ),
      ),
    );
  }
}

class InputDropdownButton extends StatefulWidget{
  InputDropdownButton({
    this.dropdownValueLabels,
    this.dropdownValue
  });

  String dropdownValue;
  final List<String> dropdownValueLabels;

  @override
  _InputDropdownButtonState createState() => _InputDropdownButtonState();
}

class _InputDropdownButtonState extends State<InputDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.dropdownValue ?? widget.dropdownValueLabels[0],
      onChanged: (String newValue) {
        setState(() {
          widget.dropdownValue = newValue;
        });
      },
      items: widget.dropdownValueLabels.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value)
        );
      }).toList(),
    );
  }
}

class CustomFormField extends StatelessWidget {
  CustomFormField({
    this.fieldTitle,
    this.child
  });

  final Widget child;
  final String fieldTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              fieldTitle,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.0,
                color: Colors.black54
              )
            ),
          ),
          child
        ],
      ),
    );
  }
}

class ReactiveInputTextField extends StatefulWidget {
  ReactiveInputTextField({
    this.controller,
    this.conditionalControl,
    this.onChange,
    this.label,
    this.conditionalLabel
  });

  final bool conditionalControl;
  final String conditionalLabel;
  TextEditingController controller;
  final String label;
  var onChange;

  @override
  _ReactiveInputTextFieldState createState() => _ReactiveInputTextFieldState();
}

class _ReactiveInputTextFieldState extends State<ReactiveInputTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
            controller: widget.controller,
            style: TextStyle(
                color: widget.conditionalControl ? Colors.black38 : Colors.black87
            ),
            decoration: InputDecoration(
              hintText: widget.label,
              labelText: widget.label,
            ),
            enabled: !widget.conditionalControl
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: widget.conditionalControl,
              onChanged: (bool value) {
                widget.onChange(value);
              },
            ),
            Text(widget.conditionalLabel)
          ],
        ),
      ],
    );
  }
}

onSave(
  fieldIndex,
  columnOneFields,
  columnTwoFields,
  columnOneController,
  columnTwoController,
  columnOneFocus,
  columnTwoFocus,
  columnOneLabel,
  columnTwoLabel
) {
  if(fieldIndex == columnOneFields.length-1 && columnOneController[fieldIndex].text.length > 0){
    int newSiblingIndex = fieldIndex + 1;

    columnOneController.add(TextEditingController());
    columnOneFocus.add(FocusNode());
    columnTwoController.add(TextEditingController());
    columnTwoFocus.add(FocusNode());

    columnOneFields.add(InputTextField(
        label: "$columnOneLabel #${newSiblingIndex + 1}",
        controller: columnOneController[newSiblingIndex],
        onSaved: () {
          onSave(
            newSiblingIndex,
            columnOneFields,
            columnTwoFields,
            columnOneController,
            columnTwoController,
            columnOneFocus,
            columnTwoFocus,
            columnOneLabel,
            columnTwoLabel);
        },
        focus: columnOneFocus[newSiblingIndex],
    ));
    columnTwoFields.add(InputTextField(
      label: columnTwoLabel,
      controller: columnTwoController[newSiblingIndex],
      focus: columnTwoFocus[newSiblingIndex],
    ));
  } else if (fieldIndex != columnOneFields.length-1 && columnOneController[fieldIndex].text.length == 0){
    for(int i = fieldIndex; i < columnOneFields.length - 1; i++){
      columnOneFields[i].controller.text = columnOneController[i+1].text;
      columnTwoFields[i].controller.text = columnTwoController[i+1].text;

      columnOneFields[i].focus = columnOneFields[i+1].focus;
      columnTwoFields[i].focus = columnTwoFields[i+1].focus;
    }
    columnOneFields.removeLast();
    columnOneController.removeLast();

    columnTwoFields.removeLast();
    columnTwoController.removeLast();

    columnTwoFocus.removeLast();
    columnOneFocus.removeLast();
  }
}