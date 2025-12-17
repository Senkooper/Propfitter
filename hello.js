
const nodemailer = require('nodemailer');



fetch(`https://accounts.google.com/o/oauth2/v2/auth?
client_id=347517349617-594rit1eb5lnhsjnr16ga2qhid79591l.apps.googleusercontent.com&
redirect_uri=http://localhost:8080/&
response_type=code&
scope=email&
access_type=offline&
prompt=consent`).then(res=>{
    console.log(res.body)
    

    return res.text()
   
}).then(data=>{
    console.log(data)
})


setInterval(()=>{

})