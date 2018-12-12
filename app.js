var http = require('http');
var fs = require('fs');

//on charge index.html qui est affiché au client
var server = http.createServer(function (req, res) {
    fs.readFile('./index.html', 'utf-8', function (error, content) {
        res.writeHead(200, { "Content-type": "text/html" });
        res.end(content);
    });
});

//chargement de socket.io
var io = require('socket.io').listen(server);


io.sockets.on('connection', function (socket) {
    //on récupère le pseudo du client, le type est 'username'
    socket.on('username', function (pseudo) {
        socket.pseudo = pseudo;
        //On log les connexions des clients en console + envoi d'un message au client
        socket.emit('messageLog', 'Vous êtes connecté !');
        socket.broadcast.emit('messageLog', pseudo + ' vient de se connecter');
        console.log('Un client est connecté (' + pseudo + ')');

    })

    //écoute des messages de type 'messageChat'
    socket.on('messageChat', function (msgchat) {
        console.log(socket.pseudo, " envoie : ", msgchat)

        //qu'on renvoie en broadcast pour affichage
        socket.broadcast.emit('messageChat', msgchat);
    });
});




server.listen(8080);