import 'dart:io';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:relis/arguments/pagearguments.dart';
import 'package:relis/authentication/otp.dart';
import 'package:relis/authentication/passwordChange.dart';
import 'package:relis/authentication/signUp.dart';
import 'package:relis/authentication/user.dart';
import 'package:relis/bookInfo.dart';
import 'package:relis/profile/profile.dart';
import 'package:relis/profile/showPhoto.dart';
import 'package:relis/view/bookView.dart';
import 'package:relis/view/homePage.dart';
import 'dart:collection';
import 'package:relis/view/pageView.dart';
import 'package:relis/view/searchPage.dart';
import 'package:relis/view/splashScreen.dart';

import 'authentication/signIn.dart';

String appTitle = "ReLis - Let the book talk!!!";

ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  scrollbarTheme: ScrollbarThemeData(
    interactive: true,
    isAlwaysShown: true,
    radius: Radius.circular(10),
    thickness: MaterialStateProperty.all(10.00),
    showTrackOnHover: true,
    thumbColor: MaterialStateProperty.all(Color(0xFF032f4b)),
    trackColor: MaterialStateProperty.all(Color(0x8d032f4b)),
    trackBorderColor: MaterialStateProperty.all(Color(0xFF032f4b)),
    minThumbLength: 10,
  ),
);

var appRoutes = {
  SplashPage.routeName: (BuildContext context) => SplashPage(),
  SignUpPage.routeName: (BuildContext context) => SignUpPage(),
  SignInPage.routeName: (BuildContext context) => SignInPage(),
  OTPPage.routeName: (BuildContext context) => OTPPage(),
  HomePage.routeName: (BuildContext context) => HomePage(),
  BookView.routeName: (BuildContext context) => BookView(),
  PageTypeView.routeName: (BuildContext context) => PageTypeView(),
  Profile.routeName: (BuildContext context) => Profile(),
  ShowPhoto.routeName: (BuildContext context) => ShowPhoto(),
  SearchView.routeName: (BuildContext context) => SearchView(),
  PasswordChange.routeName: (BuildContext context) => PasswordChange(),
};

bool changingPassword = false;
String changingEmailID = "";

bool loggedIn = false;

isLoggedIn(BuildContext context) {
  if (!loggedIn) {
    logOut(context);
  }
}

logOut(BuildContext context) {
  loggedIn = false;
  // Navigator.of(context).popUntil(ModalRoute.withName(SplashPage.routeName));
  while (Navigator.canPop(context)) Navigator.of(context).pop();
  Navigator.of(context).pushNamed(SignInPage.routeName);
}

Color mainAppBlue = Color(0xFF032f4b);
Color mainAppAmber = Color(0xFFdbb018);
Color appBarBackgroundColor = Color(0xFF1E8BC3);
Color appBarShadowColor = Color(0xFF2C3E50);
Color appBackgroundColor = mainAppAmber; // Color(0xFF1A93EF);
Color selectedDrawerTile = Color(0xFF197278);
Color commentBoxColor = Color(0xFF197278);

Map<String, bool> pages = {
  "Home": true,
  "Genre": false,
  "Trending": false,
  "Favourites": false,
  "Wish List": false,
  "History": false,
  "Bought": false,
  "Rented": false,
};

Map<String, String> Registeration = {};

String currentPage = "Home";

