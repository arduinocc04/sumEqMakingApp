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
                  r"""
                  <h1>기초지식</h1>
                  고등수학 하의 '경우의 수'와 수학 1의 '수학적 귀납법'에 대한 지식이 있으면 이해하기 쉬우나, 그렇지 않아도 이해할 수 있다. </br>
                  기호 \(\sum\)는 '시그마'라고 읽으며, 덧셈을 축약해서 적는데 사용한다. </br>
                  예시)
                  $$\sum_{i=1}^{10} i = 1 + 2 + \cdots + 10 \\
                  \sum_{i=1}^{10} i^2  = 1^2 + 2^2 + \cdots + 10^2$$
                  또, \(\binom{n}{r} = \ _nC_r = \frac{n!}{(n-r)!r!}\)이다. 즉, 조합을 나타낸다. </br>
                  <h1>수학적 원리</h1>
                  $$(x+1)^a = \sum_{i=0}^{a}\binom{a}{i}x^{a-i}$$은 항등식이다(이항정리, 경우의 수 관점에서 직관적으로 받아들이고 넘어가면 된다.) </br>
                  따라서, $$(x+1)^a - x^a = \sum_{i=1}^{a}\binom{a}{i}x^{a-i}$$역시 성립한다.
                  또, 아래의 식이 역시 성립한다.
                  $$\begin{align*}
                    2^a - 1^a &= \sum_{i=1}^a\binom{a}{i}1^{a-i} \\
                    3^a - 2^a &= \sum_{i=1}^a\binom{a}{i}2^{a-i} \\
                    &\vdots \\
                    (n+1)^a - n^a &= \sum_{i=1}^a\binom{a}{i}n^{a-i}
                  \end{align*}$$
                  위의 식을 변끼리 더하면(좌우로 스크롤 가능)
                  $$\begin{align*}
                    (n+1)^a - 1^a &= \sum_{j = 1}^n\left(\sum_{i=1}^a\binom{a}{i}j^{a-i}\right) \\
                                  &= \left\{\binom{a}{1} + \binom{a}{2} + \cdots + \binom{a}{a}\right\}
                                  + \left\{\binom{a}{1}2^{a-1} + \binom{a}{2}2^{a-2} + \cdots + \binom{a}{a} \right\}
                                  + \cdots 
                                  + \left\{\binom{a}{1}n^{a-1} + \binom{a}{2}n^{a-2} +\cdots + \binom{a}{a} \right\} \\
                                  &= \binom{a}{1}\sum_{i=1}^{n}i^{a-1} + \binom{a}{2}\sum_{i=1}^ni^{a-2} + \cdots + \binom{a}{a}\sum_{i=1}^n1
                  \end{align*}$$
                  가 성립한다. 또, 이를 \(\sum\limits_{i=1}^{n}i^{a-i}\)에 대해 정리하면
                  $$
                  \begin{equation*}
                  \sum_{i=1}^ni^{a-1} = \frac{(n+1)^a- 1 - \{\binom{a}{2}\sum_{i=1}^ni^{a-2} + \cdots + \binom{a}{a}\sum_{i=1}^n1\}}{a}
                  \end{equation*}
                  $$
                  와 같다. 즉,
                  $$S_k = 1^k + 2^k + \cdots + n^k$$
                  라고 정의하면, \((n+1)^a\)는 이항정리를 통해 쉽게 계산할 수 있고, \(S_{a-2}, S_{a-3}, \dots, S_1\)을 알면 \(S_{a-1}\)역시 알 수 있으므로 \(S_k\)는 \(S_1, S_2, \dots, S_{k-1}\)의 합으로 나타낼 수 있다!
                  또한 우리는 
                  $$S_1 = \frac{n(n+1)}{2}$$
                  가 성립함을 알기 때문에, 쌓아올리듯이 모든 자연수 \(n\)에 대해 공식을 만들 수 있다.</br>
                  그리고, $$S_0 = n$$에서 시작해도 문제는 없다.
                  <h1>구현</h1>
                  <h2>Python vs C++</h2>
                  굳이 C++보다 느린 Python을 사용한 이유는 Bigint때문이다. C++에서는 큰 수(18,446,744,073,709,551,615이상의 수)를 다루기 까다롭지만, Python은 쉽게 다룰 수 있기 때문이다.
                  Dart(Flutter)대신 Python을 사용하여 API를 만든 이유 역시 마찬가지다.
                  <h2>객체지향 프로그래밍(Object-Oriented Programming)</h2>
                  \((n+1)^a\) 같은 것도 이항전개 사용하면 굳이 직접 전개할 필요가 없기 때문에, 결국 공식을 만들기 위해서 구현해야 할 것은 다항식 사이의 덧셈, 다항식과 정수 사이의 나눗셈, 정수와 정수사이의 사칙연산이다. 즉, 분수의 구현이 필요하다.</br>
                  이를 구현하는 방법은 다양하겠지만, 나는 단항식, 다항식, 분수 클래스를 정의해서 구현했다. </br>
                  분수는 분자와 분모를 갖는다. 단항식은 계수(분수), 차수(정수)를 갖는다. 다항식은 단항식들을 갖는다(배열에 넣어둔다.)
                  그다음은 귀찮은 구현이다. 다항식끼리 더할때는 for문을 사용해 동류항을 찾은 뒤, 계수(분수)의 계산으로 넘긴다.
                  즉, 분수의 계산만 잘 정의하면 된다.
                  분수의 계산은 다음을 잘 구현해주면 된다(마지막은 약분을 의미한다.)
                  $$
                  \frac{a}{b} + \frac{c}{d} = \frac{ad + bc}{bd}
                  $$
                  $$
                  \frac{a}{b} - \frac{c}{d} = \frac{ad - bc}{bd}
                  $$
                  $$
                  \frac{a}{b} \times \frac{c}{d} = \frac{ac}{bd} 
                  $$
                  $$
                  \frac{a}{b} \div \frac{c}{d} = \frac{ad}{bc} 
                  $$
                  $$
                  \frac{e}{f} = \frac{\frac{e}{gcd(e,f)}}{\frac{f}{gcd(e,f)}} \ gcd(a,b)\text{는 }a, b\text{의 최대공약수}
                  $$
                  더이상 이 구현에 대해서 설명하는 것은 의미도 없고, 코드를 보는 것이 더 빠를테니 구현에 대해서는 설명을 마치겠다.
                  <h1>최적화</h1>
                  <h2>다이내믹 프로그래밍(Dynamic Programming)</h2>
                  처음 설명했던대로 \(S_n\)을 구하기 위해서는 \(S_{n-1}, S_{n-2}, \dots, S_1\)을 사용하면 된다. 그런데 우리는 한번 계산했던 것을 매번 다시 계산하고 있다.
                  예를 들어 \(S_3\)을 구한다고 해보자. 그러면 \(S_2, S_1\)을 계산할 것이고, \(S_2\)를 구하기 위해서 다시 \(S_1\)을 계산할 것이다. 이를 방지하기 위해 메모리에 \(S_1, S_2, \dots\)을 저장해두면 한번만 계산하면 되므로,
                  엄청난 속도향상을 기대할 수 있다. 이러한 프로그래밍 기법을 '다이내믹 프로그래밍'이라고 한다.
                  <h1>API</h1>
                  이 앱에서 k의 값을 넣고 '공식 보기'버튼을 누르면 http://arduinocc04.tech 라는 주소를 가진 컴퓨터(Microsoft Azure를 사용했다.)에 요청을 보낸다.
                  정확히는, http://arduinocc04.tech?k=k' (k'는 입력한 k의 값)에 접속한다. 그러면 위에 설명한대로 구현한 Python 프로그램이 돌아가서 json형식으로 공식을 \(\LaTeX\)포맷으로 인터넷을 통해 돌려준다.
                  그럼 이를 받아서 앱에 그려주는 것이다. 1~n까지의 합을 구하는 것도 비슷하게, http://arduinocc04.tech/getVal?k=k'&n=n'(k', n'은 각각 입력한 k와 n의 값)으로 접속한다.
                  굳이 1~n까지 합하는 것까지 Python으로 넘긴 이유는 BigInt처리의 귀찮음과 Python은 어떤 수를 제곱할때 일반적인 \(O(n)\) 시간복잡도가 아니라 \(O(\log n)\) 시간복잡도를 갖기 때문에 귀찮은 구현을 하지 않아도 계산결과가 빠르게 나오기 때문이다.
                    

                    
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
