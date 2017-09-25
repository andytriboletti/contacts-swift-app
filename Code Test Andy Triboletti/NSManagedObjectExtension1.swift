//
//  NSManagedObjectExtension1.swift
//  Code Test Andy Triboletti
//
//  Created by Andy Triboletti on 9/22/17.
//  Copyright © 2017 GreenRobot LLC. All rights reserved.
//

import Foundation
import CoreData
extension NSManagedObject {
    func addObject(value: NSManagedObject, forKey: String) {
        var items = self.mutableSetValue(forKey: forKey);
        items.add(value)
    }
}
