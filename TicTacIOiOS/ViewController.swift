//
//  ViewController.swift
//  TicTacIOiOS
//
//  Created by Erik Little on 3/7/15.
//

import UIKit
import SocketIO

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
    let manager = SocketManager(socketURL: URL(string: "http://localhost:8900")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    var name: String?
    var resetAck: SocketAckEmitter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket = manager.defaultSocket
        
        addHandlers()
        socket.connect()
        
        let grad = CAGradientLayer()
        grad.frame = self.view.bounds
        
        let colors = [UIColor(red: 127, green: 0, blue: 127, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor]
        
        grad.colors = colors
        view.layer.insertSublayer(grad, at: 0)
    }
    
    func addHandlers() {
        socket.on("startGame") {[weak self] data, ack in
            self?.handleStart()
            return
        }
        
        socket.on("name") {[weak self] data, ack in
            if let name = data[0] as? String {
                self?.name = name
            }
        }
        
        socket.on("playerMove") {[weak self] data, ack in
            if let name = data[0] as? String, let x = data[1] as? Int, let y = data[2] as? Int {
                self?.handlePlayerMove(name, coord: (x, y))
            }
        }
        
        socket.on("win") {[weak self] data, ack in
            if let name = data[0] as? String, let typeDict = data[1] as? NSDictionary {
                self?.handleWin(name, type: typeDict)
            }
        }
        
        socket.on("draw") {[weak self] data, ack in
            self?.handleDraw()
            return
        }
        
        socket.on("currentTurn") {[weak self] data, ack in
            if let name = data[0] as? String {
                self?.handleCurrentTurn(name)
                
            }
        }
        
        socket.on("gameReset") {[weak self] data, ack in
            guard let sself = self else { return }
            self?.resetAck = ack
            self?.present(sself.alertController, animated: true, completion: nil)
        }
        
        socket.on("gameOver") {data, ack in
            exit(0)
        }
        
        socket.onAny {print("Got event: \($0.event), with items: \($0.items!)")}
    }
    
    @IBAction func btnClicked(_ btn: UIButton) {
        let coord:(x: Int, y: Int)
        
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
        
        socket.emit("playerMove", coord.x, coord.y)
    }
    
    func drawWinLine(_ type: NSDictionary) {
        let winType = type["type"] as! String
        let to: CGPoint
        let from: CGPoint
        
        if winType == "row" {
            let row = type["num"] as! Int
            
            switch row {
            case 0:
                to = btn2.center
                from = btn0.center
            case 1:
                to = btn3.center
                from = btn5.center
            case 2:
                to = btn6.center
                from = btn8.center
            default:
                to = CGPoint(x: 0.0, y: 0.0)
                from = CGPoint(x: 0.0, y: 0.0)
            }
        } else if winType == "col" {
            let row = type["num"] as! Int
            
            switch row {
            case 0:
                to = btn6.center
                from = btn0.center
            case 1:
                to = btn7.center
                from = btn1.center
            case 2:
                to = btn2.center
                from = btn8.center
            default:
                to = CGPoint(x: 0.0, y: 0.0)
                from = CGPoint(x: 0.0, y: 0.0)
            }
        } else {
            let coord = type["coord"] as! NSDictionary
            let x = coord["x"] as! Int
            let y = coord["y"] as! Int
            
            switch (x, y) {
            case (0, 0):
                to = btn8.center
                from = btn0.center
            case (0, 2):
                to = btn6.center
                from = btn2.center
            case (2, 2):
                to = btn0.center
                from = btn8.center
            case (2, 0):
                to = btn2.center
                from = btn6.center
            default:
                to = CGPoint(x: 0.0, y: 0.0)
                from = CGPoint(x: 0.0, y: 0.0)
            }
        }
        
        let path = UIBezierPath()
        path.move(to: from)
        path.addLine(to: to)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(shapeLayer)
    }
    
    func handleCurrentTurn(_ name: String) {
        if name == self.name! {
            label.text = "Your turn!"
        } else {
            label.text = "Opponents turn!"
        }
    }
    
    func handleDraw() {
        label.text = "Draw!"
    }
    
    func handleGameReset() {
        btn0.setTitle("-", for: UIControl.State())
        btn1.setTitle("-", for: UIControl.State())
        btn2.setTitle("-", for: UIControl.State())
        btn3.setTitle("-", for: UIControl.State())
        btn4.setTitle("-", for: UIControl.State())
        btn5.setTitle("-", for: UIControl.State())
        btn6.setTitle("-", for: UIControl.State())
        btn7.setTitle("-", for: UIControl.State())
        btn8.setTitle("-", for: UIControl.State())
        
        btn0.isEnabled = true
        btn1.isEnabled = true
        btn2.isEnabled = true
        btn3.isEnabled = true
        btn4.isEnabled = true
        btn5.isEnabled = true
        btn6.isEnabled = true
        btn7.isEnabled = true
        btn8.isEnabled = true
        
        view.layer.sublayers?.removeLast()
        label.text = "Waiting for Opponent"
    }
    
    func handlePlayerMove(_ name: String, coord: (Int, Int)) {
        switch coord {
        case (0, 0):
            btn0.setTitle(name, for: .disabled)
            btn0.isEnabled = false
        case (0, 1):
            btn1.setTitle(name, for: .disabled)
            btn1.isEnabled = false
        case (0, 2):
            btn2.setTitle(name, for: .disabled)
            btn2.isEnabled = false
        case (1, 0):
            btn3.setTitle(name, for: .disabled)
            btn3.isEnabled = false
        case (1, 1):
            btn4.setTitle(name, for: .disabled)
            btn4.isEnabled = false
        case (1, 2):
            btn5.setTitle(name, for: .disabled)
            btn5.isEnabled = false
        case (2, 0):
            btn6.setTitle(name, for: .disabled)
            btn6.isEnabled = false
        case (2, 1):
            btn7.setTitle(name, for: .disabled)
            btn7.isEnabled = false
        case (2, 2):
            btn8.setTitle(name, for: .disabled)
            btn8.isEnabled = false
        default:
            return
        }
    }
    
    func handleStart() {
        if name == "X" {
            label.text = "Your turn!"
        } else {
            label.text = "Opponents turn"
        }
    }
    
    func handleWin(_ name: String, type: NSDictionary) {
        label.text = "Player \(name) won!"
        drawWinLine(type)
    }
    
    var alertController: UIAlertController {
        let alert = UIAlertController(title: "Play Again?",
                                      message: "Do you want to play another round?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { [weak self] action in
            self?.resetAck?.with(false)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
            self?.handleGameReset()
            self?.resetAck?.with(true)
        }))
        return alert
    }
}

