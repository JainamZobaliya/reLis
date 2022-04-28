var User = require('../models/user');
var Book = require('../models/books');
var AudioBook = require('../models/audioBooks');
var BookImage = require('../models/images');
var jwt = require('jwt-simple');
var config = require('../config/dbconfig');
const actions = require('../methods/actions');
const {spawn} = require('child_process');
const request = require('request');
const { Console } = require('console');
const { type } = require('os');
const utf8 = require('utf8');
const path = require('path');
var fs = require('fs');
const { PDFNet } = require('@pdftron/pdfnet-node');
const axios = require('axios');
// const fetch = require('node-fetch');
const schedule = require('node-schedule');
const rule = new schedule.RecurrenceRule();
rule.dayOfWeek = [0, 4];
rule.second = new schedule.Range(0, 59, 5);
rule.hour = 8;
rule.minute = 0;
 // Sunday and Thursday at 8 am
const job = schedule.scheduleJob(rule, async function(){
  var dueMap = await getRentInfo();
//   console.log("dueMap: ");
//   console.log(dueMap);
  var bookNameList = [];
  var bookNameBody = "";
  Object.keys(dueMap).map(async function(userId, index) {
    // console.log(dueMap[userId].length);
    // console.log(userId);
    bookList = dueMap[userId];
    for(var bookId of bookList) {
        bookName = await getBookName(bookId);
        console.log(bookName);
        if(bookName!="")
            bookNameList.push(bookName);
        if(bookNameList.length > 0){
            bookNameBody = bookNameBody+ ",\n" + bookName;
        }
        else
            bookNameBody = bookName;
            
    }
    // console.log(bookNameBody);
    await sendEmail(userId, "Book Due Soon!!!", "Dear user - "+userId+",\nThe following books"+bookNameBody+" rented by you are going to expire soon!! Visit ReLis App and buy the book to continue your reading experience.");
  });

});

async function getBookName(bookId) {
    var bookName = "";
    await Book.findOne(
        {
            id: bookId
        },
        async function (err, book) {
            if (err) {
                bookName = "";
                console.log('getBookName Error: ', err);
            }
            if (!book) {
                console.log('Book not found!!');
                bookName = "";
            }
            else {
                bookName = book.bookName;
            }
        }
    );  
    return bookName;
}

async function getRentInfo() {
    var dueMap = {};
    await User.find({} , (err, users) => {
        if(err)
            console.log("getRentInfo Error: ", err);
        users.map(user => {
            var currentUser = user.emailId;
            // console.log("currentUser is: ", currentUser);
            var now = Date.now();
            if(user.booksRented.size>0) {
                for( var bookId of user.booksRented.keys()) {
                    var book = user.booksRented.get(bookId)
                    var due = new Date(book["dueOn"])
                    let diffTime = due - now;
                    var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
                    if(diffDays>0) {
                        // console.log("\t DueDate not came yet");
                        if(dueMap[currentUser] != undefined && dueMap[currentUser].length>0) {
                            var bookList = dueMap[currentUser];
                            bookList.push(bookId);
                            dueMap[currentUser] = bookList;
                        }
                        else {
                            dueMap[currentUser] = [bookId];
                        }
                    }
                    else {
                        // console.log("\t DueDate Passed");
                    }
                }
            }
        })
    })
    return dueMap;
}

async function sendEmail(emailId, subject, body) {
    const service_id = 'service_xd6ttln';
    const template_id = 'template_w7cy5tq';
    const user_id = 'user_ZeaSCRhRLjK9oAEB6moy6';
    // const subject = subject;
    const from_email = 'dev.vora@somaiya.edu';
    const from_name = 'ReLis Team';
    const to_email = emailId;
    const reply_to = 'dev.vora@somaiya.edu';
    var emailBody = body + "\nThanks And Regards,\n"+from_name+".";
    const url = "https://api.emailjs.com/api/v1.0/email/send";
    const headers = {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
    };
    await axios.post(url, {
            'service_id': service_id,
            'template_id': template_id,
            'user_id': user_id,
            'template_params': {
                'subject': subject,
                'from_email': from_email,
                'to_email': to_email,
                'from_name': from_name,
                'reply_to': reply_to,
                'body': emailBody
            },
        },{
            headers: headers,
        }
    ).then(res => {
    }).catch(error => {
        console.error("sendEmail error: ", error)
    });
  }

async function sleep(ms) {
    return new Promise((resolve) => this.setTimeout(resolve, ms));
}

