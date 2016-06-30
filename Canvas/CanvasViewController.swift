//
//  CanvasViewController.swift
//  Canvas
//
//  Created by Pedro Sandoval Segura on 6/30/16.
//  Copyright © 2016 Pedro Sandoval Segura. All rights reserved.
//

import UIKit

class CanvasViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    var newlyCreatedFace: UIImageView!
    var newlyCreatedFaceOriginalCenter: CGPoint!
    var isPinching: Bool = false
    var currentScales = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        trayDownOffset = 160
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x, y: trayView.center.y + trayDownOffset)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPanFace(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(trayView)
        
        if sender.state == .Began {
            let imageView = sender.view as! UIImageView
            newlyCreatedFace = UIImageView(image: imageView.image)
            view.addSubview(newlyCreatedFace)
            newlyCreatedFace.center = imageView.center
            newlyCreatedFace.center.y += trayView.frame.origin.y
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            UIView.animateWithDuration(0.1, animations: {
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1.5, 1.5)
            })
        } else if sender.state == .Changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        } else if sender.state == .Ended {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations:  { () -> Void in
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: { (Bool) -> Void in })
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CanvasViewController.onCustomPan(_:)))
            // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
            newlyCreatedFace.userInteractionEnabled = true
            newlyCreatedFace.tag = currentScales.count
            currentScales.append(CGFloat(1))
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            //Add a pinch gesture recognizer to the newly created face
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(CanvasViewController.onCustomPinch(_:)))
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            //Add a rotate gesture recognizer
            let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(CanvasViewController.onRotate(_:)))
            rotateGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(rotateGestureRecognizer)
            
        }
        
    }
    
    func onRotate(sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        print("rotation: \(rotation) \(newlyCreatedFace.transform)")
        if sender.state == .Began {
            newlyCreatedFace.transform = CGAffineTransformMakeScale(currentScales[imageView.tag], currentScales[imageView.tag])
        } else if sender.state == .Changed {
            newlyCreatedFace.transform = CGAffineTransformMakeRotation(rotation) //CGAffineTransformMakeRotation(CGFloat(atan2f(Float(newlyCreatedFace.transform.b), Float(newlyCreatedFace.transform.a))) + rotation)
        } else if sender.state == .Ended {
            
        }
        
    }
    
    func onCustomPinch(sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        if sender.state == .Began {
            isPinching = true
        } else if sender.state == .Changed {
            newlyCreatedFace.transform = CGAffineTransformMakeScale(currentScales[imageView.tag] + scale, currentScales[imageView.tag] + scale)
            currentScales[imageView.tag] = scale
        } else if sender.state == .Ended {
            isPinching = false
        }
    }
    
    func onCustomPan(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(trayView)
        
        let imageView = sender.view as! UIImageView
        
        if sender.state == .Began && !isPinching {
            newlyCreatedFace = sender.view as! UIImageView
            newlyCreatedFaceOriginalCenter = newlyCreatedFace.center
            UIView.animateWithDuration(0.1, animations: {
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(self.currentScales[imageView.tag]*1.5, self.currentScales[imageView.tag]*1.5)
            })
        } else if sender.state == .Changed {
            newlyCreatedFace.center = CGPoint(x: newlyCreatedFaceOriginalCenter.x + translation.x, y: newlyCreatedFaceOriginalCenter.y + translation.y)
        } else if sender.state == .Ended && !isPinching {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations:  { () -> Void in
                self.newlyCreatedFace.transform = CGAffineTransformMakeScale(self.currentScales[imageView.tag], self.currentScales[imageView.tag])
                }, completion: { (Bool) -> Void in })
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func didPanTray(sender: UIPanGestureRecognizer) {
        let velocity = sender.velocityInView(trayView)
        let translation = sender.translationInView(trayView)
        if sender.state == .Began {
            trayOriginalCenter = trayView.center
        } else if sender.state == .Changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == .Ended {
            if velocity.y > 0 {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations:  { () -> Void in
                    self.trayView.center = self.trayDown
                    }, completion: { (Bool) -> Void in })
            } else {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [], animations:  { () -> Void in
                    self.trayView.center = self.trayUp
                    }, completion: { (Bool) -> Void in })
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
