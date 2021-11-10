// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Varaibles
  // TODO: Change lockerModel
  List myLockers = [
    {
      'mainBuilding': 'Edificio T',
      'lockerId': 'Locker 2A',
      'timestamp': '00:00:05',
      'cost': '\$2.00',
    },
    {
      'mainBuilding': 'Edificio T',
      'lockerId': 'Locker 1A',
      'timestamp': '00:00:03',
      'cost': '\$1.00',
    },
  ];

  List availableLockers = [
    {
      'mainBuilding': 'Edificio T',
      'price': '\$2.00/día',
      'lockers': [
        {
          'mainBuilding': 'Edificio T',
          'lockerId': 'Locker 3A',
          'timestamp': '00:00:00',
          'cost': '\$0.00'
        },
        {
          'mainBuilding': 'Edificio T',
          'lockerId': 'Locker 4A',
          'timestamp': '00:00:00',
          'cost': '\$0.00'
        },
      ]
    },
    {
      'mainBuilding': 'Domo Deportivo',
      'price': '\$5.00/hora',
      'lockers': [
        {
          'mainBuilding': 'Domo Deportivo',
          'lockerId': 'Locker 1B',
          'timestamp': '00:00:00',
          'cost': '\$0.00'
        },
        {
          'mainBuilding': 'Domo Deportivo',
          'lockerId': 'Locker 2B',
          'timestamp': '00:00:00',
          'cost': '\$0.00'
        },
      ]
    },
  ];

  bool showAvailableLockers = false;

  // Methods
  // Render available lockers
  List<ExpansionPanelRadio> generateItems(int numOfItems) {
    return List.generate(numOfItems, (index1) {
      return ExpansionPanelRadio(
        value: index1,
        headerBuilder: (context, isOpen) {
          return ListTile(
            title: Text(
              availableLockers[index1]["mainBuilding"],
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(availableLockers[index1]["price"]),
          );
        },
        body: ListView.builder(
          itemCount: availableLockers[index1]["lockers"].length,
          shrinkWrap: true,
          itemBuilder: (context, index2) {
            return ListTile(
              tileColor: Colors.white,
              title:
                  Text(availableLockers[index1]["lockers"][index2]["lockerId"]),
              trailing: TextButton(
                onPressed: () {
                  setState(() {
                    myLockers.add(availableLockers[index1]["lockers"].removeAt(
                        index2)); // Remove from availableLockers and add to myLockers
                    showAvailableLockers = false;
                  });
                },
                child: Text(
                  'Rentar',
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFF1CD8D2))),
              ),
            );
          },
        ),
      );
    });
  }

  // Send message with Twilio
  void _sendSms(target, message) async {
    print('IN SEND SMS');
    print('Sending...');

    // Twilio request
    Uri url = Uri.parse(
        'https://pzhxaho4ne.execute-api.us-east-1.amazonaws.com/dev/locker-sms');
    Map bodyMap = {"target": "+52 " + target, "message": message};
    String body = json.encode(bodyMap);
    Response response = await post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    // Print response data
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      Map<String, dynamic> result = json.decode(response.body);
      print('Response body: $result');
    }
    // Just to know if finished
    print('Done! Status Code: ${response.statusCode}');
  }

  @override
  Widget build(BuildContext context) {
    // Relative sizes
    EdgeInsets padding = MediaQuery.of(context).padding;
    double width = MediaQuery.of(context).size.width;
    double height =
        MediaQuery.of(context).size.height - padding.top - padding.bottom;
    double vw = width / 100;
    double vh = height / 100;

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color(0xFF93EDC7),
        backgroundColor: Colors.teal,
        title: Text('Renta de Lockers'),
        actions: [
          Container(
              margin: EdgeInsets.only(right: vw * 5.0),
              child: Icon(
                Icons.account_circle,
                size: 40.0,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: vw * 5.0, vertical: vh * 5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis lockers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21.0,
                  color: Colors.teal[300],
                ),
              ),
              SizedBox(
                height: vh * 2.0,
              ),
              Visibility(
                visible: myLockers.isEmpty,
                child: Text(
                  'No has rentado un locker aún.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: myLockers.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Color(0xFFE5E5E5),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: vw * 1.0, horizontal: vh * 2.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                myLockers[index]['lockerId'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        // Remove from myLockers
                                        var availableLocker =
                                            myLockers.removeAt(index);
                                        int mainBuildingIndex = availableLockers
                                            .indexWhere((mainBuilding) =>
                                                mainBuilding["mainBuilding"] ==
                                                availableLocker[
                                                    "mainBuilding"]);
                                        // Add to availableLockers
                                        availableLockers[mainBuildingIndex]
                                                ["lockers"]
                                            .add(availableLocker);
                                        // TODO: Sort lockers according to lockerId (string based)
                                      });
                                    },
                                    child: Text(
                                      'Desocupar',
                                      style:
                                          TextStyle(color: Color(0xFF1CD8D2)),
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: vw * 3.0,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _sendSms('3311778132',
                                          'Abrir ${myLockers[index]["name"]}');
                                    },
                                    child: Text(
                                      'Abrir',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xFF1CD8D2))),
                                  ),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: vh * 1.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  'Tiempo transcurrido: ${myLockers[index]["timestamp"]}'),
                              Text('Costo: \$${myLockers[index]["cost"]}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: vh * 5.0,
              ),
              Text(
                'Lockers Disponibles',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21.0,
                  color: Colors.teal[300],
                ),
              ),
              SizedBox(
                height: vh * 2.0,
              ),
              Visibility(
                visible: !showAvailableLockers,
                child: Text(
                  'Actualmente está rentando ${myLockers.length} locker${myLockers.length == 1 ? "" : "s"}, pero puede rentar más si así lo desea.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              SizedBox(
                height: vh * 2.0,
              ),
              Visibility(
                visible: !showAvailableLockers,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showAvailableLockers = true;
                    });
                  },
                  child: Text(
                    'Ver lockers disponibles',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                          Size(double.infinity, 40.0)),
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF1CD8D2))),
                ),
              ),
              Visibility(
                visible: showAvailableLockers,
                child: ExpansionPanelList.radio(
                  expandedHeaderPadding: EdgeInsets.all(0),
                  children: generateItems(availableLockers.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
