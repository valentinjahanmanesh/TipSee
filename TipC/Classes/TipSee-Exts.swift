//
//  TipSee-Exts.swift
//  Pods-TipSee_Example
//
//  Created by Farshad Jahanmanesh on 7/18/19.
//
import UIKit
public class TipcManager {
    public var pointer : TipSee
    public private(set) var tips : [TipSee.TipItem]
    public var latestTip : TipSee.TipItem?
    public var onBubbleTap: ((TipSee.TipItem?) -> Void)? {
        didSet{
            pointer.onBubbleTap = self.onBubbleTap
        }
    }
    public var onDimTap : ((TipSee.TipItem?) -> Void)? {
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
    public init(on window : UIWindow,with options: TipSee.Options) {
        self.pointer = TipSee(on: window)
        self.pointer.options(options)
        self.tips = [TipSee.TipItem]()
    }
    public func add(new view : TipTarget,text string: String, with bubbleOption: TipSee.Options.Bubble?){
        self.tips.append(pointer.createItem(for: view,text: string, with: bubbleOption))
    }
    public func add(new item: TipSee.TipItem){
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



