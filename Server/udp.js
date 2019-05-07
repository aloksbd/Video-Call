var server = require("dgram").createSocket({
    type:'udp4',
    sendBufferSize:1024*100
});
// var server = dgram.createSocket('udp4');
var UdpPort = 7000;
server.on('listening', function () {
    var address = server.address();
    console.log('UDP Server listening on ' + address.address + ":" + address.port);
});
server.on('message', function (message, remote) {
    console.log("Got message: "+message+remote.address+":"+remote.port);
    server.send(message, 0, message.length, remote.port, remote.address, function(err, bytes) {
        if (err)
        { console.log( err);
        }else{
        console.log('UDP message sent to ' + remote.address +':'+ remote.port);
        }// server.close();
    });
});
server.on("error", function(err) {
    console.log("error: ",err);
});
server.bind(UdpPort);