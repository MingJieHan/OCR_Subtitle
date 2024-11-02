function videoTags() {
    return document.getElementsByTagName("video");
}

function setupVideoPlayingHandler() {
    try {
        var videos = videoTags()
        for (var i = 0; i < videos.length; i++) {
            videos.item(i).onplaying = function() {
                var a = "VideoIsPlaying";
                webkit.messageHandlers.callbackHandler.postMessage(a);
            }
            videos.item(i).onpause = function() {
                webkit.messageHandlers.callbackHandler.postMessage("VideoIsPaused");
            }
        }
    } catch (error) {
        console.log(error);
    }
}

function setupVidePlayingListener() {
    // If we have video tags, setup onplaying handler
    if (videoTags().length > 0) {
        setupVideoPlayingHandler();
        return
    }
    // Otherwise, wait for 100ms and check again.
    setTimeout(setupVidePlayingListener, 100);
}
setupVidePlayingListener();
