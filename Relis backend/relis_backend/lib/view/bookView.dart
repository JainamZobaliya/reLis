import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:relis/arguments/bookArguments.dart';
import 'package:relis/audioBook/audiobook.dart';
import 'package:relis/authentication/user.dart';
import 'package:relis/drawer.dart';
import 'package:relis/globals.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:relis/view/pdfViewer.dart';

class BookView extends StatefulWidget {
  const BookView({Key? key}) : super(key: key);
  static const routeName = '/BookView';

  @override
  _BookViewState createState() => _BookViewState();
}

class _BookViewState extends State<BookView> {
  ValueNotifier<bool> favBook = ValueNotifier<bool>(false);
  ValueNotifier<bool> wishBook = ValueNotifier<bool>(false);
  String myComment = "";
  var userCommentInfo = {};
  TextEditingController myCommentController = new TextEditingController();
  var feedbackMap = {};
  bool addedToCart = false;
  

  void loadValues(Map<String, dynamic> user, Map<String, dynamic> currentBook) {
    for(var key in currentBook.keys) {
      print("\t ${key}");
    }
    // print("Received currentBook");
    favBook.value = isFavourite(user, currentBook["id"]);
    print("\tGot fav.");
    wishBook.value = isWishList(user, currentBook["id"]);
    print("\tGot wishBook.");
    feedbackMap = currentBook.containsKey("feedback") ? currentBook["feedback"] : {};
    print("\tGot feedbackMap.");
    if(feedbackMap.length>0)
      for(var userComment in feedbackMap.values)
        userCommentInfo = getUserInfo(userComment["userId"]);
    addedToCart = (user["cart"]["toRent"].contains(currentBook["id"]) || user["cart"]["toBuy"].contains(currentBook["id"])) && (isBookBought(currentBook["id"]) || isBookRented(currentBook["id"]));
    print("\t addedToCart: $addedToCart");
    print("\t rentCart: ${user["cart"]["toRent"].contains(currentBook["id"])}");
    print("\t buyCart: ${user["cart"]["toBuy"].contains(currentBook["id"])}");
    print("\t isBookBought: ${isBookBought(currentBook["id"])}");
    print("\t isBookRented: ${isBookRented(currentBook["id"])}");
    var and1 = (!isBookBought(currentBook["id"]) && !isBookRented(currentBook["id"]));
    print("\t and-1: $and1");
    var or1 = addedToCart || and1;
    print("\t\t or-1: $or1");
    var or2 = (!isBookBought(currentBook["id"]) || !isBookRented(currentBook["id"]));
    print("\t or-2: $or2");
    var and2 = addedToCart && or2;
    print("\t\t and-2: $and2");
    
  }
  // AddedToCart is not working properly.


