//
//  ViewController.swift
//  MyLittleMonster
//
//  Created by Bem on 6/13/16.
//  Copyright © 2016 Bem. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImage: MonsterImg!
    @IBOutlet weak var heartImage: DragImage!
    @IBOutlet weak var foodImage: DragImage!
    @IBOutlet weak var skullOneImage: UIImageView!
    @IBOutlet weak var skullTwoImage: UIImageView!
    @IBOutlet weak var skullThreeImage: UIImageView!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_SKULLS = 3
    
    var skulls = 0
    var timer: NSTimer!
    var monsterHappy: Bool = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skullOneImage.alpha = DIM_ALPHA
        skullTwoImage.alpha = DIM_ALPHA
        skullThreeImage.alpha = DIM_ALPHA
        
        foodImage.dropTarget = monsterImage
        heartImage.dropTarget = monsterImage
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:
            #selector(ViewController.itemDroppedOnCharacter), name: "onTargetDropped", object: nil)
        
        do {
            try musicPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!))
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxSkull.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        startTimer()
        
    }
    
    
    func itemDroppedOnCharacter(notif: AnyObject) {
        monsterHappy = true
        startTimer()
        
        foodImage.alpha = DIM_ALPHA
        foodImage.userInteractionEnabled = false
        heartImage.alpha = DIM_ALPHA
        heartImage.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else {
            sfxBite.play()
        }
    }
    
    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(ViewController.changeGameState), userInfo: nil, repeats: true)
        
    }
    
    func gameOver() {
        timer.invalidate()
        monsterImage.playDeathAnimation()
        sfxDeath.play()
    }
    
    func changeGameState() {
        if !monsterHappy {
            
            skulls += 1
            sfxSkull.play()
            if skulls == 1 {
                skullOneImage.alpha = OPAQUE
                skullTwoImage.alpha = DIM_ALPHA
            } else if skulls == 2 {
                skullTwoImage.alpha = OPAQUE
                skullThreeImage.alpha = DIM_ALPHA
            } else if skulls >= 3 {
                skullThreeImage.alpha = OPAQUE
            } else {
                skullOneImage.alpha = DIM_ALPHA
                skullTwoImage.alpha = DIM_ALPHA
                skullThreeImage.alpha = DIM_ALPHA
            }
        }
        
        let rand = arc4random_uniform(2)
        
        if rand == 0 {
            foodImage.alpha = DIM_ALPHA
            heartImage.alpha = OPAQUE
            foodImage.userInteractionEnabled = false
            heartImage.userInteractionEnabled = true
        } else {
            foodImage.alpha = OPAQUE
            heartImage.alpha = DIM_ALPHA
            foodImage.userInteractionEnabled = true
            heartImage.userInteractionEnabled = false
        }
        
        currentItem = rand
        monsterHappy = false
        
        if skulls >= MAX_SKULLS {
            gameOver()
        }
    }
}

