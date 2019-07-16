//
//  ViewController.swift
//  TutorialBubble
//
//  Created by Farshad Jahanmanesh on 7/2/19.
//  Copyright © 2019 Farshad Jahanmanesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var bigBottomButton : UIButton!
    @IBOutlet weak var noConstraintsButton : UIButton!
    @IBOutlet weak var transformedButton : UIButton!
    @IBOutlet weak var pugImage : UIView!
    @IBOutlet weak var pugName : UIView!
    @IBOutlet weak var pugDescrription : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigBottomButton.titleLabel?.lineBreakMode = .byWordWrapping
        bigBottomButton.titleLabel?.numberOfLines = 0
        transformedButton.transform = CGAffineTransform.identity
            .rotated(by: 45)
    }
    
    func showHints(){
        // configure our hint view
        let hint = HintPointer(on: self.view.window!)
        hint.options(HintPointer.Options
            .default()
            .with {
                $0.bubbleLiveDuration = .untilNext
        })
        
        let pugLoveConfig = HintPointer.Options.Bubble
            .default()
            .with{
                $0.backgroundColor = .clear
                $0.foregroundColor = .black
                $0.textAlignments = .left
                $0.padding = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
                $0.position = .top
        }
        
        let image = UIImageView(image: #imageLiteral(resourceName: "heart-like.png"))
        image.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        image.contentMode = .scaleAspectFit
        image.widthAnchor.constraint(equalToConstant: 50).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 1).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            hint.show(item: HintPointer.HintItem.init(ID: "100", pointTo: self.pugImage, showView: image),with: pugLoveConfig)
        }
        
        let pugDescriptionConfig = HintPointer.Options.Bubble
            .default()
            .with{
                $0.backgroundColor = UIColor.purple
                $0.foregroundColor = UIColor.white
                $0.position = .left
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            hint.show(item: (self.pugImage,"best dog ever <3 <3 ^_^ ^_^"),with: pugDescriptionConfig.with{$0.position = .right})
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            hint.show(item: (self.pugName,"my name is leo ^_^"),with: pugDescriptionConfig.with{
                $0.position = .top
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            })
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            hint.show(item: (self.pugDescrription,"i am single and looking for my soulmate"),with: pugDescriptionConfig.with{
                $0.position = .bottom
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            })
        }
        
        
        let tranformedViewsBubbleConfig = HintPointer.Options.Bubble
            .default()
            .with{
                $0.backgroundColor = .black
                $0    .foregroundColor = .white
                $0    .textAlignments = .left
                $0    .position =  .right
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            hint.show(item: (self.transformedButton,"without animation."),with: tranformedViewsBubbleConfig.with{$0.position = .left})
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            hint.show(item: (self.noConstraintsButton,"hi!"),with:tranformedViewsBubbleConfig.with{$0.backgroundColor = .red})
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+12) {
            hint.show(item: (self.bigBottomButton,"لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی "),with: tranformedViewsBubbleConfig)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 16) {
            hint.finish()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let timer =  Timer.scheduledTimer(withTimeInterval: 17, repeats: true) { (t) in
            self.showHints()
        }
        timer.fire()
    }
    
}