void showMessageSnackBar(BuildContext context, String message) {
  final snackBar = new SnackBar(content: new Text('$message'));
  // ignore: deprecated_member_use
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void changePage(String newPage) {
  pages[currentPage] = false;
  currentPage = newPage;
  pages[currentPage] = true;
}

bool isPageOpened(String pageName) {
  return pages[pageName]!;
}

BoxDecoration boxDecoration = BoxDecoration(
  color: Colors.tealAccent,
  boxShadow: [
    BoxShadow(
      color: Color(0xFF1E824C),
      offset: const Offset(
        0.0,
        5.0,
      ),
      blurRadius: 10.0,
      spreadRadius: 1.5,
    ),
    BoxShadow(
      color: Colors.black,
      offset: const Offset(0.0, 5.0),
      blurRadius: 10.0,
      spreadRadius: 1.5,
    ),
  ],
  borderRadius: BorderRadius.circular(25.00),
  border: Border.all(color: Colors.teal, width: 2),
);
BoxDecoration innerBoxDecoration = BoxDecoration(
  color: Colors.tealAccent.withOpacity(0.6),
  borderRadius: BorderRadius.vertical(
      top: Radius.circular(20.00), bottom: Radius.circular(25.00)),
  border: Border.all(color: Colors.teal.withOpacity(0.4), width: 2),
);
BoxDecoration categoryDecoration = BoxDecoration(
  color: Color(0xFF032f4b),
  boxShadow: [
    BoxShadow(
      color: Color(0xFF1E824C),
      offset: const Offset(
        0.0,
        5.0,
      ),
      blurRadius: 10.0,
      spreadRadius: 1.5,
    ),
    BoxShadow(
      color: Colors.black,
      offset: const Offset(0.0, 5.0),
      blurRadius: 10.0,
      spreadRadius: 1.5,
    ),
  ],
  borderRadius: BorderRadius.circular(25.00),
  border: Border.all(color: Colors.teal, width: 2),
);
BoxDecoration commentBoxDecoration = BoxDecoration(
  color: Color(0xFF032f4b),
  boxShadow: [
    BoxShadow(
      color: Color(0xFF1E824C),
      offset: const Offset(
        0.0,
        5.0,
      ),
      blurRadius: 10.0,
      spreadRadius: 1.5,
    ),
    BoxShadow(
      color: Colors.black,
      offset: const Offset(0.0, 5.0),
      blurRadius: 10.0,
      spreadRadius: 1.5,
    ),
  ],
  borderRadius: BorderRadius.circular(25.00),
  border: Border.all(color: Colors.teal, width: 2),
);

// bool hover = false;
Map<String, ValueNotifier<bool>> favourite = {};
Map<String, ValueNotifier<bool>> wishList = {};
Map<String, ValueNotifier<bool>> recommendationHover = {};
Map<String, ValueNotifier<bool>> historyHover = {};
Map<String, ValueNotifier<bool>> favouriteHover = {};
Map<String, ValueNotifier<bool>> trendingHover = {};
Map<String, ValueNotifier<bool>> categoryHover = {};
Map<String, ValueNotifier<bool>> categoryBookHover = {};
Map<String, ValueNotifier<bool>> wishListHover = {};
Map<String, ValueNotifier<bool>> boughtHover = {};
Map<String, ValueNotifier<bool>> rentedHover = {};
Map<String, ValueNotifier<bool>> personalBooksHover = {};
Map<String, ValueNotifier<bool>> adminBookHover = {};
Map<String, bool> visible = {
  "recommendation": true,
  "trending": true,
  "categories": true,
  "history": true,
};
int bookListLength = bookMap.length;
int categoryListLength = category.length;
ScrollController recommendationController = new ScrollController();
ScrollController scrollController = new ScrollController();
ScrollController trendingController = new ScrollController();
ScrollController historyController = new ScrollController();
CarouselController carouselController = CarouselController();

enum pageType {
  none,
  category,
  trending,
  favourite,
  wishList,
  history,
  bought,
  rented,
  personalBooks,
  adminBookView,
  recommendation,
}

gotToRoute(BuildContext context, pageType type) {
  switch (type) {
    case pageType.category:
      {
        changePage("Genre");
        return Navigator.of(context).popAndPushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.category,
          ),
        );
      }
      break;
    case pageType.trending:
      {
        changePage("Trending");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.trending,
          ),
        );
      }
      break;
    case pageType.favourite:
      {
        changePage("Favourites");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.favourite,
          ),
        );
      }
      break;
    case pageType.wishList:
      {
        changePage("Wish List");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.wishList,
          ),
        );
      }
      break;
    case pageType.history:
      {
        changePage("History");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.history,
          ),
        );
      }
      break;
    case pageType.bought:
      {
        changePage("Bought");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.bought,
          ),
        );
      }
      break;
    case pageType.rented:
      {
        changePage("Rented");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.rented,
          ),
        );
      }
      break;
    case pageType.personalBooks:
      {
        changePage("Trending");
        return Navigator.of(context).pushNamed(
          PageTypeView.routeName,
          arguments: PageArguments(
            pageType.personalBooks,
          ),
        );
      }
      break;
    case pageType.none:
    default:
      {
        changePage("Home");
        return Navigator.of(context).pushNamed(HomePage.routeName);
      }
      break;
  }
}

