//
//  AsyncOperation.swift
//  
//
//  Created by RICHEZ Thibaut on 10/27/20.
//

import Foundation

class AsyncOperation: Operation {
    /// Queue that makes access to `isExecuting` and `isFinished` thread-safe
    /// (`Operation` subclass requirements).
    ///
    /// - Note: A concurrent queue with barrier flag is used to make access
    /// to certain resources or values thread-safe. We can synchronize the write
    /// access while keeping the benefit of reading concurrently.
    private let lockQueue = DispatchQueue(label: "com.networker.asyncoperation", attributes: .concurrent)

    private var _isExecuting: Bool = false

    /// To manage the state correctly, we need to override `isExecuting`
    /// propertiy with multi-threading and KVO support.
    /// (`Operation` subclass requirements).
    override private(set) var isExecuting: Bool {
        get {
            return self.lockQueue.sync { () -> Bool in
                return self._isExecuting
            }
        }
        set {
            self.willChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
            self.lockQueue.sync(flags: [.barrier]) {
                self._isExecuting = newValue
            }
            self.didChangeValue(forKey: #keyPath(AsyncOperation.isExecuting))
        }
    }

    private var _isFinished: Bool = false

    /// To manage the state correctly, we need to override `isExecuting`
    /// propertiy with multi-threading and KVO support.
    /// (`Operation` subclass requirements).
    override private(set) var isFinished: Bool {
        get {
            return self.lockQueue.sync { () -> Bool in
                return self._isFinished
            }
        }
        set {
            self.willChangeValue(forKey: #keyPath(AsyncOperation.isFinished))
            self.lockQueue.sync(flags: [.barrier]) {
                self._isFinished = newValue
            }
            self.didChangeValue(forKey: #keyPath(AsyncOperation.isFinished))
        }
    }

    /// Marks the operation as asynchronous
    /// (`Operation` subclass requirements.)
    override var isAsynchronous: Bool { true }

    /// Needed to handle a concurrent `Operation`
    /// We updates the execution state of the operation
    /// and calls the receiver’s `main()` method.
    /// This method also performs several checks to ensure
    /// that the operation can actually run as the `super.`
    /// instance will.
    ///
    /// - Note: We must never call super.start() in this
    /// method as we’re now handling the state ourselves.
    override func start() {
        guard !self.isCancelled else {
            self.finish()
            return
        }

        guard self.isReady, !self.isFinished, !self.isExecuting else {
            return
        }

        self.isFinished = false
        self.isExecuting = true
        self.main()
    }

    /// Subclasses must implement `main`, perform asynchronous task, then
    /// call the `finish()` method.
    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }

    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
}
