//
//  ViewController+EXT.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit

extension UIViewController {
    enum AttachTo {
        case top
        case bottom
    }
    
    func showToast(message: String, attachTo: AttachTo) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = .clear
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25
        toastContainer.clipsToBounds = true
        
        let toastVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        toastVisualEffect.frame = CGRect()
        
        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = .black
        toastLabel.font.withSize(12.0)
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
        toastLabel.textAlignment = .center
        
        toastContainer.addSubview(toastVisualEffect)
        toastContainer.addSubview(toastLabel)
        
        self.view.addSubview(toastContainer)
        
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastVisualEffect.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let a1  = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
        let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
        let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
        let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
        toastContainer.addConstraints([a1, a2, a3, a4])
        
        let b1 = NSLayoutConstraint(item: toastVisualEffect, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 0)
        let b2 = NSLayoutConstraint(item: toastVisualEffect, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 0)
        let b3 = NSLayoutConstraint(item: toastVisualEffect, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: 0)
        let b4 = NSLayoutConstraint(item: toastVisualEffect, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: 0)
        toastContainer.addConstraints([b1, b2, b3, b4])
        
        switch attachTo {
        case .top:
            let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 65)
            let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -65)
            let c3 = NSLayoutConstraint(item: toastContainer, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 32)
            self.view.addConstraints([c1, c2, c3])
            
        case .bottom:
            let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 65)
            let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -65)
            let c3 = NSLayoutConstraint(item: toastContainer, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -32)
            self.view.addConstraints([c1, c2, c3])
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
