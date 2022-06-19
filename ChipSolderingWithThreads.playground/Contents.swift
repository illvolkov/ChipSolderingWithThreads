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
var chips = [Chip]()
var isGeneratedStoped = false

//MARK: - GeneratedThread

class GeneratedThread: Thread {
        
    override func main() {
                
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                
                time -= 2
                
                if time < 0 {
                    timer.invalidate()
                    print("----------------Generation finished\n")
                    print("GeneratedThread stop time: \(Date())")
                    if !chips.isEmpty {
                        print("Remaining chips in storage:\n")
                        for chip in chips {
                            print("Chip size: \(chip.chipType)\n")
                        }
                    }
                    isGeneratedStoped = true
                    GeneratedThread.exit()
                } else {
                    semaphoreAppend()
                }
            }
        }
    }
}

//MARK: - WorkerThread

class WorkerThread: Thread {
            
    override func main() {
        name = "WorkerThread"
                                
        while chips.isEmpty {
            
            Thread.sleep(forTimeInterval: 0.1)
            
            if !isGeneratedStoped {
                while !chips.isEmpty {
                    semaphorePop()
                    print("The chip is soldered")
                    print("Soldering end time: \(Date())\n")
                }
            } else {
                print("----------------Worker finished")
                print("WorkerThread stop time: \(Date())")
                print("GeneratedThread and WorkerThread completed their work")
                print("Completed time: \(Date())")
                WorkerThread.exit()
            }
        }
    }
}

//MARK: - Stack

let semaphore = DispatchSemaphore(value: 1)

func semaphoreAppend() {
            
    semaphore.wait()
    chips.append(Chip.make())
    print("GeneratedThread - Added size chip: \(chips.last?.chipType ?? Chip.ChipType.big)")
    print("Adding time: \(Date())")
    semaphore.signal()
}

func semaphorePop() {
    
    semaphore.wait()
    let index = chips.count - 1
    print("\(Thread.current.name ?? "") - Taken chip size: \(chips.last?.chipType ?? Chip.ChipType.big)")
    let poppedChip = chips.remove(at: index)
    print("Taking time: \(Date())")
    semaphore.signal()
    poppedChip.sodering()
}

let generate = GeneratedThread()
let worker = WorkerThread()

generate.start()
worker.start()
