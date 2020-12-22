import 'package:flutter/material.dart';
import 'package:github/github.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  // TODO - add user login
  var github = GitHub(
      auth:
          Authentication.withToken("3cdeeb6e0861301a3b14d3e8ba94173d5eaa1869"));

  @override
  void initState() {
    super.initState();
    _label = widget.label;
    loadIssuesWith(label: _label);
    print(_label);
  }

  void loadIssuesWith({String label}) {
    github.issues.listByRepo(RepositorySlug("flutter", "flutter"),
        labels: [_label]).listen((event) {
      setState(() {
        _issues.add(event);
        print(_label);
      });
    });
  }

  void showDialogBox(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Apply Filters"),
          // content: new Text("Alert Dialog body"),
          actions: [
            // Filter
            // TODO - filter closed issues
            // TODO - filter issues older than a year
            // Sort
            // TODO - sort by created
            // TODO - sort by last edited
            // TODO - sort by comment count
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _issues.isNotEmpty ? _issueListView() : _progressView();
  }

  Widget _issueListView() {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _issues.length,
                itemBuilder: (context, i) {
                  if (i.isOdd) return Divider();
                  final index = i ~/ 2;
                  String text = _issues[index].title + " " + index.toString();
                  return Text(text);
                })),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            child: Text("filter"),
            onPressed: () {
              showDialogBox(context);
            },
          ),
        )
      ],
    );
  }

  Widget _progressView() {
    // TODO - add progress indicator
    return Text("progress view here");
  }
}
