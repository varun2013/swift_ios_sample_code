//
//  ViewController.swift
//  AR_MeasurementApp
//
//  Created by Talentelgia on 7/3/18.
//  Copyright © 2018 Talentelgia. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController,ARSCNViewDelegate {
    @IBOutlet var scnView: ARSCNView!
    @IBOutlet var lbl_Distance: UILabel!
    var nodeColor:UIColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    var nodeRadius:CGFloat = 10.0
    var startNode:SCNNode?
    var lastNode:SCNNode?
    var distance:Double = 0.0
    
    
    var nodes:[SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScene()
        self.setupARSession()
        self.cleanAllNodes()
        
        // Add Gesture to get the touch event.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        scnView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.scnView.session.pause()
    }
    // Initalize the AR Session services.
    func setupScene(){
        let scene = SCNScene()
        self.scnView.delegate = self
        self.scnView.showsStatistics = true
        self.scnView.automaticallyUpdatesLighting = true
        self.scnView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.scnView.scene = scene
    }
    // Initalize the AR Session
    func setupARSession(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.scnView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("camera state: \(camera.trackingState)")
    }
    
    func cleanAllNodes() {
        if nodes.count > 0 {
            for node in nodes {
                node.removeFromParentNode()
            }
            for node in scnView.scene.rootNode.childNodes {
                if node.name == "measureLine" {
                    node.removeFromParentNode()
                }
            }
            nodes = []
        }
    }

    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        let tapLocation = self.scnView.center // Get the center point, of the SceneView.
        let hitTestResults = scnView.hitTest(tapLocation, types:.featurePoint)
        
        if let result = hitTestResults.first {
            
            if nodes.count == 2 {
                cleanAllNodes()
            }
            
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            
            let sphere = SphereNode(position: position)
            scnView.scene.rootNode.addChildNode(sphere)
            
            // Get the Last Node from the list
            let lastNode = nodes.last
            
            // Add the Sphere to the list.
            nodes.append(sphere)
            
            // Setting our starting point for drawing a line in real time
            self.startNode = nodes.last
            
            if lastNode != nil {
                // If there is 2 nodes or more
                if nodes.count >= 2 {
                    // Create a node line between the nodes
                    let measureLine = LineNode(from: (lastNode?.position)!,
                                               to: sphere.position, lineColor: self.nodeColor)
                    measureLine.name = "measureLine"
                    scnView.scene.rootNode.addChildNode(measureLine)
                }
                
                self.distance = Double(lastNode!.position.distance(to: sphere.position)) * 100
                print( String(format: "Distance between nodes:  %.2f cm", self.distance))
                self.lbl_Distance.text = String(format: "%2f cm.", self.distance)
            }
        }
    }
}


extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}


extension SCNNode {
    static func createLineNode(fromNode: SCNNode, toNode: SCNNode, andColor color: UIColor) -> SCNNode {
    let line = lineFrom(vector: fromNode.position, toVector: toNode.position)
    let lineNode = SCNNode(geometry: line)
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = color
    line.materials = [planeMaterial]
    return lineNode
    }
    
    static func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
    let indices: [Int32] = [0, 1]
    let source = SCNGeometrySource(vertices: [vector1, vector2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    return SCNGeometry(sources: [source], elements: [element])
    }
}

