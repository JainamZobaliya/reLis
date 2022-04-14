import { getFirestore,  collection, getDocs } from "https://www.gstatic.com/firebasejs/8.10.1/firebase-firestore.js";
import { app } from 'index.html'

// const firebase = require("firebase");
// // Required for side-effects
// require("https://www.gstatic.com/firebasejs/8.10.0/firebase-firestore.js");
function getData(){
    console.log("in getData");
    const db = getFirestore(app);
    const querySnapshot = await getDocs(collection(db, "audioBooks"));
    console.log("db: ");
    console.log(db);
    querySnapshot.forEach((doc) => {
        console.log(`${doc.id} => ${doc.data()}`);
    });
};

window.state = {
    hello: querySnapshot
}

window.logger = (flutter_value) => {
    console.log({ js_context: this, flutter_value });
 }


 getData();
