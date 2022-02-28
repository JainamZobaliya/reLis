var mongoose = require('mongoose')
var Schema = mongoose.Schema;
var bcrypt = require('bcrypt')
function  getDefaultPagesRead() {
    // console.log("In getDefaultPagesRead");
    let map = new Map();
    let date = new Date();
    let day = date.getDate() - 7;
    date.setDate(day);
    for(let i=0; i<7; i+=1) {
        day = date.getDate() + 1;
        date.setDate(day);
        day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        let dateStr = (("0" + day).slice(-2)+"/"+("0" + month).slice(-2)+"/"+year).toString();
        map[dateStr] = 0;
    }
    // console.log("Map is ",map);
    return map;
}
var userSchema = new Schema({
    firstName: {
        type: String,
        require: true
    },
    lastName: {
        type: String,
        require: true
    },
    emailId: {
        type: String,
        require: true
    },
    password: {
        type: String,
        require: true
    },
    userType: {
        type: String,
        default: "non-admin",
    },
    imageURL: {
        type: String,
        default: "assets/ReLis.gif",
    },
    userStatus: {
        type: String,
        default: "New to ReLis!!!",
    },
    favouriteBook: {
        type: Array,
        default: [],
    },
    wishListBook: {
        type: Array,
        default: [],
    },
    recommendedBook: {
        type: Array,
        default: [],
    },
    bookHistory: {
        type: Array,
        default: [],
    },
    personalBooks: {
        type: Array,
        default: [],
    },
    booksRented: {
        type: Map,
        default: {},
        // {
        //     book1["id"] : {
        //       "id" : book1["id"],
        //       "rentedOn": "${DateTime.now().subtract(Duration(days: 3))}",
        //       "dueOn": "${DateTime.now().add(Duration(days: 5))}",
        //     }
        // }
    },
    booksBought: {
        type: Map,
        default: {},
        // {
        //     book1["id"] : {
        //       "id" : book1["id"],
        //       "purchasedOn": "${DateTime.now().subtract(Duration(days: 3))}",
        //     }
        // }
    },
    cart: {
        type: Map,
        default: {
            toRent: [],
            // {
            //     type: Array,
            //     of: String,
            //     default: [],
            // },
            toBuy: [],
            // {
            //     type: Array,
            //     of: String,
            //     default: [],
            // },
        },
        // {
        //     book1["id"] : {
        //       "id" : book1["id"],
        //       "purchasedOn": "${DateTime.now().subtract(Duration(days: 3))}",
        //     }
        // }
    },
    credits: {
        type: String,
        default: "0",
    },
    booksRead: {},
    isAdmin: false,
    // {
    //     type: Map,
    //     default: {},
    //     // {
    //     //     book1["id"] : {
    //     //       "id" : book1["id"],
    //     //       "lastReadAt": "${DateTime.now().subtract(Duration(days: 3))}",
    //     //       "lastPageRead": "PgNo",
    //     //     }
    //     // }
    // },
    dailyRecords: {
        type: Map,
        default: {
            loginRecords: [],
            // {
            //     type: Array,
            //     default: [],// store DateTime as String over here
            // },
            pagesRead: getDefaultPagesRead(), // [0,0,0,0,0,0,0],
            // {
            //     type: Array,
            //     default: [0,0,0,0,0,0,0], // store pageRead Day-wise: Mon to Sun
            // },
        },
    },
    feedback: {
        type: Map,
        default: {},
        // {
        //     book1["id"] : {
        //       "id" : book1["id"],
        //       "comment" : "Book Comment here...",
        //       "rating": "4.5",
        //     }
        // }
    },
})

userSchema.pre('save', function (next) {
    var user = this;
    if (this.isModified('password') || this.isNew) {
        bcrypt.genSalt(10, function (err, salt) {
            if (err) {
                return next(err)
            }
            bcrypt.hash(user.password, salt, function (err, hash) {
                if (err) {
                    return next(err)
                }
                user.password = hash;
                next()
            })
        })
    }
    else {
        next()
    }
})

userSchema.methods.comparePassword = function (passw, cb, redirect) {
    console.log("redirect: ", redirect);
    if(redirect=="true") {
        console.log("User is tryting to redirect");
        if(passw == this.password) {
            cb(null, true)
        }
        else {
            return cb("Password Dont Match")
        }
    }
    else{
        console.log("New Authentication");
        bcrypt.compare(
            passw,
            this.password, 
            function (err, isMatch) {
                if(err) {
                    return cb(err)
                }
                cb(null, isMatch)
            }
        )
    }
}

module.exports = mongoose.model('User', userSchema)