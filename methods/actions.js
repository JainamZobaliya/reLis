var User = require('../models/user')
var Book = require('../models/books')
var BookImage = require('../models/images')
var jwt = require('jwt-simple')
var config = require('../config/dbconfig')
const actions = require('../methods/actions')
const {spawn} = require('child_process');
const request = require('request');
const { Console } = require('console')
const { type } = require('os')
const utf8 = require('utf8')

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
    const childPython = spawn('python', ['./models/mongoDB_bookRecommendation.py','Jainam']);
    // const childPython = spawn('python', ['./models/book_recommendation.py','Jainam',books]);
    // const childPython = spawn('python', ['./models/recommendation.py','Jainam',data.toString()]);
    childPython.stdout.on('data', function(data) {
        console.log(data.toString());
    });
    childPython.stdout.on('data', (data)=>{
        console.log(`stdout: ${data}`);
        if(!result.includes(data)) {
            console.log("Data pushed in result is: ", data.toString());
            result.push(data.toString())
        }
    });
    childPython.stderr.on('data', (data)=>{
        console.error(`stderr: ${data}`);
        if(!error.includes(data)) {
            console.log("Data pushed in error is: ", data.toString());
            error.push(data.toString())
        }
    });
    childPython.stdout.on('end', function(){
        console.log('Sum of numbers=',dataString);
        });
    childPython.on('close', (code)=>{
        console.log(`Child Process exited with code: ${code}`);
        return res.json({success: true, msg: 'Got Recommended Books', result: result, error: error})
    });
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
                password: req.body.password
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
        User.findOne({
            emailId: req.body.emailId
        }, function (err, user) {
                if (err) throw err
                if (!user) {
                    res.status(403).send({success: false, msg: 'Authentication Failed, User not found'})
                }
                else {
                    user.comparePassword(req.body.password, function (err, isMatch) {
                        if (isMatch && !err) {
                            var token = jwt.encode(user, config.secret)
                            res.json({success: true, token: token, user: user})
                            console.log(res.body)
                        }
                        else {
                            return res.status(403).send({success: false, msg: 'Authentication failed, wrong password'})
                        }
                    })
                }
        }
        )
    },
    changePassword: function (req, res) {
        User.findOne({
            emailId: req.body.emailId
        }, function (err, user) {
        if (err) throw err
        if (!user) {
            res.status(403).send({success: false, msg: 'Password Changing Failed, User not found', body:req.body})
        }
        else {
            user.password = req.body.password;
            user.save();
            res.json({success: true, msg: 'Password Changed Successfully', body:req.body})
        }
        })
    },
    addBook: function (req, res) {
        if ((!req.body['id']) || (!req.body['isbn']) || (!req.body['bookName']) || (!req.body['url']) || (!req.body['authorName']) || (!req.body['publication']) || (!req.body['category']) || (!req.body['price']) || (!req.file) || (!req.body['description'])) {
            res.json({success: false, msg: 'Enter all fields', body:req.body})
        }
        else {
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
                ratings: req.body.ratings,
                imagePath: req.file.path,
                imageSize: req.file.size,
                imageName: req.file.filename
            });
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
                    books.push(book)
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
    getRecommendBook: async function (req, res) {
        userId = req.body["userId"]
        console.log("userId: "+userId)
        console.log("getRecommendBook-1");
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