  @override
  Widget build(BuildContext context) {
    isLoggedIn(context);
    final book = ModalRoute.of(context)!.settings.arguments as BookArguments;
    print("\tIn Book View");
    print("\tbookType: ${book.currentBook.runtimeType}");
    loadValues(user!, book.currentBook);
    print("Book Values Loaded");
    return Hero(
      tag: "book: ${book.currentBook["id"]}",
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        appBar: AppBar(
          title: Text(book.currentBook["bookName"]),
          backgroundColor: appBarBackgroundColor,
          shadowColor: appBarShadowColor,
          elevation: 2.0,
        ),
        drawer: AppDrawer(), //DrawerPage(),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 700) {
              return desktopView(book.currentBook);
            } else {
              return mobileView(book.currentBook);
            }
          },
        ),
      ),
    );
  }

  Widget desktopView(var currentBook) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
      margin: EdgeInsets.symmetric(vertical: 0.00, horizontal: 20.00),
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 1,
            child: Transform.scale(
              scale: MediaQuery.of(context).size.width<=1000 ? 0.8 : 1.0,
              child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 300,
                        decoration: boxDecoration,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.00),
                          child: currentBook["image"],
                          // child: Image.asset(
                          //   currentBook["image"],
                          //   fit: BoxFit.fill,
                          //   height: 500,
                          //   width: double.infinity,
                          //   repeat: ImageRepeat.noRepeat,
                          // ),
                        ),
                      ), //Book-Image
                      SizedBox(height: 20,),
                      if(addedToCart || (!isBookBought(currentBook["id"]) && !isBookRented(currentBook["id"])))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: MaterialButton(
                                elevation: 2.0,
                                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: new BorderRadius.circular(15.0),
                                ),
                                focusElevation: 20.0,
                                hoverElevation: 10.0,
                                highlightElevation: 5.0,
                                hoverColor: Colors.orangeAccent,
                                autofocus: false,
                                enableFeedback: true,
                                textColor: Colors.white,
                                color: Colors.orange,
                                splashColor: Colors.orange,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(Icons.timelapse_rounded, color: Colors.white,),
                                    ),
                                    SizedBox(width: 10.00,),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Rent",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 20,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  await addToCart(context, currentBook["id"], currentBook["bookName"], isRent: true);
                                  addedToCart = !addedToCart;
                                  setState(() {});
                                },
                              ),
                            ), // For Rent Button
                            SizedBox(width: 20,),
                            Expanded(
                              child: MaterialButton(
                                elevation: 2.0,
                                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: new BorderRadius.circular(15.0),
                                ),
                                focusElevation: 20.0,
                                hoverElevation: 10.0,
                                highlightElevation: 5.0,
                                hoverColor: Colors.orangeAccent.withOpacity(0.5),
                                autofocus: false,
                                enableFeedback: true,
                                textColor: Colors.white,
                                color: Colors.deepOrange,
                                splashColor: Colors.deepOrange,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Icon(Icons.shopping_cart_rounded, color: Colors.white,),
                                    ),
                                    SizedBox(width: 10.00,),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "Buy",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 20,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  await addToCart(context, currentBook["id"], currentBook["bookName"], isRent: false);
                                  addedToCart = !addedToCart;
                                  setState(() {});
                                },
                              ),
                            ), // For Buy Button
                          ],
                        ), // For Rent / Buy Button
                      if(addedToCart && (!isBookBought(currentBook["id"]) || !isBookRented(currentBook["id"])))
                        MaterialButton(
                          elevation: 2.0,
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Color(0xFF032f4b),
                            ),
                            borderRadius: new BorderRadius.circular(15.0),
                          ),
                          focusElevation: 20.0,
                          hoverElevation: 10.0,
                          highlightElevation: 5.0,
                          hoverColor: Color(0xff0f4261),
                          autofocus: false,
                          enableFeedback: true,
                          textColor: Colors.white,
                          color: Color(0xFF032f4b),
                          splashColor: Color(0xFF032f4b).withOpacity(0.9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.shopping_cart_rounded, color: Colors.white,),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Added to Cart",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            removeFromCart(context, currentBook["id"], currentBook["bookName"]);
                            addedToCart = !addedToCart;
                            setState(() {});
                          },
                        ), 
                      if((!isBookBought(currentBook["id"]) || !isBookRented(currentBook["id"])))
                        SizedBox(height: 20,),
                      if(isBookBought(currentBook["id"]) || isBookRented(currentBook["id"]))
                        MaterialButton(
                          elevation: 2.0,
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Color(0xFF032f4b),
                            ),
                            borderRadius: new BorderRadius.circular(15.0),
                          ),
                          focusElevation: 20.0,
                          hoverElevation: 10.0,
                          highlightElevation: 5.0,
                          hoverColor: Color(0xff0f4261),
                          autofocus: false,
                          enableFeedback: true,
                          textColor: Colors.white,
                          color: Color(0xFF032f4b),
                          splashColor: Color(0xFF032f4b).withOpacity(0.9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Icon(Icons.menu_book_rounded, color: Colors.white,),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Read Now",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            addToHistory(user!, currentBook);
                            print("url: ${currentBook["url"]}");
                            Navigator.of(context).push(
                              // MaterialPageRoute(builder: (context) => PDFViewer(path: "/book/"+currentBook["id"]+".pdf")),
                              MaterialPageRoute(builder: (context) => PDFViewer(path: "/book/book1.pdf")),
                            );
                            // Navigator.of(context).pushNamed(OTPPage.routeName);
                            // Center(
                            //   child: CircularProgressIndicator(),
                            // );
                            // if (_key.currentState.validate()) {
                            //   _signInWithEmailAndPassword();
                            // } else {
                            //   showMessageSnackBar("Please fill the valid Details!!");
                            // }
                          },
                        ), // Read Now Button
                      if(!isBookBought(currentBook["id"]) || !isBookRented(currentBook["id"]))
                        SizedBox(height: 20,),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: favBook.value ? "Added to Favourite" : "Add to Favourite",
                                padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
                                child: InkResponse(
                                  highlightShape: BoxShape.circle,
                                  autofocus: false,
                                  enableFeedback: true,
                                  splashColor: Colors.red.withOpacity(0.8),
                                  hoverColor: Colors.red.withOpacity(0.5),
                                  child: ValueListenableBuilder(
                                    valueListenable: favBook,
                                    builder: (context, value, child) => favBook.value ? Icon(Icons.favorite_rounded,
                                      color: Color(0xFFff0000), size: 30,) : Icon(Icons.favorite_outline_rounded,
                                      color: Color(0xFFff0000), size: 30,),
                                  ),
                                  onTap: () async {
                                    this.setState(() {
                                      favouriteBook(context, user!, currentBook);
                                      loadValues(user!, currentBook);
                                      setState(() {});
                                    });
                                  },
                                ),
                              ),
                            ), //Favourite Button
                            if(isBookBought(currentBook["id"]) || isBookRented(currentBook["id"]))
                              Expanded(
                                child: Tooltip(
                                  message: "Listen to AudioBook",
                                  child: MaterialButton(
                                    elevation: 2.0,
                                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Color(0xFF032f4b),
                                      ),
                                      borderRadius: new BorderRadius.circular(15.0),
                                    ),
                                    focusElevation: 20.0,
                                    hoverElevation: 10.0,
                                    highlightElevation: 5.0,
                                    hoverColor: Color(0xff0f4261),
                                    autofocus: false,
                                    enableFeedback: true,
                                    textColor: Colors.white,
                                    color: Color(0xFF032f4b),
                                    splashColor: Color(0xFF032f4b).withOpacity(0.9),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Icon(Icons.multitrack_audio_rounded, color: Colors.white,),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context).pushNamed(AudioBook.routeName);
                                    },
                                  ),
                                ),
                              ), // AudioBook Button
                            Expanded(
                              child: Tooltip(
                                message: wishBook.value ? "Added to Wish-List" : "Add to Wish-List",
                                padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
                                child: InkResponse(
                                  highlightShape: BoxShape.circle,
                                  autofocus: false,
                                  enableFeedback: true,
                                  splashColor: Color(0xFF032f4b).withOpacity(0.8),
                                  hoverColor: Color(0xFF032f4b).withOpacity(0.5),
                                  child: ValueListenableBuilder(
                                    valueListenable: wishBook,
                                    builder: (context, value, child) => wishBook.value ? Icon(
                                      Icons.bookmark, color: Color(0xFF0000FF), size: 30,) : Icon(
                                      Icons.bookmark_add_outlined, color: Color(0xFF0000FF), size: 30,),
                                  ),
                                  onTap: () async {
                                    this.setState(() {
                                      wishListBook(context, user!, currentBook);
                                      loadValues(user!, currentBook);
                                      setState(() {});
                                    });
                                  },
                                ),
                              ),
                            ), //Wish-List Button
                          ],
                        ),
                      ), // Fav. / Audio-Book / Wish-List Button
                    ],
                  ),
                ),
            ),
          ), // Book-Image and Options to read/listen, buy/rent, fav./wish-list Book
          SingleChildScrollView(
            child: Expanded(
              flex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width*0.7,
                padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentBook["bookName"],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.wavy,
                          decorationThickness: 1.0,
                          fontSize: 45,
                          color: Color(0xFF154360),
                          height: 2),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ), // bookName
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: showBookAuthorName(currentBook["authorName"]),
                        ),
                        Expanded(
                          child: showBookGenre(currentBook["category"]),
                        ),
                        Expanded(
                          child: showBookPrice(currentBook["price"]),
                        ),
                      ],
                    ), // authorName, category, price
                    showBookDescription(currentBook["description"]),
                    SizedBox(height: 20,),
                    showCommentBox(),
                  ],
                ),
              ),
            ),
          ), //Book details and feedbacks
        ],
      ),
    );
  }
  
  Widget showBookAuthorName(String authorName) {
    return RichText(
      text: TextSpan(
        text: 'Author: ',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: Colors.black,
          height: 2,
          fontSize: 14,
        ),
        children: <TextSpan>[
          TextSpan(
            text: authorName,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF154360),
                height: 1),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      maxLines: 1,
    );
  }

  Widget showBookGenre(String genre) {
    return RichText(
      text: TextSpan(
        text: 'Genre:  ',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: Colors.black,
          height: 2,
          fontSize: 14,
        ),
        children: <TextSpan>[
          TextSpan(
            text: getCategoryName(genre),
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF154360),
                height: 1),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget showBookPrice(String price) {
    return RichText(
      text: TextSpan(
        text: 'Price: ',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          decoration: TextDecoration.none,
          color: Colors.black,
          height: 2,
          fontSize: 14,
        ),
        children: <TextSpan>[
          TextSpan(
            text: "\u{20B9} ${price}/-",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF154360),
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget mobileView(var currentBook){
    return Container();
  }

  getUserInfo(String userId) {
    var userInfo = {};
    userInfo["userId"] = user?["emailId"];
    userInfo["name"] = user?["firstName"] + " " + user?["lastName"];
    userInfo["imageURL"] = user?["imageURL"];
    return userInfo;
  }

  Widget showBookDescription(String description) {
    return Container(
      decoration: boxDecoration,
      margin: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
      padding: EdgeInsets.symmetric(vertical: 10.00, horizontal: 20.00),
      child: RichText(
        text: TextSpan(
          text: 'Description:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.solid,
            color: Color(0xFF154360),
            height: 2,
            fontSize: 20,
          ),
          children: <TextSpan>[
            TextSpan(
              text: "    "+description,
              style: TextStyle(
                color: Color(0xFF154360),
                height: 2,
                fontSize: 18,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
                fontStyle: FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bookRatingBar(double rating, bool isModifiable) {
    return RatingBar.builder(
      initialRating: rating,
      minRating: 1,
      maxRating: 5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemSize: isModifiable ? 35 : 20,
      itemCount: 5,
      ignoreGestures: !isModifiable,
      updateOnDrag: isModifiable,
      tapOnlyMode: false,
      itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
      },
    );
  }

  Widget commentUserRating(String rating) {
    return bookRatingBar(double.parse(rating), false);
    // return Text(
    //   "Rating: "+rating+"/5",
    //   style: TextStyle(
    //     color: mainAppAmber,
    //     fontSize: 18,
    //   ),
    //   maxLines: 1,
    //   overflow: TextOverflow.ellipsis,
    // );
  }

  Widget showCommentBox() {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: commentBoxDecoration,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: (text) {
                    myComment = text;
                  },
                  controller: myCommentController,
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.white,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: '',
                    hintStyle: TextStyle(
                      height: 0.7,
                      color: Colors.white,
                    ),
                    labelText: 'Enter your view on this book...',
                    labelStyle: TextStyle(
                      color: Colors.white,
                      height: 1,
                    ),
                    prefixIcon: Icon(Icons.add_reaction_rounded, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                ),
              ), // TextBox
              SizedBox(width: 20,),
              bookRatingBar(0, true), // Rating bar
              SizedBox(width: 20,),
              IconButton(
                onPressed: () async {},
                icon: Icon(Icons.send_rounded, color: Colors.white,),
                alignment: Alignment.center,
                color: Colors.white,
                padding: EdgeInsets.all(10.00),
                splashColor: mainAppAmber,
                tooltip: "Post your Comment!!!",
              ), // Post Comment Button
            ],
          ), // TextBox, RatingBar, Post-button
          SizedBox(height: 20,),
          if(feedbackMap.length>0)
            for(var userComment in feedbackMap.values)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10.00),
                          decoration: BoxDecoration(
                            color: commentBoxColor,
                            borderRadius: BorderRadius.all(Radius.circular(20.00)),
                            border: Border.all(
                              color: mainAppAmber,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: userCommentInfo["imageURL"] != null ? NetworkImage(userCommentInfo["imageURL"]) : Image.asset("ReLis.gif").image,
                                    backgroundColor: Color(0xFF032f4b),
                                    radius: 25.00,
                                  ),
                                  SizedBox(width: 10.00,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      commentUserRating(userComment["rating"]),
                                      Text(
                                        userCommentInfo["name"],
                                        style: TextStyle(
                                          color: mainAppAmber,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 10.00,),
                              Text(
                                userComment["comment"],
                                style: TextStyle(
                                  color: mainAppAmber,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                ],
            ),
        ],
      ),
    );
  }

}
