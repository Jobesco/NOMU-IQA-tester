import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IQA Tester',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Nomu IQA Tester'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String,dynamic> parametros = Map();
  final controle_texto = TextEditingController();

  @override
  void initState() {
    super.initState();
    parametros['pH'] = 0;
    parametros['Condutividade'] = 0;
    parametros['Temperatura'] = 0;
    parametros['Oxigenio'] = 0;
    parametros['Turbidez'] = 0;
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    controle_texto.dispose();
    super.dispose();
  }

  _tratarEntrada(title){
    setState(() {
      parametros[title] = double.tryParse(controle_texto.text);
      controle_texto.clear();
    });
  }

  _buildBox(title){
    return Row(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title
            ),
            TextField(
              controller: controle_texto,
            )
          ],
        ),
        IconButton(
            icon: Icon(Icons.send),
            onPressed: _tratarEntrada(title),
        )
      ],
    );
  }

  static const pesos = {'ph': 0.22904,'condutividade': 0.00178,'oxigenio dissolvido': 0.35500,'turbidez': 0.35500,'temperatura': 0.05917}; //Map string p double
  _getWQI(ph,cond,oxig,turb,temp){
    if(temp == -1) return 'Unable to calculate WQI due to sensor malconnection';
    if(temp == null || ph == null || cond == null || oxig == null || turb == null) return 'nhaa';
    var Qph = _getQi(ph,7,7.75);
    var Qce = _getQi(cond,0,1000);
    var Qod = _getQi(oxig,14.6,5);
    var Qtd = _getQi(turb,0,5);
    var Qtp = _getQi(temp,0,30);

    var res = (Qph*pesos['ph']+Qce*pesos['condutividade']+Qod*pesos['oxigenio dissolvido']+Qtd*pesos['turbidez']+Qtp*pesos['temperatura']) /
        (pesos['ph']+pesos['condutividade']+pesos['oxigenio dissolvido']+pesos['turbidez']+pesos['temperatura']);
    print("wqi= $res");
    if(res <= 25){
      return 'Excellent!';
    }else if(res <= 50){
      return 'Good!';
    }else if(res <= 75){
      return 'Poor';
    }else if(res <= 100){
      return 'Very poor';
    }else{
      return 'Unsuitable for drinking';
    }
  }

  _getQi(vi,vo,si){
    print('vi = $vi');
    return 100*(vi - vo/si - vo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Expanded(
            child: Column(
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  _buildBox('pH'),
                  _buildBox('Condutividade'),
                  _buildBox('Oxigenio'),
                  _buildBox('Temperatura'),
                  _buildBox('Turbidez'),
                ],
              ),
            ),
            Text(
                'IQA:'
            ),
            Text(
                _getWQI(parametros['pH'], parametros['Condutividade'], parametros['Oxigenio'], parametros['Turbidez'], parametros['Temperatura'])
            )
          ],
        )),
      ),
    );
  }
}
