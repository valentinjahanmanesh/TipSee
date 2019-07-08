//
//  ViewController.swift
//  TutorialBubble
//
//  Created by Farshad Jahanmanesh on 7/2/19.
//  Copyright © 2019 Farshad Jahanmanesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var btnToPoint1 : UIButton!
    @IBOutlet weak var btnToPoint2 : UIButton!
    @IBOutlet weak var btnToPoint3 : UIButton!
    @IBOutlet weak var btnToPoint4 : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let hint = HintPointer(with: self)
        let m = hint.show(item: (btnToPoint1,"this is some long text"))
        let z = hint.show(item: (btnToPoint2,"this is some long text"))
        let y = hint.show(item: (btnToPoint3,"this sdis some long text"))
        let x = hint.show(item: (btnToPoint4,"this sdis some lon"))
        
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (t) in
            hint.dismiss(item: y)
            hint.dismiss(item: z)
            hint.dismiss(item: x)
            hint.dismiss(item: m)
        }
    }
}

//
//  BubbleView.swift
//  Core
//
//  Created by Farshad Jahanmanesh on 7/2/19.
//  Copyright © 2019 Tap30. All rights reserved.
//

import Foundation
import UIKit

protocol HintItems: Equatable {
    var pointTo:UIView {set get}
    var showView : UIView {set get}
}

class HintPointer : UIView{
    struct HintItem : HintItems {
        var ID : Int
        var pointTo: UIView
        var showView: UIView
    }
    
    /// properties
    var options : Options = Options.default()
    private var shadowLayer : CAShapeLayer?
    private var viewController : UIViewController
    typealias StringsForViews = (pointTo:UIView,showTexts : String)
    private var views = [HintItem]()
    private var bubbles = [BubbleView]()

    
    @discardableResult func show(item : StringsForViews)->HintItem{
        setupBackgroundDim()
        let viewToShow = HintItem.init(ID: self.views.count, pointTo:item.pointTo,showView:createLabel(for: item.showTexts) as UIView)
        self.views.append(viewToShow)
        bubbles.append(self.point(to: viewToShow))
        createHoleForVisibleViews()
        return viewToShow
    }
    
    private func setupBackgroundDim(){
        if views.isEmpty {
            self.viewController.view.addSubview(self)
            self.setHintConsttraints()
        }
    }
    
    func dismiss(item : HintItem){
        if let index  = self.views.lastIndex(where:{$0  == item}) {
            let bubble = self.bubbles[index]
            bubble.removeFromSuperview()
            self.bubbles.remove(at: index)
            self.views.remove(at: index)
            createHoleForVisibleViews()
        }
        if views.isEmpty {
            self.removeFromSuperview()
        }
    }
    
    /// creates a labelView for useing inside a bubble
    ///
    /// - Parameter text: label text
    /// - Returns: generated label view
    private func createLabel(for text : String)->UILabel{
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = options.font
        label.textColor = options.foregroundColor
        return label
    }
    
    struct Options {
        let bubbleBackgroundColor: UIColor
        let backgroundColor : UIColor
        let bubblePosition : UIRectEdge
        let font : UIFont
        let foregroundColor : UIColor
        static func `default`()->HintPointer.Options{
            return Options.init(bubbleBackgroundColor: .red, backgroundColor: .black,bubblePosition: .left,font: UIFont.boldSystemFont(ofSize: 15),foregroundColor: UIColor.white)
        }
    }
    private func createHoleForVisibleViews(){
        shadowLayer?.removeFromSuperlayer()
        let pathBigRect = UIBezierPath(rect: viewController.view.bounds)
        
        self.views.forEach { (item) in
            // cuts a hole inside the layer
            let cutPosition = CGRect(origin: item.pointTo.superview!.convert(item.pointTo.frame.origin, to: self.viewController.view), size: item.pointTo.bounds.size)
            
            pathBigRect.append(UIBezierPath(roundedRect: cutPosition.insetBy(dx: -4, dy: -4),cornerRadius: 5))
            
        }
        pathBigRect.usesEvenOddFillRule = true
        self.cutHole(for: pathBigRect.cgPath)
    }
   
