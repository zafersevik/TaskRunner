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

public class TaskRunner {
    
    private static let durationToComplete = 10.0
    
    public class func runInParallel(tasks: [Task]?, done: Done?) {
        runInParallel(durationToComplete: durationToComplete, tasks: tasks, done: done)
    }
    
    public class func runInParallel(durationToComplete: Double, tasks: [Task]?, done: Done?) {
        let parallelTaskRunner = ParallelTaskRunner()
        parallelTaskRunner.set(durationToComplete: durationToComplete)
        parallelTaskRunner.set(tasks: tasks)
        parallelTaskRunner.set(allTasksDone: done)
        parallelTaskRunner.run()
    }
    
    public class func runInSeries(tasks: [Task]?, done: Done?) {
        
    }
    
    public class func runInSeries(durationToComplete: Double, tasks: [Task]?, done: Done?) {
    
    }
}
