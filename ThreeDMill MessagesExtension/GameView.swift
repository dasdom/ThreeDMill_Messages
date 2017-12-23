//  Created by dasdom on 10.07.17.
//  Copyright © 2017 dasdom. All rights reserved.
//

import UIKit
import SceneKit

protocol GameViewProtocol: class {
    func add(color: SphereColor) -> GameSphereNode
    func pole(for node: SCNNode) -> (Int, Int)?
}

class GameView: SCNView, GameViewProtocol {

    let cameraNode = SCNNode()
    let cameraOrbit = SCNNode()
    let spotLightNode = SCNNode()
    var poleNodes: [[SCNNode]] = []
//    let textNode: SCNNode
    var startAngleY: Float = 0.0
    let remainingWhiteSpheresLabel: UILabel
    let whiteButtonStackView: UIStackView
    let doneButton: UIButton
    let remainingRedSpheresLabel: UILabel
    let redButtonStackView: UIStackView
    var gameSphereNodes: [[[GameSphereNode]]] = []
    let surrenderButton: UIButton

    override init(frame: CGRect, options: [String : Any]? = nil) {
        
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.brown
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        groundGeometry.materials = [groundMaterial]
        let groundNode = SCNNode(geometry: groundGeometry)
        groundNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        let constraint = SCNLookAtConstraint(target: groundNode)
        constraint.isGimbalLockEnabled = true

        let camera = SCNCamera()
        camera.zFar = 10_000
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 35, 40)
        cameraNode.constraints = [constraint]
        
        cameraOrbit.addChildNode(cameraNode)

        let ambientLight = SCNLight()
        ambientLight.color = UIColor.gray
        ambientLight.type = SCNLight.LightType.ambient
//        ambientLight.intensity = 1500
        cameraNode.light = ambientLight
        
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.spot
        spotLight.castsShadow = true
        spotLight.spotInnerAngle = 70.0
        spotLight.spotOuterAngle = 90.0
        spotLight.zFar = 500
        spotLight.intensity = 800
        spotLightNode.light = spotLight
        spotLightNode.position = SCNVector3(20, 50, 50)
        spotLightNode.constraints = [constraint]
        
        let boardWidth: Float = 22
        let poleSpacing = boardWidth/3.0
        
        for j in 0..<Board.numberOfColumns {
            var columnNodes: [SCNNode] = []
            for i in 0..<Board.numberOfColumns {
                let poleGeometry = SCNCylinder(radius: 1.4, height: 24)
                let poleMaterial = SCNMaterial()
                poleMaterial.diffuse.contents = UIColor.yellow.withAlphaComponent(0.8)
                poleGeometry.materials = [poleMaterial]
                let poleNode = SCNNode(geometry: poleGeometry)
                poleNode.position = SCNVector3(x: poleSpacing*Float(i) - boardWidth/2.0, y: 5, z: poleSpacing*Float(j) - boardWidth/2.0)
                
                columnNodes.append(poleNode)
            }
            poleNodes.append(columnNodes)
        }
        
//        let text = SCNText(string: "Mill", extrusionDepth: 1)
//        text.font = UIFont.boldSystemFont(ofSize: 10)
//        textNode = SCNNode(geometry: text)
//        textNode.position = SCNVector3(x: -10, y: 15, z: 15)
        
        let sphereIndicatorHeight = CGFloat(20)
        
        let whiteView = UIView()
        whiteView.backgroundColor = UIColor.white
        whiteView.layer.cornerRadius = sphereIndicatorHeight/2.0
        
        remainingWhiteSpheresLabel = UILabel()
        remainingWhiteSpheresLabel.text = "32"
        remainingWhiteSpheresLabel.textColor = UIColor.white
        remainingWhiteSpheresLabel.textAlignment = .center
        remainingWhiteSpheresLabel.font = UIFont.systemFont(ofSize: 20)
        
        whiteButtonStackView = UIStackView(arrangedSubviews: [whiteView, remainingWhiteSpheresLabel])
        whiteButtonStackView.axis = .vertical
        whiteButtonStackView.alignment = .center
        whiteButtonStackView.spacing = 5
        
        let redView = UIView()
        redView.backgroundColor = UIColor.red
        redView.layer.cornerRadius = sphereIndicatorHeight/2.0

        remainingRedSpheresLabel = UILabel()
        remainingRedSpheresLabel.text = "32"
        remainingRedSpheresLabel.textColor = UIColor.white
        remainingRedSpheresLabel.textAlignment = .center
        remainingRedSpheresLabel.font = UIFont.systemFont(ofSize: 20)

