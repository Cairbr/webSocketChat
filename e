[1mdiff --git a/app.js b/app.js[m
[1mindex 53d20ce..13f3f77 100644[m
[1m--- a/app.js[m
[1m+++ b/app.js[m
[36m@@ -12,24 +12,25 @@[m [mvar server = http.createServer(function (req, res) {[m
 //chargement de socket.io[m
 var io = require('socket.io').listen(server);[m
 [m
[31m-[m
 io.sockets.on('connection', function (socket) {[m
     //on récupère le pseudo du client, le type est 'username'[m
     socket.on('username', function (pseudo) {[m
         socket.pseudo = pseudo;[m
         //On log les connexions des clients en console + envoi d'un message au client[m
[31m-        socket.emit('messageLog', 'Vous êtes connecté !');[m
[31m-        socket.broadcast.emit('messageLog', pseudo + ' vient de se connecter');[m
[32m+[m[32m        socket.emit('logConnect', 'self');[m
[32m+[m[32m        socket.broadcast.emit('logConnect', pseudo);[m
         console.log('Un client est connecté (' + pseudo + ')');[m
 [m
     })[m
 [m
     //écoute des messages de type 'messageChat'[m
[31m-    socket.on('messageChat', function (msgchat) {[m
[31m-        console.log(socket.pseudo, " envoie : ", msgchat)[m
[31m-[m
[32m+[m[32m    .on('messageChat', function (msgchat) {[m
[32m+[m[32m        pseudo = socket.pseudo;[m
[32m+[m[32m        console.log(pseudo, " envoie : ", msgchat)[m
         //qu'on renvoie en broadcast pour affichage[m
[31m-        socket.broadcast.emit('messageChat', msgchat);[m
[32m+[m[32m        socket.broadcast.emit('messageChat', {pseudo: pseudo, message: msgchat});[m
[32m+[m
[32m+[m[41m        [m
     });[m
 });[m
 [m
[1mdiff --git a/index.html b/index.html[m
[1mindex a8ffee9..45e4426 100644[m
[1m--- a/index.html[m
[1m+++ b/index.html[m
[36m@@ -19,6 +19,10 @@[m
     </p>[m
 [m
 [m
[32m+[m[32m    <div id="divZoneChat">[m
[32m+[m
[32m+[m[32m    </div>[m
[32m+[m
     <!--Au chargement de la page, on demande un pseudo pour identifier le client-->[m
     <script>[m
         var pseudo = prompt('Pseudo ?', "client");[m
[36m@@ -41,17 +45,50 @@[m
             alert('Le serveur vous indique : ' + message);[m
         });[m
         //écoute des messages de type 'messageLog' (évènements à afficher dans le chat)[m
[31m-        socket.on('messageLog', function (messageLog) {[m
 [m
[31m-        });[m
 [m
[31m-        //on envoie le message au serveur[m
[32m+[m
[32m+[m[32m        //on envoie le message au serveur et pour affichage sur le client[m
         document.querySelector('#sendmsg').onclick = function () {[m
[31m-            [m
[31m-            socket.emit('messageChat', document.querySelector('#msgchat').value);[m
[32m+[m[32m            message = document.querySelector('#msgchat').value;[m
[32m+[m[32m            socket.emit('messageChat', message);[m
[32m+[m[32m            afficher("chatSelf", "self", message);[m
         };[m
 [m
[31m-        [m
[32m+[m[32m        //on écoute les broadcasts d'évènements[m
[32m+[m[32m        socket.on('logConnect', function (pseudo, message) {[m
[32m+[m[32m            afficher("logConnexion", pseudo, message);[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        //on écoute les broadcasts de messages du chat[m
[32m+[m[32m        socket.on('messageChat', function ({ pseudo, message }) {[m
[32m+[m[32m            afficher("chatGeneral", pseudo, message);[m
[32m+[m[32m        });[m
[32m+[m
[32m+[m[32m        function afficher(evenement, pseudo, message) {[m
[32m+[m[32m            console.log('evenement', evenement, 'pseudo', pseudo, 'message', message);[m
[32m+[m[32m            var div = document.getElementById('divZoneChat');[m
[32m+[m
[32m+[m[32m            switch (evenement) {[m
[32m+[m[32m                case "logConnexion":[m
[32m+[m[32m                    if (pseudo == 'self') {[m
[32m+[m[32m                        div.innerHTML += '<br/><b><i>' + "Vous êtes connecté" + '</i></b>';[m
[32m+[m[32m                    }[m
[32m+[m[32m                    else[m
[32m+[m[32m                        div.innerHTML += '<br/><i>' + pseudo + " vient de se connecter ! " + '</i>';[m
[32m+[m[32m                    break;[m
[32m+[m[32m                case "chatGeneral":[m
[32m+[m[32m                    div.innerHTML += '<br/>' + pseudo + " dit: " + message;[m
[32m+[m[32m                    break;[m
[32m+[m[32m                case "chatSelf":[m
[32m+[m[32m                    div.innerHTML += '<br/><i>' + "Vous " + " dites: </i>" + message;[m
[32m+[m[32m                    break;[m
[32m+[m[32m                default:[m
[32m+[m[32m                    message = "Erreur"[m
[32m+[m[32m            }[m
[32m+[m
[32m+[m
[32m+[m[32m        };[m
 [m
     </script>[m
 </body>[m
[1mdiff --git a/package.json b/package.json[m
[1mindex e68a495..c589984 100644[m
[1m--- a/package.json[m
[1m+++ b/package.json[m
[36m@@ -1,10 +1,11 @@[m
 {[m
     "name": "chat-socket-express",[m
[31m-    "version": "0.1.0",[m
[32m+[m[32m    "version": "0.1.1",[m
     "dependencies": {[m
         "ejs": "~2.6.1",[m
         "express": "~4.16.4",[m
[31m-        "socket.io": "^2.2.0"[m
[32m+[m[32m        "socket.io": "^2.2.0",[m
[32m+[m[32m        "ent": "~2.2.0"[m
     },[m
     "author": "cairbre <cairbrefr@gmail.com>",[m
     "description": "Un chat utilisant WebSocket"[m
