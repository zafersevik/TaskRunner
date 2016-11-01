# TaskRunner

[![CI Status](http://img.shields.io/travis/Zafer Sevik/TaskRunner.svg?style=flat)](https://travis-ci.org/Zafer Sevik/TaskRunner)
[![Version](https://img.shields.io/cocoapods/v/TaskRunner.svg?style=flat)](http://cocoapods.org/pods/TaskRunner)
[![Language](https://img.shields.io/badge/swift-3.0-brightgreen.svg)](http://cocoapods.org/pods/TaskRunner)
[![Platform](https://img.shields.io/cocoapods/p/TaskRunner.svg?style=flat)](http://cocoapods.org/pods/TaskRunner)
[![License](https://img.shields.io/cocoapods/l/TaskRunner.svg?style=flat)](http://cocoapods.org/pods/TaskRunner)

TaskRunner is a Swift utility module which provides functions to run closures easily in series and parallel.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Creating closure list
```Swift
let closure0: Task = {
    done in
    // run a sync/async method or a job
        if error != nil {
            done(error)
            return
        }
        // done(nil)
}

let closure1: Task = {
    done in
    // run a sync/async method or a job
        if error != nil {
            done(error)
            return
        }
        // done(nil)
}

let closure2: Task = {
    done in
    // run a sync/async method or a job
        if error != nil {
            done(error)
            return
        }
        // done(nil)
}

let tasks = [closure0, closure1, closure2]
```

### Running in series
```Swift
TaskRunner.runInSeries(tasks: tasks, done: {
    error in
    if error != nil {
        // handle error
        return
    }
    // handle success
})
```
`closure1` and `closure2` start if and only if `closure0` completes it's job without an error.

### Running in parallel
```Swift
TaskRunner.runInParallel(tasks: tasks, done: {
    error in
    if error != nil {
        // handle error
        return
    }
    // handle success
})
```
`closure0`, `closure1` and `closure2` start running at the same time.

## Installation

TaskRunner is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TaskRunner"
```

## Author

Zafer Sevik, zafersevik@gmail.com

## License

TaskRunner is available under the MIT license. See the LICENSE file for more info.
