import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class WatchlistProvider {
  Database db;
  
  Future open() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "coinwatch.db");
    this.db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS watchlist (id INTEGER PRIMARY KEY, symbol TEXT UNIQUE);
        CREATE TABLE IF NOT EXISTS wallet (id INTEGER PRIMARY KEY, symbol TEXT, address TEXT UNIQUE);
        INSERT INTO wallet (symbol, address) VALUES ('ETH', '0x3CcD96131c233ceC261f9Be610020939FDC7863E'), ('ETH', '0x42E1F7d6b18b0e51e9B4Ae214BEcCb99eCC24b82');
      ''');
    });
  }

  Future<List<String>> getWatchlist () async {
    await this.open();
    List<Map<String, String>> watchlist = await this.db.query('watchlist', distinct: true);
    return watchlist.map((Map<String, String> item) => item['symbol']).toList();
  }

  Future<bool> inWatchlist (String ticker) async {
    await this.open();
    List<Map<String, String>> exists = await this.db.query('watchlist', where: 'symbol = ?', whereArgs: [ticker], distinct: true);
    await this.db.close();
    return exists.length > 0;
  }

  Future<int> toggleWatchlist (String ticker) async {
    bool watched = await this.inWatchlist(ticker);
    await this.open();
    int res = 0;
    if (watched) {
      res = await this.db.delete('watchlist', where: 'symbol = ?', whereArgs: [ticker]);
    } else {
      res = await this.db.insert('watchlist', {'symbol': ticker});
    }
    this.db.close();
    return res;
  }

  Future<int> addToWatchlist (String ticker) async {
    await this.open();
    int res = await this.db.insert('watchlist', {'symbol': ticker});
    this.db.close();
    return res;
  }

  Future<int> removeFromWatchlist (String ticker) async {
    if (!(await this.inWatchlist(ticker))) {
      return 0;
    }
    await this.open();
    int res = await this.db.delete('watchlist', where: 'symbol = ?', whereArgs: [ticker]);
    this.db.close();
    return res;
  }

  Future close() async => db.close();
}