import 'package:flutter/material.dart';
import 'package:relis/arguments/bookArguments.dart';
import 'package:relis/arguments/pagearguments.dart';
import 'package:relis/authentication/user.dart';
import 'package:relis/globals.dart';
import 'package:relis/view/bookView.dart';
import 'package:relis/view/pageView.dart';
import 'package:relis/widget/bookPreview.dart';
import 'package:relis/widget/bookWrapList.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);
  static const routeName = '/SearchPage';

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  Icon icon = new Icon(
    Icons.close,
    color: Colors.white,
  );
  final globalKey = new GlobalKey<ScaffoldState>();
  final TextEditingController searchTextController = new TextEditingController();
  Map<String, dynamic> searchList = {};
  bool _isSearching = false;
  String _filterText = "";
  List searchResult = [];
  Map<String, ValueNotifier<bool>> bookHover = {};
  dynamic currentBook = null;
  String currentMainFilter = "All";
  List<String> filterMainOptions = [
    "All",
    "Genre",
    "Book Title",
    "Author",
    "Keywords",
  ];
  String hintText = "";
  String currentGenreFilter = "All";
  List<String> filterGenreOptions = ["All"];

  @override
  void initState() {
    super.initState();
    print("\t...Reached Here-1");
    isLoggedIn(context);
    _isSearching = false;
    print("\t...Reached Here-2");
    for(var cat in category.values) {
      print("cat is...");
      print(cat["categoryName"]);
      filterGenreOptions.add(cat["categoryName"]);
    }
    hintText = getHintText(false);
    loadSearchingData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: getAppBarTitle(),
        actions: <Widget>[
          SizedBox(width: 10.00),
          filterDropdown(currentMainFilter, filterMainOptions, "Filter for Searching Books..."),
          if(currentMainFilter == "Genre")
            SizedBox(width: 10.00),
          if(currentMainFilter == "Genre")
            filterDropdown(currentGenreFilter, filterGenreOptions, "Filter Books by Genre ...", isGenre: true),
          IconButton(
            icon: icon,
            onPressed: () {
              stopSearching();
              setState(() {});
            },
          ),
        ],
      ),
      body: desktopView(),
      // LayoutBuilder(
      //   builder: (BuildContext context, BoxConstraints constraints) {
      //     if (constraints.maxWidth > 700) {
      //       return desktopView();
      //     } else {
      //       return mobileView();
      //     }
      //   },
      // ),
    );
  }

  Widget desktopView() {
    ScrollController controller = new ScrollController();
    return Container(
      padding: EdgeInsets.all(10.00),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10.00),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if((searchResult.length == 0 && searchTextController.text.isEmpty) && currentBook == null && (currentMainFilter != "Genre" && currentBook == null))
              searchBook("Type to Search Book in ReLis"),
            if((searchResult.length != 0 && searchTextController.text.isNotEmpty) || currentBook != null)
              searchFound(),
            if((searchTextController.text.isNotEmpty && currentBook == null) || (currentMainFilter == "Genre" && currentBook == null))
              searchBook("Search Query Not Found"),
          ],
        ),
      ),
    );
  }

  Widget searchBook(String messageText) {
    print(".......Not Searched Book");
    return Center(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
        decoration: categoryDecoration,
        width: MediaQuery.of(context).size.width/2,
        height: MediaQuery.of(context).size.height/2,
        child: Text(messageText, style: TextStyle(color: Colors.white, fontSize: 30),),
      ),
    );
  }

  Widget searchFound() {
    print(".......Searched Book");
    ScrollController controller = new ScrollController();
    // return BookWrapList(currentBook, scrollController, bookHover);
    // return SingleChildScrollView(
    //   controller: controller,
    //   scrollDirection: Axis.vertical,
    //   padding: EdgeInsets.all(10.00),
    //   clipBehavior: Clip.antiAliasWithSaveLayer,
    //   child: 
      return Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.spaceAround,
        spacing: 10.00,
        runSpacing: 20.00,
        direction: Axis.horizontal,
        verticalDirection: VerticalDirection.down,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          for(var currBook in currentBook)
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            runAlignment: WrapAlignment.spaceAround,
            spacing: 10.00,
            runSpacing: 10.00,
            direction: Axis.horizontal,
            verticalDirection: VerticalDirection.down,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              Hero(
                tag: "book: ${currBook["id"]}",
                child: Material(
                  shadowColor: Colors.black,
                  elevation: 1.0,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25.00),
                  type: MaterialType.card,
                  child: InkWell(
                    enableFeedback: true,
                    hoverColor: Colors.tealAccent.withOpacity(0.6),
                    splashColor: Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25.00),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          BookView.routeName, arguments: BookArguments(currentBook: currBook));
                    },
                    onHover: (hover) {
                      if(hover) {
                        print("......TRUE");
                        bookHover[currBook["id"]]!.value = true;
                      } else {
                        print("......FALSE");
                        bookHover[currBook["id"]]!.value = false;
                      }

                      print("\t --> ${bookHover}");
                      // setState(() {});
                    },
                    child: Container(
                      width: 200,
                      height: 300,
                      decoration: boxDecoration,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25.00),
                            child: currBook["image"],
                            // Image.asset(
                            //   currBook["image"],
                            //   fit: BoxFit.fill,
                            //   height: 300,
                            //   width: double.infinity,
                            //   repeat: ImageRepeat.noRepeat,
                            // ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: bookHover[currBook["id"]]!,
                            builder: (context, value, child) =>
                            bookHover[currBook["id"]]!.value ? Container(
                              decoration: innerBoxDecoration,
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    currBook["bookName"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        height: 2,
                                        fontSize: 20.00),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    currBook["authorName"],
                                    style: TextStyle(fontSize: 16.00, height: 1.5),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "\u{20B9} ${currBook["price"]}/-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16.00,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          child: Tooltip(
                                            message: favourite[currBook["id"]]!.value
                                                ? "Added to Favourite"
                                                : "Add to Favourite",
                                            padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
                                            child: InkResponse(
                                              highlightShape: BoxShape.circle,
                                              autofocus: false,
                                              enableFeedback: true,
                                              splashColor: Colors.red.withOpacity(0.8),
                                              hoverColor: Colors.red.withOpacity(0.5),
                                              child: ValueListenableBuilder(
                                                valueListenable: favourite[currBook["id"]]!,
                                                builder: (context, value, child) => favourite[currBook["id"]]!.value ? Icon(Icons.favorite_rounded,
                                                  color: Color(0xFFff0000), size: 25,) : Icon(Icons.favorite_outline_rounded,
                                                  color: Color(0xFFff0000), size: 25,),
                                              ),
                                              onTap: () async {
                                                favouriteBook(context, user!, currBook);
                                                // makeAllHoverOff();
                                                this.setState(() {});
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Tooltip(
                                            message:  wishList[currBook["id"]]!.value ? "Added to Wish-List" : "Add to Wish-List",
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.00,
                                                horizontal: 20.00
                                            ),
                                            child: InkResponse(
                                              highlightShape: BoxShape.circle,
                                              autofocus: false,
                                              enableFeedback: true,
                                              splashColor: Color(0xFF032f4b).withOpacity(0.8),
                                              hoverColor: Color(0xFF032f4b).withOpacity(0.5),
                                              child: ValueListenableBuilder(
                                                valueListenable: wishList[currBook["id"]]!,
                                                builder: (context, value, child) => wishList[currBook["id"]]!.value ? Icon(
                                                  Icons.bookmark, color: Color(0xFF0000FF), size: 25,) : Icon(
                                                  Icons.bookmark_add_outlined, color: Color(0xFF0000FF), size: 25,),
                                              ),
                                              onTap: () async {
                                                wishListBook(context, user!, currBook);
                                                this.setState(() {});
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ) : SizedBox(),
                          ),
                          ValueListenableBuilder(
                            valueListenable: bookHover[currBook["id"]]!,
                            builder: (context, value, child) =>
                            bookHover[currBook["id"]]!.value ? Positioned(
                              top: 5,
                              right: 5,
                              child: Tooltip(
                                textStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                                message: loadBookTooltip(currBook["id"]),
                                padding: EdgeInsets.all(10.00),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent,
                                        offset: const Offset(
                                          0.0,
                                          5.0,
                                        ),
                                        blurRadius: 15.0,
                                        spreadRadius: 8.0,
                                      ),
                                      BoxShadow(
                                        color: Colors.black45,
                                        offset: const Offset(
                                          0.0,
                                          5.0,
                                        ),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ) : SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20,),
            ],
          ),
        ],
      );
    // );
  }

  void startSearching() {
    _isSearching = true;
    setState(() {});
  }

  void stopSearching() {
    _isSearching = false;
    searchTextController.clear();
    Navigator.of(context).pop();
    setState(() {});
  }

  void searchOperation(String searchText) {
    startSearching();
    searchResult.clear();
    print("\tIn searchOperation");
    print("\t..._isSearching: ${_isSearching}");
    print("\t...searchText: ${searchText}");
    print("\t..._filterText: ${_filterText}");
    if (_isSearching) {
      for(var bookID in searchList.keys) {
        for(var value in searchList[bookID]) {
          print("\t...1: ${value.contains(searchText.toLowerCase())}");
          print("\t...2: ${searchText==""}");
          print("\t...3: ${value.contains(_filterText.toLowerCase())}");
          print("value: ${value}");
          if(value.contains(searchText.toLowerCase()) || (searchText=="" && value.contains(_filterText.toLowerCase()))) {
            searchResult.add(bookID);
            print("\t\t...added ${bookID} in searchResult");
            break;
          }
        }
      }
      if(searchResult.length>0) {
        loadHover(searchResult.length, searchResult, bookHover, "searchResult");
        print("\t\tbookHover: ${bookHover.runtimeType}");
        currentBook = getBooksList(searchResult);
        setState(() {});
      }
    }
    if(searchResult.length == 0 && searchTextController.text.isEmpty) {
      _isSearching = false;
      searchResult.clear();
      currentBook = null;
      setState(() {});
    }
    if(searchResult.length == 0 && searchTextController.text.isNotEmpty) {
      searchResult.clear();
      currentBook = null;
      setState(() {});
    }
    if(searchTextController.text.isEmpty && _filterText == "") {
      searchResult.clear();
      currentBook = null;
      setState(() {});
    }
    print("searchResult: ${searchResult.length}");
  }

  void loadSearchingData() {
    searchList = {};
    var bookIdList = [];
    for(var book in bookList) {
      var bookDetailsList = Set<dynamic>();
      if(currentMainFilter == "All" || currentMainFilter == "Book Title") {
        bookDetailsList.add(book["bookName"].toLowerCase());
      }
      if(currentMainFilter == "All" || currentMainFilter == "Author") {
        bookDetailsList.add(book["authorName"].toLowerCase());
      }
      if(currentMainFilter == "All" || currentMainFilter == "Genre"){
        String categoryName = getCategoryName(book["category"]);
        print("\tCategory found: $categoryName");
        if(categoryName != "-" && (currentGenreFilter == "All" || currentGenreFilter == categoryName)) {
          bookDetailsList.add(categoryName.toLowerCase());
          bookDetailsList.add(book["bookName"].toLowerCase());
          bookDetailsList.add(book["authorName"].toLowerCase());
        }
      }
      if(currentMainFilter == "All" || currentMainFilter == "Keywords")
        if(book.keys.contains("keywords")) {
          for(String bookKey in book["keywords"])
            bookDetailsList.add(bookKey.toLowerCase());
        }
      searchList[book["id"]] = bookDetailsList;
    }
    if(currentGenreFilter!="All" && searchList.length>0) {
      print("searchList: ${searchList.length}");
      _filterText = currentGenreFilter;
      print("_filterText: ${_filterText}");
      searchOperation(currentGenreFilter);
      setState(() {});
    }
    else {
      _filterText = "";
    }
  }

  Widget mobileView() {
    return Container();
  }

  Widget filterDropdown(String currentFilter, List<String> filterOptions, String tooltipMessage, {bool isGenre = false}){
    return Tooltip(
      message: tooltipMessage,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 5),
        decoration: BoxDecoration(
          color: Color(0xFF032f4b),
          borderRadius: BorderRadius.all(
            Radius.circular(15.00)
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.filter_list_rounded,
              color: Colors.tealAccent,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton(
                borderRadius: BorderRadius.all(
                  Radius.circular(15.00)
                ),
                alignment: Alignment.center,
                value: currentFilter,
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  overflow: TextOverflow.ellipsis,
                ),
                dropdownColor: Color(0xFF032f4b),
                icon: const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Colors.tealAccent,
                ),
                items: filterOptions.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) async { 
                  if(!isGenre) {
                    currentFilter = newValue!;
                    currentMainFilter = currentFilter;
                  }
                  else {
                    currentFilter = newValue!;
                    currentGenreFilter = currentFilter;
                  }
                  hintText = getHintText(isGenre);
                  loadSearchingData();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getHintText(bool isGenre) {
    hintText = "Search Books ...";
    if(isGenre){
      return "Search Books for \"${currentGenreFilter == "All" ? "All Genre": "Genre - "+currentGenreFilter}\"";
    }
    else {
      switch(currentMainFilter) {
        case "Genre":
          return "Search Books by Genre ...";
        case "Book Title":
          return "Search Books by Book Title ...";
        case "Author":
          return "Search Books by Author Name ...";
        case "Keywords":
          return "Search Books by Keywords ...";
        case "All":
        default: 
          return "Search Books by book name, author name, etc ...";
      }
    }
  }

  Widget getAppBarTitle() {
    return TextField(
      controller: searchTextController,
      style: TextStyle(
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      maxLines: 1,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: Colors.white),
        hintText: hintText, // by keywords, too
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(18.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      onChanged: searchOperation,
    );
  }

}


