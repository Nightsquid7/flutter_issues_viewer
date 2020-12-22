import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:github/github.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LabeledIssuesTabBarController(),
    );
  }
}

class LabeledIssuesTabBarController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 6,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "全て"),
                Tab(text: "p: webview"),
                Tab(text: "p: shared_preferences"),
                Tab(text: "waiting for customer response"),
                Tab(text: "severe: new feature"),
                Tab(text: "p: share")
              ],
            ),
            title: Text("Flutter Issues"),
          ),
          body: TabBarView(
            children: [
              LabeledIssuesView(
                label: "",
              ),
              LabeledIssuesView(
                label: "p: webview",
              ),
              LabeledIssuesView(
                label: "p: shared_preferences",
              ),
              LabeledIssuesView(
                label: "waiting for customer response",
              ),
              LabeledIssuesView(
                label: "severe: new feature",
              ),
              LabeledIssuesView(
                label: "p: share",
              )
            ],
          ),
        ));
  }
}

class LabeledIssuesView extends StatefulWidget {
  final String label;
  LabeledIssuesView({Key key, this.label}) : super(key: key);
  _LabeledIssuesState createState() => _LabeledIssuesState();
}

class _LabeledIssuesState extends State<LabeledIssuesView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _label;

  var _issues = <Issue>[];
  var github = GitHub(
      auth:
          Authentication.withToken("3cdeeb6e0861301a3b14d3e8ba94173d5eaa1869"));
  int pageCount = 10;

  @override
  void initState() {
    _label = widget.label;
    loadNextXNumberOfIssues(_label);
    print("initState");
    print(_label);
  }

  // get the next X number of issues
  void loadNextXNumberOfIssues(String label, {int number = 10}) {
    var listener = github.issues
        .listByRepo(RepositorySlug("flutter", "flutter"), labels: [_label])
        .take(100)
        .listen((event) {
          _issues.add(event);
          print(_label);
          // print(event.title);
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          if (_issues.isEmpty || index >= _issues.length) {
            return Text("No issues yet...");
          }

          String text = _issues[index].title + " " + index.toString();
          return Text(text);
        });
  }
}
