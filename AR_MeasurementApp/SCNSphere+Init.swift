//
//  SCNSphere+Init.swift
//  AR_MeasurementApp
//
//  Created by Talentelgia on 7/3/18.
//  Copyright © 2018 Talentelgia. All rights reserved.
//

import UIKit
import SceneKit

extension SCNSphere{
    convenience init(color:UIColor, radius:CGFloat){
        self.init(radius: radius)
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.lightingModel = .physicallyBased
        self.materials = [material]
    }
}

class SphereNode: SCNNode {
    init(position: SCNVector3) {
        super.init()
        let sphereGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .physicallyBased
        sphereGeometry.materials = [material]
        self.geometry = sphereGeometry
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class LineNode: SCNNode {
    
    init(from vectorA: SCNVector3, to vectorB: SCNVector3, lineColor color: UIColor) {
        super.init()
        
        let height = self.distance(from: vectorA, to: vectorB)
        
        self.position = vectorA
        let nodeVector2 = SCNNode()
        nodeVector2.position = vectorB
        
        let nodeZAlign = SCNNode()
        nodeZAlign.eulerAngles.x = Float.pi/2
        
        let box = SCNBox(width: 0.003, height: height, length: 0.001, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = color
        box.materials = [material]
        
        let nodeLine = SCNNode(geometry: box)
        nodeLine.position.y = Float(-height/2) + 0.001
        nodeZAlign.addChildNode(nodeLine)
        
        self.addChildNode(nodeZAlign)
        
        self.constraints = [SCNLookAtConstraint(target: nodeVector2)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // Calculate the distance between two vectors.
    func distance(from vectorA: SCNVector3, to vectorB: SCNVector3)-> CGFloat {
    return CGFloat (sqrt(
    (vectorA.x - vectorB.x) * (vectorA.x - vectorB.x)
    +   (vectorA.y - vectorB.y) * (vectorA.y - vectorB.y)
    +   (vectorA.z - vectorB.z) * (vectorA.z - vectorB.z)))
    }
    
}
 


