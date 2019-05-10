
var StringDecoder = require('string_decoder').StringDecoder;
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
var remotes = [];
server.on('message', function (message, remote) {
    var newRemote = true;
    
    console.log("Got message: "+remote.address+":"+remote.port);

    for (i = 0; i<remotes.length; i++){
        var add = remotes[i].address
        var prt = 1234
        var prtAudio = 3234
        if(add != remote.address){
            // console.log(remotes[i]);
            var decoder = new StringDecoder('utf8');
            var textChunk = decoder.write(message);
            var last = textChunk.slice(-1)
            // console.log(last);
            if (last == "%"){
                server.send(message, 0, message.length, prtAudio, add, function(err, bytes) {
                    if (err)
                    { console.log( err);
                    }else{
                    // console.log('UDP message sent to ' + add +':'+ prt);
                    }// server.close();
                });
            }else{
                server.send(message, 0, message.length, prt, add, function(err, bytes) {
                    if (err)
                    { console.log( err);
                    }else{
                    // console.log('UDP message sent to ' + add +':'+ prt);
                    }// server.close();
                });
            }
        } else{
            newRemote = false;
        }
    }
    if (newRemote){

        // console.log(server);
        console.log(remote);
        remotes.push({address: remote.address, port: remote.port});
        console.log(remotes);
    }
    
});
server.on("error", function(err) {
    console.log("error: ",err);
});
server.bind(UdpPort);