String pageName(pageType type) {
  switch (type) {
    case pageType.category:
      return "in this Genre";
    case pageType.trending:
      return "in Trending";
    case pageType.favourite:
      return "in Favourites";
    case pageType.wishList:
      return "in WishList";
    case pageType.history:
      return "in History";
    case pageType.bought:
      return "Bought";
    case pageType.rented:
      return "Rented";
    case pageType.personalBooks:
      return "in your Personal Library";
    case pageType.none:
    default:
      return "";
  }
}

Map<String, dynamic> book1 = {
  "id": "bk-001",
  "bookName": "Wings Of Fire",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "category": "ct-005",
  "authorName": "APJ Abdul Kalam",
  "price": "599",
  "image": "book/book1.jpeg",
  "description":
      "The Wings of Fire is an autobiography of former Indian President APJ Abdul Kalam. The book covers his life before he became the President of India and commanded the armed forces. Renowned scientist and former Indian President APJ Abdul Kalam from 2002 to 2007 is well known across India and abroad as well.",
  "publication": "XYZ",
  "feedback": {
    "user0user0@relix.app": {
      "userId": "user0user0@relix.app",
      "comment": "Truly Inspiring Book!!!",
      "rating": "4",
    }
  },
  "ratings": {
    "1": "100",
    "2": "250",
    "3": "350",
    "4": "450",
    "5": "500",
  },
};
Map<String, dynamic> book2 = {
  "id": "bk-002",
  "bookName": "Steve Jobs",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Walter Isaacson",
  "category": "ct-004",
  "price": "495",
  "image": "book/book2.jpg",
  "description":
      "This biography by Water Isaacson was published shortly after Jobs death in 2011. Isaacson has the accolade of being Jobs' exclusive official biographer and was granted more than 40 interviews with Jobs and interviewed more than 100 of Jobs colleagues, family members and friends.",
  "publication": "ABC",
  "feedback": {
    "user1user1@relix.app": {
      "userId": "user1user1@relix.app",
      "comment": "Steve And Einstein both used apple and created History...",
      "rating": "3",
    }
  },
  "ratings": {
    "1": "150",
    "2": "280",
    "3": "450",
    "4": "570",
    "5": "600",
  },
};
Map<String, dynamic> book3 = {
  "id": "bk-003",
  "bookName": "Maharana Pratap",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Rima Hooja",
  "category": "ct-005",
  "price": "500",
  "image": "book/book3.jpg",
  "description":
      "One the greatest Indian warriors, Maharana Pratap was born on May 9 in the year 1540. Maharana Pratap was the ruler of Mewar, a province in modern day Rajasthan. Renowned as a fearsome warrior and an excellent combat strategist, Pratap protected the Mewar region against repeated onslaughts from the Mughals.",
  "publication": "PQR",
  "feedback": {
    "user2user2@relix.app": {
      "userId": "user2user2@relix.app",
      "comment":
          "One the greatest Indian warriors, Maharana Pratap was born on May 9 in the year 1540. Maharana Pratap was the ruler of Mewar, a province in modern day Rajasthan. Renowned as a fearsome warrior and an excellent combat strategist, Pratap protected the Mewar region against repeated onslaughts from the Mughals.",
      "rating": "3",
    },
    "user3user3@relix.app": {
      "userId": "user2user2@relix.app",
      "comment": "Great History...",
      "rating": "2.5",
    },
    "user4user4@relix.app": {
      "userId": "user4user4@relix.app",
      "comment": "Great History...",
      "rating": "4",
    },
  },
  "ratings": {
    "1": "10",
    "2": "480",
    "3": "550",
    "4": "650",
    "5": "700",
  },
};
Map<String, dynamic> book4 = {
  "id": "bk-004",
  "bookName": "Madhushala",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Harivansh Rai Bacchan",
  "category": "ct-006",
  "price": "122",
  "image": "book/book4.jpg",
  "description":
      "हरिवंशराय 'बच्चन' की अमर काव्य-रचना मधुशाला 1935 से लगातार प्रकाशित होती आ रही है। सूफियाना रंगत की 135 रुबाइयों से गूँथी गई इस कविता क हर रुबाई का अंत 'मधुशाला' शब्द से होता है। पिछले आठ दशकों से कई-कई पीढि़यों के लोग इस गाते-गुनगुनाते रहे हैं। यह एक ऐसी कविता है] जिसमें हमारे आसपास का जीवन-संगीत भरपूर आध्यात्मिक ऊँचाइयों से गूँजता प्रतीत होता है। \nमधुशाला का रसपान लाखों लोग अब तक कर चुके हैं और भविष्य में भी करते रहेंगे] लेकिन यह 'कविता का प्याला' कभी खाली होने वाला नहीं है, जैसा बच्चन जी ने स्वयं लिखा है- \nभावुकता अंगूर लता से खींच कल्पना की हाला, कवि साकी बनकर आया है भरकर कविता का प्याला; कभी न कण भर खाली होगा, लाख पिएँ, दो लाख पिएँ! पाठक गण हैं पीनेवाले, पुस्तक मेरी मधुशाला।",
  "publication": "XYZ",
  "feedback": {
    "user3user3@relix.app": {
      "userId": "user3user3@relix.app",
      "comment": "Book by Harivansh Rai Bacchan....",
      "rating": "3",
    }
  },
  "ratings": {
    "1": "10",
    "2": "480",
    "3": "150",
    "4": "350",
    "5": "500",
  },
};
Map<String, dynamic> book5 = {
  "id": "bk-005",
  "bookName": "Dark Matter",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Blake Crouch",
  "category": "ct-002",
  "price": "130",
  "image": "book/book5.jpg",
  "description":
      "'Brilliant. . . I think Blake Crouch just invented something new' Lee Child, author of the Jack Reacher series.\nFrom Blake Crouch, the author of the bestselling Wayward Pines trilogy, Dark Matter is sweeping and intimate, mind-bendingly strange and profoundly human – a relentlessly surprising thriller about choices, paths not taken, and how far we'll go to claim the lives we dream of, perfect for fans of Stranger Things and Ready Player One.\n\n'Are you happy in your life?'\nThose are the last words Jason Dessen hears before the masked abductor knocks him unconscious.\nBefore he awakes to find himself strapped to a gurney, surrounded by strangers in hazmat suits.\nBefore the man he's never met smiles down at him and says, 'Welcome back.'\n\nIn this world he's woken up to, Jason's life is not the one he knows. His wife is not his wife. His son was never born. And Jason is not an ordinary college physics professor, but a celebrated genius who has achieved something remarkable. Something impossible.\n\nIs it this world or the other that's the dream? And even if the home he remembers is real, how can Jason possibly make it back to the family he loves? The answers lie in a journey more wondrous and horrifying than anything he could've imagined – one that will force him to confront the darkest parts of himself even as he battles a terrifying, seemingly unbeatable foe.",
  "publication": "PQR",
  "feedback": {
    "user4user4@relix.app": {
      "userId": "user4user4@relix.app",
      "comment": "Book by Blake Crouch....",
      "rating": "3",
    }
  },
  "ratings": {
    "1": "10",
    "2": "480",
    "3": "550",
    "4": "650",
    "5": "700",
  },
};
Map<String, dynamic> book6 = {
  "id": "bk-006",
  "bookName": "No Matter What . . . I will always love you!",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Rohit Dawesar",
  "category": "ct-007",
  "price": "150",
  "image": "book/book6.jpg",
  "description":
      "An ordinary-turned-extraordinary tale about the magic of love...\n\nFrom romantic escapes in the beaches of Goa to witnessing the beautiful Manali sky lit up with fireworks on a Diwali night, Rishi and Mishika’s lives were like an exciting roller-coaster ride every moment that they were together.\nBut when Mishika disappears on the morning of their engagement without leaving so much as a wisp of a trace behind, Rishi finds himself alone and adrift in a dark sea of doubts and fears. Was this one of those pranks that Mishika loved to pull on him to test his love for her? Or had something happened to her?\nJoin Rishi as he tries to look for answers in an unforgiving world where holding on to even the slightest bit of hope is a daily struggle. Will he ever find Mishika? Was she even alive? What unbelievable things would his love for her make him do?\nFrom the bestselling author of The Stupid Somebody comes yet another gripping story that will make you laugh, cry, and reaffirm your faith in the strength of love.",
  "publication": "XYZ",
  "feedback": {
    "user5user5@relix.app": {
      "userId": "user5user5@relix.app",
      "comment": "Book by Rohit Dawesar....",
      "rating": "3",
    }
  },
  "ratings": {
    "1": "150",
    "2": "280",
    "3": "450",
    "4": "570",
    "5": "600",
  },
};
Map<String, dynamic> book7 = {
  "id": "bk-007",
  "bookName": "1Q84: Books 1, 2 & 3",
  "authorName": "Haruki Murakami",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "category": "ct-004",
  "price": "356",
  "image": "book/book7.jpg",
  "description":
      "The year is 1Q84.\n\nThis is the real world, there is no doubt about that.\nBut in this world, there are two moons in the sky.\nIn this world, the fates of two people, Tengo and Aomame, are closely intertwined. They are each, in their own way, doing something very dangerous. And in this world, there seems no way to save them both.\n\nSomething extraordinary is starting.",
  "publication": "ABC",
  "feedback": {
    "user5user5@relix.app": {
      "userId": "user5user5@relix.app",
      "comment": "Book by Haruki Murakami....",
      "rating": "3",
    }
  },
  "ratings": {
    "1": "150",
    "2": "280",
    "3": "450",
    "4": "570",
    "5": "600",
  },
};
Map<String, dynamic> book8 = {
  "id": "bk-008",
  "bookName": "The Silent Patient",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Alex Michaelides",
  "category": "ct-002",
  "price": "179",
  "image": "book/book8.jpg",
  "description":
      "The Silent Patient is a shocking psychological thriller of a woman’s act of violence against her husband—and of the therapist obsessed with uncovering her motive.\n\nAlicia Berenson’s life is seemingly perfect. A famous painter married to an in-demand fashion photographer, she lives in a grand house with big windows overlooking a park in one of London’s most desirable areas. One evening her husband Gabriel returns home late from a fashion shoot, and Alicia shoots him five times in the face, and then never speaks another word.\nAlicia’s refusal to talk, or give any kind of explanation, turns a domestic tragedy into something far grander, a mystery that captures the public imagination and casts Alicia into notoriety. The price of her art skyrockets, and she, the silent patient, is hidden away from the tabloids and spotlight at the Grove, a secure forensic unit in North London.\nTheo Faber is a criminal psychotherapist who has waited a long time for the opportunity to work with Alicia. His determination to get her to talk and unravel the mystery of why she shot her husband takes him down a twisting path into his own motivations—a search for the truth that threatens to consume him....",
  "publication": "ABC",
  "feedback": {
    "user5user5@relix.app": {
      "userId": "user5user5@relix.app",
      "comment": "Book by Alex Michaelides....",
      "rating": "3",
    }
  },
  "ratings": {
    "1": "150",
    "2": "280",
    "3": "450",
    "4": "570",
    "5": "600",
  },
};
Map<String, dynamic> book9 = {
  "id": "bk-009",
  "bookName": "One Arranged Murder",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Chetan Bhagat",
  "category": "ct-007",
  "price": "142",
  "image": "book/book9.jpg",
  "description":
      "Keshav has set up an investigation agency with his best friend, Saurabh. Can the two amateur detectives successfully solve another murder case that affects them personally? And where will it leave their friendship?\n\n‘Ever since you found Prerna, I lost my best friend’ is what I told Saurabh.\nHi, this is Keshav, and Saurabh, my best friend, flatmate, colleague and business partner, won’t talk to me. Because I made fun of him and his fiancée.\nSaurabh and Prerna will be getting married soon. It is an arranged marriage. However, there is more cheesy romance between them than any love-marriage couple.\nOn Karva Chauth, she fasted for him. She didn’t eat all day. In the evening, she called him and waited on the terrace for the moon and for Saurabh to break her fast. Excited, Saurabh ran up the steps of her three-storey house. But when he reached...\nWelcome to One Arranged Murder, an unputdownable thriller from India’s highest-selling author. A story about love, friendship, family and crime, it will keep you entertained and hooked right till the end.",
  "publication": "XYZ",
  "feedback": {
    "user8user8@relix.app": {
      "userId": "user8user8@relix.app",
      "comment": "Book by Chetan Bhagat....",
      "rating": "2",
    }
  },
  "ratings": {
    "1": "150",
    "2": "280",
    "3": "450",
    "4": "570",
    "5": "600",
  },
};
Map<String, dynamic> book10 = {
  "id": "bk-010",
  "bookName": "The Time Traveler's Wife",
  "url": "http://cart.ebalbharati.in/BalBooks/pdfs/101030001.pdf",
  "authorName": "Audrey Niffenegger",
  "category": "ct-004",
  "price": "180",
  "image": "book/book10.jpg",
  "description":
      "This extraordinary, magical novel is the story of Clare and Henry who have known each other since Clare was six and Henry was thirty-six, and were married when Clare was twenty-two and Henry thirty. Impossible but true, because Henry is one of the first people diagnosed with Chrono-Displacement Disorder: periodically his genetic clock resets and he finds himself pulled suddenly into his past or future. His disappearances are spontaneous and his experiences are alternately harrowing and amusing.\n\nThe Time Traveler's Wife depicts the effects of time travel on Henry and Clare's passionate love for each other with grace and humour. Their struggle to lead normal lives in the face of a force they can neither prevent nor control is intensely moving and entirely unforgettable.",
  "publication": "ABC",
  "feedback": {
    "user10user10@relix.app": {
      "userId": "user10user10@relix.app",
      "comment": "Book by Audrey Niffenegger....",
      "rating": "3.5",
    }
  },
  "ratings": {
    "1": "150",
    "2": "280",
    "3": "450",
    "4": "570",
    "5": "600",
  },
};
var bookList = [
  book1,
  book2,
  book3,
  book4,
  book5,
  book6,
  book7,
  book8,
  book9,
  book10
];
Map<String, dynamic> bookMap = {};

