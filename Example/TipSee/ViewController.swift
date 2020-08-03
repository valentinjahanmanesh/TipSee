//
//  ViewController.swift
//  TipSee
//
//  Created by farshadjahanmanesh on 07/16/2019.
//  Copyright (c) 2019 farshadjahanmanesh. All rights reserved.
//

import UIKit
import TipSee

class ViewController: UIViewController {
    @IBOutlet weak var bigBottomButton : UIButton!
    @IBOutlet weak var noConstraintsButton : UIButton!
    @IBOutlet weak var transformedButton : UIImageView!
    @IBOutlet weak var pugImage : UIView!
    @IBOutlet weak var pugName : UIView!
    @IBOutlet weak var pugDescrription : UIView!
    private var tips : TipSeeManager?
	private var rotationDegree : CGFloat = 45
	private var startDayAndNight = false
	
	@IBAction func reShowTips(){
		self.tips?.finish()
		self.showTips()
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		
        bigBottomButton.titleLabel?.lineBreakMode = .byWordWrapping
        bigBottomButton.titleLabel?.numberOfLines = 0
		
		if #available(iOS 10.0, *) {
			let t = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [unowned self](_) in
				UIView.animate(withDuration: 0.75) {
					
					if self.startDayAndNight {
						if self.rotationDegree < 0 {
	//						day
							self.transformedButton.image = UIImage(named: "sunny")
							self.tips?.pointer.options.dimColor = UIColor(red:0.97, green:0.76, blue:0.29, alpha:1.0)
						}else{
	//						night
							self.transformedButton.image = UIImage(named: "moon")
							self.tips?.pointer.options.dimColor = UIColor(red:0.02, green:0.18, blue:0.23, alpha:1.0)
						}
					}
					self.transformedButton.transform = self.transformedButton.transform
						.rotated(by: self.rotationDegree)
				}
			}
			t.fire()
		}
    }

	private var pugLoveConfig: TipSee.Options.Bubble {
		return TipSee.Options.Bubble
			.default()
			.with{
				$0.foregroundColor = .white
				$0.textAlignments = .justified
				$0.position = .top

		}
	}

	private var pugDescriptionConfig : TipSee.Options.Bubble {
		return TipSee.Options.Bubble
			.default()
			.with{
				$0.backgroundColor = UIColor.purple
				$0.foregroundColor = UIColor.white
				$0.position = .left
		}
	}

    private func showTips() {
        
        let image = UIImageView(image: #imageLiteral(resourceName: "heart-like.png"))
        image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        image.contentMode = .scaleAspectFit
        let transformed = TipSee.Options.Bubble
            .default()
            .with{
				$0.backgroundColor = UIColor.orange
                $0    .foregroundColor = .white
                $0    .textAlignments = .left
                $0    .position =  .right
				//$0.changeDimColor = UIColor(red:0.02, green:0.18, blue:0.23, alpha:1.0)
        }
		
		let defaultTipOption = TipSee.Options
			.default()
			.with {
				$0.dimColor =  UIColor.black.withAlphaComponent(0.3)
				$0.bubbleLiveDuration = .untilNext
				$0.dimFading = false
		}
				
        self.tips = TipSeeManager(on: self.view.window!,with: defaultTipOption)
       
		tips!.add(
			new: self.pugImage,
			texts: [
				"We can show interactive tips on top of views or anything else conforming to `TipTarget`.",
				"The positioning of the tip bubble (or custom view) is automatically calculated by TipSee for you.",
				"This decision is based on the size of the tip and the available space around it.",
				"Alternatively, the tip position can be explicity set for precise control."
			],
			with: pugLoveConfig)
		{
			previousButton, nextButton in
			nextButton.imageView?.contentMode = .scaleAspectFit
			previousButton.imageView?.contentMode = .scaleAspectFit
			nextButton.setImage(#imageLiteral(resourceName: "right-arrow.pdf"), for: .normal)
			previousButton.setImage(#imageLiteral(resourceName: "left-arrow.pdf"), for: .normal)
			previousButton.tintColor = .white
			nextButton.tintColor = .white
		}
		
        tips!.add(new: self.pugImage, text: "Best dog ever <3 <3 ^_^ ^_^", with: pugDescriptionConfig.with{$0.position = .right})

		addAttributedTextTip()

        tips!.add(new: self.pugName, text: "My name is leo ^_^", with: pugDescriptionConfig.with{
            $0.position = .top
            if #available(iOS 10.0, *) {
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
        })
        
        tips!.add( new: self.pugDescrription,text: "I am single and looking for my soulmate", with: pugDescriptionConfig.with{
            $0.position = .bottom
            if #available(iOS 10.0, *) {
                $0.backgroundColor = UIColor(displayP3Red: 0.451, green: 0.807, blue: 0.317, alpha: 1)
            } else {
                // Fallback on earlier versions
            }
        })
        
        tips!.add(new: self.transformedButton,text: "Please tap on the \(rotationDegree < 0 ? "☀️" : "🌑").", with: transformed.with{
			$0.position = .left
			$0.changeDimColor = UIColor(red:0.02, green:0.18, blue:0.23, alpha:1.0)
			$0.onTargetAreaTap = {[weak self] item in
				guard var degree = self?.rotationDegree else {return}
				self?.startDayAndNight = true
				degree = (degree * -1)
				self?.rotationDegree = degree
				guard let label = item.contentView as? UILabel else {
					return
				}
				label.text = "Please tap on the \(degree < 0 ? "☀️" : "🌑")"
			}
			$0.onBubbleTap = {[unowned self]_ in
				self.startDayAndNight = false
				self.tips?.pointer.options = defaultTipOption
			}
		})
        
        tips!.add(new: self.noConstraintsButton,text: "Hi!", with:transformed.with{ $0.backgroundColor = .red })
		
		tips!.add(
			new: SimpleTipTarget(on:  CGRect(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.midY - 50, width: 100, height: 100),cornerRadius: 50),
			text: "Tip with no target view, just an arbitrary fixed position", with: transformed.with{$0.backgroundColor = .red})

		tips!.add(
			new: self.bigBottomButton,
			text: "A long piece of tip text which needs to span over multiple lines. This tip text will only fit if placed above the target area. This placement is provided for us by TipSee.",
			with: transformed.with {
				$0.onTargetAreaTap = { [weak self]_ in
					guard let degree = self?.rotationDegree else {return}
					self?.rotationDegree = (degree * -1)
				}
				$0.backgroundColor = UIColor.black
				$0.shouldFinishOnTargetAreaTap = true
			}
		)

        tips!.onBubbleTap = {[unowned tips] _ in
			tips?.next()
        }
		
        tips!.onDimTap = {[unowned self] _ in
			self.startDayAndNight = false
			guard let tips = self.tips else {return}
			tips.pointer.options = defaultTipOption
            if let index = tips.currentIndex,tips.tips.count == (index + 1) {
                tips.finish()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.tips = nil
                })
            }
            
            tips.next()
        }
        self.tips!.next()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		self.navigationController?.navigationBar.barStyle = .black

		self.showTips()
    }

	private func addAttributedTextTip() {

		let boldAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .bold)]
		let normalAttributes = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15, weight: .regular)]
		let puppiesText = NSMutableAttributedString(string: "Soon to have some ", attributes: normalAttributes)
		let boldStringPart = NSMutableAttributedString(string: " puppies", attributes: boldAttributes)

		puppiesText.append(boldStringPart)

		// create attachment
		let imageAttachment = NSTextAttachment()
		imageAttachment.image = UIImage(named: "pug_puppy")

		// wrap the attachment in its own attributed string so we can append it
		let imageString = NSAttributedString(attachment: imageAttachment)

		// add the NSTextAttachment wrapper to our string, then add some more text.
		puppiesText.append(imageString)
		puppiesText.append(imageString)
		puppiesText.append(imageString)
		puppiesText.append(NSAttributedString(string: " !!!"))

		tips!.add(new: self.pugImage, text: puppiesText, with: pugDescriptionConfig.with{$0.position = .right})
	}
}
