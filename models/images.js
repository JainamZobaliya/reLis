var mongoose = require('mongoose');
var Schema = mongoose.Schema;
  
var imageSchema = new Schema({
    bookId: {
        type: String,
        require: true
    },
    imageId: {
        type: String,
        require: true
    },
    bookName: {
        type: String,
        require: true
    },
    desc: {
        type: String,
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
});
  
//Image is a model which has a schema imageSchema

imageSchema.pre('save', function (next) {
    next();
});
  
module.exports = new mongoose.model('BookImage', imageSchema);