Map<String, dynamic> categoryNovel = {
  "id": "ct-001",
  "categoryName": "Novel",
};
Map<String, dynamic> categoryThriller = {
  "id": "ct-002",
  "categoryName": "Thriller",
  "bookList": ["bk-005", "bk-006"],
};
Map<String, dynamic> categoryFictional = {
  "id": "ct-003",
  "categoryName": "Fictional",
};
Map<String, dynamic> categorySciFic = {
  "id": "ct-004",
  "categoryName": "Sci-Fic",
  "bookList": ["bk-002", "bk-007"],
};
Map<String, dynamic> categoryHistorical = {
  "id": "ct-005",
  "categoryName": "Historical",
  "bookList": ["bk-001", "bk-003"],
};
Map<String, dynamic> categoryPoetry = {
  "id": "ct-006",
  "categoryName": "Poetry",
  "bookList": ["bk-004"],
};
Map<String, dynamic> categoryRomance = {
  "id": "ct-007",
  "categoryName": "Romance",
  "bookList": ["bk-006", "bk-009"],
};
Map<String, dynamic> categoryOther = {
  "id": "ct-008",
  "categoryName": "Other",
  "bookList": null,
};
var categoryList = [
  categoryNovel,
  categoryThriller,
  categoryFictional,
  categorySciFic,
  categoryHistorical,
  categoryPoetry,
  categoryRomance,
  categoryOther
];
Map<String, dynamic> category = {};

