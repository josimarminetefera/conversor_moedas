import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=e361127a";

void main() async{
  runApp(MaterialApp(
    home: HomeScreen(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white
    ),
  ));
}

//esta função me retorna um mapa no futuro
Future<Map> getData () async{
  //tem que esperar os dados chegarem do servidor
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _mudarValorReal(String valor){
    double real = double.parse(valor);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _mudarValorDolar(String valor){
    double dolar = double.parse(valor);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _mudarValorEuro(String valor){
    double euro = double.parse(valor);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(//barra
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$Conversor\$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: FutureBuilder<Map>(

        //que futuro ele tera
        future: getData(),

        //como ele vai montar como ele vai montar
        builder: (context, snapshot){//snapshot é uma fotografia do que ele esta analisando do future
          switch(snapshot.connectionState){ //qual o estatos da nossa conexão
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
            default:
              //terminou de carregar os dados
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Erro ao Carregar os Dados!",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ),
                );
              }else{
                //pegar os dados e colocar na tela
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  
                  padding: EdgeInsets.all(10.0),
                  
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.stretch, //alinhamento ao centro

                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber,),
                      criarTextField("Reais", "R\$ ", realController, _mudarValorReal),
                      Divider(),
                      criarTextField("Dolares", "US\$ ", dolarController, _mudarValorDolar),
                      Divider(),
                      criarTextField("Euros", "E ", euroController, _mudarValorEuro),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget criarTextField(String label, String prefix, TextEditingController t, Function f){
  return TextField(
    keyboardType: TextInputType.number,
    controller: t,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    onChanged: f,
  );
}
