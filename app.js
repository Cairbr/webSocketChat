var http = require('http');
var fs = require('fs');


console.log(([] + ![])[+(!![]) + (!![])] + ({} + [])[+(!![])] + [] + ([] + ![])[+(!![]) + (!![])]);



//on charge index.html qui est affiché au client
var server = http.createServer(function (req, res) {
    fs.readFile('./index.html', 'utf-8', function (error, content) {
        res.writeHead(200, { "Content-type": "text/html" });
        res.end(content);
    });
});

//chargement de socket.io
var io = require('socket.io').listen(server);

var listeConnectes = [];

io.sockets.on('connection', function (socket) {
    //on récupère le pseudo du client, le type est 'username'
    socket.on('username', function (pseudo) {
        socket.pseudo = pseudo;
        //On log les connexions des clients en console + envoi d'un message au client
        socket.emit('logConnect', 'self');
        socket.broadcast.emit('logConnect', pseudo);
        console.log('Un client est connecté (' + pseudo + ')');
        //on actualise la liste des connectés


    })

        //si déconnection
        .on('disconnect', (reason) => {
            pseudo = socket.pseudo;
            socket.emit('logDisconnect', 'self');
            socket.broadcast.emit('logDisconnect', pseudo);
            console.log('Un client est déconnecté (' + pseudo + ')');
        })
        //écoute des messages de type 'messageChat'
        .on('messageChat', function (msgchat) {
            pseudo = socket.pseudo;
            console.log(pseudo, " envoie : ", msgchat)
            //qu'on renvoie en broadcast pour affichage
            socket.broadcast.emit('messageChat', { pseudo: pseudo, message: msgchat });


        });
});




server.listen(8080);