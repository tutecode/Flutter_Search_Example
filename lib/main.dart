import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Api Filter list Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  // ExamplePage({ Key key }) : super(key: key);
  @override
  _ExamplePageState createState() => new _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // final formKey = new GlobalKey<FormState>();
  // final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _filter = new TextEditingController(); //A controller for an editable text field.
  final dio = new Dio(); //for http request
  String _searchText = "";
  List names = new List();
  List filteredNames = new List();
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text( 'Search Example' );

  ///4. Attach a listener to our TextEditingController
  _ExamplePageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this._getNames();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,

      ),
    );
  }

  ///5. Build a table with the API information we’ve queried.
  ///we stored these in two lists, one called names and the other filteredNames.
  ///The reason we did this is that we want to constantly be filtering out names IF there is search text,
  ///but we also want to keep the original list as is somewhere.
  Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List(); //call _getName list (build the list with the API
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]['name'].toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredNames[index]['name']),
          onTap: () => print(filteredNames[index]['name']),
        );
      },
    );
  }

  ///3. Build our appBar with our with the search Icon present
  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search),
              hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text( 'Search Example' );
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  ///2. Instantiate our lists when the page loads
  void _getNames() async {
    final response = await dio.get('https://swapi.co/api/people');
    List tempList = new List();
    for (int i = 0; i < response.data['results'].length; i++) {
      tempList.add(response.data['results'][i]);
    }
    setState(() {
      names = tempList; //es igual a la lista de nombres de Star Wars
      names.shuffle();
      filteredNames = names;
    });
  }
}
