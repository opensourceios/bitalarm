import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import '../components/portfolio/wallet_list.dart';
import '../components/portfolio/portfolio_list.dart';
import '../components/portfolio/portfolio_header.dart';
import '../components/portfolio/portfolio_chart.dart';
import '../components/pill_button.dart';

import '../services/wallet.service.dart';
import '../services/settings.service.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _PortfolioPageState createState() => new _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {

  List<Object> _wallets = [];
  List<Object> _coins = [];
  double _total = 0.0;
  double _stake = 0.0;
  WalletProvider _wp = new WalletProvider();
  SettingsService _ss = new SettingsService();

  initStateAsync() async {
    _stake = await _ss.getStake();
    _wallets = await _wp.getWallets();
    _coins = await _wp.getWalletValues();
    setState((){});
    _coins = await _wp.coinsToPrice(coins: _coins, currency: 'sek');
    _total = _coins.map((coin) => coin['value']).reduce((double a, double b) => a + b);
    setState((){});
  }

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Add a wallet',
        child: new Icon(Icons.add, color: Colors.white,),
        onPressed: () {
          Navigator.pushNamed(ctx, '/wallets');
        },
      ),
      drawer: new Drawer(
        child: new Column(children: [
          new Expanded(child: new WalletList(wallets: _wallets)),
          new Container(
            height: 150.0,
            child: new Column(children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.add),
                title: new Text('Add a wallet'),
                onTap: () => Navigator.of(ctx).pushNamed('/wallets')
              ),
              new ListTile(
                leading: new Icon(Icons.settings),
                title: new Text('Settings'),
                onTap: () => Navigator.of(ctx).pushNamed('/settings')
              )
            ],)
          )
        ])
      ),
      body: new Column(
        children: [
          new Stack(children: <Widget>[
            new Container(
              height: 230.0,
              child: new PortfolioHeader(total: _total, stake: _stake),
            ),
            new RowWithMenu(),
          ]),
          new Expanded(
            child: new ListView(children: [
              _coins.length == 0
                ? new Center(child: new Text('Add a wallet to start tracking your assets'))
                : new PortfolioChart(data: _coins),
              _total == 0.0 && _coins.length > 0
                ? new Center(child: new CircularProgressIndicator(backgroundColor: Theme.of(ctx).primaryColor))
                : new PortfolioList(coins: _coins)
            ])
          ),
        ],
      ),
      bottomNavigationBar: new AppBotNav(currentIndex: 2),
    );
  }
}


class RowWithMenu extends StatelessWidget {
  @override
  Widget build (BuildContext ctx) {
    return new Container(
      margin: new EdgeInsets.only(left: 15.0, top: 32.0),
      child: new IconButton(
        icon: new Icon(Icons.menu, size: 32.0),
        color: Colors.white,
        onPressed: () {
          Scaffold.of(ctx).openDrawer();
        },
      ) 
    );
  }
}