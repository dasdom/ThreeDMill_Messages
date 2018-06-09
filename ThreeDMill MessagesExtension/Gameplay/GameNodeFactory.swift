//  Created by dasdom on 21.05.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

import SceneKit

struct GameNodeFactory {
    static func ground() -> SCNNode {
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor.brown
        let groundGeometry = SCNFloor()
        groundGeometry.reflectivity = 0
        groundGeometry.materials = [groundMaterial]
        let groundNode = SCNNode(geometry: groundGeometry)
        groundNode.position = SCNVector3(0, -6, 0)
        return groundNode
    }
    
    static func ambientLight() -> SCNLight {
        let light = SCNLight()
        light.color = UIColor.gray
        light.type = SCNLight.LightType.ambient
        //        ambientLight.intensity = 1500
        return light
    }
    
    static func camera(constraint: SCNLookAtConstraint) -> SCNNode {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zFar = 10_000
        cameraNode.camera = camera
        if #available(iOSApplicationExtension 11.0, *) {
            cameraNode.position = SCNVector3(0, 35, 45)
        } else {
            cameraNode.position = SCNVector3(0, 45, 45)
        }
        cameraNode.constraints = [constraint]
        
        cameraNode.light = self.ambientLight()
        return cameraNode
    }
    
    static func spotLight(constraint: SCNLookAtConstraint) -> SCNNode {
        let spotLightNode = SCNNode()
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
        return spotLightNode
    }
    
    static func base() -> SCNNode {
        let baseNode = SCNNode()
        let baseGeometry = SCNBox(width: 30, height: 6, length: 30, chamferRadius: 2)
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = UIColor(red: 0.8, green: 0.7, blue: 0.2, alpha: 1)
        baseGeometry.materials = [baseMaterial]
        baseNode.geometry = baseGeometry
        baseNode.position = SCNVector3(0, -3, 0)
        return baseNode
    }
    
    static func poleMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow.withAlphaComponent(0.8)
        return material
    }
    
    static func poles(columns: Int) -> [[SCNNode]] {
        
        let boardWidth: Float = 22
        let poleSpacing = boardWidth/3.0
        
        var poleNodes: [[SCNNode]] = []
        for j in 0..<columns {
            var columnNodes: [SCNNode] = []
            for i in 0..<columns {
                let poleGeometry = SCNCylinder(radius: 1.4, height: 24)
                poleGeometry.materials = [poleMaterial()]
                let poleNode = SCNNode(geometry: poleGeometry)
                poleNode.position = SCNVector3(x: poleSpacing*Float(i) - boardWidth/2.0, y: 5, z: poleSpacing*Float(j) - boardWidth/2.0)
                
                columnNodes.append(poleNode)
            }
            poleNodes.append(columnNodes)
        }
        return poleNodes
    }
    
    static func text(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 1)
        text.font = UIFont.boldSystemFont(ofSize: 10)
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(x: -10, y: 15, z: 15)
        textNode.isHidden = true
        textNode.castsShadow = false
        return textNode
    }
}
