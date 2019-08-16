//
//  Plane.swift
//  ConnectFourAR
//
//  Created by joconnor on 8/13/19.
//  Copyright © 2019 joconnor. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    
    /// Creates An SCNPlane With A Single Colour Or Image For It's Material
    /// (Either A Colour Or UIImage Must Be Input)
    /// - Parameters:
    ///   - width: Optional CGFloat (Defaults To 60cm)
    ///   - height: Optional CGFloat (Defaults To 30cm)
    ///   - content: Any (UIColor Or UIImage)
    ///   - doubleSided: Bool
    ///   - horizontal: The Alignment Of The Plane
    init(width: CGFloat = 0.4, height: CGFloat = 0.3, content: Any, doubleSided: Bool, horizontal: Bool) {
        
        super.init()
        //1. Create The Plane Geometry With Our Width & Height Parameters
        self.geometry = SCNPlane(width: width, height: height)
        
        //2. Create A New Material
        let material = SCNMaterial()
        
        if let colour = content as? UIColor{
            
            //The Material Will Be A UIColor
            material.diffuse.contents = colour
            
        }else if let image = content as? UIImage{
            
            //The Material Will Be A UIImage
            material.diffuse.contents = image
            
        }else{
            
            //Set Our Material Colour To Cyan
            material.diffuse.contents = UIColor.cyan
            
        }
        
        //3. Set The 1st Material Of The Plane
        self.geometry?.firstMaterial = material
        
        //4. If We Want Our Material To Be Applied On Both Sides The Set The Property To True
        if doubleSided{
            material.isDoubleSided = true
        }
        
        //5. By Default An SCNPlane Is Rendered Vertically So If We Need It Horizontal We Need To Rotate It
        if horizontal{
            self.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        }
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError("Plane Node Coder Not Implemented") }
}
