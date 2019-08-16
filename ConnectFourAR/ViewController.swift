//
//  ViewController.swift
//  ConnectFourAR
//
//  Created by joconnor on 8/12/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var redNodeModel: SCNNode!
    var blackNodeModel: SCNNode!
    var gameBoardModel: SCNNode!
    var redCrownNodeModel: SCNNode!
    var blackCrownNodeModel: SCNNode!
    let redName = "redPiece"
    let blackName = "blackPiece"
    let boardName = "gameBoard"
    let redCrownName = "redCrown"
    let blackCrownName = "blackCrown"
    
    
    var boardX: Float!
    var boardY: Float!
    var boardZ: Float!
    var gameBoardMat: simd_float4x4!
    
    var turnCount: Int = 0
    var isBoardSet = false
    
    var planes = [ARPlaneAnchor: Plane]()
    var boardPlane: Plane!
    
    var boardColumnCoords: [Float]!
    var boardsRowCoords: [Float]!
    var boardContents: [Int] = [0, 0, 0, 0, 0, 0, 0]
    
    var boardData = BoardData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let modelSceneBoard = SCNScene(named: "art.scnassets/connectFourBoardPack/connectFourBoard.dae")!
        gameBoardModel = modelSceneBoard.rootNode.childNode(withName: boardName, recursively: true)
        
        let modelSceneRed = SCNScene(named: "art.scnassets/redPiecePack/redPiece.dae")!
        redNodeModel = modelSceneRed.rootNode.childNode(withName: redName, recursively: true)
        
        let modelSceneBlack = SCNScene(named: "art.scnassets/blackPiecePack/blackPiece.dae")!
        blackNodeModel = modelSceneBlack.rootNode.childNode(withName: blackName, recursively: true)
        
        let modelCrownRed = SCNScene(named: "art.scnassets/redCrown/redCrowndae.dae")!
        redCrownNodeModel = modelCrownRed.rootNode.childNode(withName: redCrownName, recursively: true)
        
        let modelCrownBlack = SCNScene(named: "art.scnassets/blackCrown/blackCrown.dae")!
        blackCrownNodeModel = modelCrownBlack.rootNode.childNode(withName: blackCrownName, recursively: true)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                let modelClone: SCNNode
                
                if self.boardData.getGameOver() {
                    if self.boardData.getCurrentPlayer() == .red {
                        modelClone = self.redCrownNodeModel.clone()
                    } else {
                        modelClone = self.blackCrownNodeModel.clone()
                    }
                    modelClone.position = SCNVector3Zero
                    node.addChildNode(modelClone)
                    return
                }
                
                if !self.isBoardSet {
                    modelClone = self.gameBoardModel.clone()
                    modelClone.position = SCNVector3Zero
                    node.addChildNode(modelClone)
                    self.isBoardSet = true
                    print("% the board was set")
                    return
                } else {
                    if self.boardData.getCurrentPlayer() == .red {
                        modelClone = self.redNodeModel.clone()
                    } else {
                        modelClone = self.blackNodeModel.clone()
                    }
                    modelClone.position = SCNVector3Zero
                    node.addChildNode(modelClone)
                    self.turnCount += 1
                }
            }
        }
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    func addPlane(on vector: SCNVector3 = SCNVector3(0, 0, -0.5)) {
        
        let plane = Plane(content: UIColor.clear, doubleSided: true, horizontal: false)
        plane.position = vector
        self.sceneView.scene.rootNode.addChildNode(plane)
        self.boardPlane = plane
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        if isBoardSet {
            if boardData.getGameOver() {return}
            let planeHitResults: [SCNHitTestResult] =
                sceneView.hitTest(location, options: nil)
            if let hit = planeHitResults.first {
                
                var simMat = matrixConvert(from: hit.modelTransform)
                
                let columnIndex = convertXCoordToColumn(from: hit.localCoordinates.x)
                if columnIndex > 6 || columnIndex < 0 {return}
                
                let targetRow = self.boardContents[columnIndex]
                if targetRow > 5 {return}
                
                print("% local coordinates \(hit.localCoordinates)")
                print("% world coordinates \(hit.worldCoordinates)")
                print("% column index \(columnIndex)")
                
                let newXCoord = self.boardColumnCoords[columnIndex]
                let newYCoord = self.boardsRowCoords[targetRow]
                
                simMat.columns.3.x = newXCoord
                simMat.columns.3.y = newYCoord
                simMat.columns.3.z = self.boardZ ?? 0
                self.boardContents[columnIndex] = boardContents[columnIndex] + 1

                print("% local coordinates \(hit.localCoordinates)")
                sceneView.session.add(anchor: ARAnchor(transform: simMat))
                
                moveAndUpdateUI(index: columnIndex)
            }
        } else {
            let hitResultsFeaturePoints: [ARHitTestResult] =
                sceneView.hitTest(location, types: .featurePoint)
            if let hit = hitResultsFeaturePoints.first {
                
                var modTransform = hit.worldTransform
                modTransform.columns.3.y = modTransform.columns.3.y + 0.08
                
                self.gameBoardMat = modTransform
                self.boardX = modTransform.columns.3.x
                self.boardY = modTransform.columns.3.y + 0.08
                self.boardZ = modTransform.columns.3.z
                self.boardColumnCoords = createColumnXCoords(from: self.boardX)
                self.boardsRowCoords = createRowYCoords(from: self.boardY)
                
                sceneView.session.add(anchor: ARAnchor(transform: modTransform))
                addPlane(on: SCNVector3(self.boardX, self.boardY - 0.08, self.boardZ))
            }
        }
        if boardData.getGameOver() {
            var crownMat = self.gameBoardMat
            let yCoord = crownMat?.columns.3.y
            crownMat?.columns.3.y = yCoord! + 0.2
            //sceneView.session.add(anchor: ARAnchor(transform: crownMat!))
        }
    }
    
    func matrixConvert(from oldMat: SCNMatrix4) -> simd_float4x4 {
        let col1: simd_float4 = float4(x: oldMat.m11, y: oldMat.m12, z: oldMat.m13, w: oldMat.m14)
        let col2: simd_float4 = float4(x: oldMat.m21, y: oldMat.m22, z: oldMat.m23, w: oldMat.m24)
        let col3: simd_float4 = float4(x: oldMat.m31, y: oldMat.m32, z: oldMat.m33, w: oldMat.m34)
        let col4: simd_float4 = float4(x: oldMat.m41, y: oldMat.m42, z: oldMat.m43, w: oldMat.m44)
        let resultMat: simd_float4x4 = simd_float4x4(columns: (col1, col2, col3, col4))
        return resultMat
    }
    
    func convertXCoordToColumn(from xCoord: Float) -> Int {
        let dividend = (xCoord - 0.02) / 0.055
        return Int(dividend + 4)
    }
    
    func createColumnXCoords(from boardCenter: Float) -> [Float] {
        let columnCoords: [Float] =  [boardCenter - 0.16,
                                      boardCenter - 0.105,
                                      boardCenter - 0.055,
                                      boardCenter,
                                      boardCenter + 0.055,
                                      boardCenter + 0.105,
                                      boardCenter + 0.16]
        return columnCoords
    }
    
    func createRowYCoords(from boardCenter: Float) -> [Float] {
        let rowCoords: [Float] =  [boardCenter - 0.21,
                                   boardCenter - 0.16,
                                   boardCenter - 0.11,
                                   boardCenter - 0.06,
                                   boardCenter - 0.01,
                                   boardCenter + 0.035]
        return rowCoords
    }

    @objc func tapped(recognizer :UIGestureRecognizer) {
        let touchPosition = recognizer.location(in: sceneView)
        
        let hitTestResult = sceneView.hitTest(touchPosition, types: .featurePoint)
        
        if !hitTestResult.isEmpty {
            guard let hitResult = hitTestResult.first else {
                return
            }
        }
    }
    
    func moveAndUpdateUI(index: Int) {
        
        if (self.boardData.getGameOver()) {
            return
        }
        
        let player: Player  = self.boardData.getCurrentPlayer()
        self.boardData.changeCurrentPlayer()
        
        guard let indexFound: Int = index else {
            print("Something was nil")
            return
        }
        
        print("column \(indexFound) has been tapped")
        
        let moveValid = boardData.makeMove(column: indexFound)
        if (moveValid != -1) {
            print("move is good to go")
        } else {
            print("cannot make the move for some reason")
            return
        }
        
        let win = boardData.checkWin(column: indexFound, row: moveValid)
        if (win) {
            boardData.changeGameOver()
            print("I have made it to this point")
            return
        }
        print("Winning move --> \(win)")
    }
}
