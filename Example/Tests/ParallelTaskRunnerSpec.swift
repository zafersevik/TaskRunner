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
            let runnerTimeoutLimitForTest = 1.0
            let testTimeout = runnerTimeoutLimitForTest + 0.5
            
            var isTask0Finished  = false
            var isTask0Called = false
            var isTask1Finished = false
            var task1Called = false
            var task2Finished = false
            var task2Called = false
            var taskWithErrorCalled = false
            
            let taskWithErrorError: Error = NSError(domain: "",
                                                    code: -1,
                                                    userInfo: [NSLocalizedDescriptionKey: "Task Error"])
            var taskExceedingTimeoutLimitCalled = false
            
            var isTask0FinishedValueWhenDoneCalled = false
            var isTask1FinishedValueWhenDoneCalled = false
            var task2FinishedValueWhenDoneCalled = false
            var allTasksDoneError:  Error?
            var allTasksDoneCalled = false
            
            let allTasksDone: Done = {
                error in
                isTask0FinishedValueWhenDoneCalled = isTask0Finished
                isTask1FinishedValueWhenDoneCalled = isTask1Finished
                task2FinishedValueWhenDoneCalled = task2Finished
                allTasksDoneCalled = true
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
                    isTask0Finished = true
                    done(nil)
                }
            }
            
            let task1: Task = {
                done in
                task1Called = true
                runConcurrent(delay: 0.2) {
                    isTask1Finished = true
                    done(nil)
                }
            }
            
            let task2: Task = {
                done in
                task2Called = true
                runConcurrent(delay: 0.3) {
                    task2Finished = true
                    done(nil)
                }
            }
            
            let taskWithError: Task = {
                done in
                taskWithErrorCalled = true
                runConcurrent(delay: 0.1) {
                    done(taskWithErrorError)
                }
            }
            
            let taskExceedingTimeoutLimit: Task = {
                done in
                taskExceedingTimeoutLimitCalled = true
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
                runner.set(durationToComplete: runnerTimeoutLimitForTest)
                runner.set(allTasksDone: allTasksDone)
            }
            
            context("when there is no task to run (tasks equal to nil)"){
                
                beforeEach() {
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should call all tasks' done") {
                    expect(allTasksDoneCalled).to(beTrue())
                    expect(allTasksDoneError).to(beNil())
                }
            }
            
            context("when tasks are empty") {
                
                beforeEach() {
                    runner.set(tasks: [Task]())
                    runner.run()
                    makeTestsWaitUntil(timeout: testTimeout)
                }
                
                it("should call all tasks' done") {
                    expect(allTasksDoneCalled).to(beTrue())
                    expect(allTasksDoneError).to(beNil())
                }
            }
            
            context("when there is one task") {
                
                context("when task is completed in timeout limit") {
                    
                    beforeEach() {
                        runner.set(tasks: [task0])
                        runner.run()
                        makeTestsWaitUntil(timeout: testTimeout)
                    }
                    
                    it("should run task") {
                        expect(isTask0Called).to(beTrue())
                    }
                    
                    it("should call all tasks' done") {
                        expect(allTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError).to(beNil())
                    }
                    
                    context("when timeout limit exceeds") {
                        
                        beforeEach() {
                            makeTestsWaitUntil(timeout: 0.5)
                        }
                        
                        it("should not call all tasks' done again with error") {
                            expect(allTasksDoneError).to(beNil())
                        }
                    }
                }
                
                context("when task takes time more than timeout limit") {
                    
                    beforeEach() {
                        runner.set(tasks: [taskExceedingTimeoutLimit])
                        runner.run()
                        makeTestsWaitUntil(timeout: testTimeout)
                    }
                    
                    it("should run task") {
                        expect(taskExceedingTimeoutLimitCalled).to(beTrue())
                    }
                    
                    it("should call all tasks done with error") {
                        expect(allTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError?.localizedDescription).to(equal("Task timed out"))
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
                        expect(task1Called).to(beTrue())
                    }
                    
                    it("should finish all tasks") {
                        expect(isTask0Finished).to(beTrue())
                        expect(isTask1Finished).to(beTrue())
                    }
                    
                    it("should call tasks' done callback after all tasks finished") {
                        expect(isTask0FinishedValueWhenDoneCalled).to(beTrue())
                        expect(isTask1FinishedValueWhenDoneCalled).to(beTrue())
                        // TODO: Can't find why this expectation is not working
                        //expect(task2FinishedValueWhenDoneCalled).to(beTrue())
                        expect(allTasksDoneCalled).to(beTrue())
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
                        expect(taskWithErrorCalled).to(beTrue())
                        expect(task1Called).to(beTrue())
                    }
                    
                    it("should call tasks' done callback with error") {
                        expect(allTasksDoneCalled).to(beTrue())
                        expect(allTasksDoneError).toNot(beNil())
                        expect(allTasksDoneError?.localizedDescription).to(equal(taskWithErrorError.localizedDescription))
                    }
                }
            }
        }
    }
}
