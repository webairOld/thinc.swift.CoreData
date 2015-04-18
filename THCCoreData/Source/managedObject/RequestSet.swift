//
//  RequestSet.swift
//  THCCoreData
//
//  Created by Christopher weber on 17.04.15.
//  Copyright (c) 2015 Thinc. All rights reserved.
//

import Foundation
import CoreData

public class RequestSet<T:ManagedObjectEntity>: SequenceType {
    
    private var objects:[NSManagedObject]?
    public var context:NSManagedObjectContext
    
    public var count: Int {
        get{
            if let objects = self.objects {
                return objects.count
            }
            return self.context.countForFetchRequest(self.fetchRequest, error: nil)
        }
    }
    
    private(set) public var fetchRequest: NSFetchRequest
    
    public subscript(index: Int) -> T {
        get {
            assert(index >= 0 && index < self.count, "Index out of range")
            self.fetchObjects()
            return self.objects![index] as! T
        }
    }
    
    public func generate() -> GeneratorOf<T> {
        self.fetchObjects()
        var nextIndex = 0
        return GeneratorOf<T> {
            if self.objects == nil || nextIndex == self.objects!.count {
                return nil
            }
            return self.objects![nextIndex++] as? T
        }
    }
    
    public func filter(predicate:NSPredicate) -> Self {
        //TODO: validate predicate
        if let fetchPredicate = self.fetchRequest.predicate {
            self.fetchRequest.predicate = NSCompoundPredicate.andPredicateWithSubpredicates([fetchPredicate, predicate])
        } else {
            self.fetchRequest.predicate = predicate
        }
        return self
    }
    
    public func filter(filter: (key:String,value:AnyObject)) -> Self {
        let predicate = NSPredicate(format: "%K = %@", filter.key, filter.value as! NSObject)
        return self.filter(predicate)
    }
    
    public func filter(filters: [(key:String, value:AnyObject)]) -> Self {
        for filter in filters{
            self.filter(filter)
        }
        return self
    }
    
    public init(context:NSManagedObjectContext) {
        self.context = context
        self.fetchRequest = self.context.fetchRequest(T)
    }
    
    private func fetchObjects() {
        if self.objects == nil {
            var error:NSError?
            self.objects = self.context.executeFetchRequest(self.fetchRequest, error: &error) as? [NSManagedObject]
        }
    }
}
