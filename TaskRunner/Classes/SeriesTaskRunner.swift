//
//  SeriesTaskRunner.swift
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

open class SeriesTaskRunner: InnerTaskRunnerProtocol {
    
    private var durationToComplete = DEFAULT_DURATION_TO_COMPLETE
    private var tasks: [Task]?
    private var allTasksDone: Done?
    private var isAllTasksDoneCalled = false
    private var taskIndex = 0
    
    public init() {}
    
    open func set(durationToComplete: Double) {
       self.durationToComplete = durationToComplete
    }
    
    open func set(tasks: [Task]?) {
        self.tasks = tasks
    }
    
    open func set(allTasksDone: Done?) {
        self.allTasksDone = allTasksDone
    }
    
    open func run() {
        startTasksTimer()
        
        if isTasksListEmpty() {
            callAllTasksDone()
        }
        else {
            runTask()
        }
    }
    
    private func startTasksTimer() {
        let deadline = DispatchTime.now() + durationToComplete
        DispatchQueue.global(qos: .background).asyncAfter(deadline: deadline) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.callAllTasksDone(error: TIMEOUT_ERROR)
        }
    }
    
    private func isTasksListEmpty() -> Bool {
        guard let tasks = tasks else { return true }
        return tasks.isEmpty
    }
    
    private func callAllTasksDone(error: Error? = nil) {
        if isAllTasksDoneCalled == false {
            isAllTasksDoneCalled = true
            allTasksDone?(error)
        }
    }
    
    lazy private var whenTaskDone: Done = { [weak self] error in
        guard let strongSelf = self else { return }
        
        if error != nil {
            strongSelf.callAllTasksDone(error: error)
            return
        }
        
        strongSelf.incrementTaskIndex()
        
        if strongSelf.areAllTasksFinished() {
            strongSelf.callAllTasksDone()
        }
        else {
            strongSelf.runTask()
        }
    }
    
    private func runTask() {
        guard let tasks = tasks else { return }
        tasks[taskIndex](whenTaskDone)
    }
    
    private func incrementTaskIndex() {
        taskIndex += 1
    }
    
    private func areAllTasksFinished() -> Bool {
        guard let tasks = tasks else { return true }
        return taskIndex >= tasks.count
    }
    
    public static func ==(lhs: SeriesTaskRunner, rhs: SeriesTaskRunner) -> Bool {
        return lhs === rhs
    }
}
