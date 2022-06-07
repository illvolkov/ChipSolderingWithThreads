import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
    }
}

var time = 20

//MARK: - GeneratedThread

class GeneratedThread: Thread {
            
    override func main() {
        name = "GeneratedThread"
        RunLoop.current.add(timer, forMode: .default)
        RunLoop.current.run()
    }
    
    let timer = Timer(timeInterval: 2, repeats: true) { timer in
            
        time -= 2
        
        if time < 0 {
            timer.invalidate()
            Thread.current.cancel()
            print("----------------Generation finished\n")
            print("Remaining chips in storage: \(chips)\n")
            print("----------------GeneratedThread is cancelled? \(GeneratedThread.current.isCancelled)\n")
        } else {
            semaphoreAppend()
        }
    }
}

//MARK: - WorkerThread

class WorkerThread: Thread {
    
    var chip = Chip(chipType: .big)
        
    override func main() {
        name = "WorkerThread"
                                
        while chips.isEmpty {
            
            Thread.sleep(forTimeInterval: 0.1)
            
            while !chips.isEmpty {
                semaphorePop()
                chip.sodering()
                print("The chip is soldered\n")
            }
        }
    }
}

//MARK: - Stack

var chips = [Chip]()

let semaphore = DispatchSemaphore(value: 1)

func semaphoreAppend() {
            
    semaphore.wait()
    chips.append(Chip.make())
    print("\(Thread.current.name ?? "") - Chip added: \(chips.last ?? Chip(chipType: .big))")
    semaphore.signal()
}

func semaphorePop() -> Chip {
    
    semaphore.wait()
    let index = chips.count - 1
    print("\(Thread.current.name ?? "") - Chip taken: \(chips.last ?? Chip(chipType: .big))")
    let poppedChip = chips.remove(at: index)
    semaphore.signal()
    return poppedChip
}

let generate = GeneratedThread()
let worker = WorkerThread()

generate.start()
worker.start()
