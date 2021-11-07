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
                          r"$$\sum_{i=1}^{n}i^k = 1^k + 2^k + \cdots + n^k$$",
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
                  sum = "대기중..";
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayEqPage(title: '공식 보기')));
                },
                child: Text("공식 보기"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage(title: '설명')));
        },
        label: Text("작동 원리"),
        icon: Icon(Icons.help),
      ),
    );
  }
}

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HelpPage> createState() => _HelpState();
}

class _HelpState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TeXView(
              child: TeXViewInkWell(
                id: "id_10",
                child: TeXViewDocument(
                  r"""$$(x+1)^a = \sum_{i=0}^{a}\binom{a}{i}x^{a-i}$$은 항등식이다.
                  따라서, $$(x+1)^a - x^a = \sum_{i=1}^{a}\binom{a}{i}x^{a-i}$$역시 성립한다.
                  $$\begin{align}
                    2^a - 1^a &= \sum_{i=1}^a\binom{a}{i}1^{a-i} \\
                    3^a - 2^a &= \sum_{i=1}^a\binom{a}{i}2^{a-i} \\
                    &\vdots \\
                    (n+1)^a - n^a &= \sum_{i=1}^a\binom{a}{i}n^{a-i}
                  \end{align}$$
                  """
                )
              )
            )
          ],
        ),
      ),
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
                                hintText: "100만 이하의 수를 입력하세요."
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
                                setState(() {
                                  sum ="대기중..";
                                });
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
                            child: Text("1~n까지의 합: $sum"),
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
