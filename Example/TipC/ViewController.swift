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
	private var rotationDegree : CGFloat = 45
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigBottomButton.titleLabel?.lineBreakMode = .byWordWrapping
        bigBottomButton.titleLabel?.numberOfLines = 0
	
		if #available(iOS 10.0, *) {
			let t = Timer.scheduledTimer(withTimeInterval: 0.55, repeats: true) { [unowned self](_) in
				UIView.animate(withDuration: 0.5) {
					self.transformedButton.transform = self.transformedButton.transform
						.rotated(by: self.rotationDegree)
				}
			}
			t.fire()
		}
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
				$0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                $0    .foregroundColor = .white
                $0    .textAlignments = .left
                $0    .position =  .right
        }
        
        self.hints = HintPointerManager(on: self.view.window!,with: HintPointer.Options
            .default()
            .with {
				$0.dimColor =  UIColor.black.withAlphaComponent(0.3)
                $0.bubbleLiveDuration = .untilNext
				$0.dimFading = false
				
        })
        
        hints!.add(new: HintPointer.HintItem.init(ID: "100", pointTo: self.pugImage, showView: image,bubbleOptions: pugLoveConfig))
        
        hints!.add(new: self.pugImage,text:"best dog ever <3 <3 ^_^ ^_^",with: pugDescriptionConfig.with{$0.position = .right})
        
        hints!.add(new: self.pugName,text:"my name is leo ^_^",with: pugDescriptionConfig.with{
            $0.position = .top
            if #available(iOS 10.0, *) {
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
			
        })
        
        hints!.add( new: self.pugDescrription,text:"i am single and looking for my soulmate",with: pugDescriptionConfig.with{
            $0.position = .bottom
            if #available(iOS 10.0, *) {
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
        })
        
        hints!.add(new: self.transformedButton,text:"without animation.",with: transformed.with{$0.position = .left})
        
        hints!.add(new: self.noConstraintsButton,text:"hi!",with:transformed.with{$0.backgroundColor = .red})
		
		hints!.add(new: SimpleHintTarget(on:  CGRect(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.midY - 50, width: 100, height: 100), cornerRadius: 50),text:"no view just show a hint on this bounds",with:transformed.with{$0.backgroundColor = .red})

		
		
		hints!.add(new: self.bigBottomButton,text:"لورم ایپسوم متن ساختگی با تولید سادگی نامفهوم از صنعت چاپ و با استفاده از طراحان گرافیک است. چاپگرها و متون بلکه روزنامه و مجله در ستون و سطرآنچنان که لازم است و برای شرایط فعلی ",with: transformed.with{
			$0.targetViewTap = {[weak self]_ in
				guard let degree = self?.rotationDegree else {return}
 				self?.rotationDegree = (degree * -1)
			}
			$0.dismissOnTargetViewTap = true
		})
        
        
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
		
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			// changes color in the middle of presentation
			self.hints?.pointer.options.dimColor = UIColor.blue.withAlphaComponent(0.3)
		}
    }
    
}


