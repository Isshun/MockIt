// http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/
"use strict";

// Optional. You will see this name in eg. 'ps' or 'top' command
process.title = 'node-chat';

// Port where we'll run the websocket server
var webSocketsServerPort = 8124;

// websocket and http servers
var webSocketServer = require('websocket').server;
var http = require('http');

/**
 * Global variables
 */
// latest 100 messages
var history = [ ];
// list of currently connected clients (users)
var clients = [ ];

/**
 * Helper function for escaping input strings
 */
function htmlEntities(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

var objects = [];

objects["p1"] = {id: "p1", type: "workspace", name: "workspace 1"};
objects["p2"] = {id: "p2", type: "page", name: "page 1", offsetLeft: 0, offsetTop: 0};
objects["p3"] = {id: "p3", type: "page", name: "page 2", offsetLeft: 100, offsetTop: 100};
objects["p4"] = {id: "p4", type: "page", name: "page 3", offsetLeft: 200, offsetTop: 200};

// Array with some colors
var colors = [ 'green', 'blue', 'magenta', 'purple', 'plum', 'orange' ];
// ... in random order
colors.sort(function(a,b) { return Math.random() > 0.5; } );

/**
 * HTTP server
 */
var server = http.createServer(function(request, response) {
    // Not important for us. We're writing WebSocket server, not HTTP server
});
server.listen(webSocketsServerPort, function() {
    console.log((new Date()) + " Server is listening on port " + webSocketsServerPort);
});

/**
 * WebSocket server
 */
var wsServer = new webSocketServer({
    // WebSocket server is tied to a HTTP server. WebSocket request is just
    // an enhanced HTTP request. For more info http://tools.ietf.org/html/rfc6455#page-6
    httpServer: server
});

// This callback function is called every time someone
// tries to connect to the WebSocket server
wsServer.on('request', function(request) {
    console.log((new Date()) + ' Connection from origin ' + request.origin + '.');

    // accept connection - you should check 'request.origin' to make sure that
    // client is connecting from your website
    // (http://en.wikipedia.org/wiki/Same_origin_policy)
    var connection = request.accept(null, request.origin); 
    // we need to know client index to remove them on 'close' event
    var index = clients.push(connection) - 1;
    var userName = false;
    var userColor = false;

    console.log((new Date()) + ' Connection accepted.');

    // send back chat history
    if (history.length > 0) {
        connection.sendUTF(JSON.stringify( { type: 'history', data: history} ));
    }

    // user sent some message
    connection.on('message', function(message) {
				// console.log(message)
        if (message.type === 'utf8') { // accept only text
            if (userName === false) { // first message sent by user is their name
                // remember user name
                userName = htmlEntities(message.utf8Data);
                // get random color and send it back to the user
                userColor = colors.shift();
                connection.sendUTF(JSON.stringify({ type:'hello', data: {user: userName, color: userColor} }));
                console.log((new Date()) + ' User is known as: ' + userName + ' with ' + userColor + ' color.');

            } else { // log and broadcast the message

								console.log("\n================================\nmsg: ", message.utf8Data);

								var action = JSON.parse(message.utf8Data);

								console.log("cmd: ", action.cmd);

								if (action.cmd == 'updateWorkspace') {
										// console.log('update workspace ' + action.data);

										for (var p in action.data) {
												console.log('update "' + action.id + '" -> set "' + p + '" to "' + action.data[p] + '"');
												objects[action.id][p] = action.data[p];
										}
								} else {
										console.log('Nothing to update');
										// console.log((new Date()) + ' Received Message from ' + userName + ': ' + message.utf8Data);
								}

								broadcast();
            }
        }
    });

		function broadcast() {
				// broadcast message to all connected clients
				var array = [];
				for (var i in objects) {
						if (objects[i])
								array.push(objects[i]);
				}
				var json = JSON.stringify({ type:'model', objects: array });
				for (var i=0; i < clients.length; i++) {
						clients[i].sendUTF(json);
				}
		}

    // user disconnected
    connection.on('close', function(connection) {
        if (userName !== false && userColor !== false) {
            console.log((new Date()) + " Peer "
                + connection.remoteAddress + " disconnected.");
            // remove user from the list of connected clients
            clients.splice(index, 1);
            // push back user's color to be reused by another user
            colors.push(userColor);
        }
    });

});