    init(with vc : UIViewController) {
        self.viewController = vc
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func point(to item : HintItem)->BubbleView{
        let view = item.pointTo
        let label = item.showView
        
        // creates a new empty bubble
        let bubble = BubbleView(frame: .zero)
        bubble.backColor = self.options.bubbleBackgroundColor
        bubble.arrow = .init(position: .init(distance: .mid(offset: 0), edge: .left), size: .init(width: 10, height: 5))
        self.addSubview(bubble)
        
        // binds constraints
        let pointTo = self.setBubbleConstraints(to: view,for: bubble)
        bubble.setContent(view: label,padding: 8)
        
        
        self.layoutIfNeeded()
        // align the arrow
        let center  = view.superview!.convert(view.center, to: viewController.view)
        if pointTo == .top || pointTo ==  .bottom{
            bubble.arrow = .init(position: .init(distance: .constant(center.x - bubble.frame.origin.x), edge: pointTo), size: .init(width: 10, height: 5))
        }else{
            bubble.arrow = .init(position: .init(distance: .mid(offset:0), edge: pointTo), size: .init(width: 10, height: 5))
        }
        return bubble
    }
    
    
    private func findBetterSpace(view: UIView, checkEdges : [UIRectEdge] = [.top,.left,.right,.bottom])->UIRectEdge{
        if view.frame.minX < 100, options.bubblePosition == .left {
            return  .right
        }
        if view.frame.maxX > viewController.view.bounds.width - 100, options.bubblePosition == .right {
            return .left
        }
        if view.frame.minY > viewController.view.bounds.height - 100, options.bubblePosition == .bottom {
            return  .top
        }
        if view.frame.maxY > -100, options.bubblePosition == .bottom {
            return  .bottom
        }
        return options.bubblePosition
    }
    private func setBubbleConstraints(to view : UIView,for bubble : BubbleView)-> UIRectEdge {
        let position  = findBetterSpace(view: view)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        var arrowPoint : UIRectEdge = .right
        switch position {
        case .top,.bottom:
            var TopOrBottomConstraints = bubble.topAnchor.constraint(equalTo: view.bottomAnchor,constant: 16)
            arrowPoint = .top
            if position == .top {
                arrowPoint = .bottom
                TopOrBottomConstraints = bubble.bottomAnchor.constraint(equalTo: view.topAnchor,constant: -16)
            }
            let trailing = bubble.rightAnchor.constraint(lessThanOrEqualTo: viewController.view.rightAnchor, constant: -16)
            let leading = bubble.leftAnchor.constraint(greaterThanOrEqualTo: viewController.view.leftAnchor, constant: 16)
            let midX = bubble.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            midX.priority = .defaultLow
            
            NSLayoutConstraint.activate([leading,trailing,TopOrBottomConstraints,midX])
            
        case .left,.right:
            var leading = bubble.leftAnchor.constraint(equalTo: view.rightAnchor,constant: 16)
            var trailing =  bubble.rightAnchor.constraint(lessThanOrEqualTo: viewController.view.rightAnchor, constant: -16)
            arrowPoint = .left
            if position == .left {
                arrowPoint = .right
                leading = bubble.rightAnchor.constraint(equalTo: view.leftAnchor,constant: -16)
                trailing =  bubble.leftAnchor.constraint(greaterThanOrEqualTo: viewController.view.leftAnchor, constant: 16)
            }
            
            let midY =   bubble.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            let top = bubble.topAnchor.constraint(greaterThanOrEqualTo: viewController.view.topAnchor, constant: -16)
            
            let bottom = bubble.bottomAnchor.constraint(lessThanOrEqualTo: viewController.view.bottomAnchor, constant: -16)
            
            NSLayoutConstraint.activate([leading,top,bottom,midY,trailing])
        default:
            break
        }
        self.viewController.view.setNeedsUpdateConstraints()
        self.viewController.view.layoutIfNeeded()
        return arrowPoint
    }
    
    private func setHintConsttraints(){
        // My Constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: self.viewController.view.topAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: self.viewController.view.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: self.viewController.view.leftAnchor).isActive = true
    }
    
    private func cutHole(for path : CGPath){
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = options.backgroundColor.cgColor
        fillLayer.opacity = 0.7
        self.layer.insertSublayer(fillLayer, at: 0)
        shadowLayer = fillLayer
    }
}
class BubbleView: UIView {
    
