//
//  ParallelTaskRunnerSpec.swift
//  TaskRunnerTests
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

class ParallelTaskRunnerSpec: QuickSpec {
    override func spec() {
        
        describe("ParallelTaskRunnerSpec") {
            
            var runner: ParallelTaskRunner!
            let runnerDeadlineForTest = 1.0
            let testTimeout = runnerDeadlineForTest + 0.5
            
            var isTask0Completed  = false
            var isTask0Called = false
            var isTask1Completed = false
            var isTask1Called = false
            var isTask2Completed = false
            var isTask2Called = false
            var isTaskWithErrorCalled = false
            
            let taskError: Error = NSError(domain: "",
                                           code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "Task Error"])
            var isTaskExceedingDeadlineCalled = false
            
            var isTask0CompletedValueWhenDoneCalled = false
            var isTask1CompletedValueWhenDoneCalled = false
            var isTask2CompletedValueWhenDoneCalled = false
            var allTasksDoneError:  Error?
            var isAllTasksDoneCalled = false
            
            let allTasksDone: Done = {
                error in
                isTask0CompletedValueWhenDoneCalled = isTask0Completed
                isTask1CompletedValueWhenDoneCalled = isTask1Completed
                isTask2CompletedValueWhenDoneCalled = isTask2Completed
                isAllTasksDoneCalled = true
                allTasksDoneError = error
            }
            
            func runConcurrent(delay: Double, callback: @escaping (() -> Void)) {
                let deadline = DispatchTime.now() + delay
                DispatchQueue
                    .global(qos: DispatchQoS.QoSClass.background)
                    .asyncAfter(deadline: deadline, execute: callback)
            }
            
            let task0: Task = {
                done in
                isTask0Called = true
                runConcurrent(delay: 0.1) {
                    isTask0Completed = true
                    done(nil)
                }
            }
            
            let task1: Task = {
                done in
                isTask1Called = true
                runConcurrent(delay: 0.2) {
                    isTask1Completed = true
                    done(nil)
                }
            }
            
            let task2: Task = {
                done in
                isTask2Called = true
                runConcurrent(delay: 0.3) {
                    isTask2Completed = true
                    done(nil)
                }
            }
            
            let taskWithError: Task = {
                done in
                isTaskWithErrorCalled = true
                runConcurrent(delay: 0.1) {
                    done(taskError)
                }
            }
            
            let taskExceedingDeadline: Task = {
                done in
                isTaskExceedingDeadlineCalled = true
                runConcurrent(delay: 3.0) {
                    done(nil)
                }
            }
            
            func makeTestsWaitUntil(timeout: TimeInterval) {
                let timeoutDate = Date(timeIntervalSinceNow: timeout)
                RunLoop.main.run(until: timeoutDate)
            }
            
            beforeEach() {
                runner = ParallelTaskRunner()
                runner.set(durationToComplete: runnerDeadlineForTest)
                runner.set(allTasksDone: allTasksDone)
            }
            
            context("when there is no task to run (tasks equal to nil)"){
                
                beforeEach() {
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should immediately call all tasks' done callback") {
                    expect(isAllTasksDoneCalled).to(beTrue())
                    expect(allTasksDoneError).to(beNil())
                }
            }
            
            context("when tasks are empty") {
                
                beforeEach() {
                    runner.set(tasks: [Task]())
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should immediately call all tasks' done callback") {
                    expect(isAllTasksDoneCalled).to(beTrue())
                    expect(allTasksDoneError).to(beNil())
                }
            }
            
            context("when there is only one task") {
                
                context("when task is completed before deadline`") {
                    
                    beforeEach() {
                        runner.set(tasks: [task0])
                        runner.run()
                        makeTestsWaitUntil(timeout: testTimeout)
                    }
                    
                    it("should run task") {
                        expect(isTask0Called).to(beTrue())
                    }
                    
                    it("should call all tasks' done callback") {
                        expect(isAllTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError).to(beNil())
                    }
                    
                    context("when deadline exceeded") {
                        
                        let extraTime = 0.5
                        
                        beforeEach() {
                            makeTestsWaitUntil(timeout: extraTime)
                        }
                        
                        it("should not call all tasks' done again with a timeout error") {
                            expect(allTasksDoneError).to(beNil())
                        }
                    }
                }
                
                context("when task exceeds deadline") {
                    
                    beforeEach() {
                        runner.set(tasks: [taskExceedingDeadline])
                        runner.run()
                        makeTestsWaitUntil(timeout: testTimeout)
                    }
                    
                    it("should run task") {
                        expect(isTaskExceedingDeadlineCalled).to(beTrue())
                    }
                    
                    it("should call all tasks done callback with error") {
                        expect(isAllTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError?.localizedDescription).to(equal("Task isn't completed in expected time interval"))
                    }
                }
            }
            
            context("when there are more than one task") {
                
                context("when all tasks are successful") {
                    
                    beforeEach() {
                        runner.set(tasks: [task0, task1])
                        runner.run()
                        makeTestsWaitUntil(timeout: testTimeout)
                    }
                    
                    it("should run tasks") {
                        expect(isTask0Called).to(beTrue())
                        expect(isTask1Called).to(beTrue())
                    }
                    
                    it("should finish all tasks") {
                        expect(isTask0Completed).to(beTrue())
                        expect(isTask1Completed).to(beTrue())
                    }
                    
                    it("should call tasks' done callback after all tasks finished") {
                        expect(isTask0CompletedValueWhenDoneCalled).to(beTrue())
                        expect(isTask1CompletedValueWhenDoneCalled).to(beTrue())
                        expect(isAllTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError).to(beNil())
                    }
                }
                
                context("when there is a task with error") {
                    
                    beforeEach() {
                        runner.set(tasks: [task0, taskWithError, task1])
                        runner.run()
                        makeTestsWaitUntil(timeout: testTimeout)
                    }
                    
                    it("should run all tasks") {
                        expect(isTask0Called).to(beTrue())
                        expect(isTaskWithErrorCalled).to(beTrue())
                        expect(isTask1Called).to(beTrue())
                    }
                    
                    it("should call tasks' done callback with error") {
                        expect(isAllTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError).toNot(beNil())
                        expect(allTasksDoneError?.localizedDescription).to(equal(taskError.localizedDescription))
                    }
                }
            }
        }
    }
}
