//
//  PiPPluginProxy.m
//  PiPPlugin
//
//  UniApp iOS 原生插件 - 画中画（PiP）功能 - 插件代理类
//  用于实现 AppDelegate 相关方法，支持后台上传
//

#import "PiPPluginProxy.h"

// 全局字典，用于存储 completionHandler（key 为 identifier）
static NSMutableDictionary<NSString *, void (^)(void)> *sBackgroundCompletionHandlers = nil;
static NSLock *sBackgroundCompletionHandlersLock = nil;

@implementation PiPPluginProxy

+ (void)initialize {
    if (self == [PiPPluginProxy class]) {
        sBackgroundCompletionHandlers = [NSMutableDictionary dictionary];
        sBackgroundCompletionHandlersLock = [[NSLock alloc] init];
    }
}

- (void)onCreateUniPlugin {
    NSLog(@"PiPPluginProxy: onCreateUniPlugin called");
}

/**
 * 处理后台 URL 会话事件（支持完全的后台上传）
 * 
 * 此方法由 UniApp 框架通过 UniPluginProtocol 自动调用
 * 当 app 被系统重新启动（因为后台任务完成）时，系统会调用此方法
 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    NSLog(@"═══════════════════════════════════════════════════════════");
    NSLog(@"PiPPluginProxy: 📬 handleEventsForBackgroundURLSession called");
    NSLog(@"PiPPluginProxy: This means iOS is telling us a background task completed");
    NSLog(@"PiPPluginProxy: Identifier: %@", identifier);
    
    // 检查是否是 PiP 插件的后台会话
    if ([identifier hasPrefix:@"com.pipplugin.upload."]) {
        NSLog(@"PiPPluginProxy: ✅ This is a PiP plugin background session");
        
        // 存储 completionHandler（因为 block 不能直接放在通知的 userInfo 中）
        if (completionHandler) {
            NSLog(@"PiPPluginProxy: 💾 Storing completion handler");
            [sBackgroundCompletionHandlersLock lock];
            sBackgroundCompletionHandlers[identifier] = completionHandler;
            [sBackgroundCompletionHandlersLock unlock];
            NSLog(@"PiPPluginProxy: ✅ Completion handler stored");
        }
        
        // 通过通知机制，让 PictureInPictureModule 监听并处理
        NSLog(@"PiPPluginProxy: 📢 Posting notification to PictureInPictureModule...");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PiPPluginHandleBackgroundURLSession"
                                                            object:nil
                                                          userInfo:@{@"identifier": identifier}];
        
        NSLog(@"PiPPluginProxy: ✅ Notification posted");
    } else {
        NSLog(@"PiPPluginProxy: ⚠️ Not a PiP plugin session, calling completion handler directly");
        // 其他后台会话的处理
        if (completionHandler) {
            completionHandler();
        }
    }
    NSLog(@"═══════════════════════════════════════════════════════════");
}

/**
 * 获取并移除 completionHandler（由 PictureInPictureModule 调用）
 */
+ (void (^)(void))getAndRemoveCompletionHandlerForIdentifier:(NSString *)identifier {
    if (!identifier) {
        return nil;
    }
    
    [sBackgroundCompletionHandlersLock lock];
    void (^completionHandler)(void) = sBackgroundCompletionHandlers[identifier];
    if (completionHandler) {
        [sBackgroundCompletionHandlers removeObjectForKey:identifier];
    }
    [sBackgroundCompletionHandlersLock unlock];
    
    return completionHandler;
}

@end

