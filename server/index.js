var app = require('http').createServer()

app.listen(8900)

function Player(socket) {
    var self = this
    this.socket = socket
    this.name = ""
    this.game = {}

    this.socket.on("playerMove", function(x, y) {
        self.game.playerMove(self, x, y)
    })
}

Player.prototype.joinGame = function(game) {
    this.game = game
}

function Game() {
    this.io = require('socket.io')(app)
    this.board = [
        ["", "", ""],
        ["", "", ""],
        ["", "", ""]
    ]
    this.player1 = null
    this.player2 = null
    this.currentTurn = "X"
    this.moveCount = 0
    this.started = false
    this.addHandlers()
}

Game.prototype.addHandlers = function() {
    var game = this

    this.io.sockets.on("connection", function(socket) {
        game.addPlayer(new Player(socket))
    })
}

Game.prototype.addPlayer = function(player) {
    console.log("adding player")
    if (this.player1 === null) {
        this.player1 = player
        this.player1["game"] = this
        this.player1["name"] = "X"
        this.player1.socket.emit("name", "X")
    } else if (this.player2 === null) {
        this.player2 = player
        this.player2["game"] = this
        this.player2["name"] = "O"
        this.player2.socket.emit("name", "O")
        this.startGame()
    }
}

Game.prototype.announceWin = function(player, type) {
    this.player1.socket.emit("win", player["name"], type)
    this.player2.socket.emit("win", player["name"], type)
    this.resetGame()
}

Game.prototype.gameOver = function() {
    this.player1.socket.emit("gameOver")
    this.player2.socket.emit("gameOver")
}

Game.prototype.playerMove = function(player, x, y) {
    if (player["name"] !== this.currentTurn || x >= 3 || y >= 3) {
        return
    }

    this.player1.socket.emit("playerMove", player["name"], x, y)
    this.player2.socket.emit("playerMove", player["name"], x, y)
    this.board[x][y] = player["name"]

    var n = 3
        //check row
    for (var i = 0; i < n; i++) {
        if (this.board[x][i] !== player["name"]) {
            break
        }

        if (i === n - 1) {
            this.announceWin(player, {
                type: "row",
                num: x
            })
            return
        }
    }

    // Check col
    for (var i = 0; i < n; i++) {
        if (this.board[i][y] !== player["name"]) {
            break
        }

        if (i === n - 1) {
            this.announceWin(player, {
                type: "col",
                num: y
            })
            return
        }
    }

    // Check diags
    if (x === y) {
        for (var i = 0; i < n; i++) {
            if (this.board[i][i] !== player["name"]) {
                break
            }

            if (i == n - 1) {
                this.announceWin(player, {
                    type: "diag",
                    coord: {
                        x: x,
                        y: y
                    },
                    anti: false
                })
                return
            }
        }
    }

    for (var i = 0; i < n; i++) {
        if (this.board[i][(n - 1) - i] !== player["name"]) {
            break
        }

        if (i === n - 1) {
            this.announceWin(player, {
                type: "diag",
                coord: {
                    x: x,
                    y: y
                },
                anti: true
            })
            return
        }
    }

    if (this.moveCount === (Math.pow(n, 2) - 1)) {
        this.player1.socket.emit("draw")
        this.player2.socket.emit("draw")
        this.resetGame()
        return
    }

    this.moveCount++
    if (player["name"] === "X") {
        this.currentTurn = "O"
        this.player1.socket.emit("currentTurn", "O")
        this.player2.socket.emit("currentTurn", "O")
    } else {
        this.currentTurn = "X"
        this.player1.socket.emit("currentTurn", "X")
        this.player2.socket.emit("currentTurn", "X")
    }
}

Game.prototype.resetGame = function() {
    var self = this
    var player1Ans = null
    var player2Ans = null

    var reset = function() {
        if (player1Ans === null || player2Ans === null) {
            return
        } else if ((player1Ans & player2Ans) === 0) {
            self.gameOver()
            process.exit(0)
        }

        self.board = [
            ["", "", ""],
            ["", "", ""],
            ["", "", ""]
        ]
        self.moveCount = 0

        if (self.player1["name"] === "X") {
            self.player1["name"] = "O"
            self.player1.socket.emit("name", "O")
            self.player2["name"] = "X"
            self.player2.socket.emit("name", "X")
        } else {
            self.player1["name"] = "X"
            self.player1.socket.emit("name", "X")
            self.player2["name"] = "O"
            self.player2.socket.emit("name", "O")
        }

        self.startGame()
    }

    this.player1.socket.emit("gameReset", function(ans) {
        player1Ans = ans
        reset()
    })
    this.player2.socket.emit("gameReset", function(ans) {
        player2Ans = ans
        reset()
    })
}

Game.prototype.startGame = function() {
    this.player1.socket.emit("startGame")
    this.player2.socket.emit("startGame")
}

// Start the game server
var game = new Game()