void addItem(Map<String, dynamic> map, var list) {
  for (var ls in list) {
    map[ls["id"]] = ls;
  }
}

void loadEachHover() {
  loadHoverMap(category, categoryHover);
  loadHover(user["recommendedBook"].length, user["recommendedBook"],
      recommendationHover, "recommendedBook");
  loadHover(bookInfo["trendingBook"].length, bookInfo["trendingBook"],
      trendingHover, "trendingBook");
  loadHover(user["favouriteBook"].length, user["favouriteBook"], favouriteHover,
      "favouriteBook");
  loadHover(user["wishListBook"].length, user["wishListBook"], wishListHover,
      "wishListBook");
  loadHover(user["bookHistory"].length, user["bookHistory"], historyHover,
      "bookHistory");
  loadHoverMap(
    user["booksBought"],
    boughtHover,
  );
  loadHoverMap(
    user["booksRented"],
    rentedHover,
  );
  loadHover(user["personalBooks"].length, user["personalBooks"],
      personalBooksHover, "personalBooks");
}

void loadData() {
  addItem(bookMap, bookList);
  addItem(category, categoryList);
  bookMap.forEach((key, value) {
    favourite[key] = ValueNotifier<bool>(false);
    wishList[key] = ValueNotifier<bool>(false);
  });
  loadEachHover();
}

