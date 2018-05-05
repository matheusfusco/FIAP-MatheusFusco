//
//  UIViewController+CoreData.swift
//  MatheusFusco
//
//  Created by Matheus Pacheco Fusco on 18/04/2018.
//  Copyright © 2018 FIAP. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
