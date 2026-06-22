const express = require('express');

const app = express();

app.use(express.static('public'));

app.get('/health', (req,res)=>{
    res.json({
        status:'UP',
        app: process.env.APP_NAME,
        version: process.env.APP_VERSION
    });
});

app.listen(3000, ()=>{
    console.log("Application Started");
});
