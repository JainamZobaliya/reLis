const express = require('express')
const morgan = require('morgan')
const cors = require('cors')
const connectDB = require('./config/db')
const passport = require('passport')
const bodyParser = require('body-parser')
const routes = require('./routes/index')
const multer = require('multer');
const uploadFile = require('express-fileupload');

connectDB()

const app = express()

if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'))
}

// app.use(uploadFile())
app.use(function (req, res, next) {

    // Website you wish to allow to connect
    res.setHeader('Access-Control-Allow-Origin', 'https://relis-frontend.web.app/');

    // Request methods you wish to allow
    // res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');

    // Request headers you wish to allow
    // res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

    // Set to true if you need the website to include cookies in the requests sent
    // to the API (e.g. in case you use sessions)
    // res.setHeader('Access-Control-Allow-Credentials', true);

    // Pass to next layer of middleware
    next();
});

app.use(cors())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(express.urlencoded({extended: true}))
app.use(bodyParser.json())
app.use(routes)
app.use(passport.initialize())
// app.use(express.static('public'))

require('./config/passport')(passport)


const PORT = process.env.PORT || 3000

app.listen(PORT, console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`))