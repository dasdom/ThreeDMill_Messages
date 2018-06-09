//  Created by dasdom on 10.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
import SceneKit
import ThreeDMillBoard

protocol GameViewProtocol: class {
    func insert(color: SphereColor) -> GameSphereNode
    func pole(for node: SCNNode) -> (Int, Int)?
}

final class GameView: SCNView, GameViewProtocol {

    let cameraNode: SCNNode
    let cameraOrbit: SCNNode
    let spotLightNode: SCNNode
    let baseNode: SCNNode
    var poleNodes: [[SCNNode]]
    let textNode: SCNNode
    let textOrbit: SCNNode
    private var startAngleY: Float = 0.0
    private var startPositionY: Float = 0.0
    let remainingWhiteSpheresLabel: UILabel
    let remainingWhiteInfoStackView: UIStackView
    let doneButton: UIButton
    let tutorialButton: UIButton
    let continueButton: UIButton
    let remainingRedSpheresLabel: UILabel
    let remainingRedInfoStackView: UIStackView
    var gameSphereNodes: [[[GameSphereNode]]] = []
    let surrenderButton: UIButton
    let reanimateButton: UIButton
    let emitter = SCNParticleSystem(named: "confetti", inDirectory: nil)
    let infoLabel: UILabel
    static let startY: Float = 25.0
    static let preAnimationStartPosition = SCNVector3(x: 0, y: GameView.startY+20, z: 0)
    static let startPosition = SCNVector3(x: 0, y: GameView.startY, z: 0)

    override init(frame: CGRect, options: [String : Any]? = nil) {
        
        let groundNode = GameNodeFactory.ground()
        
        let constraint = SCNLookAtConstraint(target: groundNode)
        constraint.isGimbalLockEnabled = true
        constraint.influenceFactor = 0.8
        
        cameraNode = GameNodeFactory.camera(constraint: constraint)
        
        cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        
        spotLightNode = GameNodeFactory.spotLight(constraint: constraint)
        
        baseNode = GameNodeFactory.base()
        
        poleNodes = GameNodeFactory.poles(columns: Board.numberOfColumns)
        
        textNode = GameNodeFactory.text(string: "Mill")
        
        textOrbit = SCNNode()
        textOrbit.addChildNode(textNode)
        
        let whiteView = GameViewFactory.colorIndicatorView(UIColor.white)
        remainingWhiteSpheresLabel = GameViewFactory.remainingSpheresLable()
        remainingWhiteInfoStackView = GameViewFactory.remainingInfoStackView(views: [whiteView, remainingWhiteSpheresLabel])
        
        let redView = GameViewFactory.colorIndicatorView(UIColor.red)
        remainingRedSpheresLabel = GameViewFactory.remainingSpheresLable()
        remainingRedInfoStackView = GameViewFactory.remainingInfoStackView(views: [redView, remainingRedSpheresLabel])

        doneButton = GameViewFactory.button(title: "3", fontSize: 30)
        doneButton.isHidden = true
        
        continueButton = GameViewFactory.button(title: "Continue", fontSize: 15)
        continueButton.isHidden = true
        
        tutorialButton = GameViewFactory.button(title: "Tutorial", fontSize: 15)
        tutorialButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        tutorialButton.addTarget(nil, action: .help, for: .touchUpInside)

        surrenderButton = GameViewFactory.button(title: "Surrender", fontSize: 15)
        surrenderButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        surrenderButton.addTarget(nil, action: .surrender, for: .touchUpInside)
        
        reanimateButton = GameViewFactory.button(title: "Reanimate", fontSize: 15)
        reanimateButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        reanimateButton.addTarget(nil, action: .reanimate, for: .touchUpInside)
        reanimateButton.isEnabled = false
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 0
        infoLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.6)
        infoLabel.textColor = UIColor.white
        infoLabel.isHidden = true
        
        super.init(frame: frame, options: options)
        
        backgroundColor = UIColor.black
        
        doneButton.addTarget(nil, action: .done, for: .touchUpInside)
        continueButton.addTarget(nil, action: .continueWithGame, for: .touchUpInside)
        
        showsStatistics = true

        scene = SCNScene()
        
        scene?.rootNode.addChildNode(groundNode)
        scene?.rootNode.addChildNode(baseNode)
        scene?.rootNode.addChildNode(cameraOrbit)
        cameraOrbit.addChildNode(spotLightNode)
        scene?.rootNode.addChildNode(textOrbit)

        for j in 0..<Board.numberOfColumns {
            for i in 0..<Board.numberOfColumns {
                scene?.rootNode.addChildNode(poleNodes[j][i])
            }
        }
        
