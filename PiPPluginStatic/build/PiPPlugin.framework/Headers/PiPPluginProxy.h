//
//  PiPPluginProxy.h
//  PiPPlugin
//
//  UniApp iOS 原生插件 - 画中画（PiP）功能 - 插件代理类
//  用于实现 AppDelegate 相关方法，支持后台上传
//

#import <Foundation/Foundation.h>
#import "UniPluginProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface PiPPluginProxy : NSObject <UniPluginProtocol>

/**
 * 获取并移除 completionHandler（由 PictureInPictureModule 调用）
 * 
 * @param identifier 后台会话标识符
 * @return completionHandler，如果不存在则返回 nil
 */
+ (void (^_Nullable)(void))getAndRemoveCompletionHandlerForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END