async function replaceWithTranslatedText(page, replacer, translateTo, reqCount) {
    const txt = await PDFNet.TextExtractor.create();
    const rect = await page.getCropBox()
    // const rect = new PDFNet.Rect(0,0,612,794);
    txt.begin(page, rect);
    text = await txt.getAsText();
        wordCounter = await txt.getWordCount();
        console.log("wordCounter: ");
        console.log(wordCounter);
    var textList = text.split(/[,.;:]/);
    var tt = "";
    var originalText = "";
    var wordTimer = 0;
    for(var i=0; i<textList.length; ++i){
        var textToBeTranslated = textList[i]+ ". ";
        while(textToBeTranslated.length<500 && i+1!=textList.length && (textList[i+1].length+textToBeTranslated.length)<498){
            textToBeTranslated = textToBeTranslated + textList[++i] + ". "
        }
        if(reqCount>=20){
            console.log("...Sleeping for "+(60000)+" ms");
            // this.clearInterval(timer1)
            var t = await sleep(60000);
            // sleep((min - wordTimer));
            wordTimer = 0;
            reqCount = 0;
            console.log("Back from Sleeping...");
        }
        var timer1 = setInterval(
            function() {  
                ++wordTimer
            }, 
            60000
        );  
        translatedText = await translateText(textToBeTranslated, translateTo, reqCount);
        reqCount++;
        originalText = originalText+textToBeTranslated+".\n"
        tt = tt+translatedText+".\n"
    }
    // console.log("reqCount: "+reqCount);
    // console.log("\t\toriginalText: ");
    // console.log(originalText);
    // console.log("\t\ttranslatedText: ");
    // console.log(tt);
    // await replacer.setMatchStrings("", "");
    // await replacer.addText(rect, tt);
    // await replacer.addString(originalText, translatedText);
    await replacer.process(page);
    // const text = txt.getAsText();
    // Extract words one by one.
    // let line = await txt.getFirstLine();
    // translatedLine = "";
    // word = await line.getFirstWord()
    // var wordTimer = 0;
    // var min = 1 * 60 * 1000;
    // for (; (await line.isValid()); line = (await line.getNextLine())) 
    // {
    //     // translatedLine = await gTranslateText(line, "es");
    //     // replacer.addString(line, translatedLine);
    //     console.log(line)
    //     for (word = await line.getFirstWord(); (await word.isValid()); word = (await word.getNextWord())) 
    //     {
    //         originalWord = await word.getString();
    //         if(wordCount>=20){
    //             console.log("Sleeping for "+(60000)+" ms");
    //             // this.clearInterval(timer1)
    //             var t = await sleep(60000);
    //             // sleep((min - wordTimer));
    //             wordTimer = 0;
    //             wordCount = 0;
    //             console.log("Back from Sleeping...");
    //         }
    //         var timer1 = setInterval(
    //             function() {  
    //                 ++wordTimer
    //             }, 
    //             min
    //         );  
    //         translatedWord = await translateText(originalWord, translateTo, wordCount);
    //         await replacer.addString(originalWord, translatedWord);
    //         ++wordCount;
    //         // console.log(originalWord, " - ", translatedWord)
    //     }
    // }
    result = {};
    result["originalText"] = originalText;
    result["translatedText"] = tt;
    result["reqCount"] = reqCount;
    result["rect"] = rect;
    return result;
}

async function translateText(originalText, translateTo, wordCount) {
    console.log("In translateText - ", wordCount)
    translatedText = originalText;
    // const res = await fetch("https://libretranslate.com/translate", {
    //     method: "POST",
    //     body: JSON.stringify({
    //         q: originalText,
    //         source: "en",
    //         target: translateTo,
    //         format: "text"
    //     }),
    //     headers: { "Content-Type": "application/json" }
    // }).then(
    //     res => {
    //         console.log("res: ", res.json())
    //         console.log("Out translateText")
    //         return originalText;
    //     }
    // ).catch(
    //     (error) => console.log("translateText error: ", error)
    // );
    // const res = await request.post(
    //     'https://libretranslate.com/translate', {
    //         json: { 
    //             q: originalText,
    //             source: "en",
    //             target: translateTo,
    //             format: "text"
    //         }
    //     },
    //     function (error, response, body) {
    //         if(error)
    //             console.log(error)
    //         if (!error && response.statusCode == 200) {
    //             console.log(body);
    //         }
    //     }
    // );
    const res = await axios.post('https://libretranslate.de/translate', {
            q: originalText,
            source: "en",
            target: translateTo,
            format: "text"
        },
    ).then(res => {
        translatedText = res.data.translatedText
    }).catch(error => {
        console.error("translateText error: ", error)
    })
    return translatedText
    // console.log(await res.json());
    // console.log(translatedText);
}

function bookRecommendation(userId, req, res) {
    console.log("")
    console.log("")
    console.log("")
    console.log("userId: "+userId)
    // console.log("books: "+books)
    console.log("")
    console.log("")
    result = []
    error = []
    // listy = [1,2,3,4,5,6]
    const childPython = spawn('python', ['./models/mongoDB_bookRecommendation.py', userId]);
    // const childPython = spawn('python', ['./models/book_recommendation.py','Jainam',books]);
    // const childPython = spawn('python', ['./models/recommendation.py','Jainam',data.toString()]);
    childPython.stdout.on('data', function(data) {
        console.log(data.toString());
    });
    childPython.stdout.on('data', (data)=>{
        console.log("...stdout: ", data.toString());
        if(!result.includes(data)) {
            console.log("...Data pushed in result is: ", data.toString());
            result.push(data.toString())
        }
    });
    childPython.stderr.on('data', (data)=>{
        console.error("...stderr: ", data.toString());
        if(!error.includes(data)) {
            console.log("...Data pushed in error is: ", data.toString());
            error.push(data.toString())
        }
    });
    childPython.stdout.on('end', function(){
        console.log("...Sum of numbers=",dataString);
    });
    childPython.on('close', (code)=>{
        console.log("...Child Process exited with code: ", code.toString());
        return res.json({success: true, msg: 'Got Recommended Books', result: result, error: error})
    });
}

function getRatingsKey(rating) {
    switch(rating) {
        case 0 :
            return "rate0";
        case 0.5 :
            return "rate005";
        case 1 :
        case 1.0 :
            return "rate1";
        case 1.5 :
            return "rate105";
        case 2 :
        case 2.0 :
            return "rate2";
        case 2.5 :
            return "rate205";
        case 3 :
        case 3.0 :
            return "rate3";
        case 3.5 :
            return "rate305";
        case 4 :
        case 4.0 :
            return "rate4";
        case 4.5 :
            return "rate405";
        case 5 :
        case 5.0 :
            return "rate5";
    }
}

