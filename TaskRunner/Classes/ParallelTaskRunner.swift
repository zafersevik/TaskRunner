//
//  ParallelTaskRunner.swift
//  TaskRunner
//
//  Copyright © 2016 Zafer Sevik
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public typealias Task = (@escaping Done) -> Void
public typealias Done = (Error?) -> Void
public typealias Callback = () -> Void

class ParallelTaskRunner {
    
    private let timeoutError: Error = NSError(domain: "TaskRunner",
                                              code: 1,
                                              userInfo: [NSLocalizedDescriptionKey: "Task timed out"])
    private var tasks: [Task]?
    private var allTasksDone: Done?
    private var durationToComplete = 10.0
    private var isAllTasksDoneCalled = false
    private var numberOfTasksRan = 0
    
    lazy private var done: Done = {
        [weak self] error in
        guard let weakSelf = self else { return }
        
        if error != nil {
            weakSelf.callAllTasksDone(error: error)
            return
        }
        
        weakSelf.incrementNumberOfTasksRan()
        
        if weakSelf.areAllTasksFinished() {
            weakSelf.callAllTasksDone(error: nil)
        }
    }
    
    private func callAllTasksDone(error: Error?) {
        if isAllTasksDoneCalled == false {
            isAllTasksDoneCalled = true
            allTasksDone?(error)
        }
    }
    
    private func incrementNumberOfTasksRan() {
        numberOfTasksRan += 1
    }
    
    private func areAllTasksFinished()  -> Bool {
        return numberOfTasksRan == tasks?.count
    }
    
    func set(durationToComplete: Double) {
        self.durationToComplete = durationToComplete
    }
    
    func set(allTasksDone: Done?) {
        self.allTasksDone = allTasksDone
    }
    
    func set(tasks: [Task]?) {
        self.tasks = tasks
    }
    
    func run() {
        startTasksTimer()
        
        if doesAnyTaskExist() {
            startAllTasks()
        }
        else {
            callAllTasksDone(error: nil)
        }
    }
    
    private func startTasksTimer() {
        let deadline = DispatchTime.now() + durationToComplete
        DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) {
            [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.callAllTasksDone(error: weakSelf.timeoutError)
        }
    }
    
    private func doesAnyTaskExist() -> Bool {
        guard let theTasks = tasks else { return false }
        
        if theTasks.count == 0 {
            return false
        }
        return true
    }
    
    private func startAllTasks() {
        guard let theTasks = tasks else { return }
        
        for task in theTasks {
            task(done)
        }
    }
}
