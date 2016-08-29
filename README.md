# DownloadManager

A simple downlaod manager to keep track and handle downloads in various places of an app.

USAGE:

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
