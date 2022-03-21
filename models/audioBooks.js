var mongoose = require('mongoose')
var Schema = mongoose.Schema;

var audioBookSchema = new Schema({
    id: {
        type: String,
        require: true
    },
    bookId: {
        type: String,
        require: true
    },
    audioBookMaxDuration: {
        type: String,
        require: true
    },
    audioBookURL: {
        type: String,
        require: true
    },
    audioBook: {
        data: Buffer,
    },
    audioBookChapterName: {
        type: String,
        require: true
    },
    audioBookName: {
        type: String,
        require: true
    },
    audioBookPath: {
        type: String,
        require: true
    },
    audioBookSize: {
        type: Number,
        require: true
    },
})  

audioBookSchema.pre('save', function (next) {
    next();
});

module.exports = mongoose.model('AudioBook', audioBookSchema, 'audioBooks')