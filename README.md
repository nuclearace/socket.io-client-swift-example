# socket.io-client-swift-example
An example of socket.io-client for Swift in the form of a TicTacToe app

<center>
![](http://i.imgur.com/wOkugkml.jpg)
<center>


### Gettings Started

- Clone the Reopo 
`git clone https://github.com/nuclearace/socket.io-client-swift-example.git`

Open the project directory in terminal and spin up the server localy.
`cd socket.io-client-swift-example`
`npm install`
`cd sever`
`npm install`
`node index.js`

This launches a node server on your local machine listening on port `8900`.

open the socket.io-client-swift-example project in XCode.
If you are in terminal in the project directory you can.
`open -a Xcode TicTacIOiOS.xcodeproj`

Select a simulator `hit Run`, the app will build and once it connects to the server you will get a "adding player" message in your terminal window.

Now here is the hard part. In order to play TicTacToe you need two devices but running the app on your phone will not work out of the box because it needs to know the address of the server. Here is how to set that up.

`open /System/Library/PreferencePanes/Network.prefPane/`

then look for your "IP Address" copy that and replace line 21
`let socket = SocketIOClient(socketURL: NSURL(string:"http://localhost:8900")!)` with -> `let socket = SocketIOClient(socketURL: NSURL(string:"http://YOUR_IP_ADRESS_HERE:8900")!)`

Build and run the app on your device. Once again you should get "adding player" in the terminal. 

Now you can play TicTacToe with your self. Have fun 😱