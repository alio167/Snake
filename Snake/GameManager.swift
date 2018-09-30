//
//  GameManager.swift
//  Snake
//
//  Created by clinic18 on 9/22/18.
//  Copyright © 2018 Ali Otondo. All rights reserved.
//

import SpriteKit

class GameManager {
    var scene: GameScene!
    var nextTime: Double?
    var timeExtension: Double = 0.15
    var playerDirection: Int = 4 // 1 is left, 2 is up, 3 is right, 4 is down
    var currentScore: Int = 0
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    // Adds starting snake position
    func initGame() {
        scene.playerPositions.append((10,10))
        scene.playerPositions.append((10,11))
        scene.playerPositions.append((10,12))
        renderChange()
        generateNewPoint()
    }
    
    // Check if the snake has hit the target
    private func checkForScore() {
        if scene.targetPos != nil {
            let x = scene.playerPositions[0].0
            let y = scene.playerPositions[0].1
            if Int((scene.targetPos?.x)!) == y && Int((scene.targetPos?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
            }
        }
    }
    
    // Generates random target cell
    private func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(19))
        var randomY = CGFloat(arc4random_uniform(39))
        
        // Make sure target is not generated inside snake
        while contains(a: scene.playerPositions, v: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(19))
            randomY = CGFloat(arc4random_uniform(39))
        }
        
        // Update target position
        scene.targetPos = CGPoint(x: randomX, y: randomY)
    }
    
    // Updates snake position every second.
    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeExtension
        } else {
            if time >= nextTime! {
                nextTime = time + timeExtension
                updatePlayerPosition()
                checkForScore()
                checkForDeath()
                finishAnimation()
            }
        }
    }
    
    // Go back to menu
    private func finishAnimation() {
        if playerDirection == 0 && scene.playerPositions.count > 0 {
            var hasFinished = true
            let headOfSnake = scene.playerPositions[0]
            for position in scene.playerPositions {
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            
            if hasFinished {
                print("end game")
                updateScore()
                playerDirection = 4
                
                // restart data
                scene.targetPos = nil
                scene.playerPositions.removeAll()
                renderChange()
                
                // return to menu
                scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.currentScore.isHidden = true
                }
                scene.gameBG.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.gameBG.isHidden = true
                    self.scene.gameLogo.isHidden = false
                    self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                        self.scene.playButton.isHidden = false
                        self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                        self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
                    }
                }
            }
        }
    }
    
    private func updateScore() {
        if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
            UserDefaults.standard.set(currentScore, forKey: "bestScore")
        }
        currentScore = 0
        scene.currentScore.text = "Score: 0"
        scene.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
    
    // Checks if the snake ran into itself
    private func checkForDeath() {
        if scene.playerPositions.count > 0 {
            var arrayOfPositions = scene.playerPositions
            let headOfSnake = arrayOfPositions[0]
            arrayOfPositions.remove(at: 0)
            if contains(a: arrayOfPositions, v: headOfSnake) {
                playerDirection = 0
            }
        }
    }
    
    // Called every time snake is moved. Updates snake position on screen.
    func renderChange() {
        for (node, x, y) in scene.gameArray {
            if contains(a: scene.playerPositions, v: (x,y)) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
                
                // If the node is the target, make it red
                if scene.targetPos != nil {
                    if Int((scene.targetPos?.x)!) == y && Int((scene.targetPos?.y)!) == x {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
    }
    
    // Checks if a coordinate, v, is contained in an array of coordinates, a.
    func contains(a: [(Int, Int)], v: (Int, Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a {
            if v1 == c1 && v2 == c2 {
                return true
            }
        }
        return false
    }
    
    // Updates the snake's position
    private func updatePlayerPosition() {
        var xChange = -1
        var yChange = 0
        
        // Update the direction of the snake
        switch playerDirection {
            case 1:
                // left
                xChange = -1
                yChange = 0
                break
            case 2:
                // up
                xChange = 0
                yChange = -1
            case 3:
                // right
                xChange = 1
                yChange = 0
            case 4:
                // down
                xChange = 0
                yChange = 1
            case 0:
                // dead
                xChange = 0
                yChange = 0
                break
            default:
                break
        }
        
        // Move each part of the snake forward
        if scene.playerPositions.count > 0 {
            var start = scene.playerPositions.count - 1
            
            // Move everything but the snake's head
            while start > 0 {
                scene.playerPositions[start] = scene.playerPositions[start - 1]
                start -= 1
            }
            
            // Move the snake's head in the correct direction.
            scene.playerPositions[0] = (scene.playerPositions[0].0 + yChange, scene.playerPositions[0].1 + xChange)
        }
        
        // Check if the snake ran into the wall
        if scene.playerPositions.count > 0 {
            let x = scene.playerPositions[0].1
            let y = scene.playerPositions[0].0
            if y > 40 || y < 0 || x > 20 || x < 0 {
                playerDirection = 0
            }
        }
        
        // Update the screen
        renderChange()
    }
    
    // Detect swipe direction
    func swipe(ID: Int) {
        // Check for conflicting directions
        if !(ID == 2 && playerDirection == 4) &&
            !(ID == 4 && playerDirection == 2) &&
            !(ID == 1 && playerDirection == 3) &&
            !(ID == 3 && playerDirection == 1) &&
            playerDirection != 0 {
            playerDirection = ID
        }
    }
}
