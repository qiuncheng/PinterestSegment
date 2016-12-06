//
//  PinterestSegment.swift
//  Demo
//
//  Created by Tbxark on 06/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit

public struct PinterestSegmentStyle {

    public var coverBackgroundColor = UIColor(white: 0.95, alpha: 1)
    public var titleMargin: CGFloat = 15
    public var titlePendingHorizontal: CGFloat = 14
    public var titlePendingVertical: CGFloat = 14
    public var titleFont = UIFont.boldSystemFont(ofSize: 14)
    public var normalTitleColor = UIColor.lightGray
    public var selectedTitleColor = UIColor.darkGray

    public init() {}

}



public class PinterestSegment: UIControl {

    public var style: PinterestSegmentStyle {
        didSet {
            reloadData()
        }
    }
    public var titles:[String] {
        didSet {
            guard oldValue != titles else { return }
            reloadData()
            setSelectIndex(index: 0, animated: true)
        }
    }
    public var valueChange: ((Int) -> Void)?
    fileprivate var titleLabel: [UILabel] = []
    fileprivate(set) var selectIndex = 0


    fileprivate  let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.bounces = true
        view.isPagingEnabled = false
        view.scrollsToTop = false
        view.isScrollEnabled = true
        return view
    }()

    fileprivate let selectContent =  UIView()
    fileprivate var indicator: UIView = {
        let cover = UIView()
        cover.layer.masksToBounds = true
        return cover
    }()
    fileprivate let selectedLabelsMaskView: UIView = {
        let cover = UIView()
        cover.layer.masksToBounds = true
        return cover
    }()



    //MARK:- life cycle
    public convenience init(frame: CGRect, titles: [String]) {
        self.init(frame: frame, segmentStyle: PinterestSegmentStyle(), titles:  titles)
    }

    public init(frame: CGRect, segmentStyle: PinterestSegmentStyle, titles: [String]) {
        self.style = segmentStyle
        self.titles = titles
        super.init(frame: frame)
        addSubview(scrollView)
        reloadData()
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    @objc fileprivate func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x + scrollView.contentOffset.x
        for (i, label) in titleLabel.enumerated() {
            if x >= label.frame.minX && x <= label.frame.maxX {
                setSelectIndex(index: i, animated: true)
            }
        }

    }

}

//MARK: - public helper
extension PinterestSegment {

    public func setSelectIndex(index: Int,animated: Bool = true) {

        guard index != selectIndex, index >= 0 , index < titleLabel.count else { return }

        let currentLabel = titleLabel[index]
        let offSetX = min(max(0, currentLabel.center.x - bounds.width / 2),
                          max(0, scrollView.contentSize.width - bounds.width))
        scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: true)

        if animated {

            UIView.animate(withDuration: 0.2, animations: {
                var rect = self.indicator.frame
                rect.origin.x = currentLabel.frame.origin.x
                rect.size.width = currentLabel.frame.size.width
                self.setIndicatorFrame(rect)            })

        } else {
            var rect = indicator.frame
            rect.origin.x = currentLabel.frame.origin.x
            rect.size.width = currentLabel.frame.size.width
            setIndicatorFrame(rect)
        }

        selectIndex = index
        valueChange?(index)
        sendActions(for: UIControlEvents.valueChanged)
    }
}



//MARK: - fileprivate helper
extension PinterestSegment {

    func setIndicatorFrame(_ frame: CGRect) {
        indicator.frame = frame
        selectedLabelsMaskView.frame = frame

    }


    fileprivate func reloadData() {

        scrollView.subviews.forEach { $0.removeFromSuperview() }
        selectContent.subviews.forEach { $0.removeFromSuperview() }
        titleLabel.removeAll()

        // Set titles
        let font  = style.titleFont
        var titleX: CGFloat = 0.0
        let titleY: CGFloat = 0.0
        let titleH = font.lineHeight
        let coverH: CGFloat = font.lineHeight + style.titlePendingVertical

        selectedLabelsMaskView.backgroundColor = UIColor.black
        scrollView.frame = bounds
        selectContent.frame = bounds
        selectContent.layer.mask = selectedLabelsMaskView.layer
        selectedLabelsMaskView.isUserInteractionEnabled = true

        let toToSize: (String) -> CGFloat = { text in
            return (text as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 0.0), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).width
        }

        for (index, title) in titles.enumerated() {

            let titleW = toToSize(title) + style.titlePendingHorizontal * 2
            titleX = (titleLabel.last?.frame.maxX ?? 0 ) + style.titleMargin
            let rect = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)

            let label = UILabel(frame: CGRect.zero)
            label.tag = index
            label.text = title
            label.textColor = style.normalTitleColor
            label.font = style.titleFont
            label.textAlignment = .center
            label.frame = rect

            let select = UILabel(frame: CGRect.zero)
            select.tag = index
            select.text = title
            select.textColor = style.selectedTitleColor
            select.font = style.titleFont
            select.textAlignment = .center
            select.frame = rect

            titleLabel.append(label)
            scrollView.addSubview(label)
            selectContent.addSubview(select)

            if index == titles.count - 1 {
                scrollView.contentSize.width = rect.maxX
                selectContent.frame.size.width = rect.maxX
            }
        }

        // Set Cover
        indicator.backgroundColor = style.coverBackgroundColor
        scrollView.addSubview(indicator)
        scrollView.addSubview(selectContent)

        let coverX = titleLabel[0].frame.origin.x
        let coverY = (bounds.size.height - coverH) / 2
        let coverW = titleLabel[0].frame.size.width

        let indRect = CGRect(x: coverX, y: coverY, width: coverW, height: coverH)
        setIndicatorFrame(indRect)

        indicator.layer.cornerRadius = coverH/2
        selectedLabelsMaskView.layer.cornerRadius = coverH/2


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PinterestSegment.handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
}