async function addBookFeedback(req, res) {
    var bookId = req.body['bookId']
    var emailId = req.body['emailId']
    var comment = req.body['comment']
    var rating = req.body['rating']
    if ((!emailId) || (!bookId) || (!comment) || (!rating)) {
        res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
    }
    else { 
        rating = parseFloat(rating)
        bookMap = {
            "userId": emailId,
            "comment":  comment,
            "rating":  rating,
        };
        console.log("BookMap: ", bookMap)
        await Book.findOne(
            {
                id: bookId
            },
            async function (err, book) {
                if (err) throw err
                if (!book) {
                    res.status(403).send({success: false, msg: 'Adding Feeback Info. Failed, Book not found!!', body:req.body})
                }
                else {
                    try{
                        // bookFeedMap = book.feedback;
                        var bookFeedMap = {};
                        console.log("book[feedback] ? ",book.hasOwnProperty("feedback"))
                        if(book.hasOwnProperty("feedback") && book.feedback.length>0) {
                            bookFeedMap = book["feedback"];
                            console.log("...before Adding book-feedback: ");
                            console.log(book["feedback"]);
                        }
                        console.log("...Reached Here-1");
                        bookFeedMap = bookMap;
                        console.log("...Reached Here-2");
                        book.feedback = bookFeedMap;
                        console.log("...after Adding book-feedback: ");
                        console.log(book.feedback);
                        console.log("...Reached Here-3");
                        console.log(book.feedback.emailId);
                        var key = getRatingsKey(rating)
                        console.log(key,": ",book["ratings"][key])
                        book["ratings"][key] = book["ratings"][key]+1;
                        console.log(key,": ",book["ratings"][key])
                        await book.save(
                            function(err) {
                                if(!err) {
                                    console.log("... Book-Feeback Added. ");
                                }
                                else {
                                    console.log("... Error: could not add book-feedback. ");
                                    console.log("... Error: ", err);
                                }
                            }
                        );
                    }
                    catch(err) {  
                        res.status(403).send({success: false, msg: 'Error in adding book-feedback', body:req.body})
                    }
                }
            }
        );    
        return;   
        // res.json({success: true, msg: 'Feedback Added Successfully', body:req.body})
    }
}

