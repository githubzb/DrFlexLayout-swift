//
//  CollectionViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/11/27.
//

import UIKit

class CollectionViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.itemSize = CGSize(width: 0, height: 60)
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.dataSource = self
        v.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        v.backgroundColor = .green
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        if size.width == 0 {
            (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: view.bounds.width * 0.9, height: size.height)
        }
        collectionView.frame = view.bounds
    }
    
}


extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 10
        cell.backgroundView = v
        return cell
    }
    
}
