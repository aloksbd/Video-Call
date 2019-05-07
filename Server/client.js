var PORT = 7000;
var HOST = '192.168.10.122';

var dgram = require('dgram');
var message = Buffer.from('My KungFu is Good!');

var client = dgram.createSocket('udp4');
client.send(message, 0, message.length, PORT, HOST, function(err, bytes) {
    if (err) throw err;
    console.log('UDP message sent to ' + HOST +':'+ PORT);
    // client.close();
});
client.on('message', function (message, remote) {
    console.log("Got message: "+message+remote.address+":"+remote.port);
    // client.close();
});