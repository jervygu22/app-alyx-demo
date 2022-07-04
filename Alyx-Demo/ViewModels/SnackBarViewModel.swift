//
//  SnackBarViewModel.swift
//  Jeeves-dev
//
//  Created by CDI on 3/28/22.
//

import Foundation
import UIKit

typealias SnackBarHandler = (()->Void)

enum SnackBarViewType {
    case info
    case action(handler: SnackBarHandler)
}

struct SnackBarViewModel {
    let type: SnackBarViewType
    let text: String
    let image: UIImage?
}