    private let cornerRadius: CGFloat = 4
    private lazy var shape : CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.rasterizationScale = UIScreen.main.scale
        shape.shouldRasterize = true
        return shape
    }()
    
    var backColor: UIColor? {
        didSet { setNeedsLayout() }
    }
    
    public struct Arrow {
        public struct Position {
            enum Distance {
                case mid(offset:CGFloat)
                case constant(_ offset:CGFloat)
            }
            public var distance: Distance
            public var edge: UIRectEdge
        }
        public var position: Position
        public var size: CGSize
    }
    
    var arrow: Arrow = .init(position: .init(distance: .constant(0), edge: .left), size: .zero) {
        didSet { setNeedsLayout() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //default value
        backgroundColor = .clear//UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 1.0)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        layer.insertSublayer(shape, at: 0)
        backgroundColor = .clear
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1.0
        layer.shadowColor = UIColor.black.cgColor
    }
    
    func setContent(view: UIView, padding : CGFloat = 0) {
        //remove all subviews
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,constant: padding).isActive = true
        view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,constant: -padding).isActive = true
        view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor,constant: -padding).isActive = true
        view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor,constant: padding).isActive = true
        
    }
    
    private func getStandardArrowCenterOffset() -> CGFloat {
        let minOffset = arrow.size.width/2 + cornerRadius
        let viewWidth = self.frame.width
        switch arrow.position.distance {
        case .mid(let offset):
            return max(minOffset, min(offset + ((arrow.position.edge == .top || arrow.position.edge == .bottom) ? self.bounds.midX : self.bounds.midY), ((arrow.position.edge == .top || arrow.position.edge == .bottom) ? self.frame.width : self.frame.height) - minOffset))
        case .constant(let offset):
            return max(minOffset, min(offset, viewWidth - minOffset))
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        
        let height = self.frame.height
        let width = self.frame.width
        let minX = self.bounds.minX
        let minY = self.bounds.minY
        let arrowWidth = arrow.size.width
        let arrowHeight = arrow.size.height
        let offset = getStandardArrowCenterOffset()
        
        switch arrow.position.edge {
        case .top:
            path.move(to: CGPoint(x: minX + offset - arrowWidth/2, y: minY))
            path.addLine(to: CGPoint(x: minX + offset, y: minY - arrowHeight))
            path.addLine(to: CGPoint(x: minX + offset + arrowWidth/2, y: minY))
        case .bottom:
            path.move(to: CGPoint(x: minX + offset - arrowWidth/2, y: minY + height))
            path.addLine(to: CGPoint(x: minX + offset, y: minY + height + arrowHeight))
            path.addLine(to: CGPoint(x: minX + offset + arrowWidth/2, y: minY + height))
        case .right:
            path.move(to: CGPoint(x: minX + width, y: minY + offset - arrowWidth/2))
            path.addLine(to: CGPoint(x: minX + width + arrowHeight, y: minY + offset))
            path.addLine(to: CGPoint(x: minX + width, y: minY + offset + arrowWidth/2))
        default:
            path.move(to: CGPoint(x: minX, y: minY + offset - arrowWidth/2))
            path.addLine(to: CGPoint(x: minX - arrowHeight, y: minY + offset))
            path.addLine(to: CGPoint(x: minX, y: minY + offset + arrowWidth/2))
        }
        
        let roundedRectPath = UIBezierPath(
            roundedRect: CGRect(x: minX, y: minY, width: width, height: height),
            cornerRadius: cornerRadius
        )
        
        path.append(roundedRectPath)
        shape.fillColor = backColor?.cgColor
        shape.path = path.cgPath
        
        
    }
}


extension HintPointer {
    func slideShow(for views : [StringsForViews],interval : TimeInterval){
        //        self.viewController.view.addSubview(self)
        //        self.setHintConsttraints()
        //
        //        self.views = views.compactMap({v,text in
        //            let label = UILabel()
        //            label.text = text
        //            label.textAlignment = .center
        //            label.lineBreakMode = .byWordWrapping
        //            label.numberOfLines = 0
        //            label.sizeToFit()
        //            label.font = options.font
        //            label.textColor = options.foregroundColor
        //            return (v, label)
        //        })
        //        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
        //            self.point(to: self.views[].pointTo, with: self.views[(0...3).randomElement()!].showView)
        //        }
    }
}
