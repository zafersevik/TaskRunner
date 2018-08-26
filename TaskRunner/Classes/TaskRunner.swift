//
//  TaskRunner.swift
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

public typealias Task = (@escaping Done) -> ()
public typealias Done = (Error?) -> ()

let DEFAULT_DURATION_TO_COMPLETE = 10.0
let TIMEOUT_ERROR: Error = NSError(domain: "TaskRunner",
                                   code: 1,
                                   userInfo: [NSLocalizedDescriptionKey: "Task isn't completed in expected time interval"])

open class TaskRunner {
    
    private var durationToComplete: Double!
    var runnerReferansHolder: [InnerTaskRunnerProtocol]!
    
    public init(durationToComplete: Double) {
        self.durationToComplete = durationToComplete
        runnerReferansHolder = [InnerTaskRunnerProtocol]()
    }
    
    public convenience init() {
        self.init(durationToComplete: DEFAULT_DURATION_TO_COMPLETE)
    }
    
    open class func runInParallel(tasks: [Task]?, done: Done?) {
        TaskRunner(durationToComplete: DEFAULT_DURATION_TO_COMPLETE).runInParallel(tasks: tasks, done: done)
    }
    
    open func runInParallel(tasks: [Task]?, done: Done?) {
        let parallelTaskRunner = ParallelTaskRunner()
        runnerReferansHolder.append(parallelTaskRunner)
        
        parallelTaskRunner.set(durationToComplete: durationToComplete)
        parallelTaskRunner.set(tasks: tasks)
        parallelTaskRunner.set(allTasksDone: { [unowned self] error in
            done?(error)
            self.removeFromReferansHolder(itemReferans: parallelTaskRunner)
        })
        parallelTaskRunner.run()
    }
    
    private func removeFromReferansHolder(itemReferans: InnerTaskRunnerProtocol) {
        let indexInReferansHolder = runnerReferansHolder.index(where: { (item) -> Bool in
            return itemReferans === item
        })
        
        guard let indexToRemove = indexInReferansHolder else { return }
        runnerReferansHolder.remove(at: indexToRemove)
    }
    
    open class func runInSeries(tasks: [Task]?, done: Done?) {
        TaskRunner(durationToComplete: DEFAULT_DURATION_TO_COMPLETE).runInSeries(tasks: tasks, done: done)
    }
    
    open func runInSeries(tasks: [Task]?, done: Done?) {
        let seriesTaskRunner = SeriesTaskRunner()
        runnerReferansHolder.append(seriesTaskRunner)
        
        seriesTaskRunner.set(durationToComplete: durationToComplete)
        seriesTaskRunner.set(tasks: tasks)
        seriesTaskRunner.set(allTasksDone: { [unowned self] error in
            done?(error)
            self.removeFromReferansHolder(itemReferans: seriesTaskRunner)
        })
        seriesTaskRunner.run()
    }
}
