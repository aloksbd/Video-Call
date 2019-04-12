var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);

app.get('/', function(req, res){
  res.send('<h1>AppCoda - SocketChat Server</h1>');
});


http.listen(1000, function(){
  console.log('Listening on *:1000');
});

socketList = [];

io.sockets.on('connection',function(socket){
    console.log('player connected');

    // socketList[socket.id] = socket;
    
    socketList.push(socket);

    for (i = 0; i < socketList.length; i++){
        console.log(socketList[i].id);
        if (socket != socketList[i]){
            socketList[i].emit("newConnection",socket.id);
        }
    }

    socket.on('disconnect',function(){
        delete socketList[socket.id];
        console.log('player left');
    });

    socket.on("packet",function(data){

        // console.log(data);
        for (i = 0; i < socketList.length; i++){
            // console.log(socketList[i].id);
            if (socket != socketList[i]){
                socketList[i].emit("newPacket",socket.id,data);
            }
        }
    });

    socket.on("audio",function(data){

        console.log(data);
        for (i = 0; i < socketList.length; i++){
            console.log(socketList[i].id);
            if (socket != socketList[i]){
                socketList[i].emit("newAudio",socket.id,data);
            }
        }
    });

});