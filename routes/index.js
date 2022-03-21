const express = require('express')
const actions = require('../methods/actions')
const router = express.Router()
const multer = require('multer');
const mongodb = require('mongodb');
var fs = require('fs');
// const uploadFile = require('express-fileupload');

// set up multer for storing uploaded files
// var storage = multer.diskStorage({
//     destination: (req, file, callback) => {
//         callback(null, './assets/books')
//     },
//     filename: (req, file, callback) => {
//         callback(null, req.body.bookId+'.png')
//     }
// });
  
// var upload = multer({ storage: storage });

// var storeBookFile = multer.diskStorage({
//     destination: (req, file, callback) => {
//         callback(null, './assets/books')
//     },
//     filename: (req, file, callback) => {
//         // console.log("...file: ",file.length);
//         // console.log("...file: ",file);
//         // console.log("...mimetype: ",file.mimetype);
//         // // console.log("...req: ",req.file);
//         // const imageMatch = ["image/png", "image/jpeg", "image/jpg"];
//         // const pdfMatch = ["application/pdf", "file/pdf"];
//         // if (imageMatch.indexOf(file.mimetype) === 1) {
//         //     return callback(null, req.body.id+'.png');
//         // }
//         // else if (pdfMatch.indexOf(file.mimetype) === 1) {
//         //     // var file = file;
//         //     file.mv(
//         //         './assets/books',
//         //         req.body.id+'.pdf',
//         //         function(err) {
//         //             if(err) {
//         //                 console.log("Error: ",err)
//         //             }
//         //         }
//         //     );
//         //     return
//         //     // return callback(null, req.body.id+'.pdf');
//         // }
//         // else {
//         //     return
//         // }
//         callback(null, req.body.id+'.png')
//     }
// });
  
// var uploadBookFile = multer({ storage: storeBookFile });
// // var uploadFilesMiddleware = util.promisify(uploadBookFile);
// var fileUploads = uploadBookFile.fields([{ name: 'image', maxCount: 1 }]) //, { name: 'bookFile', maxCount: 1 }])

var storeBookImage = multer.diskStorage({
    destination: (req, file, callback) => {
        callback(null, './assets/books')
    },
    filename: (req, file, callback) => {
        callback(null, req.body.id+'.png')
    }
});
  
var uploadBookImage = multer({ storage: storeBookImage });

const storeAudioBook = multer.diskStorage({
  filename: function (req, file, cb) {
    console.log('filename')
    console.log('1...body: ', req.body)
    console.log('1...file: ', file)
    cb(null, req.body.id+'.mp3')
  },
  destination: function (req, file, cb) {
    console.log('storage')
    console.log('2...body: ', req.body)
    console.log('2...file: ', file)
    const filePath = './assets/audioBooks/'+req.body.bookId
    fs.mkdirSync(filePath, { recursive: true })
    cb(null, filePath)
  },
})

const uploadAudioBook = multer({ storage: storeAudioBook })

router.get('/', (req, res) => {
    res.send('Hello World')
})

router.get('/dashboard', (req, res) => {
    res.send('Dashboard')
})

//@desc Adding new user
//@route POST /adduser
router.post('/adduser', actions.addNew)

//@desc Authenticate a user
//@route POST /authenticate
router.post('/authenticate', actions.authenticate)

//@desc Change Password of a user
//@route POST /changePassword
router.post('/changePassword', actions.changePassword)

//@desc Adding new book
//@route POST /addBook
router.post('/addBook', uploadBookImage.single('image'), actions.addBook)
// router.post('/addBook', fileUploads, actions.addBook)

//@desc Get Book Details
//@route POST /getBookDetails
router.post('/getBookDetails', actions.getBookDetails)

//@desc Get Recommended Book
//@route POST /getRecommendBook
router.post('/getRecommendBook', actions.getRecommendBook)

//@desc Get All Books
//@route POST /getAllBook
router.post('/getAllBooks', actions.getAllBooks)

//@desc Get Book Image
//@route POST /getBookImage
router.post('/getBookImage', actions.getBookImage)

//@desc Adding book to current users favourites
//@route POST /addToFavourites
router.post('/addToFavourites', actions.addToFavourites)

//@desc Removing book from current users favourites
//@route POST /removeFromFavourites
router.post('/removeFromFavourites', actions.removeFromFavourites)

//@desc Adding book to current users WishList
//@route POST /addToWishList
router.post('/addToWishList', actions.addToWishList)

//@desc Removing book from current users WishList
//@route POST /removeFromWishList
router.post('/removeFromWishList', actions.removeFromWishList)

//@desc Update User's Cart
//@route POST /updateCart
router.post('/updateCart', actions.updateCart)

//@desc Buy Books
//@route POST /buyBooks
router.post('/buyBooks', actions.buyBooks)

//@desc Change Last Page Read
//@route POST /changeLastPageRead
router.post('/changeLastPageRead', actions.changeLastPageRead)

//@desc Update User's Reward
//@route POST /addReward
router.post('/addReward', actions.addReward)

//@desc Add AudioBook
//@route POST /addAudioBook
router.post('/addAudioBook', uploadAudioBook.single('audioBook'), actions.addAudioBook)

//@desc Get AudioBook
//@route POST /getAudioBook
router.post('/getAudioBook', actions.getAudioBook)

//@desc Adding new book image
//@route POST /addBookImage
// router.post('/addBookImage', upload.single('img'), actions.addBookImage.bind(actions))

//@desc Get info on a user
//@route GET /getinfo
router.get('/getinfo', actions.getinfo)

module.exports = router