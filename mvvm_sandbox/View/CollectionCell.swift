//
//  CollectionCell.swift
//  mvvm_sandbox
//
//  Created by Omar Eduardo Gomez Padilla on 6/30/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class CollectionCell: UICollectionViewCell {
    
    static let id = "\(CollectionCell.self)"
    
    @IBOutlet weak var image: UIImageView!
    
    var task: URLSessionTask?
    
    func scheduleImageLoad(_ url: URL) {
        
        self.task?.cancel()
        self.task = URLSession.shared.createImageTask(fromURL: url, completion: { [weak self] image, error in
            guard let theImage = image, error == nil else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.image.image = theImage
                self.setNeedsLayout()
            }
        })
        self.task?.resume()
    }
    
    override func prepareForReuse() {
        guard let task = self.task else {
            return
        }
        
        if task.state == .running {
            task.cancel()
        }
        self.task = nil
        self.image.image = nil
        
    }
}
