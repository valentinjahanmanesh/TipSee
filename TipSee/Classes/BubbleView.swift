//
//  BubbleView.swift
//  TipSee
//
//  Created by Farshad Jahanmanesh on 8/14/19.
//

import Foundation
import UIKit
public class BubbleView: UIView {
	public private(set) var insideView: UIView?
	private let cornerRadius: CGFloat = 4
	private lazy var shape: CAShapeLayer = {
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
			public enum Distance {
				case mid(offset:CGFloat)
				case constant(_ offset:CGFloat)
			}
			public var distance: Distance
			public var edge: CGRectEdge
		}
		public var position: Position
		public var size: CGSize
	}
	
	public var arrow: Arrow = .init(position: .init(distance: .constant(0), edge: .minXEdge), size: .zero) {
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
		layer.shadowOpacity = 0.2
		layer.shadowOffset = CGSize(width: 0, height: 1)
		layer.shadowRadius = 1.0
		layer.shadowColor = UIColor.black.cgColor
	}
	
	func setContent(view: UIView, padding: CGFloat = 0) {
		//remove all subviews
		self.subviews.forEach {
			$0.removeFromSuperview()
		}
		
		self.addSubview(view)
		insideView = view
		if self.translatesAutoresizingMaskIntoConstraints {
			view.frame.origin = CGPoint(x: padding, y: padding)
			view.frame.size = self.frame.insetBy(dx: padding, dy: padding).size
			view.removeConstraints(view.constraints)
		}else {
			view.translatesAutoresizingMaskIntoConstraints = false
			if #available(iOS 11.0, *) {
				view.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -padding).isActive = true
				view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: padding).isActive = true
				view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -padding).isActive = true
				view.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: padding).isActive = true
				
			} else {
				view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -padding).isActive = true
				view.topAnchor.constraint(equalTo: self.topAnchor, constant: padding).isActive = true
				view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding).isActive = true
				view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: padding).isActive = true
			}
		}
	}
	
	private func getStandardArrowCenterOffset() -> CGFloat {
		let minOffset = arrow.size.width/2 + cornerRadius
		let viewWidth = self.frame.width
		switch arrow.position.distance {
		case .mid(let offset):
			switch arrow.position.edge {
			case .maxYEdge, .minYEdge:
				return max(minOffset, min(offset +  self.bounds.midX, self.frame.width - minOffset))
			default :
				return max(minOffset, min(offset + self.bounds.midY, self.frame.height - minOffset))
			}
		case .constant(let offset):
			return max(minOffset, min(offset, viewWidth - minOffset))
		}
	}
	
	public override func layoutSubviews() {
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
		case .minYEdge:
			path.move(to: CGPoint(x: minX + offset - arrowWidth/2, y: minY))
			path.addLine(to: CGPoint(x: minX + offset, y: minY - arrowHeight))
			path.addLine(to: CGPoint(x: minX + offset + arrowWidth/2, y: minY))
		case .maxYEdge:
			path.move(to: CGPoint(x: minX + offset - arrowWidth/2, y: minY + height))
			path.addLine(to: CGPoint(x: minX + offset, y: minY + height + arrowHeight))
			path.addLine(to: CGPoint(x: minX + offset + arrowWidth/2, y: minY + height))
		case .maxXEdge:
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
