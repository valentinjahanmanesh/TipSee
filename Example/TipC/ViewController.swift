//
//  ViewController.swift
//  TipC
//
//  Created by farshadjahanmanesh on 07/16/2019.
//  Copyright (c) 2019 farshadjahanmanesh. All rights reserved.
//

import UIKit
import TipC
class ViewController: UIViewController {
    @IBOutlet weak var bigBottomButton : UIButton!
    @IBOutlet weak var noConstraintsButton : UIButton!
    @IBOutlet weak var transformedButton : UIButton!
    @IBOutlet weak var pugImage : UIView!
    @IBOutlet weak var pugName : UIView!
    @IBOutlet weak var pugDescrription : UIView!
    private var hints : HintPointerManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigBottomButton.titleLabel?.lineBreakMode = .byWordWrapping
        bigBottomButton.titleLabel?.numberOfLines = 0
        transformedButton.transform = CGAffineTransform.identity
            .rotated(by: 45)
    }
    
    func showHints(){
        // configure our hint view
        let pugLoveConfig = HintPointer.Options.Bubble
            .default()
            .with{
                $0.backgroundColor = .clear
                $0.foregroundColor = .black
                $0.textAlignments = .left
                $0.padding = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
                $0.position = .top
        }
        
        let pugDescriptionConfig = HintPointer.Options.Bubble
            .default()
            .with{
                $0.backgroundColor = UIColor.purple
                $0.foregroundColor = UIColor.white
                $0.position = .left
        }
        
        let image = UIImageView(image: #imageLiteral(resourceName: "heart-like.png"))
        image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        image.contentMode = .scaleAspectFit
        let transformed = HintPointer.Options.Bubble
            .default()
            .with{
                $0.backgroundColor = .black
                $0    .foregroundColor = .white
                $0    .textAlignments = .left
                $0    .position =  .right
        }
        
        self.hints = HintPointerManager(on: self.view.window!,with: HintPointer.Options
            .default()
            .with {
                $0.bubbleLiveDuration = .untilNext
        })
        
        hints!.add(new: HintPointer.HintItem.init(ID: "100", pointTo: self.pugImage, showView: image,bubbleOptions: pugLoveConfig))
        
        hints!.add(new: (self.pugImage,"best dog ever <3 <3 ^_^ ^_^"),with: pugDescriptionConfig.with{$0.position = .right})
        
        hints!.add(new: (self.pugName,"my name is leo ^_^"),with: pugDescriptionConfig.with{
            $0.position = .top
            if #available(iOS 10.0, *) {
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
        })
        
        hints!.add( new: (self.pugDescrription,"i am single and looking for my soulmate"),with: pugDescriptionConfig.with{
            $0.position = .bottom
            if #available(iOS 10.0, *) {
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
        })
        
        hints!.add(new: (self.transformedButton,"without animation."),with: transformed.with{$0.position = .left})
        
        hints!.add(new: (self.noConstraintsButton,"hi!"),with:transformed.with{$0.backgroundColor = .red})
        
        hints!.add(new: (self.bigBottomButton,"لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی "),with: transformed)
        
        
        hints!.bubbleTap = {_ in
            self.hints!.next()
        }
        hints!.dimTap = {_ in
            if let index = self.hints!.currentIndex,self.hints!.hints.count == (index + 1) {
                self.hints!.finish()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.hints = nil
                })
            }
            
            self.hints!.next()
        }
        self.hints!.next()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showHints()
//        if #available(iOS 10.0, *) {
//            let timer =  Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (t) in
//                self.hints!.next()
//                if let x = self.hints!.currentIndex,x == self.hints!.views.count {
//                    self.hints!.finish()
//                }
//            }
//            timer.fire()
//        }
    }
    
}