void loadValues(Map<String, dynamic> user, var currentBook) {
  favourite[currentBook["id"]]!.value = isFavourite(user, currentBook);
  wishList[currentBook["id"]]!.value = isWishList(user, currentBook);
}

void loadHoverMap(var data, var hover) {
  if (data != null && data.length > 0)
    for (var cat in data.values) {
      hover[cat["id"]!] = ValueNotifier<bool>(false);
    }
}

// void loadCategoryBooks(var bookList) {
//   for(var id in bookList) {
//     print("${id} is Category Hover.....");
//     categoryBookHover[id] = ValueNotifier<bool>(false);
//   }
// }

void loadHover(var length, var data, var hover, var type) {
  for (int i = 0; i < length; ++i) {
    hover[data[i]] = ValueNotifier<bool>(false);
  }
  print("$type: ${hover!.length}");
}

void favouriteBook(Map<String, dynamic> user, var currentBook) {
  print("IN favouriteBook");
  final favList = new Queue();
  favList.addAll(user["favouriteBook"].toList());
  if (isFavourite(user, currentBook)) {
    favouriteHover.remove(currentBook["id"]);
    favList.remove(currentBook["id"]);
    favourite[currentBook["id"]] = ValueNotifier<bool>(false);
  } else {
    favList.addLast(currentBook["id"]);
    favouriteHover[currentBook["id"]] = ValueNotifier<bool>(false);
    favourite[currentBook["id"]] = ValueNotifier<bool>(true);
  }
  user["favouriteBook"] = favList.toList();
  // favourite[currentBook["id"]]!.value = !favourite[currentBook["id"]]!.value;
  // for(int i=0; i<favouriteHover.length; ++i)
  // hover = true;
  print("\t ... ${favouriteHover}");
  print("OUT favouriteBook");
}

