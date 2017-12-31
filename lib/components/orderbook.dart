import 'package:flutter/material.dart';
import '../services/api.dart';

class Orderbook extends StatefulWidget {
  
  final String ticker;
  final double size;
  Orderbook({this.ticker, this.size});

  @override
  createState() => new OrderbookState(ticker: this.ticker, size: this.size);
}

class OrderbookState extends State<Orderbook> {
  
  List bids = [];
  List asks = [];
  final String ticker;
  final double size;
  final TextStyle askStyle = const TextStyle(color: Colors.red, fontFamily: 'Roboto Mono');
  final TextStyle bidStyle = const TextStyle(color: Colors.green, fontFamily: 'Roboto Mono');
  
  OrderbookState({this.ticker, this.size});

  @override
  initState() {
    API.getOrderbook(this.ticker).then((Map<String, List<List<double>>> data) {
      setState((){
        this.bids = data['bids'];
        this.asks = data['asks'];
      });
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext ctx) {

    List<DataRow> askRows = new List.generate(
      this.asks.length,
      (int i) => new DataRow(cells: [
        new DataCell(new Text(this.asks[i][0].toString(), style: askStyle)),
        new DataCell(new Text(this.asks[i][1].toStringAsFixed(4), style: askStyle)),
      ])
    );
    List<DataRow> bidRows = new List.generate(
      this.asks.length,
      (int i) => new DataRow(cells: [
        new DataCell(new Text(this.bids[i][0].toString(), style: bidStyle)),
        new DataCell(new Text(this.bids[i][1].toStringAsFixed(4), style: bidStyle)),
      ])
    );

    return new Container(
      height: this.size,
      color: const Color(0xff222222),
      child: new Row(children: [
        new Expanded(child: 
          new ListView(children: <Widget>[
            new DataTable(
              columns: [
                new DataColumn(label: new Text('Ask', style: const TextStyle(color: Colors.red, fontFamily: 'Roboto Mono', fontWeight: FontWeight.w700, fontSize: 14.0)), numeric: true),
                new DataColumn(label: new Text(ticker, style: const TextStyle(color: Colors.red, fontFamily: 'Roboto Mono', fontWeight: FontWeight.w700, fontSize: 14.0))),
              ],
              rows: askRows
            ),
          ])
        ),
        new Expanded(child: 
          new ListView(children: <Widget>[
            new DataTable(
              columns: [
                new DataColumn(label: new Text('Bid', style: bidStyle), numeric: true),
                new DataColumn(label: new Text(ticker, style: bidStyle)),
              ],
              rows: bidRows
            ),
          ])
        )
      ])
    );
  } 
}