
enum DownloadState {
    
    case inProgress
    case complete(data: NSData?, response: NSURLResponse?, error: NSError?)
}

class DownloadManager {
    
    static let sharedInstace = DownloadManager()
    
    typealias Listener = (DownloadState) -> Void
    typealias OperationData = (operation: NSURLSessionDataTask, state: DownloadState, listeners: [Listener])
    private var operations = [NSURL: OperationData]()
    
    func download(url: NSURL, listener: (DownloadState) -> Void) {
        if let existing = self.operations[url] {
            self.operations[url] = (existing.operation, existing.state, existing.listeners + [listener])
            self.notifyListeners(existing.listeners, state: existing.state)
            
        } else {
            NSLog("Started Downloading: \(url)")
            let operation = NSURLSession.sharedSession().dataTaskWithURL(url) { [unowned self] (data, response, error) in
                dispatch_async(dispatch_get_main_queue(), {
                    guard let operationData = self.operations[url] else { return }
                    NSLog("Finished Downloading: \(url)")
                    let newState: DownloadState = .complete(data: data, response: response, error: error)
                    self.operations[url] = (operationData.operation, newState, operationData.listeners)
                    self.notifyListeners(operationData.listeners, state: newState)
                })
            }
            self.operations[url] = (operation, .inProgress, [listener])
            self.notifyListeners([listener], state: .inProgress)
            operation.resume()
        }
    }
    
    private func notifyListeners(listeners: [Listener], state: DownloadState) {
        listeners.forEach { $0(state) }
    }
}

// USAGE:
/*
DownloadManager.sharedInstance.download(url: "http://foo.com/file.png”) { state in
    switch state {
    case .inProgress:
    //start loading spinner
    case .complete(let data, let response, let error):
    //stop loading spinner
    guard let data = data, let image = UIImage(data: data) else { return }
    
    //use image or video
    }
}
 */


