var mongoose = require('mongoose')
var Schema = mongoose.Schema;

var bookSchema = new Schema({
    id: {
        type: String,
        require: true
    },
    isbn: {
        type: String,
        require: true
    },
    bookName: {
        type: String,
        require: true
    },
    url: {
        type: String,
        require: true
    },
    category: {
        type: String,
        require: true
    },
    authorName: {
        type: String,
        require: true
    },
    publication: {
        type: String,
        require: true
    },
    price: {
        type: String,
        require: true
    },
    image: {
        data: Buffer,
        contentType: String
    },
    bookFile: {
        data: Buffer,
        contentType: String
    },
    description: {
        type: String,
        require: true
    },
    feedback: {
        userId: {
            userId: {
                type: String,
                require: true
            },
            comment: {
                type: String,
                require: true
            },
            rating: {
                type: Number,
                min: 0,
                max: 5,
                require: true
            },
        },
    },
    ratings: {
        rate0: {
            type: Number,
            default: 0
        },
        rate005: {
            type: Number,
            default: 0
        },
        rate1: {
            type: Number,
            default: 0
        },
        rate105: {
            type: Number,
            default: 0
        },
        rate2: {
            type: Number,
            default: 0
        },
        rate205: {
            type: Number,
            default: 0
        },
        rate3: {
            type: Number,
            default: 0
        },
        rate305: {
            type: Number,
            default: 0
        },
        rate4: {
            type: Number,
            default: 0
        },
        rate405: {
            type: Number,
            default: 0
        },
        rate5: {
            type: Number,
            default: 0
        },
    },
    imageName: {
        type: String,
        require: true
    },
    imagePath: {
        type: String,
        require: true
    },
    imageSize: {
        type: Number,
        require: true
    },
    boughtBy: [],
    rentedBy: [],
})

bookSchema.pre('save', function (next) {
    next();
});

module.exports = mongoose.model('Book', bookSchema)