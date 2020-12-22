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
                Tab(text: "webview"),
                Tab(text: "shared_preferences"),
                Tab(text: "waiting for customer response"),
                Tab(text: "severe: new feature"),
                Tab(text: "share")
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
  var _filteredIssues = <Issue>[];
  // filter issues
  bool showOpenIssues = true;
  bool showClosedIssues = false;
  bool showOldIssues = true;

  // TODO - add user login
  var github = GitHub(
      auth:
          Authentication.withToken("3cdeeb6e0861301a3b14d3e8ba94173d5eaa1869"));

  @override
  void initState() {
    super.initState();
    _label = widget.label;
    loadIssuesWith(label: _label);
  }

  void loadIssuesWith({String label}) {
    github.issues
        .listByRepo(RepositorySlug("flutter", "flutter"),
            state: "all", labels: [_label])
        .take(500)
        .listen((event) {
          setState(() {
            _issues.add(event);
            _filteredIssues.add(event);
          });
        });
  }

  // filter the issues using options from showFilterOptions
  // update _filteredIssues and set state
  void filterIssues() {
    DateTime filterTime = showOldIssues
        ? DateTime.utc(1977, 7, 7)
        : DateTime.now().subtract(Duration(days: 365));
    List filteredIssues = _issues
        .where((f) => f.isOpen == showOpenIssues)
        .where((f) => f.isClosed == showClosedIssues)
        .where((f) => f.createdAt.isAfter(filterTime))
        .toList();
    // TODO - handle 0 items in filteredIssues
    if (filteredIssues.length == 0) {
      filteredIssues.add(Issue(title: "There is actually nothing here..."));
    }
    setState(() {
      _filteredIssues = filteredIssues;
    });
  }

  void showFilterOptions(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Apply Filters"),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filter
                    // TODO - filter closed issues
                    Row(
                      children: [
                        Text("Show open issues"),
                        Checkbox(
                          value: showOpenIssues,
                          onChanged: (bool internalValue) {
                            setState(() {
                              showOpenIssues = !showOpenIssues;
                            });
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text("Show closed issues"),
                        Checkbox(
                          value: showClosedIssues,
                          onChanged: (bool internalValue) {
                            setState(() {
                              showClosedIssues = !showClosedIssues;
                            });
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text("show old issues"),
                        Checkbox(
                          value: showOldIssues,
                          onChanged: (bool internalValue) {
                            setState(() {
                              showOldIssues = !showOldIssues;
                            });
                          },
                        )
                      ],
                    ),
                    // Sort
                    // TODO - sort by created
                    // TODO - sort by last edited
                    // TODO - sort by comment count
                    FlatButton(
                      child: Text("Filter"),
                      onPressed: () {
                        filterIssues();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _filteredIssues.isNotEmpty
        ? _buildFilteredIssueListView()
        : _progressView();
  }

  Widget _buildFilteredIssueListView() {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: _filteredIssues.length,
                itemBuilder: (context, i) {
                  if (i.isOdd) return Divider();
                  final index = i ~/ 2;
                  return _issueView(_filteredIssues[index]);
                })),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            child: Text("Filter"),
            onPressed: () {
              showFilterOptions(context);
            },
          ),
        )
      ],
    );
  }

  Widget _issueView(Issue issue) {
    return Column(
      children: [
        Row(
          children: [
            Text("No. " + issue.number.toString() + " "),
            Divider(
              color: Colors.white,
              thickness: 200,
            ),
            Icon(
              Icons.comment,
              size: 14,
            ),
            Text(" " + issue.commentsCount.toString())
          ],
        ),
        Row(
          children: [
            Icon(Icons.info, color: Colors.green, size: 25),
            Text(issue.state)
          ],
        ),
        Text(issue.title),
        Text(formattedDate(issue))
      ],
    );
  }

  Widget _progressView() {
    // TODO - add progress indicator
    return Text("progress view here");
  }

  Widget _checkboxColumn(String label, bool value) {
    return Row(
      children: [
        Text(label),
        Checkbox(
          value: value,
          onChanged: (bool internalValue) {
            setState(() {
              value = !value;
            });
          },
        )
      ],
    );
  }
}

// Helpers
String formattedDate(Issue issue) {
  return issue.createdAt.year.toString() +
      "年" +
      issue.createdAt.month.toString() +
      "月" +
      issue.createdAt.day.toString() +
      "日";
}
