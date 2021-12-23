import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:relis/arguments/bookArguments.dart';
import 'package:relis/authentication/user.dart';
import 'package:relis/arguments/pagearguments.dart';
import 'package:relis/bookInfo.dart';
import 'package:relis/profile/profile.dart';
import 'package:relis/view/bookView.dart';
import 'package:relis/view/pageView.dart';
import 'package:relis/drawer.dart';
import 'package:relis/globals.dart';
import 'package:relis/view/searchPage.dart';
import 'package:relis/widget/bookPreview.dart';
import 'package:relis/widget/bookScrollList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List <Widget> bottom = [];
  int currentIndex = 0;
  int click = 0;
  int ijk = 0;


  List<PopupMenuEntry<dynamic>> popUpLists(BuildContext context) {
    return [
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.stacked_bar_chart),
          title: Text("Status"),
          tileColor: Colors.redAccent,
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.person),
          title: Text("Profile"),
          tileColor: Colors.redAccent,
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.logout),
          title: Text("Log Out"),
          tileColor: Colors.redAccent,
          onTap: () {
            logOut(context);
          },
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    isLoggedIn(context);
    // var item = SingleChildScrollView(
    //   child: LayoutBuilder(
    //     builder: (BuildContext context, BoxConstraints constraints) {
    //       if (constraints.maxWidth > 700) {
    //           return desktopView();
    //         } else {
    //           return mobileView();
    //         }
    //     },
    //   ),
    // );
    // bottom = [
    //   item,item,item
    // ];
    // currentIndex = 0;
    loadData();
    WidgetsBinding.instance!.addPostFrameCallback((_){
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    print("ijk: ${++ijk}");
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text(appTitle),
        backgroundColor: appBarBackgroundColor,
        shadowColor: appBarShadowColor,
        elevation: 2.0,
        actions: [
          Tooltip(
            message: "Search Books",
            child: Material(
              shadowColor: Colors.black,
              elevation: 0.0,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.00),
              type: MaterialType.card,
              child: InkWell(
                enableFeedback: true,
                hoverColor: Colors.tealAccent.withOpacity(0.6),
                splashColor: Color(0xFF032f4b).withOpacity(0.8),
                borderRadius: BorderRadius.circular(1000.00),
                onTap: () {
                  Navigator.of(context).pushNamed(SearchView.routeName);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20.00, right: 20.00),
                  child: Icon(Icons.search, color: Colors.white,),
                ),
              ),
            ),
          ),
          PopupMenuButton(itemBuilder: popUpLists, color: Colors.purpleAccent,),
          Tooltip(
            message: "Your Profile",
            child: Material(
              shadowColor: Colors.black,
              elevation: 0.0,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25.00),
              type: MaterialType.card,
              child: InkWell(
                enableFeedback: true,
                hoverColor: Colors.tealAccent.withOpacity(0.6),
                splashColor: Color(0xFF032f4b).withOpacity(0.8),
                borderRadius: BorderRadius.circular(1000.00),
                onTap: () {
                  Navigator.of(context).pushNamed(Profile.routeName);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20.00, right: 20.00),
                  child: CircleAvatar(
                    backgroundImage: user["imageURL"] != null ? NetworkImage(user["imageURL"]) : Image.asset("ReLis.gif").image,
                    backgroundColor: Color(0xFF032f4b),
                    radius: 25.00,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: currentIndex,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "", tooltip: "Active Reading"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "", tooltip: "Profile"),
      //     BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "", tooltip: "Statistics"),
      //   ],
      //   backgroundColor: Colors.tealAccent,
      // ),
      drawer: AppDrawer(), //DrawerPage(),
      body:  SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 700) {
              return desktopView();
            } else {
              return mobileView();
            }
          },
        ),
      ),// bottom[currentIndex],
    );
  }

  Widget desktopView() {
    return Column(
      children: [
        bookCarousel(),
        customDivider(),
        if(bookInfo["trendingBook"]!.length>0)
          viewButton("Current Trends", "trending", bookScrollList(getBooksMap(bookInfo["trendingBook"]), trendingController, trendingHover),),
        customDivider(),
        if(user["recommendedBook"].length > 0)
          viewButton("Recommended For You", "recommendation", BookScrollList(currentBook: getBooksMap(user["recommendedBook"]), controller: recommendationController, bookHover:recommendationHover, type: pageType.recommendation),
          ),
        customDivider(),
        viewButton("Genre", "categories", Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
          margin: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            runAlignment: WrapAlignment.spaceAround,
            spacing: 10.00,
            runSpacing: 20.00,
            direction: Axis.horizontal,
            verticalDirection: VerticalDirection.down,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              for(var cat in category.values)
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
                    // Hero(
                    //   tag: "category: ${category[i%(categoryListLength)]["id"]}",
                    //   child:
                      Container(
                        width: 300,
                        height: 100,
                        decoration: categoryDecoration,
                        alignment: Alignment.center,
                        child: Material(
                          shadowColor: Colors.black,
                          elevation: 1.0,
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(25.00),
                          type: MaterialType.card,
                          child: InkWell(
                            enableFeedback: true,
                            hoverColor: Colors.white.withOpacity(0.1),
                            splashColor: Colors.tealAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(25.00),
                            onTap: (){
                              Navigator.of(context).pushNamed(
                                PageTypeView.routeName,
                                arguments: PageArguments(
                                  pageType.category,
                                  currentCategory: cat,
                                ),
                              );
                            },
                            onHover: (hover){
                              categoryHover.update(cat["id"], (value) => categoryHover[cat["id"]]!);
                              hover = categoryHover[cat["id"]]!.value;
                              // setState(() {});
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: Text(cat["categoryName"], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 30), overflow: TextOverflow.ellipsis,),
                            ),
                          ),
                        ),
                      ),
                    // ),
                    SizedBox(width: 20,),
                  ],
                ),
            ],
          ),
        ),
        ),
        customDivider(),
        viewButton("Your Reading History", "history", bookScrollList(getBooksMap(user["bookHistory"]), historyController, historyHover),),
        customDivider(),
        Container(color: Colors.green, height: 150,),
        Container(color: Colors.white, height: 20,),
        Container(color: Colors.red, height: 150,),
        customDivider(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Row(
              children: [
                Container(color: Colors.teal, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
                Container(color: Colors.purple, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
                Container(color: Colors.teal, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
                Container(color: Colors.purple, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
              ],
            ),
          ),
        ),
        customDivider(),
        Container(color: Colors.green, height: 150,),
        Container(color: Colors.white, height: 20,),
        Container(color: Colors.red, height: 150,),
        Container(color: Colors.transparent, height: 20,),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Row(
              children: [
                Container(color: Colors.teal, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
                Container(color: Colors.purple, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
                Container(color: Colors.teal, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
                Container(color: Colors.purple, width: 500, height: 200,),
                Container(color: Colors.deepOrange, width: 20, height: 150,),
              ],
            ),
          ),
        ),
        customDivider(),
        Container(color: Colors.green, height: 150,),
        Container(color: Colors.white, height: 20,),
      ],
    );
  }

  Widget mobileView() {
    return Container();
  }

  Widget customDivider() {
    return Column(
      children: [
        Container(color: Color(0xFF032f4b), height: 5,),
        Container(color: Colors.transparent, height: 2,),
        Container(color: Color(0xFF032f4b), height: 5,),
      ],
    );
  }

  Widget viewButton(String containerName, String visibilityName, Widget containerChild) {
    print("viewButton - ${containerName}");
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MaterialButton(
            splashColor: Color(0xff014b76),
            onPressed: (){
              visible[visibilityName] = !visible[visibilityName]!;
              setState(() {});
            },
            child: Container(
              alignment: Alignment.centerLeft,
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 40.00),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    visible[visibilityName]! ? Icons.keyboard_arrow_down_rounded : Icons.play_arrow_rounded,
                    size: 30,
                  ),
                  SizedBox(width: 20.00,),
                  Text(containerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                ],
              ),
            ),
          ),
          Visibility(
            visible: visible[visibilityName]!,
            child: containerChild,
          ),
        ],
    );
  }

  Widget bookScrollList(var currentBook, ScrollController controller, Map<String, ValueNotifier<bool>> bookHover) {
    if(currentBook == null || currentBook.isEmpty){
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
        margin: EdgeInsets.symmetric(vertical: 20.00, horizontal: 20.00),
        width: 600,
        height: 200,
        decoration: categoryDecoration,
        child: Text("No History", style: TextStyle(color: Colors.white, fontSize: 30),),
      );
    }
    return Scrollbar(
      controller: controller,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(10.00),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
          margin: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
          child: Row(
            children: [
              for(var curBook in currentBook.values)
                Row(
                  children: [
                    BookPreview(currentBook: curBook, bookHover: bookHover,),
                    SizedBox(width: 20,),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bookCarousel() {
    List<Widget> carouselList = [];
    var bookList = getBooksMap(bookInfo["topPicks"]);
    for(var currentBook in bookList.values){
      carouselList.add(Hero(
        tag: "book: ${currentBook["id"]}",
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
                  BookView.routeName, arguments: BookArguments(currentBook));
            },
            child: Container(
              width: MediaQuery.of(context).size.width/2,
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              decoration: boxDecoration,
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.00),
                child: Image.asset(
                  currentBook["image"],
                  fit: BoxFit.fill,
                  width: double.infinity,
                  repeat: ImageRepeat.noRepeat,
                ),
              ),
            ),
          ),
        ),
      ));
    }
    int currentCarousel = 0;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.00),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 40.00),
            child: Text("Top Picks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
          ),
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.width/3,
              viewportFraction: 0.5,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 1000),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              onPageChanged: (int pageNo, dynamic reason){
                print("homePage: Auto: ");
                print("\t currentCarousel was: ${currentCarousel}");
                currentCarousel = pageNo;
                print("\t New currentCarousel is: ${currentCarousel}");
                setState(() {});
              },
            ),
            items: carouselList,
            carouselController: carouselController,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: carouselList.asMap().entries.map((entry) {
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                  print("homePage: Tapped: ");
                  print("\t currentCarousel was: ${currentCarousel}");
                  currentCarousel = entry.key;
                  print("\t New currentCarousel is: ${currentCarousel}");
                  setState(() {});
                  carouselController.animateToPage(entry.key);
                },
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(currentCarousel == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

}
