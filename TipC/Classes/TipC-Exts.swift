//
//  TipC-Exts.swift
//  Pods-TipC_Example
//
//  Created by Farshad Jahanmanesh on 7/18/19.
//
import UIKit
public class TipcManager {
    public var pointer : TipC
    public private(set) var tips : [TipC.TipItem]
    public var latestTip : TipC.TipItem?
    public var onBubbleTap: ((TipC.TipItem?) -> Void)? {
        didSet{
            pointer.onBubbleTap = self.onBubbleTap
        }
    }
    public var onDimTap : ((TipC.TipItem?) -> Void)? {
        didSet{
            pointer.onDimTap = self.onDimTap
        }
    }
    public var currentIndex : Int? {
        didSet {
            guard let index = currentIndex else {
                self.pointer.finish()
                return
            }
            latestTip = tips[index]
            self.pointer.show(item: latestTip!)
        }
    }
    
    /// creates a slider manager.
    /// - Warning: the TipPointer object that should be passed in in init, is accessed with strong reference so you do not need to keep it strong too
    /// - Parameters:
    ///   - pointer: tip pointer object
    ///   - items: items
    public init(on window : UIWindow,with options: TipC.Options) {
        self.pointer = TipC(on: window)
        self.pointer.options(options)
        self.tips = [TipC.TipItem]()
    }
    public func add(new view : TipTarget,text string: String, with bubbleOption: TipC.Options.Bubble?){
        self.tips.append(pointer.createItem(for: view,text: string, with: bubbleOption))
    }
    public func add(new item: TipC.TipItem){
        self.tips.append(item)
    }
    /// shows the next tip
    public func next(){
        guard let current = latestTip,let currentIndex = tips.firstIndex(of: current) else {
            if !tips.isEmpty{
                self.currentIndex = 0
            }
            return
        }
        let next  = currentIndex+1
        if next < tips.count {
            self.currentIndex = next
        }
    }
    
    // shows the previous tip
    public func previous(){
        guard let current = latestTip,let currentIndex = tips.firstIndex(of: current) else {
            return
        }
        let previous  = currentIndex-1
        if previous >= 0 {
            self.currentIndex = previous
        }
    }
    
    public func finish(){
        pointer.finish()
    }
}



