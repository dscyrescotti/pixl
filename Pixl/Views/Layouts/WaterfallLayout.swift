//
//  WaterfallLayout.swift
//  Pixl
//
//  Created by Dscyre Scotti on 21/04/2021.
//

import UIKit

@objc protocol WaterfallLayoutDelegate {
    @objc optional func collectionView(collectionView: UICollectionView,
                                       sizeForSectionHeaderViewForSection section: Int) -> CGSize
    
    @objc optional func collectionView(collectionView: UICollectionView,
                                       sizeForSectionFooterViewForSection section: Int) -> CGSize
    
    func collectionView(collectionView: UICollectionView,
                        heightForCellAtIndexPath indexPath: IndexPath,
                        withWidth: CGFloat) -> CGFloat
}

class WaterfallLayout: UICollectionViewLayout {
    weak var delegate: WaterfallLayoutDelegate!
    
    var numberOfColumns: Int = 1
    
    var cellPadding: CGFloat = 0
    
    
    private var cache = [WaterfallLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        get {
            let bounds = collectionView.bounds
            let insets = collectionView.contentInset
            return bounds.width - insets.left - insets.right
        }
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(
                width: contentWidth,
                height: contentHeight
            )
        }
    }
    
    override class var layoutAttributesClass: AnyClass {
        return WaterfallLayoutAttributes.self
    }
    
    override var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    private var numberOfSections: Int {
        return collectionView.numberOfSections
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    
    override func invalidateLayout() {
        cache.removeAll()
        contentHeight = 0
        
        super.invalidateLayout()
    }
    
    override func prepare() {
        if cache.isEmpty {
            let columnWidth = contentWidth / CGFloat(numberOfColumns)
            let cellWidth = columnWidth - (cellPadding * 2)
            
            var xOffsets = [CGFloat]()
            
            for collumn in 0..<numberOfColumns {
                xOffsets.append(CGFloat(collumn) * columnWidth)
            }
            
            for section in 0..<numberOfSections {
                let numberOfItems = self.numberOfItems(inSection: section)
                
                if let headerSize = delegate.collectionView?(
                    collectionView: collectionView,
                    sizeForSectionHeaderViewForSection: section
                    ) {
                    let headerX = (contentWidth - headerSize.width) / 2
                    let headerFrame = CGRect(
                        origin: CGPoint(
                            x: headerX,
                            y: contentHeight
                        ),
                        size: headerSize
                    )
                    let headerAttributes = WaterfallLayoutAttributes(
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        with: IndexPath(item: 0, section: section)
                    )
                    headerAttributes.frame = headerFrame
                    cache.append(headerAttributes)
                    
                    contentHeight = headerFrame.maxY
                }
                
                var yOffsets = [CGFloat](
                    repeating: contentHeight,
                    count: numberOfColumns
                )
                
                for item in 0..<numberOfItems {
                    let indexPath = IndexPath(item: item, section: section)
                    
                    let column = yOffsets.firstIndex(of: yOffsets.min() ?? 0) ?? 0
                    
                    let height = delegate.collectionView(
                        collectionView: collectionView,
                        heightForCellAtIndexPath: indexPath,
                        withWidth: cellWidth
                    )
                    let cellHeight = cellPadding + height + cellPadding
                    
                    let frame = CGRect(
                        x: xOffsets[column],
                        y: yOffsets[column],
                        width: columnWidth,
                        height: cellHeight
                    )
                    
                    let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                    let attributes = WaterfallLayoutAttributes(
                        forCellWith: indexPath
                    )
                    attributes.frame = insetFrame
                    attributes.height = height
                    cache.append(attributes)
                    
                    contentHeight = max(contentHeight, frame.maxY)
                    yOffsets[column] = yOffsets[column] + cellHeight
                }
                
                if let footerSize = delegate.collectionView?(
                    collectionView: collectionView,
                    sizeForSectionFooterViewForSection: section
                    ) {
                    let footerX = (contentWidth - footerSize.width) / 2
                    let footerFrame = CGRect(
                        origin: CGPoint(
                            x: footerX,
                            y: contentHeight
                        ),
                        size: footerSize
                    )
                    let footerAttributes = WaterfallLayoutAttributes(
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                        with: IndexPath(item: 0, section: section)
                    )
                    footerAttributes.frame = footerFrame
                    cache.append(footerAttributes)
                    
                    contentHeight = footerFrame.maxY
                }
            }
        }
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}

class WaterfallLayoutAttributes: UICollectionViewLayoutAttributes {
    var height: CGFloat = 0
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! WaterfallLayoutAttributes
        copy.height = height
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? WaterfallLayoutAttributes {
            if attributes.height == height {
                return super.isEqual(object)
            }
        }
        return false
    }
}
