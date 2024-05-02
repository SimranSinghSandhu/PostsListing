//
//  Storyboarded.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit

enum StorybordName: String {
    case main = "Main"
}

protocol Storyboarded { }

extension Storyboarded where Self: UIViewController {

    // Creates a view controller from our storyboard. This relies on view controllers having the same storyboard identifier as their class name. This method shouldn't be overridden in conforming types.

    static func instantiate(storyBoardName: String) -> Self {

        let storyboardIdentifier = String(describing: self)

        let storyboard = UIStoryboard(name: storyBoardName, bundle: Bundle.main)

        return storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
    }
}