        redButtonStackView = UIStackView(arrangedSubviews: [redView, remainingRedSpheresLabel])
        redButtonStackView.axis = .vertical
        redButtonStackView.alignment = .center
        redButtonStackView.spacing = 5
        
        func button() -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle("＋", for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            let buttonFont = UIFont.systemFont(ofSize: 26)
            button.titleLabel?.font = buttonFont
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 5
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return button
        }

        doneButton = button()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("3", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        doneButton.isHidden = true
        
        surrenderButton = button()
        surrenderButton.translatesAutoresizingMaskIntoConstraints = false
        surrenderButton.setTitle("surrender", for: .normal)
        surrenderButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        surrenderButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5)
        surrenderButton.addTarget(nil, action: .surrender, for: .touchUpInside)
        
        super.init(frame: frame, options: options)
        
//        addRedButton.addTarget(nil, action: .add, for: .touchUpInside)
//        addWhiteButton.addTarget(nil, action: .add, for: .touchUpInside)
        doneButton.addTarget(nil, action: .done, for: .touchUpInside)

        showsStatistics = true

        scene = SCNScene()
        
        scene?.rootNode.addChildNode(groundNode)
        scene?.rootNode.addChildNode(cameraOrbit)
        scene?.rootNode.addChildNode(spotLightNode)
//        scene?.rootNode.addChildNode(textNode)

        for j in 0..<Board.numberOfColumns {
            for i in 0..<Board.numberOfColumns {
                scene?.rootNode.addChildNode(poleNodes[j][i])
            }
        }
        
        addSubview(redButtonStackView)
        addSubview(whiteButtonStackView)
        addSubview(doneButton)
        addSubview(surrenderButton)
        
        redButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        whiteButtonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            redButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            redButtonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            whiteButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            whiteButtonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            doneButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            whiteView.heightAnchor.constraint(equalToConstant: sphereIndicatorHeight),
            whiteView.widthAnchor.constraint(equalTo: whiteView.heightAnchor),
            redView.heightAnchor.constraint(equalToConstant: sphereIndicatorHeight),
            redView.widthAnchor.constraint(equalTo: redView.heightAnchor),
            surrenderButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            surrenderButton.topAnchor.constraint(equalTo: topAnchor, constant: 10)
            ])
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        addGestureRecognizer(panRecognizer)
        
//        let tapRecognizer = UITapGestureRecognizer(target: nil, action: .tap)
//        addGestureRecognizer(tapRecognizer)
        
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
    
    func update(with board: Board) {
        for column in 0..<Board.numberOfColumns {
            for row in 0..<Board.numberOfColumns {
                let pole = board.poles[column][row]
                let poleNode = poleNodes[column][row]
                for (index, sphereColor) in pole.sphereColors.enumerated() {
                    
                    let material = SCNMaterial()
                    material.diffuse.contents = sphereColor.uiColor()
                    let geometry = SCNSphere(radius: 2.6)
                    geometry.materials = [material]
                    
                    let sphere = GameSphereNode(geometry: geometry, color: sphereColor)
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
        default:
            break
        }
        
        cameraOrbit.eulerAngles.y = startAngleY - GLKMathDegreesToRadians(Float(translation.x))
    }

    @discardableResult func add(color sphereColor: SphereColor) -> GameSphereNode {
        
//        if sphereColor == .red {
//            redButtonStackView.isHidden = true
//            whiteButtonStackView.isHidden = true
//        } else {
//            redButtonStackView.isHidden = false
//            whiteButtonStackView.isHidden = true
//        }
        
        let material = SCNMaterial()
        material.diffuse.contents = sphereColor.uiColor()
        let geometry = SCNSphere(radius: 2.6)
        geometry.materials = [material]
        
        let sphere = GameSphereNode(geometry: geometry, color: sphereColor)
        sphere.position = SCNVector3(x: 0, y: 25, z: 0)
        
//        gameSphereNodes.append(sphere)
        scene?.rootNode.addChildNode(sphere)
        
        return sphere
    }
    
    func add(_ sphereNode: GameSphereNode, toColumn: Int, andRow: Int) {
        gameSphereNodes[toColumn][andRow].append(sphereNode)
//        print(gameSphereNodes)
    }
    
    func topSphereAt(column: Int, row: Int) -> GameSphereNode? {
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
}

@objc protocol ButtonActions {
//    @objc func add(sender: UIButton!)
    @objc func done(sender: UIButton!)
    @objc func surrender(sender: UIButton!)
}

extension Selector {
//    static let add = #selector(ButtonActions.add(sender:))
    static let done = #selector(ButtonActions.done(sender:))
    static let surrender = #selector(ButtonActions.surrender(sender:))
}