        addSubview(remainingRedInfoStackView)
        addSubview(remainingWhiteInfoStackView)
        addSubview(doneButton)
        addSubview(tutorialButton)
        addSubview(continueButton)
        addSubview(surrenderButton)
        addSubview(reanimateButton)
        addSubview(infoLabel)
        
        remainingRedInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        remainingWhiteInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOSApplicationExtension 11.0, *) {
            NSLayoutConstraint.activate([
                remainingRedInfoStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
                remainingRedInfoStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                remainingWhiteInfoStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
                remainingWhiteInfoStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                continueButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                surrenderButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                ])
        } else {
            NSLayoutConstraint.activate([
                remainingRedInfoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                remainingRedInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                remainingWhiteInfoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                remainingWhiteInfoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                doneButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                continueButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                ])
        }
        NSLayoutConstraint.activate([
            doneButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            continueButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            surrenderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            tutorialButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            tutorialButton.topAnchor.constraint(equalTo: surrenderButton.topAnchor),
            reanimateButton.leadingAnchor.constraint(equalTo: surrenderButton.trailingAnchor, constant: 10),
            reanimateButton.topAnchor.constraint(equalTo: surrenderButton.topAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            infoLabel.bottomAnchor.constraint(equalTo: remainingRedInfoStackView.topAnchor, constant: -10)
            ])
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        addGestureRecognizer(panRecognizer)
        
        for _ in 0..<Board.numberOfColumns {
            var rows: [[GameSphereNode]] = []
            for _ in 0..<Board.numberOfColumns {
                rows.append([])
            }
            gameSphereNodes.append(rows)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension GameView {
    
    func update(with board: Board) {
        
        // First remove all remaining shperes.
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                for sphereNode in gameSphereNodes[column][row] {
                    sphereNode.removeFromParentNode()
                }
            }
        }
        
        // Add spheres as they are stored in the board.
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                let pole = board.poles[column][row]
                let poleNode = poleNodes[column][row]
                for (index, sphereColor) in pole.sphereColors.enumerated() {
                    
                    let sphere = GameSphereNode.standardSphere(color: sphereColor)
                    sphere.isMoving = false
                    var position = poleNode.position
                    position.y = 2.0 + 3.5 * Float(index)
                    sphere.position = position
                    scene?.rootNode.addChildNode(sphere)
                    
//                    print("update: \(column), \(row)")
                    gameSphereNodes[column][row].append(sphere)
                }
            }
        }
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self)
        
        switch sender.state {
        case .began:
            startAngleY = cameraOrbit.eulerAngles.y
//            startAngleY = baseNode.eulerAngles.y
            startPositionY = cameraOrbit.position.y
//            startAngleSpotY = spotLightNode.eulerAngles.y
        default:
            break
        }
        
