//
//  SeriesTaskRunnerSpec.swift
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
import Quick
import Nimble
@testable import TaskRunner

class SeriesTaskRunnerSpec: QuickSpec {
    override func spec() {
        
        describe("Series Task Runner Spec") {
            
            var runner: SeriesTaskRunner!
            let runnerDeadlineForTest = 1.0
            let testTimeout = runnerDeadlineForTest + 0.5
            
            let initialValue = 2
            var result = initialValue
            
            let taskError: Error = NSError(domain: "",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Task Error"])
            
            var errorOfAllTasksDoneCallback: Error?
            
            func runConcurrent(delay: Double, callback: @escaping (() -> Void)) {
                let deadline = DispatchTime.now() + delay
                DispatchQueue
                    .global(qos: DispatchQoS.QoSClass.background)
                    .asyncAfter(deadline: deadline, execute: callback)
            }
            
            func makeTestsWaitUntil(timeout: TimeInterval) {
                let timeoutDate = Date(timeIntervalSinceNow: timeout)
                RunLoop.main.run(until: timeoutDate)
            }
            
            let times3: Task = {
                done in
                runConcurrent(delay: 0.2) {
                    result = result * 3
                    done(nil)
                }
            }
            
            let minus1: Task = {
                done in
                runConcurrent(delay: 0.2) {
                    result = result - 1
                    done(nil)
                }
            }
            
            let erroneousOperation: Task = {
                done in
                runConcurrent(delay: 0.1) {
                    done(taskError)
                }
            }
            
            let deadlineExceedingOperation: Task = {
                done in
                runConcurrent(delay: runnerDeadlineForTest + 0.1) {
                    done(nil)
                }
            }
            
            let plus5AfterAllOperations: Done = {
                error in
                result = result + 5
                errorOfAllTasksDoneCallback = error
            }
            
            beforeEach {
                result = initialValue
                runner = SeriesTaskRunner()
                runner.set(durationToComplete: runnerDeadlineForTest)
                runner.set(allTasksDone: plus5AfterAllOperations)
            }
            
            context("when there is no operation to run (tasks equal to nil)"){
                
                beforeEach() {
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should immediately call all tasks' done callback") {
                    expect(result) == initialValue + 5
                }
            }
            
            context("when there is only one operation") {
                
                beforeEach {
                    runner.set(tasks: [times3])
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should first multiply by 3 and add 5 to the result") {
                    expect(result) == (initialValue * 3) + 5
                }
            }
            
            context("when there are more than one operation") {
                
                beforeEach {
                    runner.set(tasks: [minus1, times3])
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should apply operations in order") {
                    expect(result) == ((initialValue - 1) * 3) + 5
                }
                
                context("when deadline exceeded") {
                    
                    let extraTime = 2.0
                    
                    beforeEach() {
                        makeTestsWaitUntil(timeout: extraTime)
                    }
                    
                    it("should not call all tasks' done again with a timeout error") {
                        expect(errorOfAllTasksDoneCallback).to(beNil())
                    }
                }
            }
            
            context("when there is a failed operation") {
                
                beforeEach {
                    runner.set(tasks: [minus1, erroneousOperation, times3])
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should not apply operations after failed operation") {
                    expect(result) == (initialValue - 1) + 5
                }
                
                it("should send error to the all tasks done callback") {
                    expect(errorOfAllTasksDoneCallback) === taskError
                }
            }
            
            context("when there is an operation exceeding runner deadline") {
                
                beforeEach {
                    runner.set(tasks: [minus1, deadlineExceedingOperation, times3])
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should not apply operations after exceeding operation") {
                    expect(result) == (initialValue - 1) + 5
                }
                
                it("should send error to the all tasks done callback") {
                    expect(errorOfAllTasksDoneCallback) === TIMEOUT_ERROR
                }
            }
        }
    }
}
