# LHShareManager


## Usage:

#step 1
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[LHShareManager sharedInstance] configShareInfo];

}

#step 2
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    [[LHShareManager sharedInstance] handleURL:url];

}

#step 3
info.plist ==> URL types
include :
QQ ==> URL Schemes :tencent+openID
                    QQ+openID transform
weixin ==> URL Schemes : wx+openID
weibo ==> URL Schemes : wb+openID

#step 4
LHShareManager.m ==> configShareInfo 
fill your openID in Weibo、WX、QQ api register

#step 5
use share methods