//        print("translation: \(translation)")
        if abs(translation.x) < abs(translation.y) {
            let positionY = startPositionY + Float(translation.y)/6.0
            if positionY > -10, positionY < 20 {
                cameraOrbit.position.y = positionY
//                print("positionY: \(positionY)")
//            } else {
//                print("-10 < \(positionY)")
            }
        } else {
            cameraOrbit.eulerAngles.y = startAngleY - GLKMathDegreesToRadians(Float(translation.x))
            
//            spotLightNode.eulerAngles.y = startAngleSpotY - GLKMathDegreesToRadians(Float(translation.x))
        }
    }

    @discardableResult func insert(color sphereColor: SphereColor) -> GameSphereNode {
        
        let sphere = GameSphereNode.standardSphere(color: sphereColor)
        sphere.position = GameView.preAnimationStartPosition
        
//        gameSphereNodes.append(sphere)
        scene?.rootNode.addChildNode(sphere)
        
        DispatchQueue.main.async {
            let moveToStart = SCNAction.move(to:GameView.startPosition, duration: 0.5)
            sphere.runAction(moveToStart)
        }
        
        return sphere
    }
    
    func add(_ sphereNode: GameSphereNode, toColumn: Int, andRow: Int) {
        gameSphereNodes[toColumn][andRow].append(sphereNode)
//        print(gameSphereNodes)
    }
    
    func topSphereAt(column: Int, row: Int) -> GameSphereNode? {
        return gameSphereNodes[column][row].last
    }
    
    func removeTopSphereAt(column: Int, row: Int) -> GameSphereNode? {
        if gameSphereNodes[column][row].count < 1 {
            return nil
        }
        let sphereToRemove = gameSphereNodes[column][row].removeLast()
        return sphereToRemove
    }
    
    func columnAndRow(for sphereNode: GameSphereNode) -> (Int, Int) {
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                if gameSphereNodes[column][row].contains(sphereNode) {
                    return (column, row)
                }
            }
        }
        return (-1, -1)
    }

    func pole(for node: SCNNode) -> (Int, Int)? {
        for column in 0..<4 {
            for row in 0..<4 {
                if node == poleNodes[column][row] {
                    return (column, row)
                }
            }
        }
        return nil
    }
    
    func poleNode(column: Int, row: Int) -> SCNNode {
        return poleNodes[column][row]
    }
    
    func color(polesColumnAndRows: [(Int, Int)]) {
        let poleMaterial = SCNMaterial()
        poleMaterial.diffuse.contents = UIColor.green.withAlphaComponent(0.8)
        for columnRow in polesColumnAndRows {
            let poleNode = poleNodes[columnRow.0][columnRow.1]
            
            poleNode.geometry?.materials = [poleMaterial]
        }
    }
    
    func resetPoleColor() {
        let allPoles = poleNodes.flatMap { return $0 }
        for pole in allPoles {
            pole.geometry?.materials = [GameNodeFactory.poleMaterial()]
        }
    }
    
    func emptyPoles() {
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                gameSphereNodes[column][row].forEach({ node in
                    node.removeFromParentNode()
                })
                gameSphereNodes[column][row].removeAll()
            }
        }
    }
    
    func fadeAllBut(result: [(Int, Int, Int)], toOpacity: CGFloat) {
//        let poleMaterial = SCNMaterial()
//        poleMaterial.diffuse.contents = UIColor.green.withAlphaComponent(0.4)
        
        let sphereIds = result.map { sphereId in
            return "\(sphereId.0)\(sphereId.1)\(sphereId.2)"
        }
        
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                let poleNode = poleNodes[column][row]
//                poleNode.geometry?.materials = [poleMaterial]
//                poleNode.opacity = 0.3
                
                let fade = SCNAction.fadeOpacity(to: toOpacity, duration: 0.5)
                poleNode.runAction(fade, completionHandler: {
                    poleNode.castsShadow = toOpacity > 0.5
                })
                
                for (index, sphereNode) in gameSphereNodes[column][row].enumerated() {
                    let sphereId = "\(column)\(row)\(index)"
                    if !sphereIds.contains(sphereId) {
                        print("sphereId: \(sphereId)")
//                        continue
                    
                    let fade = SCNAction.fadeOpacity(to: toOpacity, duration: 0.5)
                    sphereNode.runAction(fade, completionHandler: {
                        sphereNode.castsShadow = toOpacity > 0.5
                    })
                    }
                }
            }
        }
    }
    
    func showText() {
        textOrbit.eulerAngles.y = cameraOrbit.eulerAngles.y
        
        textNode.isHidden = false
    }
    
    func hideText() {
        textNode.isHidden = true
    }
    
    func showConfetti() {
        scene?.addParticleSystem(emitter!, transform: SCNMatrix4MakeTranslation(0, 20, 0))
        
        let text = SCNText(string: "You won!", extrusionDepth: 1)
        text.font = UIFont.boldSystemFont(ofSize: 5)
        textNode.geometry = text
        textNode.position = SCNVector3(x: -12, y: 15, z: 15)
        textOrbit.eulerAngles.y = cameraOrbit.eulerAngles.y
        textNode.isHidden = false
    }
    
    func hideConfetti() {
        scene?.removeParticleSystem(emitter!)
    }
    
    func showLostText() {
        let text = SCNText(string: "You lost", extrusionDepth: 1)
        text.font = UIFont.boldSystemFont(ofSize: 5)
        textNode.geometry = text
        textNode.position = SCNVector3(x: -12, y: 15, z: 15)
        textOrbit.eulerAngles.y = cameraOrbit.eulerAngles.y
        textNode.isHidden = false
    }
}

@objc protocol ButtonActions {
    @objc func done(sender: UIButton!)
    @objc func surrender(sender: UIButton!)
    @objc func help(sender: UIButton!)
    @objc func continueWithGame(sender: UIButton!)
    @objc func reanimate(sender: UIButton!)
}

extension Selector {
    static let done = #selector(ButtonActions.done(sender:))
    static let surrender = #selector(ButtonActions.surrender(sender:))
    static let help = #selector(ButtonActions.help(sender:))
    static let continueWithGame = #selector(ButtonActions.continueWithGame(sender:))
    static let reanimate = #selector(ButtonActions.reanimate(sender:))
}

