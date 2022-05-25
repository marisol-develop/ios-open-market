//
//  RegistrationViewController.swift
//  OpenMarket
//
//  Created by Eddy, marisol on 2022/05/24.
//

import UIKit

final class RegistrationViewController: UIViewController, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    var imageArray = [UIImage]()
    let rightNavigationButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        return collectionView
    }()
    
    let productDetailView = ProductDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        self.view.addSubview(productDetailView)
        self.view.backgroundColor = .white
        productDetailView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        imagePicker.delegate = self
        collectionView.register(RegistrationViewCell.self, forCellWithReuseIdentifier: RegistrationViewCell.identifier)
        setLayout()
        self.navigationController?.navigationBar.topItem?.title = "Cancel"
        self.title = "상품등록"
        self.navigationItem.rightBarButtonItem = rightNavigationButton
        rightNavigationButton.isEnabled = false
    }
    
    func setLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: productDetailView.topAnchor, constant: -10),
            collectionView.heightAnchor.constraint(equalToConstant: 160),
            
            productDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productDetailView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            productDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func pickImage(_ sender: UIButton) {
        let actionSheet = UIAlertController()
        
        let importFromAlbum = UIAlertAction(title: "앨범에서 가져오기", style: .default) { _ in
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhoto = UIAlertAction(title: "카메라로 사진 찍기", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(importFromAlbum)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension RegistrationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imageCount = imageArray.count + 1
        return imageCount < 5 ? imageCount : 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegistrationViewCell.identifier, for: indexPath) as? RegistrationViewCell else {
            return UICollectionViewCell()
        }
        
        cell.button.addTarget(self, action: #selector(self.pickImage(_:)), for: .touchUpInside)
        
        cell.contentView.addSubview(cell.button)
        
        if imageArray.count > indexPath.row {
            let image = imageArray[indexPath.row]
            cell.button.setImage(image, for: .normal)
            cell.button.backgroundColor = .clear
            cell.button.setTitle(nil, for: .normal)
        }
        
        return cell
    }
}

extension RegistrationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension RegistrationViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true) {
            guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
                return
            }
            
            let imageCapacity = image.checkImageCapacity()
            
            if imageCapacity > 300 {
                let resizedImage = image.resize(newWidth: 80)
                self.imageArray.append(resizedImage)
            } else {
                self.imageArray.append(image)
            }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RegistrationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actionSheet = UIAlertController()
        
        let importFromAlbum = UIAlertAction(title: "앨범에서 가져오기", style: .default) { _ in
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let takePhoto = UIAlertAction(title: "카메라로 사진 찍기", style: .default) { _ in
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        actionSheet.addAction(importFromAlbum)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale

        let size = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return renderedImage
    }
    
    func checkImageCapacity() -> Double {
        var capacity: Double = 0.0
        guard let data = self.pngData() else {
            return 0.0
        }
        
        capacity = Double(data.count) / 1024
        
        return capacity
    }
}
