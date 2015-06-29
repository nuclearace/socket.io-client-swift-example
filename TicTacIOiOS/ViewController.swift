//
//  ViewController.swift
//  TicTacIOiOS
//
//  Created by Erik Little on 3/7/15.
//

import UIKit

class ViewController: UIViewController, UIAlertViewDelegate {
    @IBOutlet weak var btn0:UIButton!
    @IBOutlet weak var btn1:UIButton!
    @IBOutlet weak var btn2:UIButton!
    @IBOutlet weak var btn3:UIButton!
    @IBOutlet weak var btn4:UIButton!
    @IBOutlet weak var btn5:UIButton!
    @IBOutlet weak var btn6:UIButton!
    @IBOutlet weak var btn7:UIButton!
    @IBOutlet weak var btn8:UIButton!
    @IBOutlet weak var label:UILabel!
    let socket = SocketIOClient(socketURL: "localhost:8900")
    var name:String?
    var resetAck:AckEmitter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addHandlers()
        self.socket.connect()
        
        let grad = CAGradientLayer()
        grad.frame = self.view.bounds
        
        let colors = [UIColor(red: 127, green: 0, blue: 127, alpha: 1).CGColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).CGColor]
        
        grad.colors = colors
        self.view.layer.insertSublayer(grad, atIndex: 0)
    }
    
    func addHandlers() {
        self.socket.on("startGame") {[weak self] data, ack in
            self?.handleStart()
            return
        }
        
        self.socket.on("name") {[weak self] data, ack in
            if let name = data?[0] as? String {
                self?.name = name
            }
        }
        
        self.socket.on("playerMove") {[weak self] data, ack in
            if let name = data?[0] as? String, x = data?[1] as? Int, y = data?[2] as? Int {
                self?.handlePlayerMove(name, coord: (x, y))
            }
        }
        
        self.socket.on("win") {[weak self] data, ack in
            if let name = data?[0] as? String, typeDict = data?[1] as? NSDictionary {
                self?.handleWin(name, type: typeDict)
            }
        }
        
        self.socket.on("draw") {[weak self] data, ack in
            self?.handleDraw()
            return
        }
        
        self.socket.on("currentTurn") {[weak self] data, ack in
            if let name = data?[0] as? String {
                self?.handleCurrentTurn(name)
                
            }
        }
        
        self.socket.on("gameReset") {[weak self] data, ack in
            let alert = UIAlertView(title: "Play Again?",
                message: "Do you want to play another round?", delegate: self,
                cancelButtonTitle: "No", otherButtonTitles: "Yes")
            self?.resetAck = ack
            alert.show()
        }
        
        self.socket.on("gameOver") {data, ack in
            exit(0)
        }
        
        self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
    }
    
    @IBAction func btnClicked(btn:UIButton) {
        let coord:(x:Int, y:Int)
        
        switch btn.tag {
        case 0:
            coord = (0, 0)
        case 1:
            coord = (0, 1)
        case 2:
            coord = (0, 2)
        case 3:
            coord = (1, 0)
        case 4:
            coord = (1, 1)
        case 5:
            coord = (1, 2)
        case 6:
            coord = (2, 0)
        case 7:
            coord = (2, 1)
        case 8:
            coord = (2, 2)
        default:
            coord = (-1, -1)
        }
        
        self.socket.emit("playerMove", coord.x, coord.y)
    }
    
    func drawWinLine(type:NSDictionary) {
        let winType = type["type"] as! String
        let to:CGPoint
        let from:CGPoint
        
        if winType == "row" {
            let row = type["num"] as! Int
            
            switch row {
            case 0:
                to = self.btn2.center
                from = self.btn0.center
            case 1:
                to = self.btn3.center
                from = self.btn5.center
            case 2:
                to = self.btn6.center
                from = self.btn8.center
            default:
                to = CGPointMake(0.0, 0.0)
                from = CGPointMake(0.0, 0.0)
            }
        } else if winType == "col" {
            let row = type["num"] as! Int
            
            switch row {
            case 0:
                to = self.btn6.center
                from = self.btn0.center
            case 1:
                to = self.btn7.center
                from = self.btn1.center
            case 2:
                to = self.btn2.center
                from = self.btn8.center
            default:
                to = CGPointMake(0.0, 0.0)
                from = CGPointMake(0.0, 0.0)
            }
        } else {
            let anti = type["anti"] as! Bool
            let coord = type["coord"] as! NSDictionary
            let x = coord["x"] as! Int
            let y = coord["y"] as! Int
            
            switch (x, y) {
            case (0, 0):
                to = self.btn8.center
                from = self.btn0.center
            case (0, 2):
                to = self.btn6.center
                from = self.btn2.center
            case (2, 2):
                to = self.btn0.center
                from = self.btn8.center
            case (2, 0):
                to = self.btn2.center
                from = self.btn6.center
            default:
                to = CGPointMake(0.0, 0.0)
                from = CGPointMake(0.0, 0.0)
            }
        }
        
        let path = UIBezierPath()
        path.moveToPoint(from)
        path.addLineToPoint(to)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.view.layer.addSublayer(shapeLayer)
    }
    
    func handleCurrentTurn(name:String) {
        if name == self.name! {
            self.label.text = "Your turn!"
        } else {
            self.label.text = "Opponents turn!"
        }
    }
    
    func handleDraw() {
        self.label.text = "Draw!"
    }
    
    func handleGameReset() {
        self.btn0.setTitle("-", forState: UIControlState.Normal)
        self.btn1.setTitle("-", forState: UIControlState.Normal)
        self.btn2.setTitle("-", forState: UIControlState.Normal)
        self.btn3.setTitle("-", forState: UIControlState.Normal)
        self.btn4.setTitle("-", forState: UIControlState.Normal)
        self.btn5.setTitle("-", forState: UIControlState.Normal)
        self.btn6.setTitle("-", forState: UIControlState.Normal)
        self.btn7.setTitle("-", forState: UIControlState.Normal)
        self.btn8.setTitle("-", forState: UIControlState.Normal)
        
        self.btn0.enabled = true
        self.btn1.enabled = true
        self.btn2.enabled = true
        self.btn3.enabled = true
        self.btn4.enabled = true
        self.btn5.enabled = true
        self.btn6.enabled = true
        self.btn7.enabled = true
        self.btn8.enabled = true
        
        self.view.layer.sublayers.removeLast()
        self.label.text = "Waiting for Opponent"
    }
    
    func handlePlayerMove(name:String, coord:(Int, Int)) {
        switch coord {
        case (0, 0):
            self.btn0.setTitle(name, forState: UIControlState.Disabled)
            self.btn0.enabled = false
        case (0, 1):
            self.btn1.setTitle(name, forState: UIControlState.Disabled)
            self.btn1.enabled = false
        case (0, 2):
            self.btn2.setTitle(name, forState: UIControlState.Disabled)
            self.btn2.enabled = false
        case (1, 0):
            self.btn3.setTitle(name, forState: UIControlState.Disabled)
            self.btn3.enabled = false
        case (1, 1):
            self.btn4.setTitle(name, forState: UIControlState.Disabled)
            self.btn4.enabled = false
        case (1, 2):
            self.btn5.setTitle(name, forState: UIControlState.Disabled)
            self.btn5.enabled = false
        case (2, 0):
            self.btn6.setTitle(name, forState: UIControlState.Disabled)
            self.btn6.enabled = false
        case (2, 1):
            self.btn7.setTitle(name, forState: UIControlState.Disabled)
            self.btn7.enabled = false
        case (2, 2):
            self.btn8.setTitle(name, forState: UIControlState.Disabled)
            self.btn8.enabled = false
        default:
            return
        }
    }
    
    func handleStart() {
        if self.name == "X" {
            self.label.text = "Your turn!"
        } else {
            self.label.text = "Opponents turn"
        }
    }
    
    func handleWin(name:String, type:NSDictionary) {
        self.label.text = "Player \(name) won!"
        self.drawWinLine(type)
    }
    
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int) {
        if buttonIndex == 0 {
            self.resetAck?(false)
        } else {
            self.handleGameReset()
            self.resetAck?(true)
        }
    }
}

