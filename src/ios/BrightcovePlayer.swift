import BrightcovePlayerSDK

@objc(BrightcovePlayer) class BrightcovePlayer : CDVPlugin {

    //MARK: Properties
    fileprivate var playbackService: BCOVPlaybackService?
    fileprivate var playerView: PlayerViewController?
    fileprivate var storyboard: UIStoryboard?
    fileprivate var brightcovePolicyKey: String?
    fileprivate var brightcoveAccountId: String?


    //MARK: Cordova Methods

    @objc(play:)
    func play(_ command: CDVInvokedUrlCommand) {
        let videoId = command.arguments[0] as? String ?? ""
        playById(videoId, callbackId: command.callbackId )
    }

    @objc(getPoster:)
    func getPoster(_ command: CDVInvokedUrlCommand){
        let videoId = command.arguments[0] as? String ?? ""

        if self.brightcovePolicyKey == nil || self.brightcovePolicyKey?.isEmpty == true {
            commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Please set up Brightcove IDs"), callbackId:command.callbackId)
        } else {
            if videoId.isEmpty == true {
                commandDelegate!.send(CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "There is no video ID"), callbackId:command.callbackId)
            } else {
                self.initPlayService()

                playbackService?.findVideo(withVideoID: videoId, parameters: nil) { (video: BCOVVideo?, jsonResponse: [AnyHashable: Any]?, error: Error?) -> Void in

                    if let v = video {
                        let posterUrl = (v.properties["poster"] as! String)
                        // print("Poster video url: \(posterUrl)")
                        let result    = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: posterUrl)
                        self.commandDelegate!.send(result, callbackId:command.callbackId)
                    } else {
                        print("ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")")
                        self.commandDelegate!.send(
                            CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "ViewController Debug - Error retrieving video: \(error?.localizedDescription ?? "unknown error")"),
                            callbackId: command.callbackId
                        )
                    }
                }
            }
        }
    }

    @objc(initAccount:)
    func initAccount(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult? = nil
        self.brightcovePolicyKey = command.arguments[0] as? String ?? ""
        self.brightcoveAccountId = command.arguments[1] as? String ?? ""

        if self.brightcovePolicyKey?.isEmpty == false && self.brightcoveAccountId?.isEmpty == false {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Brightcove player initialised")
        } else {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Could not initialise Brightcove player")
        }

        commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    //MARK: Private Methods

    fileprivate func initPlayService(){
        if self.playbackService == nil {
            self.playbackService = BCOVPlaybackService(accountId: self.brightcoveAccountId, policyKey: self.brightcovePolicyKey)
        }
    }

    fileprivate func initPlayerView(_ videoId: String) {
        if self.playerView == nil {
            self.storyboard = UIStoryboard(name: "BrightcovePlayer", bundle: nil)
            self.playerView = self.storyboard?.instantiateInitialViewController() as? PlayerViewController
            playerView?.setAccountIds(brightcovePolicyKey!, accountId: brightcoveAccountId!)
            playerView?.setVideoId(videoId)
        } else {
            playerView?.setVideoId(videoId)
            playerView?.playFromExistingView()
        }
    }

    fileprivate func playById(_ videoId: String, callbackId: String) {
        var pluginResult: CDVPluginResult?

        if self.brightcovePolicyKey == nil || self.brightcovePolicyKey?.isEmpty == true {
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Please set up Brightcove IDs")
        } else {
            if videoId.isEmpty == true {
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "There is no video ID")
            } else {
                initPlayerView(videoId)

                self.viewController.present(self.playerView!, animated: false)
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Playing with video: \(videoId)")
            }
        }

        commandDelegate.send(pluginResult, callbackId: callbackId)
    }

}