void wishListBook(Map<String, dynamic> user, var currentBook) {
  print("IN wishListBook");
  var wList = new Queue();
  wList.addAll(user["wishListBook"].toList());
  if (isWishList(user, currentBook)) {
    wishListHover.remove(currentBook["id"]);
    wList.remove(currentBook["id"]);
  } else {
    wList.addLast(currentBook["id"]);
    wishListHover[currentBook["id"]] = ValueNotifier<bool>(false);
  }
  user["wishListBook"] = wList.toList();
  wishList[currentBook["id"]]!.value = !wishList[currentBook["id"]]!.value;
  print("OUT wishListBook");
}

void addToHistory(Map<String, dynamic> user, var currentBook) {
  var historyList = new Queue();
  historyList.addAll(user["bookHistory"].toList());
  if (isHistory(user, currentBook)) {
    historyList.remove(currentBook["id"]);
  }
  historyList.addFirst(currentBook["id"]);
  user["bookHistory"] = historyList;
}

void removeFromHistory(Map<String, dynamic> user, var currentBook) {
  var historyList = new Queue();
  historyList.addAll(user["bookHistory"].toList());
  if (isHistory(user, currentBook)) {
    historyList.remove(currentBook["id"]);
  }
  user["bookHistory"] = historyList;
}

