//
//  ViewController.swift
//  SwiftBreakout
//
//  Created by Naoto Yoshioka on 2014/06/03.
//  Copyright (c) 2014年 Naoto Yoshioka. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, MySceneDelegate {
    @IBOutlet weak var skView : SKView!
    @IBOutlet weak var padSlider : UISlider!
    @IBOutlet weak var lifeLabel : UILabel!
    @IBOutlet weak var gameOverButton : UIButton!
    @IBOutlet weak var gameClearButton : UIButton!

    var _myScene : MyScene!
    var _readyToFire = false
    var _lifeCount : Int = 0 {
    didSet {
        lifeLabel.text = String(_lifeCount)
    }
    }

    func gameStart() {
        _lifeCount = 10
        gameOverButton.hidden = true
        gameClearButton.hidden = true
        
        _myScene.reset()
        _readyToFire = true
    }

    @IBAction func restart(_ : AnyObject) {
        _myScene.respawn(completion:{ self.gameStart() })
    }
    
    func respawn() {
        _myScene.respawn(completion:{ self._readyToFire = true })
    }
    
    func dead() {
        _lifeCount--
        
        if 0 < _lifeCount {
            NSTimer.scheduledTimerWithTimeInterval(3.0,
                target:self, selector:"respawn",
                userInfo:nil, repeats:false)
        } else {
            gameOverButton.hidden = false
        }
        _readyToFire = false
    }
    
    func clear() {
        gameClearButton.hidden = false
        _readyToFire = false
    }

    func setPadPosition(value:Float) {
        if _readyToFire {
            _myScene.fire()
            _readyToFire = false
        }
        _myScene.padX = value
    }
    
    @IBAction func padSliderMoved(sender : UISlider) {
        setPadPosition(sender.value)
    }
    
    @IBAction func pan(sender : UIPanGestureRecognizer) {
        let value = Float(sender.locationInView(_myScene.view).x)
        padSlider.value = value
        setPadPosition(value)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        _myScene = MyScene(size: skView.frame.size)
        skView.presentScene(_myScene)

        padSlider.minimumValue = 0
        padSlider.maximumValue = Float(_myScene.size.width)
        padSlider.value = Float(_myScene.padX)
        
        _myScene.mySceneDelegate = self
        gameStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