var functions = {
    addNew: function (req, res) {
        if ((!req.body['firstName']) || (!req.body['lastName']) || (!req.body['emailId']) || (!req.body['password'])) {
            res.status(403).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            var newUser = User({
                firstName: req.body.firstName,
                lastName: req.body.lastName,
                emailId: req.body.emailId,
                password: req.body.password,
                isAdmin: false,
            });
            newUser.save(function (err, newUser) {
                if (err) {
                    res.json({success: false, msg: 'Failed to save'})
                }
                else {
                    res.json({success: true, msg: 'Successfully saved'})
                }
            })
        }
    },
    authenticate: function (req, res) {
        console.log("req.body.emailId: "+req.body.emailId)
        User.findOne(
            {
                emailId: req.body.emailId
            }, 
            function (err, user) {
                if (err) throw err
                if (!user) {
                    res.status(403).send({success: false, msg: 'Authentication Failed, User not found'})
                }
                else {
                    // redirect = req.body.redirect ?? false;
                    if(req.body.redirect == null) {
                        redirect = false
                    }
                    else {
                        redirect = req.body.redirect
                    }
                    console.log("redirect: ", redirect)
                    user.comparePassword(
                        req.body.password,
                        function (err, isMatch) {
                            if (isMatch && !err) {
                                var token = jwt.encode(user, config.secret)
                                res.json({success: true, token: token, user: user})
                            }
                            else {
                                return res.status(403).send({success: false, msg: 'Authentication Failed, Wrong Password'})
                            }
                        },
                        redirect,
                    )
                }
        }
        )
    },
    changePassword: function (req, res) {
        User.findOne(
            {
                emailId: req.body.emailId
            },
            function (err, user) {
                if (err) throw err
                if (!user) {
                    res.status(403).send({success: false, msg: 'Password Changing Failed, User not found', body:req.body})
                }
                else {
                    user.password = req.body.password;
                    user.save();
                    res.json({success: true, msg: 'Password Changed Successfully', body:req.body})
                }
            }
        )
    },
    getUserDetails: function (req, res) {
        var emailId = req.body['emailId']
        var userId = req.body['userId']
        if ((!emailId) || (!userId)) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            User.findOne(
                {
                    emailId: userId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'User not found', body:req.body})
                    }
                    else {
                        userDetails = {}
                        userDetails['emailId'] = user.emailId
                        userDetails['firstName'] = user.firstName
                        userDetails['lastName'] = user.lastName
                        userDetails['imageURL'] = user.imageURL
                        userDetails['feedback'] = user.feedback
                        res.json({success: true, msg: 'User Details Retrieved Successfully', userDetails: userDetails})
                    }
                }
            )
        }
    },
    addBook: function (req, res) {
        // console.log("Got req: ", req.body);
        if ((!req.body['id']) || (!req.body['isbn']) || (!req.body['bookName']) || (!req.body['url']) || (!req.body['authorName']) || (!req.body['publication']) || (!req.body['category']) || (!req.body['price']) || (!req.body['description'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            // console.log("req: ", req);
            var newBook = Book({ 
                id: req.body.id,
                isbn: req.body.isbn,
                bookName: req.body.bookName,
                url: req.body.url,
                category: req.body.category,
                authorName: req.body.authorName,
                publication: req.body.publication,
                price: req.body.price,
                image: req.file,
                description: req.body.description,
                feedback: req.body.feedback,
                noOfChapters: req.body.noOfChapters,
                language: req.body.language,
                ratings: req.body.ratings,
                imagePath: req.file.path,
                imageSize: req.file.size,
                imageName: req.file.filename,
                // bookFile: req.file.bookFile,
            });
            // console.log("newBook: ",newBook);
            newBook.save(function (err, newBook) {
                if (err) {
                    res.json({success: false, msg: 'Failed to add book'})
                }
                else {
                    res.json({success: true, msg: 'Book Successfully added'})
                }
            })
        }
    },
    addPersonalBooks: function (req, res) {
        console.log("Got req: ");
        console.log(req.body);
        var emailId = req.body['emailId']
        var personalBook = req.body['personalBook']
        if ((!emailId) || (!personalBook)) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            // console.log("req: ", req);
            var newBook = PersonalBook({ 
                id: personalBook.id,
                isbn: personalBook.isbn,
                bookName: personalBook.bookName,
                url: personalBook.url,
                category: personalBook.category,
                authorName: personalBook.authorName,
                publication: personalBook.publication,
                price: personalBook.price,
                image: req.file,
                description: personalBook.description,
                feedback: personalBook.feedback,
                noOfChapters: personalBook.noOfChapters,
                language: personalBook.language,
                ratings: personalBook.ratings,
                imagePath: req.file.path,
                imageSize: req.file.size,
                imageName: req.file.filename,
                bookFile: req.bookFile,
                // bookFile: req.file.bookFile,
            });
            var bookWriteFailed = false;
            fs.writeFile("../assets/personalBooks/"+personalBook.id+'.pdf', newBook.bookFile, function (err) {
                if (err) {
                    bookWriteFailed = true;
                    throw err;
                };
                console.log('Saved!');
            });
            // console.log("newBook: ",newBook);
            if(bookWriteFailed) {
                res.json({success: false, msg: 'Failed to add perosnal book'})
            }
            newBook.save(function (err, newBook) {
                if (err) {
                    res.json({success: false, msg: 'Failed to add perosnal book'})
                }
                else {
                    res.json({success: true, msg: 'Personal Book Successfully added'})
                }
            })
        }
    },
    getBookDetails: function (req, res) {
        console.log(req.body)
        var bookId = req.body.id
        if((!bookId)) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            Book.findOne({
                id: bookId
                },
                function (err, book) {
                    if (err) throw err
                    if (!book) {
                        res.status(403).send({success: false, msg: 'Book not found'})
                    }
                    else {
                        var dir = path.join(__dirname, "../assets/books/")
                        var imageName = book.imageName
                        dir = path.join(dir,imageName)
                        book["imagePng"] = {
                            data: fs.readFileSync(dir),
                            contentType: 'image/png'
                        }
                        // console.log("imagePng is here: ")
                        // console.log(book["imagePng"])
                        // console.log("Created Book Image")
                        res.json({success: true, book: book})
                    }
                }
            )
        }
    },
    getAllBooks: async function (req, res) {
        var books = []
        await Book.find().then(
            book => {
                if (!book) {
                    return res.status(403).send({success: false, msg: 'Book retrieving error'})
                }
                else {
                    console.log("book.toString: "+book);
                    books = book
                }
            }
        ).catch(error => {
            console.log(error);
        })
        if(books.length>0) {
            return res.json({success: true, books: books})
        }
        return res.status(403).send({success: false, msg: 'Book not found'})
    },
    getBookImage: async function (req, res) {
        var bookId = req.body.bookId
        if((!bookId) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            await Book.findOne({
                    id: bookId,
                }).then(
                book => {
                    if (!book) {
                        return res.status(403).send({success: false, msg: 'BookImage retrieving error'})
                    }
                    else {
                        var dir = path.join(__dirname, "../assets/books/")
                        var imageName = book.imageName
                        dir = path.join(dir,imageName)
                        var options = {
                            root: dir
                        };
                        imagePng = {
                            data: fs.readFileSync(dir),
                            contentType: 'image/png'
                        }
                        res.json({success: true, msg: 'BookImage retrieved', bookId: bookId, imagePng: imagePng});
                    }
                }
            ).catch(
                error => {
                    console.log(error);
                }
            )
        }
    },
    getImage: async function (req, res) {
        var imageType = req.body.imageType
        if(!imageType) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            imageTypeList = ["signUpImage", "signInImage", "relisGif", "ReLis"];
            if (imageTypeList.indexOf(imageType) == -1) {
                return res.status(403).send({success: false, msg: 'Image retrieving error'})
            }
            else {
                var dir = path.join(__dirname, "../assets/images/")
                var imageExt = imageType == "relisGif" ? '.gif' : '.png'
                var imageName = imageType + imageExt
                dir = path.join(dir,imageName)
                imagePng = {
                    data: fs.readFileSync(dir),
                    contentType: imageType == "relisGif" ? 'image/gif' : 'image/png'
                }
                console.log("Image - ", imageName, "sent", imagePng["data"].length);
                res.json({success: true, msg: 'Image retrieved', imagePng: imagePng});
            }
        }
    },
    getRecommendBook: async function (req, res) {
        userId = req.body["userId"]
        console.log("...userId: "+userId)
        console.log("...getRecommendBook-1");
        data = [1,2,3,4,5,6,7,8,9]
        dataString = 'No Xata'
        // let url = "http://localhost:3000/getAllBooks"
        // let options = {json: true}
        // var books = []
        // request.post({
        //     url: url,
        //     options: options,
        //   }, function(error, response, body){
        //     if (error) {
        //         console.log(error)
        //         return res.status(404).send({ success: false, msg: 'Error While fetching books', error: error })
        //     };

        //     if (!error && response.statusCode == 200) {
        //         console.log("body: "+ body)
        //         data = body
        //         dataType = typeof(data)
        //         // console.log("Received Data: " + data)
        //         console.log("Received Data DataType: " + dataType)
        //         var book = dict(subString.split("=") for subString in data.split(";"))
        //         // var book = JSON.parse(data);
        //         // console.log("Received book: " + book)
        //         console.log("Received book datatype: " + type(book))
        //         console.log("Received book.length: " + book.length)
        //         books = []
        //         // console.log("Received Books DataType: " + typeof(obj.books[0]))
        //         // let i=0
        //         // console.log("Received obj books: " + obj.books)
        //         // console.log("Received obj books.length: " + obj.books.length)
        //         // for(let i = 0; i < obj.books.length; i++)
        //         // {
        //         //     book = obj.books[0]
        //         //     console.log("Converting : "+i+" "+book)
        //         //     booky = JSON.parse(book)
        //         //     books.push(booky)
        //         //     console.log("Adding book no.: "+i+" "+booky)
        //         //     ++i
        //         // }
        //         // console.log("Received Books DataType: " + typeof(obj.books))
        //         // console.log("Received obj.books: " + obj.books)
        //         // books = JSON.parse(obj.books)
        //         // console.log("Received Books: " + books)
        //         // dataType = typeof(books)
        //         // console.log("Received Books DataType: " + dataType)
        //         // var val;
        //         // for (let key of Object.keys(data)) {
        //         //     if(key=="books") {
        //         //         val = data[key];
        //         //         // console.log(val[0][0]);
        //         //     }
        //         // }
        //         // for (let i = 0; i < val[0].length; i++) {
        //         //     console.log("Adding book no.: "+i+" "+val[0][i])
        //         //     books.push(val[0][i])
        //         // }
        //         // bookRecommendation(JSON.parse(books), userId)
        //         // return res.json({success: true, msg: 'Got Recommended Books', books: books})
        //         res.json({})
        //     };
        // });
        // var books = []
        // await Book.find().then(
        //     book => {
        //         if (!book) {
        //             return res.status(403).send({success: false, msg: 'Book retrieving error'})
        //         }
        //         else {
        //             // console.log("book.toString: "+book)
        //             books.push(book)
        //         }
        //     }
        // ).catch(error => {
        //     console.log(error);
        // })
        // if(books.length==0) {
        //     return res.status(403).send({success: false, msg: 'No Books found'})
        // }
        bookRecommendation(userId, req, res)
        
    },
    addBookImage: function (req, res) { 
        if ((!req.body['bookId']) || (!req.body['imageId']) || (!req.body['bookName']) || (!req.file)) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            console.log("fileName:")
            console.log(req.file)
            var bookImage = BookImage({
                bookId: req.body.bookId,
                imageId: req.body.imageId,
                bookName: req.body.bookName,
                desc: req.body.desc,
                img: req.file,
                imagePath: req.file.path,
                imageSize: req.file.size,
                imageName: req.file.filename
            })
            console.log("Saving:")
            bookImage.save(function (err, bookImage) {
                if (err) {
                    res.json({success: false, msg: 'Failed to add book image', err: err})
                }
                else {
                    res.json({success: true, msg: 'Book Image Successfully added'})
                }
            })
            console.log("Saved")
        }
    },
    addToFavourites: function(req, res) {
        if ((!req.body['bookId']) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Adding To Favourites Failed', body:req.body})
                    }
                    else {
                        user.favouriteBook.push(req.body.bookId);
                        user.save();
                        res.json({success: true, msg: 'Book Added to Favourites Successfully', favouriteBook: user.favouriteBook})
                    }
                }
            )
        }
    },
    removeFromFavourites: function(req, res) {
        if ((!req.body['bookId']) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Removing From Favourites Failed', body:req.body})
                    }
                    else {
                        user.favouriteBook.pull(req.body.bookId);
                        user.save();
                        res.json({success: true, msg: 'Removed Book From Favourites Successfully', favouriteBook: user.favouriteBook})
                    }
                }
            )
        }
    },
    addToWishList: function(req, res) {
        if ((!req.body['bookId']) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Adding To WishList Failed', body:req.body})
                    }
                    else {
                        user.wishListBook.push(req.body.bookId);
                        user.save();
                        res.json({success: true, msg: 'Book Added to WishList Successfully', wishListBook: user.wishListBook})
                    }
                }
            )
        }
    },
    removeFromWishList: function(req, res) {
        if ((!req.body['bookId']) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Removing From WishList Failed', body:req.body})
                    }
                    else {
                        user.wishListBook.pull(req.body.bookId);
                        user.save();
                        res.json({success: true, msg: 'Removed Book From WishList Successfully', wishListBook: user.wishListBook})
                    }
                }
            )
        }
    },
    updateCart: function(req, res) {
        if ((!req.body['cartMap']) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Updating Cart Info Failed, User not found', body:req.body})
                    }
                    else {
                        try{
                            // console.log("emailId: ",req.body.emailId)
                            cartMap = JSON.parse(req.body.cartMap)
                            // toBuy = cartMap["toBuy"]
                            // toRent = cartMap["toRent"]
                            user.cart = cartMap;
                            // user.cart.toBuy = toBuy;
                            // user.cart.toRent = toRent;
                            // user.save();
                            user.save(function(err) {
                                if(!err) {
                                    console.log("... Cart Updated. ");
                                }
                                else {
                                    console.log("... Error: could not update user. ");
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in organising cart', body:req.body})
                        }
                        res.json({success: true, msg: 'Cart Updated Successfully', body:req.body})
                    }
                }
            )
        }
    },
    buyBooks: function(req, res) {
        if ((!req.body['cartMap']) || (!req.body['booksBoughtMap']) || (!req.body['booksRentedMap']) || (!req.body['emailId'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Buying Books Failed, User not found', body:req.body})
                    }
                    else {
                        try{
                            cartMap = JSON.parse(req.body.cartMap)
                            booksBoughtMap = JSON.parse(req.body.booksBoughtMap)
                            booksRentedMap = JSON.parse(req.body.booksRentedMap)
                            user.cart = cartMap;
                            user.booksBought = booksBoughtMap;
                            user.booksRented = booksRentedMap;
                            booksBoughtMap = Object.keys(booksBoughtMap);
                            booksRentedMap = Object.keys(booksRentedMap);
                            console.log("\n\n\n ");
                            console.log("\n booksRentedMap: ",booksRentedMap);
                            console.log("\n booksBoughtMap: ",booksBoughtMap);
                            console.log("\n\n\n ");
                            for(let i=0; i<booksRentedMap.length; ++i) {
                                let bookId = booksRentedMap[i];
                                console.log("\tbookId: ",bookId);
                                Book.findOne(
                                    {
                                        id: bookId
                                    },
                                    function(err, book) {
                                        var userId = req.body.emailId
                                        if(err) throw err
                                        if(!book) {
                                            res.status(403).send({success: false, msg: 'Buying Books Failed, Book not found', body:req.body})
                                        }
                                        else {
                                            var rentedByMap = book.rentedBy;
                                            if(!rentedByMap.includes(bookId)) {
                                                rentedByMap.push(userId)
                                            }
                                            console.log("rentedByMap: ",rentedByMap)
                                            book.rentedBy = rentedByMap;
                                            book.save(
                                                function(err) {
                                                    if(!err) {
                                                        console.log("... Books Bought. ");
                                                    }
                                                    else {
                                                        console.log("... Error: could not buy books. ");
                                                    }
                                                }
                                            );
                                        }
                                    }
                                );
                            }
                            for(let i=0; i<booksBoughtMap.length; ++i) {
                                let bookId = booksBoughtMap[i];
                                console.log("bookId: ",bookId);
                                Book.findOne(
                                    {
                                        id: bookId
                                    },
                                    function(err, book) {
                                        var userId = req.body.emailId
                                        if(err) throw err
                                        if(!book) {
                                            res.status(403).send({success: false, msg: 'Buying Books Failed, Book not found', body:req.body})
                                        }
                                        else {
                                            var boughtByMap = book.boughtBy;
                                            if(!booksBoughtMap.includes(bookId)) {
                                                boughtByMap.push(userId)
                                            }
                                            book.boughtBy = boughtByMap;
                                            console.log("boughtByMap: ",boughtByMap)
                                            book.save(
                                                function(err) {
                                                    if(!err) {
                                                        console.log("... Books Bought. ");
                                                    }
                                                    else {
                                                        console.log("... Error: could not buy books. ");
                                                    }
                                                }
                                            );
                                        }
                                    }
                                );
                            }
                            user.save(function(err) {
                                if(!err) {
                                    console.log("... Books Bought. ");
                                }
                                else {
                                    console.log("... Error: could not buy books. ");
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in buying books', body:req.body})
                        }
                        res.json({success: true, msg: 'Books Bought Successfully', body:req.body})
                    }
                }
            )
        }
    },
    changeLastPageRead: function(req, res) {
        if ((!req.body['booksReadMap']) || (!req.body['emailId']) || (!req.body['dailyRecordsMap'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Updating Last Page Read Info. Failed, User not found', body:req.body})
                    }
                    else {
                        try{
                            booksReadMap = JSON.parse(req.body.booksReadMap)
                            dailyRecordsMap = JSON.parse(req.body.dailyRecordsMap)
                            user.booksRead = booksReadMap;
                            user.dailyRecords = dailyRecordsMap;
                            user.save(function(err) {
                                if(!err) {
                                    console.log("... Updated Last Page Read Info. ");
                                }
                                else {
                                    console.log("... Error: could not update last page read info. ");
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in Updating Last Page Read Info.', body:req.body})
                        }
                        res.json({success: true, msg: 'Updated Last Page Read Info. Successfully', body:req.body})
                    }
                }
            )
        }
    },
    changeDailyRecords: function(req, res) {
        if ((!req.body['emailId']) || (!req.body['dailyRecordsMap'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Updating Daily Records Failed, User not found', body:req.body})
                    }
                    else {
                        try{
                            dailyRecordsMap = JSON.parse(req.body.dailyRecordsMap)
                            user.dailyRecords = dailyRecordsMap;
                            user.save(function(err) {
                                if(!err) {
                                    console.log("... Updated Daily Records Info. ");
                                }
                                else {
                                    console.log("... Error: could not update Daily Records info. ");
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in Updating Daily Records Info.', body:req.body})
                        }
                        res.json({success: true, msg: 'Updated Daily Records Info. Successfully', body:req.body})
                    }
                }
            )
        }
    },
    changeHistory: function(req, res) {
        if ((!req.body['emailId']) || (!req.body['historyMap'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Updating Daily Records Failed, User not found', body:req.body})
                    }
                    else {
                        try{
                            historyMap = JSON.parse(req.body.historyMap)
                            user.bookHistory = historyMap;
                            user.save(function(err) {
                                if(!err) {
                                    console.log("... Users Reading History Info. Updated");
                                }
                                else {
                                    console.log("... Error: could not update Users Reading History Info. ");
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in Updating Users Reading History Info.', body:req.body})
                        }
                        res.json({success: true, msg: 'Updated Users Reading History Info. Successfully', body:req.body})
                    }
                }
            )
        }
    },
    addReward: function(req, res) {
        if ((!req.body['dailyRecords']) || (!req.body['emailId']) || (!req.body['credits'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            User.findOne(
                {
                    emailId: req.body.emailId
                },
                function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Updating Cart Info Failed, User not found', body:req.body})
                    }
                    else {
                        try{
                            dailyRecords = JSON.parse(req.body.dailyRecords)
                            user.dailyRecords = dailyRecords;
                            user.credits = req.body.credits;
                            user.save(function(err) {
                                if(!err) {
                                    console.log("... Daily Login Details Updated. ");
                                }
                                else {
                                    console.log("... Error: could not update Daily Login Details. ");
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in organising cart', body:req.body})
                        }
                        res.json({success: true, msg: 'Cart Updated Successfully', body:req.body})
                    }
                }
            )
        }
    },
    addAudioBook: function (req, res) {
        if ((!req.body['id']) || (!req.body['bookId']) || (!req.body['audioBookMaxDuration']) || (!req.body['audioBookURL']) || (!req.body['audioBookChapterName'])) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
            var filePath = 'assets/audioBooks/'+req.body.bookId+'/'+req.body.id+'.mp3'
            var newAudioBook = AudioBook({ 
                id: req.body.id,
                bookId: req.body.bookId,
                audioBookMaxDuration: req.body.audioBookMaxDuration,
                audioBookURL: req.body.audioBookURL,
                audioBookChapterName: req.body.audioBookChapterName,
                audioBookPath: req.file.path,
                audioBookSize: req.file.size,
                audioBookName: req.file.filename,
            });
            newAudioBook.save(function (err, newAudioBook) {
                if (err) {
                    res.json({success: false, msg: 'Failed to add Audio-Book'})
                }
                else {
                    res.json({success: true, msg: 'Audio-Book Successfully added'})
                }
            })
        }
    },
    getBookFile: function (req, res) {
        console.log("...getBookFile body: ", req.body)
        var bookId = req.body.bookId
        var userId = req.body.emailId
        if((!bookId) || (!userId)) {
            res.status(404).send({
                success: false,
                msg: 'Enter all fields',
                body: req.body
            })
        }
        else {
            Book.find({
                id: bookId
                },
                function (err, book) {
                    if (err) throw err
                    else if (!book) {
                        res.status(403).send({success: false, msg: 'Book not found'})
                    }
                    else {
                        var dir = path.join(__dirname, "../assets/books/"+bookId+".pdf")
                        console.log("...dir: ", dir)
                        bookFile = {
                            data: fs.readFileSync(dir),
                            contentType: 'application/pdf'
                        }
                        res.json({success: true, msg: 'BookFile retrieved', bookId: bookId, bookFile: bookFile});
                        // const bookStream = fs.createReadStream(dir)
                        // console.log("book: ", bookStream)
                        // bookStream.pipe(res)
                    }
                }
            )
        }
    },
    translateBookFile: async function (req, res) {
        console.log("...translateBookFile body: ", req.body)
        var bookId = req.body["bookId"]
        var userId = req.body["userId"]
        var translateTo = req.body["translateTo"]
        // if(false) {
        if((!bookId) || (!userId) || (!translateTo)) {
            res.status(404).send({
                success: false,
                msg: 'Enter all fields',
                body: req.body
            })
        }
        else {
            Book.find({
                id: bookId
                },
                async function (err, book) {
                    if (err) throw err
                    else if (!book) {
                        res.status(403).send({success: false, msg: 'Book not found'})
                    }
                    else {
                        var filePath = path.join(__dirname, "../assets/books/")
                        var dir = path.join(filePath, bookId+".pdf")
                        console.log("...dir: ", dir)
                        bookData = ""
                        // bookFile = fs.readFileSync(dir)
                        // pdfUtil.pdfToText(dir,function(err, data) {
                        //     if (err) throw(err); 
                        //     bookData = data; //print text    
                        //     res.json({success: true, msg: 'BookFile retrieved', bookId: bookId, bookData: bookData});
                        // });

                        // pdfParse(bookFile).then(function (data) {
                        //     bookData = data.text
                        //     res.json({success: true, msg: 'BookFile retrieved', bookId: bookId, bookData: bookData});
                        // })
                        await PDFNet.initialize("demo:1649515536848:7bdef7ad03000000006f3917e290cc19d4b0cfdd79fde3a10df92acff6");  
                        const pdfDoc = await PDFNet.PDFDoc.createFromFilePath(dir);
                        await pdfDoc.initSecurityHandler()
                        const replacer = await PDFNet.ContentReplacer.create();
                        const pageCount = await pdfDoc.getPageCount();
                        console.log("pageCount is ");
                        console.log(pageCount)
                        // res.json({success: true, msg: 'Translation Request of '+bookId+' received.\nWe\'ll notify you once the book gets translated!!!', bookId: bookId,});
                        var reqCount = 0;
                        // var wordTimer = 0;
                        var docContent = "";
                        for(var i=1; i<=pageCount; ++i) {
                            const page = await pdfDoc.getPage(i);
                            const txt = await PDFNet.TextExtractor.create();
                            const rect = await page.getCropBox()
                            // const rect = new PDFNet.Rect(0,0,612,794);
                            txt.begin(page, rect);
                            text = await txt.getAsText();
                            docContent = docContent + text+"\n";
                            // if(reqCount>=20){
                            //     console.log("Sleeping for "+(60000)+" ms");
                            //     // this.clearInterval(timer1)
                            //     var t = await sleep(60000);
                            //     // sleep((min - wordTimer));
                            //     wordTimer = 0;
                            //     reqCount = 0;
                            //     console.log("Back from Sleeping...");
                            // }
                            // var timer1 = setInterval(
                            //     function() {  
                            //         ++wordTimer
                            //     }, 
                            //     60000
                            // );  
                            // result = await replaceWithTranslatedText(page, replacer, translateTo, reqCount);
                            // // originalText = result["originalText"];
                            // // translatedText = result["translatedText"];
                            // reqCount = result["reqCount"];
                            // rect = result["rect"];
                            // await replacer.addText(rect, translatedText)
                            // console.log("originalText: ")
                            // console.log(originalText)
                            // console.log()
                            // console.log()
                            // console.log("translatedText: ")
                            // console.log(translatedText)
                            // await replacer.addString(originalText, translatedText);
                            // await replacer.process(page);
                            console.log("\t\tDone Page ",i,"/",pageCount);
                        }
                        // var outputFilePath = filePath + bookId+"_"+translateTo+".pdf"
                        // await pdfDoc.save(outputFilePath, PDFNet.SDFDoc.SaveOptions.e_remove_unused);
                        // replace a text placeholder
                        // await replacer.addString('OrigninalText', 'NewText');
                        // await replacer.process(page);
                        // var subject = "Translation Request is Fulfilled!!";
                        // var body = "Dear user - "+userId+",\nYour translated book is ready!! Visit ReLis App. and enjoy reading the book...";
                        // sendEmail(userId, subject, body)
                        // console.log("\tMail Sent to ", userId);
                        console.log("docContent is loaded");
                        res.json({
                            success: true,
                            msg: 'BookFile Translated',
                            bookId: bookId,
                            pageCount: pageCount,
                            docContent: docContent,
                        });
                    }
                }
            )
        }
    },
    getAudioBook: function (req, res) {
        console.log("body: ", req.body)
        var bookId = req.body.bookId
        var userId = req.body.emailId
        if((!bookId) || (!userId)) {
            res.status(404).send({
                success: false,
                msg: 'Enter all fields',
                body: req.body
            })
        }
        else {
            AudioBook.find({
                bookId: bookId
                },
                function (err, audioBooks) {
                    if (err) throw err
                    if(audioBooks.length == 0) {
                        res.json({success: true, msg: "Audio Book Not Added Yet..."})
                    }
                    else if (!audioBooks) {
                        res.status(403).send({success: false, msg: 'AudioBooks not found'})
                    }
                    else {
                        console.log("audioBooksLength: ", audioBooks.length)
                        res.json({
                            success: true,
                            msg: 'AudioBooks Info retrieved',
                            bookId: bookId,
                            audioBooks: audioBooks
                        });
                    }
                }
            )
        }
    },
    getAudioBookFile: function (req, res) {
        console.log("...getBookFile body: ", req.body)
        var audioId = req.body.audioId
        var bookId = req.body.bookId
        var userId = req.body.emailId
        if((!audioId) || (!userId) || (!bookId)) {
            res.status(404).send({
                success: false,
                msg: 'Enter all fields',
                body: req.body
            })
        }
        else {
            AudioBook.findOne({
                id: audioId
                },
                function (err, audioBook) {
                    if (err) throw err
                    else if (!audioBook) {
                        res.status(403).send({success: false, msg: 'AudioBook not found'})
                    }
                    else {
                        console.log("audioBook: ")
                        console.log(audioBook)
                        var audioBookPath = audioBook.audioBookPath
                        var dir = path.join(__dirname, '..\\'+audioBookPath)
                        console.log("...dir: ", dir)
                        audioFile = {
                            data: fs.readFileSync(dir),
                            contentType: 'audio/mpeg'
                        }
                        res.json({
                            success: true,
                            msg: 'Audio-File retrieved',
                            audioId: audioId,
                            audioFile: audioFile
                        });
                    }
                }
            )
        }
    },
    addFeedback: async function(req, res) {
        var bookId = req.body['bookId']
        var emailId = req.body['emailId']
        var comment = req.body['comment']
        var rating = req.body['rating']
        if ((!emailId) || (!bookId) || (!comment) || (!rating)) {
            res.status(404).send({success: false, msg: 'Enter all fields', body:req.body})
        }
        else { 
            rating = parseFloat(rating);
            var feedMap = {};
            await User.findOne(
                {
                    emailId: emailId
                },
                async function (err, user) {
                    if (err) throw err
                    if (!user) {
                        res.status(403).send({success: false, msg: 'Adding Feeback Info. Failed, User not found!!', body:req.body})
                    }
                    else {
                        try{
                            // feedMap = user.feedback;
                            console.log("user[feedback] ? ",user.hasOwnProperty("feedback"))
                            // if(user.hasOwnProperty("feedback")) {
                            if(Object.keys(user["feedback"]).length>0) {
                                feedMap = user["feedback"];
                            }
                            console.log("...before Adding feedback: ");
                            console.log(feedMap);
                            feedMap[bookId.toString()] = {}
                            feedMap[bookId.toString()]["id"] =  bookId;
                            feedMap[bookId.toString()]["comment"] =  comment;
                            feedMap[bookId.toString()]["rating"] =  rating;
                            user.feedback = feedMap;
                            console.log("...after Adding feedback: ");
                            console.log(user.feedback);
                            await user.save(function(err) {
                                if(!err) {
                                    console.log("... Feeback Added. ");
                                }
                                else {
                                    console.log("... Error: could not add feedback. ");
                                    console.log("... Error: ", err);
                                    res.status(403).send({success: false, msg: 'Error in adding feedback', body:req.body, error: err })
                                }
                            });
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in adding feedback', body:req.body, error: err})
                        }
                    }
                }
            );
            bookMap = {
                "userId": emailId,
                "comment":  comment,
                "rating":  rating,
            };
            console.log("BookMap: ", bookMap)
            var ratings = [];
            var bookFeedMap = {};
            await Book.findOne( 
                {
                    id: bookId
                },
                async function (err, book) {
                    if (err) throw err
                    if (!book) {
                        res.status(403).send({success: false, msg: 'Adding Feeback Info. Failed, Book not found!!', body:req.body})
                    }
                    else {
                        try{
                            // bookFeedMap = book.feedback;
                            console.log("book[feedback] ? ",book.hasOwnProperty("feedback"))
                            if(Object.keys(book["feedback"]).length>0) {
                                bookFeedMap = book["feedback"];
                                console.log("...before Adding book-feedback: ");
                                console.log(bookFeedMap);
                            }
                            try{
                                console.log("in try")
                                console.log(bookFeedMap);
                                // bookFeedMap[emailId.toString()] = {};
                                bookFeedMap.set(emailId.toString(), bookMap );
                                // bookFeedMap.set(emailId.toString(), {} );
                                // bookFeedMap[emailId.toString()]["userId"] = emailId;
                                // bookFeedMap[emailId.toString()]["comment"] = comment;
                                // bookFeedMap[emailId.toString()]["rating"] = rating;
                                // book["feedback"] = bookFeedMap;
                                console.log("...after Adding book-feedback: ");
                                console.log(book["feedback"]);
                                var key = getRatingsKey(rating);
                                ratings = book["ratings"];
                                console.log(key,": ",book["ratings"][key]);
                                ratings[key] = ratings[key]+1;
                                console.log(key,": ",ratings[key]);
                                ratings = book["ratings"];
                            }
                            catch(error){
                                consol.log("Error Due to map: ", error)
                            }
                        }
                        catch(err) {  
                            res.status(403).send({success: false, msg: 'Error in adding book-feedback', body:req.body})
                        }
                    }
                }
            ); 
            console.log(bookFeedMap);
            console.log(ratings);
            await Book.updateOne(
                {
                    id: bookId
                },
                {
                    "feedback": bookFeedMap,
                    "ratings": ratings,
                },
                function (err, user) {
                    if (err){
                        console.log(err)
                    }
                    else{
                        console.log("Updated Feedback");
                    }
                }
            );
            // await addBookFeedback(req, res)
            res.json(
                {
                    success: true,
                    msg: 'Feedback Added Successfully',
                    feedback: bookFeedMap,
                    body:req.body
                }
            )
        }
    },
    getinfo: function (req, res) {
        if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Bearer') {
            var token = req.headers.authorization.split(' ')[1]
            var decodedtoken = jwt.decode(token, config.secret)
            return res.json({success: true, msg: 'Hello ' + decodedtoken.name})
        }
        else {
            return res.json({success: false, msg: 'No Headers'})
        }
    }
}

module.exports = functions