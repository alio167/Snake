//
//  GameScene.swift
//  Snake
//
//  Created by clinic18 on 9/22/18.
//  Copyright © 2018 Ali Otondo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    // Declare the game menu objects
    var gameLogo:SKLabelNode!
    var bestScore:SKLabelNode!
    var playButton: SKShapeNode!
    
    // Declare the game manager
    var game: GameManager!
    
    // Declare the game objects
    var currentScore: SKLabelNode!
    var playerPosition: [(Int, Int)] = []
    var gameBG: SKShapeNode!
    var gameArray: [(node: SKShapeNode, x: Int, y: Int)] = []
    
    // This function is called once GameScene has loaded
    override func didMove(to view: SKView) {
        // Create the game menu
        initializeMenu()
        
        // Initialize game
        game = GameManager()
        
        // Create the game view
        initializeGameView()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    // This function creates the game menu
    private func initializeMenu() {
        // Initialize gameLogo and add it to GameScene
        gameLogo = SKLabelNode(fontNamed: "ArielRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 60
        gameLogo.text = "SNAKE"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        
        // Initialize bestScore and add it to GameScene
        bestScore = SKLabelNode(fontNamed: "ArielRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: 0"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        
        // Initialize playButton
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        
        // Make triangle shape
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        
        // Make playButton a triangle and add it to GameScene
        playButton.path = path
        self.addChild(playButton)
    }
    
    // This function is called when the user taps on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    // The user has tapped the play button
                    startGame()
                }
            }
        }
    }
    
    // This function starts the snake game
    private func startGame() {
        print("start game")
        
        // Move gameLogo up and off of the screen
        gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameLogo.isHidden = true
        }
        
        // Scale playButton down until it disappears
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        
        // Move bottomCorner down to the bottom of the screen
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4)) {
            self.gameBG.setScale(0)
            self.currentScore.setScale(0)
            self.gameBG.isHidden = false
            self.currentScore.isHidden = false
            self.gameBG.run(SKAction.scale(to: 1, duration: 0.4))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
        }
    }
    
    // This function creates the game view
    private func initializeGameView() {
        // Initialize currentScore
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
        
        // Initialize gameBG
        let width = 550
        let height = 1100
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBG.fillColor = SKColor.darkGray
        gameBG.zPosition = 2
        gameBG.isHidden = true
        self.addChild(gameBG)
        
        // Create the game board
        createGameBoard(width: width, height: Int(height))
    }
    
    // This function creates the game board
    private func createGameBoard(width: Int, height: Int) {
        let cellWidth: CGFloat = 27.5
        let numRows = 40
        let numCols = 20
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        
        // Loop through rows and columns, create cells
        for i in 0..<numRows{
            for j in 0..<numCols {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                
                // add to array of cells, then to game board
                gameArray.append((node: cellNode, x: i, y: j))
                gameBG.addChild(cellNode)
                
                // iterate x
                x += cellWidth
            }
            
            // reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
}
