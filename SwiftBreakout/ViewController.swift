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
    @IBOutlet var skView : SKView
    @IBOutlet var padSlider : UISlider
    @IBOutlet var lifeLabel : UILabel
    @IBOutlet var gameOverButton : UIButton
    @IBOutlet var gameClearButton : UIButton

    var _myScene : MyScene!
    var _readyToFire = false
    var _lifeCount = 0

    func updateLifeLabel() {
        lifeLabel.text = String(_lifeCount)
    }

    func gameStart() {
        _lifeCount = 10
        updateLifeLabel()
        gameOverButton.hidden = true
        gameClearButton.hidden = true
        
        _myScene.reset()
        _readyToFire = true
    }

    @IBAction func restart(_ : AnyObject) {
        _myScene.respawn({ self.gameStart() })
    }
    
    func respawn() {
        _myScene.respawn({ self._readyToFire = true })
    }
    
    func dead() {
        _lifeCount--
        updateLifeLabel()
        
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
    
    @IBAction func padSliderMoved(sender : UISlider) {
        if _readyToFire {
            _myScene.fire()
            _readyToFire = false
        }
        _myScene.padX = sender.value
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let skView = self.skView
        _myScene = MyScene(size: skView.frame.size)
        skView.presentScene(_myScene)

        padSlider.minimumValue = 0
        padSlider.maximumValue = _myScene.size.width
        padSlider.value = _myScene.padX
        
        _myScene.mySceneDelegate = self
        gameStart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

