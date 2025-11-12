//
//  PictureInPictureModule.h
//  PiPPlugin
//
//  UniApp iOS 原生插件 - 画中画（PiP）功能
//

#import <Foundation/Foundation.h>
#import "DCUniModule.h"  // UniApp 模块基类
#import "DCUniDefine.h"  // UniApp 定义

NS_ASSUME_NONNULL_BEGIN

/**
 * PictureInPictureModule
 * UniApp iOS 原生插件，提供画中画（Picture-in-Picture）功能
 *
 * 功能：
 * - 显示/隐藏画中画窗口
 * - 更新文本内容（第一行、第二行、提示文本）
 * - 显示/隐藏录音状态
 * - 显示/隐藏加载状态
 * - 文件上传功能（单文件上传）
 */
@interface PictureInPictureModule : DCUniModule

// 检查是否支持画中画
- (void)isSupported:(UniModuleKeepAliveCallback)callback;

// 显示画中画（支持回调返回执行状态和日志，callback可选）
- (void)showPictureInPicture:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;

// 隐藏画中画
- (void)hidePictureInPicture:(NSDictionary *)options;

// 更新第一行文本
- (void)updateFirstText:(NSDictionary *)options;

// 更新第二行文本
- (void)updateSecondText:(NSDictionary *)options;

// 更新提示文本
- (void)updateTipText:(NSDictionary *)options;

// 显示录音状态
- (void)showRecording:(NSDictionary *)options;

// 显示内容状态
- (void)showContent:(NSDictionary *)options;

// 显示加载状态
- (void)showLoading:(NSDictionary *)options;

// 隐藏加载状态
- (void)hiddenLoading:(NSDictionary *)options;

/**
 * 上传文件（单文件上传）
 *
 * @param options 上传参数配置字典，包含以下字段（参考 yijianfanyi.vue）：
 *   - url (NSString, 必填): 上传接口地址，例如: "http://14.103.175.207:5000/upload"
 *   - filePath (NSString, 必填): 文件路径，例如: "/path/to/file.mp3"
 *   - name (NSString, 可选): 文件字段名，默认为 "file"，例如: "audio"
 *   - formData (NSDictionary, 可选): 额外的表单数据，例如: @{@"language": @"AUTOandPTP"}
 *   - header (NSDictionary, 可选): 自定义请求头，例如: @{@"Content-Type": @"multipart/form-data"}
 *   - method (NSString, 可选): HTTP 请求方法，默认为 "POST"
 *   - timeout (NSNumber, 可选): 超时时间（秒），默认为 60
 *
 * @note 使用默认会话配置（defaultSessionConfiguration）+ beginBackgroundTask 方式（参考 f3transpro），
 *   app 进入后台时使用 beginBackgroundTask 延长执行时间（约30秒到几分钟）
 *
 * @param callback 回调函数（UniModuleKeepAliveCallback），返回上传结果
 *
 *   回调函数签名：void (^callback)(NSDictionary *result, BOOL keepAlive)
 *
 *   参数说明：
 *   - result (NSDictionary): 上传结果字典，包含以下字段：
 *     - success (BOOL): 是否成功
 *     - statusCode (NSNumber): HTTP 状态码
 *     - data (NSString): 服务器返回的数据（格式：识别文本$^$语言代码，例如: "laurens & pop art$^$en/n"）
 *     - header (NSDictionary): 响应头字典
 *     - errMsg (NSString): 错误信息，成功时为 "uploadFile:ok"
 *
 *   - keepAlive (BOOL): 是否保持回调函数存活
 *     - YES: 保持回调函数 ID 存活，可以多次调用（适用于需要多次回调的场景，如进度更新）
 *     - NO: 回调函数调用后立即移除，节省内存（适用于一次性回调，如上传完成）
 *
 *   注意：对于上传文件这种一次性操作，应该传入 NO，表示回调只调用一次
 *
 * @note Content-Type 会自动设置为 multipart/form-data（包含 boundary），
 *   即使 header 中设置了 Content-Type 也会被覆盖
 *
 * @note 响应数据格式：服务器返回的数据格式为 "识别文本$^$语言代码"，
 *   可以使用 componentsSeparatedByString:@"$^$" 来分割
 *
 * @example 使用示例（参考 yijianfanyi.vue）：
 *   [module uploadFile:@{
 *       @"url": @"http://14.103.175.207:5000/upload",  // 后台接口地址
 *       @"filePath": @"/path/to/file.mp3",              // 录音文件路径
 *       @"name": @"audio",                              // 文件字段名称
 *       @"formData": @{@"language": @"AUTOandPTP"},     // 表单数据
 *       @"header": @{@"Content-Type": @"multipart/form-data"}
 *   } callback:^(NSDictionary *result, BOOL keepAlive) {
 *       // result: 上传结果字典
 *       // keepAlive: 是否保持回调（上传完成后应传入 NO）
 *
 *       if (result[@"success"]) {
 *           NSString *data = result[@"data"];
 *           NSArray *parts = [data componentsSeparatedByString:@"$^$"];
 *           NSString *text = parts[0];        // 识别文本
 *           NSString *lang = parts[1];       // 语言代码
 *           NSLog(@"识别结果: %@, 语言: %@", text, lang);
 *       }
 *
 *       // 注意：上传完成后，keepAlive 参数应传入 NO，表示回调只调用一次
 *       // 如果需要进度回调（多次调用），keepAlive 应传入 YES
 *   }];
 */
- (void)uploadFile:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback;

@end

NS_ASSUME_NONNULL_END
