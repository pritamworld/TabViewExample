//
//  MMDrawerViewController.swift
//  Pods
//
//  Created by Millman YANG on 2017/3/30.
//
//

import UIKit

// only check segue are (main/segue) ,
public class DrawerSegue: UIStoryboardSegue {
    override public func perform() {}
}

public enum SliderMode {
    case frontWidth(w:CGFloat)
    case frontWidthRate(r:CGFloat)

    case rearWidth(w:CGFloat)
    case rearWidthRate(r:CGFloat)
    case none
}

public enum ShowMode {
    case left
    case right
    case main
}
public typealias ConfigBLock = ((_ vc:UIViewController)->Void)?
struct SegueParams {
    var type: String
    var params: Any?
    var config: ConfigBLock
}

open class MMDrawerViewController: UIViewController  {
    lazy var containerView: UIView = {
        let v = UIView()
        self.view.addSubview(v)
        v.mLayout.constraint { (maker) in
            maker.set(type: .leading, value: 0)
            maker.set(type: .top, value: 0)
            maker.set(type: .bottom, value: 0)
            maker.set(type: .width, value: self.view.frame.width)
        }
        
        return v
    }()
    
    var sliderMap = [SliderLocation:SliderManager]()
    var currentManager:SliderManager?
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let s = segue as? DrawerSegue ,
           let p = sender as? SegueParams {
            
            if let config = p.config {
                config(segue.destination)
            }
            switch p.type {
            case "main":
                self.set(main: s.destination)
            case "left":
                if let slideMode = p.params as? SliderMode {
                    self.set(left: s.destination, mode: slideMode)
                }
            case "right":
                if let slideMode = p.params as? SliderMode {
                    self.set(right: s.destination, mode: slideMode)
                }
            default:
              break
            }
        }
    }
    
    public var main: UIViewController? {
        willSet {
            main?.removeFromParentViewController()
            main?.beginAppearanceTransition(true, animated: true)
            main?.didMove(toParentViewController: nil)
            main?.endAppearanceTransition()
            main?.view.removeFromSuperview()
        } didSet {
            if let new = main {                
                new.view.shadow(opacity: 0.4, radius: 5.0)
                new.view.addGestureRecognizer(mainPan)
                new.view.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(new.view)
                new.view.mLayout.constraint { (maker) in
                    maker.set(type: .leading, value: 0)
                    maker.set(type: .top, value: 0)
                    maker.set(type: .bottom, value: 0)
                    maker.set(type: .trailing, value: 0)
                }
                self.view.layoutIfNeeded()
                self.addChildViewController(new)
//                new.beginAppearanceTransition(true, animated: true)
//                new.didMove(toParentViewController: self)
//                new.endAppearanceTransition()
            }
        }
    }
    
    lazy var mainPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MMDrawerViewController.panAction(pan:)))
        pan.delegate = self
        return pan
    }()
    
    public var draggable: Bool = true {
        didSet{
            mainPan.isEnabled = draggable
            sliderMap.forEach { $0.1.sliderPan.isEnabled = draggable }
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.containerView.mLayout.update { (make) in
            make.constraintMap[.width]?.constant = size.width
        }
        
        sliderMap.forEach { (_ ,value) in
            value.viewRotation(size: size)
        }
    }
    
    public func set(left: UIViewController, mode: SliderMode) {
        sliderMap[.left] = SliderManager(drawer:self)
        sliderMap[.left]?.addSlider(slider: left, location: .left, mode: mode)
        self.view.layoutIfNeeded()
    }
    
    public func set(right: UIViewController , mode: SliderMode) {
        sliderMap[.right] = SliderManager(drawer: self)
        sliderMap[.right]?.addSlider(slider: right, location: .right, mode: mode)
        self.view.layoutIfNeeded()
    }
    
    public func setLeft(mode: SliderMode) {
        sliderMap[.left]?.mode = mode
        self.view.layoutIfNeeded()
    }
    
    public func setRight(mode: SliderMode) {
        sliderMap[.right]?.mode = mode
        self.view.layoutIfNeeded()
    }
    
    public func set(main: UIViewController) {
        print("Drawer set main : \(main)")
        self.main = main
        self.view.layoutIfNeeded()
    }
    
    public func showLeftSlider(isShow:Bool) {
        sliderMap[.left]?.show(isShow: isShow)
    }
    
    public func showRightSlider(isShow:Bool) {
        sliderMap[.right]?.show(isShow: isShow)
    }
    
    public func getManager(direction:SliderLocation) -> SliderManager? {
        return sliderMap[direction]
    }
    
    public func setMainWith(identifier: String) {
        print("Drawer setMainWith identifier : \(identifier)")
        self.setController(identifier: identifier, params: SegueParams(type: "main", params: nil, config: nil))
    }
    
    public func setMain(identifier: String, config: ConfigBLock) {
        self.setController(identifier: identifier, params: SegueParams(type: "main", params: nil, config: config))
    }
    
    public func setLeftWith(identifier:String, mode: SliderMode) {
        self.setController(identifier: identifier, params: SegueParams(type: "left", params: mode, config: nil))
    }
    
    public func setLeft(identifier:String, mode: SliderMode, config: ConfigBLock) {
        self.setController(identifier: identifier, params: SegueParams(type: "left", params: mode, config: config))
    }
    
    public func setRightWith(identifier: String, mode: SliderMode) {
        self.setController(identifier: identifier, params: SegueParams(type: "right", params: mode, config: nil))
    }

    public func setRightWith(identifier: String, mode: SliderMode, config: ConfigBLock) {
        self.setController(identifier: identifier, params: SegueParams(type: "right", params: mode, config: config))
    }
    
    fileprivate func setController(identifier: String, params: SegueParams ) {
        self.performSegue(withIdentifier: identifier, sender: params)
    }
}

extension MMDrawerViewController {
    func panAction(pan:UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            currentManager = self.searchCurrentManagerWith(pan: pan)
            currentManager?.panAction(pan: pan)
        case .changed:
            currentManager?.panAction(pan: pan)
        case .cancelled , .ended :
            currentManager?.panAction(pan: pan)
            currentManager = nil
        default:
            break
        }
    }
    
    fileprivate func searchCurrentManagerWith(pan:UIPanGestureRecognizer) -> SliderManager? {
        var manager:SliderManager?
        let rect = self.view.bounds.insetBy(dx: 40, dy: 40)
        let first = pan.location(in: pan.view)
        //Edge
        if !rect.contains(first) {
            sliderMap.forEach({ (_ , value) in
                
                if let s = manager?.slider?.view {
                    
                    let pre = first.distance(point: s.center)
                    let current = first.distance(point: value.slider?.view.center)
                    
                    if current < pre {
                        manager = value
                    }
                } else {
                    manager = value
                }
            })
            
        } else {
            manager = nil
        }
        return manager
    }
}

extension MMDrawerViewController: UIGestureRecognizerDelegate {
   
    
//    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if let pan = otherGestureRecognizer as? UIPanGestureRecognizer,
//           let scroll = otherGestureRecognizer.view as? UIScrollView {
//            print(scroll.contentOffset.x)
//            return (scroll.contentOffset.x < 0 || scroll.contentOffset.x + scroll.frame.width > scroll.contentSize.width)
//        }
//        return true
//    }

}
