// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:demo/api/getapi.dart';
import 'package:demo/model/newsapi.dart';
import 'package:demo/modules/cardsandmodules.dart';
import 'package:demo/modules/dialogboxes.dart';
import 'package:demo/pages/news/newsdetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NewsUII extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NewsUIIState();
  }
}

class NewsUIIState extends State<NewsUII> {
  late Future<Newsapi?>? _futurehorizontallist;
  late Future<Newsapi?>? _futureverticallist;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  horizontallistitem(size, Articles article) {
    return GestureDetector(
      onTap: () {
        //navigator// login sucess //go to detail page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NewsDetail(article)));
      },
      child: Container(
        margin: EdgeInsets.only(left: 10),
        child: Stack(
          children: [
            Container(
              width: size.width / 1.7,
              height: size.height / 4.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(article.urlToImage!, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              bottom: 65,
              left: 20,
              child: Container(
                width: size.width / 1.9,
                child: Text(
                  article.title!.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 5,
              child: Text(
                CardsandModules.formatDateTimestring(article.publishedAt!),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Positioned(
                bottom: 5,
                right: 15,
                child: Icon(
                  Icons.play_circle,
                  color: Colors.white,
                  size: 25,
                ))
          ],
        ),
      ),
    );
  }

  apicallh() {
    _futurehorizontallist = GetApi.getnewsdata();
  }

  apicallv() {
    _futureverticallist = GetApi.getnewsdata();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    apicallh();
    apicallv();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      ShowDialogbox.warningDialogueBox(context, e.message.toString());
      // developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    Future<void> _updateConnectionStatus(ConnectivityResult result) async {
      setState(() {
        _connectionStatus = result;
        //dialoguebox(connection)
        if (_connectionStatus == ConnectivityResult.mobile) {
          //dialoguebox
          // I am connected to a mobile network.
        } else if (_connectionStatus == ConnectivityResult.wifi) {
          // I am connected to a wifi network.
          //dialoguebox
        } else {
          ShowDialogbox.warningDialogueBox(
              context, "Check your internet connection");
        }
      });
    }

    return _updateConnectionStatus(result);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: Scaffold(
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                //horizontal list
                // stack // image // title // date // icon

                //future builder
                FutureBuilder<Newsapi?>(
                    future: _futurehorizontallist,
                    // a previously-obtained Future<String> or null
                    builder: (BuildContext context,
                        AsyncSnapshot<Newsapi?> snapshot) {
                      //switch
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          ShowDialogbox.warningDialogueBox(
                              context, "Connect your internet");
                          return Container(); // paxi dialog box thapne
                        case ConnectionState.waiting: //loading
                          // return Container(
                          //   height: 300,
                          //   child:ShowDialogbox.warningDialogueBox(context, "dialogbox test"),
                          //
                          // );

                          return Center(
                            child: Container(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ); //
                        case ConnectionState.done:
                          if (snapshot.data == null ||
                              snapshot.data!.articles!.isEmpty) {
                            return Center(
                              child: Container(
                                child: Text("No Data or api issue"),
                              ),
                            );
                          } else {
                            // data ayo
                            //show ui

                            return Container(
                              width: size.width,
                              height: size.height / 4.1,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: snapshot.data!.articles!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return horizontallistitem(
                                        size, snapshot.data!.articles![index]);
                                  }),
                            );
                          }
                        default: //error
                          return Container(); //error paxi thapaula
                      }
                    }),
                //vertical list
                // row //
                //col // col
                //1st col
                // stack //icon
                //2nd col
                // text
                //row // container //text  /// text

                //future builder
                FutureBuilder<Newsapi?>(
                    future: _futureverticallist,
                    // a previously-obtained Future<String> or null
                    builder: (BuildContext context,
                        AsyncSnapshot<Newsapi?> snapshot) {
                      //switch
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          //error
                          return Container(); // paxi dialog box thapne
                        case ConnectionState.waiting: //loading
                          return Center(
                            child: Container(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ); //
                        case ConnectionState.done:
                          if (snapshot.data == null ||
                              snapshot.data!.articles!.isEmpty) {
                            return Center(
                              child: Container(
                                child: Text("No Data or api issue"),
                              ),
                            );
                          } else {
                            // data ayo
                            //show ui

                            return Container(
                              width: size.width,
                              height: size.height / 1.8,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: snapshot.data!.articles!.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return CardsandModules.verticallistitem(
                                        context,
                                        size,
                                        snapshot.data!.articles![index]);
                                  }),
                            );
                          }
                        default: //error
                          return Container(); //error paxi thapaula
                      }
                    }),
                //list view
              ],
            ),
          ),
        ));
  }
}
