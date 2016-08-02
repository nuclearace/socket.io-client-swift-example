# socket.io-client-swift-example
An example of socket.io-client for Swift in the form of a TicTacToe app

<center>
![](http://i.imgur.com/wOkugkml.jpg)
<center>



## Getting Started

- Clone the Repo 
`git clone https://github.com/nuclearace/socket.io-client-swift-example.git`

### Setup Server
Open the project directory in terminal and spin up the server locally.

 - `cd socket.io-client-swift-example`
 - `npm install`
 - `cd server`
 - `npm install`
 - `node index.js`

This launches a node server on your local machine listening on port `8900`.

### Setup First Client
Open the socket.io-client-swift-example project in Xcode.
Via terminal, navigate to the project directory and type this:
 - `open -a Xcode TicTacIOiOS.xcodeproj`
Or open via Finder.

Select a simulator, hit `Run`, the app will build and once it connects to the server you will get a "adding player" message in your terminal window.

### Setup Second Client
Now you just need to run the project on a real device.
 - Connect your phone via lightning connector to your computer.
 - Select your phone as the device and hit `Run`.
 - Once the app launches you will be prompted with an Alert asking for the IP Address of the server.

It will look like this.
<center>
![](/documentation/input_IP_Address.png)
<center>

#### Get Your IP Address
 - On Your computer that is running the example server go to terminal and type. 
        - `open /System/Library/PreferencePanes/Network.prefPane/`

 - Look for your "IP Address" and type it into your phone.

You should see a "adding player" message appear on the terminal. That means the Phone sucsessfully connected to the server.

Now you can play TicTacToe with yourself. Have fun! 😱
