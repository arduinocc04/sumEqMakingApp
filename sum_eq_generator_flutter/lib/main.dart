import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
int k = 0, n = 0;
String sum = "";
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sum formula generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '홈'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final text = TextEditingController();
  TeXViewRenderingEngine renderingEngine = TeXViewRenderingEngine.katex();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
        padding: EdgeInsets.symmetric(vertical: 200, horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TeXView(
              child: TeXViewColumn(children: [
                TeXViewInkWell(
                    child: TeXViewDocument(
                        r"\(\sum_{i=1}^{n}i^k = 1^k + 2^k + \cdots + n^k\)",
                        style: TeXViewStyle(
                            textAlign: TeXViewTextAlign.Center,
                            fontStyle: TeXViewFontStyle(fontSize: 40))),
                    id: "id_0")
              ]),
              style: TeXViewStyle(
                elevation: 10,
                borderRadius: TeXViewBorderRadius.all(25),
                border: TeXViewBorder.all(TeXViewBorderDecoration(
                    borderColor: Colors.blue,
                    borderStyle: TeXViewBorderStyle.Solid,
                    borderWidth: 5)),
                backgroundColor: Colors.white,
              ),
            ),
            TextField(
              controller: text,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "100이하의 정수를 입력하세요.", labelText: "k=?"),
            ),
            TextButton(
              onPressed: () {
                k = int.parse(text.text);
                text.text = "";
                Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayEqPage(title: '공식 보기')));
              },
              child: Text("공식 보기"),
            )
          ],
        ),
      )),
    );
  }
}

class DisplayEqPage extends StatefulWidget {
  const DisplayEqPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<DisplayEqPage> createState() => _DisplayEqState();
}

class _DisplayEqState extends State<DisplayEqPage> {
  Future<String> _download() async {
    dynamic json;
    dynamic response;
    try{
      response = await http.get(Uri.parse("http://arduinocc04.tech/?k=$k"));
      if(response.statusCode == 200) {
        json = convert.jsonDecode(response.body) as Map<String, dynamic>;
      }
    }
    catch(e) {
      print(e);
      json = {'array':[]};
    }
    if(json == null) {
      return "-1";
    }
    print(json);
    return json['tex'];
  }
  var text = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              FutureBuilder(
                future: _download(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData == false) {
                    return CircularProgressIndicator();
                  } 
                  else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  } 
                  else {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                            child: TeXView(
                              child: TeXViewInkWell(
                                child: TeXViewDocument(
                                  r'\(' + snapshot.data + r'\)',
                                  style: TeXViewStyle(
                                    textAlign: TeXViewTextAlign.Center,
                                    fontStyle: TeXViewFontStyle(fontSize: 10)
                                  ),
                                ),
                                id: "id_1"
                              ),
                              style: TeXViewStyle(
                                elevation: 10,
                                borderRadius: TeXViewBorderRadius.all(25),
                                border: TeXViewBorder.all(TeXViewBorderDecoration(
                                    borderColor: Colors.blue,
                                    borderStyle: TeXViewBorderStyle.Solid,
                                    borderWidth: 5)),
                                backgroundColor: Colors.white,
                              )
                            )
                          ),
                          Container(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "n=?",
                                hintText: "원하는 수를 입력하세요."
                              ),
                              keyboardType: TextInputType.number,
                              controller: text,
                            ),
                          ),
                          Container(
                            child: TextButton(
                              child: Text("값 찾기"),
                              onPressed: () async {
                                n = int.parse(text.text);
                                text.text = "";
                                dynamic response, json;
                                response = await http.get(Uri.parse("http://arduinocc04.tech/getVal?k=$k&n=$n"));
                                if(response.statusCode == 200) {
                                  json = convert.jsonDecode(response.body) as Map<String, dynamic>;
                                  setState(() {
                                    sum = json['val'];
                                  });
                                }
                              },
                            ),
                          ),
                          Container(
                            child: Text("값: $sum"),
                          )
                        ],
                      ),
                    );   
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
