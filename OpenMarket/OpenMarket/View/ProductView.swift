//
//  ProductView.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/16.
//

import UIKit

class ProductView: UIView {
    
    func makeSegmentedControl() -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: ["LIST", "GRID"])
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .systemBlue
        
        return segmentedControl
    }
    
    func makePlusButton() -> UIBarButtonItem {
        let plusButton = UIBarButtonItem()
        
        plusButton.title = "+"
        
        return plusButton
    }
    
    func makeCollectionView() -> UICollectionView {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeListlayout())
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    func makeListlayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func makeGridlayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeLayout() {
        backgroundColor = .white
    
        NSLayoutConstraint.activate([
            self.makeCollectionView().leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.makeCollectionView().trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.makeCollectionView().topAnchor.constraint(equalTo: self.topAnchor),
            self.makeCollectionView().bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        makeSegmentedControl().addTarget(self, action: #selector(switchSegment(segmentControl:)), for: .valueChanged)
    }
    
    @objc func switchSegment(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            makeCollectionView().collectionViewLayout = makeListlayout()
        case 1:
            makeCollectionView().collectionViewLayout = makeGridlayout()
        default:
            makeCollectionView().collectionViewLayout = makeListlayout()
        }
    }
}