bool isFavourite(Map<String, dynamic> user, var currentBook) {
  var favList = user["favouriteBook"].toList();
  if (favList.contains(currentBook["id"])) {
    return true;
  }
  return false;
}

bool isWishList(Map<String, dynamic> user, var currentBook) {
  var wishList = user["wishListBook"].toList();
  if (wishList.contains(currentBook["id"])) {
    return true;
  }
  return false;
}

bool isHistory(Map<String, dynamic> user, var currentBook) {
  var wishList = user["bookHistory"].toList();
  if (wishList.contains(currentBook["id"])) {
    return true;
  }
  return false;
}

String getCategoryName(String categoryId) {
  if (category.containsKey(categoryId))
    return category[categoryId]["categoryName"];
  return "-";
}

dynamic getBooksList(var bookList, {bool isList = false}) {
  print("${bookList.runtimeType}");
  if (bookList == null || bookList.length == 0) {
    return null;
  }
  var bookData = new Queue();
  for (var id in bookList) {
    if (bookMap.keys.contains(id)) bookData.addLast(bookMap[id]);
  }
  if (bookData.length == 0) {
    return null;
  }
  return bookData.toList();
}

dynamic getBooksMap(var bookList, {bool isList = false}) {
  // print("${bookList.runtimeType}");
  if (bookList == null || bookList.length == 0) {
    return null;
  }
  Map<String, dynamic> bookData = {};
  for (var id in bookList) {
    if (bookMap.keys.contains(id)) bookData[id] = bookMap[id];
  }
  if (bookData.length == 0) {
    return null;
  }
  return bookData;
}

void makeAllHoverOff() {
  for (var favBook in favouriteHover.values) {
    favBook.value = false;
  }
}

bool cameraSource(BuildContext context) {
  if (MediaQuery.of(context).size.width <= 700) {
    return false;
  }
  return true;
}

Future<void> uploadImage(BuildContext context, File photo) async {
  Navigator.of(context).pop();
  String fileName = photo.path.split('/').last;
  String extension = fileName.split('.').last;
  // var map = {
  //   'name': fileName,
  //   'photo': await MultipartFile.fromFile(
  //     photo.path,
  //     filename: fileName,
  //     // contentType: new MediaType("image", extension),
  //   ),
  // };
  // FormData formData = new FormData.fromMap(map,);
  // var response = await dio.put(
  //     uploadUserProfilePhotoURL,
  //     data: formData,
  //     options: Options(headers: {"token": widget.jwt_token}));
  // if(response.data['success'])
  // {
  //   await getUserProfile(widget.u_id, widget.jwt_token);
  // }
}

Future<void> chooseImage(BuildContext context, bool imageSource) async {
  cameraSource(context) ? () {} : Navigator.of(context).pop();
  // File _image;
  dynamic _image;
  final pickedFile = await ImagePicker()
      .getImage(source: imageSource ? ImageSource.camera : ImageSource.gallery);
  if (pickedFile != null) {
    _image = File(pickedFile.path);
    uploadImage(context, _image);
  } else {
    _image = null;
  }
}

// void printHover(var bookHover) {
//   print("bookHover: ${bookHover}");
//   for(var key in bookHover.keys)
//     print("\t ${key}: ${bookHover[key]}");
// }

String loadBookTooltip(String id) {
  String userBookDetails = "";
  userBookDetails = isRented(id)
      ? "Rented on: ${user["booksRented"][id]["rentedOn"]}\Due on: ${user["booksRented"][id]["dueOn"]}\n"
      : "Rented on: Not Yet\n";
  userBookDetails += "\n";
  userBookDetails += isPurchased(id)
      ? "Purchased on: ${user["booksBought"][id]["purchasedOn"]}"
      : "Purchased on: Not Yet";
  return userBookDetails;
}

isRented(String id) {
  return user["booksRented"]!.keys.contains(id);
}

isPurchased(String id) {
  return user["booksBought"]!.keys.contains(id);
}
