//
//  PictureInPictureModule.m
//  PiPPlugin
//
//  UniApp iOS 原生插件 - 画中画（PiP）功能
//

#import "PictureInPictureModule.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVPictureInPictureController.h>
#import <UIKit/UIKit.h>
#import "UniPluginProtocol.h"
#import "PiPPluginProxy.h"

// 自定义浮窗视图
@interface UniAppCustomFloatingView : UIView
@property (nonatomic, strong) UILabel *firstLabel;
@property (nonatomic, strong) UILabel *secondLabel;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;

// 状态跟踪
@property (nonatomic, assign) BOOL isRecordingState;
@property (nonatomic, assign) BOOL isContentState;
@property (nonatomic, assign) BOOL isLoadingState;
@property (nonatomic, strong) NSString *customTipText;
@end

@implementation UniAppCustomFloatingView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCustomView];
    }
    return self;
}

- (void)setupCustomView {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.backgroundColor = [UIColor whiteColor].CGColor; // 确保 layer 背景也是白色
    
    // 背景容器
    self.bgView = [[UIView alloc] init];
    // bgView 不设置背景色，使用默认（透明）
    [self addSubview:self.bgView];
    self.bgView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.bgView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:10],
        [self.bgView.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:10],
        [self.bgView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-10],
        [self.bgView.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-10],
        [self.bgView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.bgView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
    
    // 第一行文本
    self.firstLabel = [[UILabel alloc] init];
    // 不设置背景色，使用默认（透明）
    self.firstLabel.textColor = [UIColor colorWithRed:0x39/255.0 green:0x38/255.0 blue:0x36/255.0 alpha:0.7];
    self.firstLabel.font = [UIFont systemFontOfSize:14];
    self.firstLabel.numberOfLines = 0;
    [self.bgView addSubview:self.firstLabel];
    self.firstLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.firstLabel.leftAnchor constraintEqualToAnchor:self.bgView.leftAnchor],
        [self.firstLabel.topAnchor constraintEqualToAnchor:self.bgView.topAnchor],
        [self.firstLabel.rightAnchor constraintEqualToAnchor:self.bgView.rightAnchor]
    ]];
    
    // 第二行文本
    self.secondLabel = [[UILabel alloc] init];
    // 不设置背景色，使用默认（透明）
    self.secondLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    self.secondLabel.font = [UIFont systemFontOfSize:14];
    self.secondLabel.numberOfLines = 0;
    [self.bgView addSubview:self.secondLabel];
    self.secondLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.secondLabel.topAnchor constraintEqualToAnchor:self.firstLabel.bottomAnchor constant:5],
        [self.secondLabel.leftAnchor constraintEqualToAnchor:self.bgView.leftAnchor],
        [self.secondLabel.rightAnchor constraintEqualToAnchor:self.bgView.rightAnchor],
        [self.secondLabel.bottomAnchor constraintEqualToAnchor:self.bgView.bottomAnchor]
    ]];
    
    // 提示文本
    self.tipLabel = [[UILabel alloc] init];
    // 不设置背景色，使用默认（透明）
    self.tipLabel.text = @"按住说话";
    self.tipLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
    self.tipLabel.font = [UIFont systemFontOfSize:16]; // 减小字体以适应小窗口
    self.tipLabel.textAlignment = NSTextAlignmentCenter; // 确保居中
    self.tipLabel.numberOfLines = 0; // 支持多行文本
    self.tipLabel.lineBreakMode = NSLineBreakByWordWrapping; // 按词换行
    [self addSubview:self.tipLabel];
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tipLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:10],
        [self.tipLabel.topAnchor constraintGreaterThanOrEqualToAnchor:self.topAnchor constant:10],
        [self.tipLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-10],
        [self.tipLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.bottomAnchor constant:-10],
        [self.tipLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.tipLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
    ]];
    
    // 默认显示 tipLabel，隐藏 bgView（和 f3transpro 一样）
    self.bgView.hidden = YES;
    self.tipLabel.hidden = NO; // 确保 tipLabel 可见
}

- (void)updateFirstText:(NSString *)text {
    self.firstLabel.text = text ?: @"";

    // 更新文本时，重置状态并显示内容视图
    if (text && text.length > 0) {
        self.isRecordingState = NO;
        self.isContentState = NO;  // 不使用内容状态，使用直接的文本显示
        self.isLoadingState = NO;
        self.bgView.hidden = NO;   // 显示内容视图
        self.tipLabel.hidden = YES; // 隐藏提示文本
    } else {
        // 如果文本为空，检查是否需要隐藏内容视图
        if (!self.secondLabel.text || [self.secondLabel.text isEqualToString:@""]) {
            self.bgView.hidden = YES;
            self.tipLabel.hidden = NO;
        }
    }

    // 确保视图刷新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)updateSecondText:(NSString *)text {
    self.secondLabel.text = text ?: @"";

    // 更新文本时，重置状态并显示内容视图
    if (text && text.length > 0) {
        self.isRecordingState = NO;
        self.isContentState = NO;  // 不使用内容状态，使用直接的文本显示
        self.isLoadingState = NO;
        self.bgView.hidden = NO;   // 显示内容视图
        self.tipLabel.hidden = YES; // 隐藏提示文本
    } else {
        // 如果文本为空，检查是否需要隐藏内容视图
        if (!self.firstLabel.text || [self.firstLabel.text isEqualToString:@""]) {
            self.bgView.hidden = YES;
            self.tipLabel.hidden = NO;
        }
    }

    // 确保视图刷新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)updateTipText:(NSString *)text {
    // 保存自定义提示文本
    if (text && ![text isEqualToString:@""]) {
        self.customTipText = text;
    } else {
        self.customTipText = nil;
    }

    // 更新文本时重置所有状态，确保提示文本可以正常显示
    self.isRecordingState = NO;
    self.isContentState = NO;
    self.isLoadingState = NO;

    // 更新提示文本
    self.tipLabel.text = text ?: @"";
    self.bgView.hidden = YES; // 隐藏内容视图
    self.tipLabel.hidden = NO; // 显示提示文本
    // 确保视图刷新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)showRecording {
    self.isRecordingState = YES;
    self.isContentState = NO;
    self.isLoadingState = NO;
    self.bgView.hidden = YES;
    self.tipLabel.hidden = NO;
    self.tipLabel.text = @"录音中";
}

- (void)showContent {
    self.isRecordingState = NO;
    self.isContentState = YES;
    self.isLoadingState = NO;
    self.bgView.hidden = NO;
    self.tipLabel.hidden = YES;
    // 确保视图刷新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)showLoading {
    self.isRecordingState = NO;
    self.isContentState = NO;
    self.isLoadingState = YES;
    // 如果加载视图不存在，创建它
    if (!self.loadingView) {
        self.loadingView = [[UIView alloc] init];
        self.loadingView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.loadingView];
        self.loadingView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [self.loadingView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.loadingView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
            [self.loadingView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
            [self.loadingView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        // 创建加载指示器 (iOS 15+ 支持)
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        self.activityIndicator.color = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
        [self.loadingView addSubview:self.activityIndicator];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 创建加载文本标签
        self.loadingLabel = [[UILabel alloc] init];
        self.loadingLabel.text = @"翻译中";
        self.loadingLabel.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1.0];
        self.loadingLabel.font = [UIFont systemFontOfSize:18];
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.loadingView addSubview:self.loadingLabel];
        self.loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 设置约束
        [NSLayoutConstraint activateConstraints:@[
            [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.loadingView.centerXAnchor],
            [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.loadingView.centerYAnchor constant:-15],
            [self.loadingLabel.topAnchor constraintEqualToAnchor:self.activityIndicator.bottomAnchor constant:10],
            [self.loadingLabel.centerXAnchor constraintEqualToAnchor:self.loadingView.centerXAnchor]
        ]];
    }
    
    // 隐藏其他视图
    self.bgView.hidden = YES;
    self.tipLabel.hidden = YES;
    
    // 显示加载视图
    self.loadingView.hidden = NO;
    [self.activityIndicator startAnimating];
    
    // 确保视图刷新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)hiddenLoading {
    self.isLoadingState = NO;

    // 停止动画（如果存在）
    if (self.activityIndicator) {
        [self.activityIndicator stopAnimating];
    }

    // 隐藏加载视图（如果存在）
    if (self.loadingView) {
        self.loadingView.hidden = YES;
    }
    // 确保视图刷新
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end

// PiP 视图控制器
@interface UniAppPipViewController : UIViewController
@property (nonatomic, strong) AVPictureInPictureController *pipController;
@property (nonatomic, assign) BOOL isPortrait;
@property (nonatomic, assign) BOOL needsPlayerSetup;
@property (nonatomic, assign) BOOL hasSetupPlayer;
@end

@implementation UniAppPipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];

    // 先设置基础属性
    _isPortrait = YES;

    // 注册生命周期通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];

    // 检查音频权限
    AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (author == AVAuthorizationStatusAuthorized) {
        // 权限已授权，直接设置
        [self setupAudioAndPlayer];
    } else if (author == AVAuthorizationStatusNotDetermined) {
        // 权限未确定，请求权限 - 但不立即设置播放器，等待应用进入后台
        self.needsPlayerSetup = YES;

        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    [self setupAudioSession];
                } else {
                }
            });
        }];
    } else {
    }
}

- (void)setupAudioSession {
    if (@available(iOS 15.0, *)) {
        @try {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];

            if (error) {
            } else {
            }
        } @catch (NSException *exception) {
        }
    }
}

- (void)setupAudioAndPlayer {
    [self setupAudioSession];
    [self setupPlayer];
}

- (void)setupPlayerWhenNeeded {
    if (self.needsPlayerSetup && !self.hasSetupPlayer) {
        [self setupPlayer];
        self.hasSetupPlayer = YES;
        self.needsPlayerSetup = NO;
    }
}

- (void)setupPlayerAndNotifications {
    if (@available(iOS 15.0, *)) {
        @try {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];

            if (error) {
            } else {
            }
        } @catch (NSException *exception) {
        }

        _isPortrait = YES;
        [self setupPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
}

- (void)setupPlayer {
    if (@available(iOS 15.0, *)) {
        @try {
            NSString *videoName = _isPortrait ? @"floating_video_9_16" : @"floating_video_16_9";
            NSURL *url = nil;

            // 1. 优先从主应用 bundle 查找（UniApp 打包后资源在这里）
            url = [[NSBundle mainBundle] URLForResource:videoName withExtension:@"mp4"];
            
            // 2. 如果主 bundle 中找不到，尝试 Framework bundle
            if (!url) {
                NSBundle *frameworkBundle = [NSBundle bundleForClass:[PictureInPictureModule class]];
                url = [frameworkBundle URLForResource:videoName withExtension:@"mp4"];
            }
            
            // 3. 最后尝试 PiPPlugin.bundle（兼容性）
            if (!url) {
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PiPPlugin" ofType:@"bundle"];
                if (bundlePath) {
                    NSBundle *pipBundle = [NSBundle bundleWithPath:bundlePath];
                    url = [pipBundle URLForResource:videoName withExtension:@"mp4"];
                }
            }
            
            if (!url) {
                return;
            }
            AVAsset *asset = [AVAsset assetWithURL:url];
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
            AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
            player.muted = YES;
            
            AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
            layer.frame = CGRectMake(0, 0, 100, 100);
            layer.hidden = NO; // 重要：PlayerLayer 必须可见，PiP 才能正常显示内容
            layer.backgroundColor = [UIColor blackColor].CGColor; // 设置黑色背景，避免透明
            [self.view.layer addSublayer:layer];
            NSError *error = nil;
            self.pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:layer];
            if (!self.pipController) {
                return;
            }
            if (@available(iOS 15.0, *)) {
                [self.pipController setValue:[NSNumber numberWithInt:2] forKey:@"controlsStyle"];
            }
            self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
            self.pipController.delegate = self;
        } @catch (NSException *exception) {
        }
    }
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notice {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isPortrait = orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown;
    [self transform:isPortrait];
}

- (void)transform:(BOOL)isPortrait {
    _isPortrait = isPortrait;
    if (@available(iOS 15.0, *)) {
        NSString *videoName = isPortrait ? @"floating_video_9_16" : @"floating_video_16_9";
        NSURL *url = nil;

        // 1. 优先从主应用 bundle 查找（UniApp 打包后资源在这里）
        url = [[NSBundle mainBundle] URLForResource:videoName withExtension:@"mp4"];
        
        // 2. 如果主 bundle 中找不到，尝试 Framework bundle
        if (!url) {
            NSBundle *frameworkBundle = [NSBundle bundleForClass:[PictureInPictureModule class]];
            url = [frameworkBundle URLForResource:videoName withExtension:@"mp4"];
        }
        
        // 3. 最后尝试 PiPPlugin.bundle（兼容性）
        if (!url) {
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PiPPlugin" ofType:@"bundle"];
            if (bundlePath) {
                NSBundle *pipBundle = [NSBundle bundleWithPath:bundlePath];
                url = [pipBundle URLForResource:videoName withExtension:@"mp4"];
            }
        }

        if (!url) {
            return;
        }
        AVAsset *asset = [AVAsset assetWithURL:url];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
        [self.pipController.playerLayer.player replaceCurrentItemWithPlayerItem:item];
    }
}

- (void)playbackFinished:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        if (finished) {
            [self.pipController.playerLayer.player play];
        }
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

// PiP Window
@interface UniAppPipWindow : UIWindow
@property (nonatomic, strong) UniAppPipViewController *pipViewController;
@end

@implementation UniAppPipWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 使用正常窗口级别，避免遮挡主应用界面
        self.windowLevel = UIWindowLevelNormal - 1; // 稍微低一点，确保不遮挡主窗口
        self.backgroundColor = [UIColor clearColor]; // 使用透明背景
        self.layer.masksToBounds = YES;
        self.pipViewController = [[UniAppPipViewController alloc] init];
        self.rootViewController = self.pipViewController;
        
        // UniApp 环境下的 windowScene 设置（需要更安全的处理）
        if (@available(iOS 13.0, *)) {
            // 先尝试从 keyWindow 获取
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            if (keyWindow && keyWindow.windowScene) {
                self.windowScene = keyWindow.windowScene;
            } else {
                // 如果 keyWindow 不存在，尝试从 windows 数组中获取
                NSArray<UIWindow *> *windows = [UIApplication sharedApplication].windows;
                for (UIWindow *window in windows) {
                    if (window.windowScene && window.isKeyWindow) {
                        self.windowScene = window.windowScene;
                        break;
                    }
                }
                // 如果还是找不到，尝试第一个 window 的 windowScene
                if (!self.windowScene && windows.count > 0) {
                    UIWindow *firstWindow = windows.firstObject;
                    if (firstWindow.windowScene) {
                        self.windowScene = firstWindow.windowScene;
                    }
                }
            }
            // 如果仍然没有 windowScene，系统会自动处理，不需要强制设置
        }
    }
    return self;
}

@end

// 主模块实现
@interface PictureInPictureModule ()<AVPictureInPictureControllerDelegate, UniPluginProtocol>
@property (nonatomic, strong) UniAppPipWindow *pipWindow;
@property (nonatomic, strong) UniAppCustomFloatingView *floatingView;

// 文本状态保存（用于重新创建floatingView时恢复内容）
@property (nonatomic, strong) NSString *savedFirstText;
@property (nonatomic, strong) NSString *savedSecondText;
@property (nonatomic, strong) NSString *savedTipText;
@property (nonatomic, assign) BOOL savedRecordingState;
@property (nonatomic, assign) BOOL savedContentState;
@property (nonatomic, assign) BOOL savedLoadingState;

// 后台上传任务相关（参考 f3transpro 实现）
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UniModuleKeepAliveCallback> *uploadCallbacks;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTaskId; // 后台任务标识（参考 f3transpro）

// 全局日志收集器（用于收集后台日志）
@property (nonatomic, strong) NSMutableArray<NSString *> *backgroundLogs;

// 私有方法
- (void)removeFloatingView;
- (void)setupPip;
- (void)setupPipWithCallback:(void(^)(NSArray *logs))callback;
- (void)destroyPip;
- (void)ensureFloatingViewExists;
- (void)refreshFloatingViewDisplay;
- (void)applicationWillResignActiveNotification:(NSNotification *)notification;
- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification;
- (void)endBackgroundTask; // 结束后台任务（参考 f3transpro）
- (void)clearAllSavedStates;

@end

@implementation PictureInPictureModule

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化后台上传任务相关属性（参考 f3transpro）
        _uploadCallbacks = [NSMutableDictionary dictionary];
        _bgTaskId = UIBackgroundTaskInvalid;
        
        // 不在这里注册监听器，避免在 pipWindow 初始化前触发
        // 监听器将在 setupPip 完成后注册
    }
    return self;
}

+ (void)load {
    // 监听应用生命周期，确保回到前台时移除 floatingView
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        // 应用回到前台时，移除 floatingView（如果 PiP 未激活）
        PictureInPictureModule *instance = [self getInstance];
        if (instance) {
            // 检查 PiP 是否还在运行
            BOOL pipActive = instance.pipWindow && 
                            instance.pipWindow.pipViewController && 
                            instance.pipWindow.pipViewController.pipController &&
                            instance.pipWindow.pipViewController.pipController.isPictureInPictureActive;
            
            if (!pipActive) {
                [instance removeFloatingView];
                
                // 确保主 window 恢复
                UIWindow *mainWindow = [UIApplication sharedApplication].windows.firstObject;
                if (mainWindow && !mainWindow.isKeyWindow) {
                    [mainWindow makeKeyAndVisible];
                }
                
                // 隐藏 PiP window
                if (instance.pipWindow && !instance.pipWindow.hidden) {
                    instance.pipWindow.hidden = YES;
                }
            }
        }
    }];
}

+ (instancetype)getInstance {
    // 这里需要想办法获取实例，但 UniApp 模块是动态创建的
    // 暂时使用通知机制，让实例自己处理
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 结束后台任务
    [self endBackgroundTask];
    // 清理上传回调
    @synchronized(self) {
        [self.uploadCallbacks removeAllObjects];
    }
}

#pragma mark - UniPluginProtocol (AppDelegate 事件处理)

// 实现 UniPluginProtocol 的方法（接收 UIApplication * 参数）
- (void)applicationWillResignActive:(UIApplication *)application {
    // 调用通知处理方法
    [self applicationWillResignActiveNotification:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 开始后台任务（参考 f3transpro）
    self.bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^(void){
        [self endBackgroundTask];
    }];
    // 调用通知处理方法
    [self applicationDidEnterBackgroundNotification:nil];
}

#pragma mark - 通知处理方法（接收 NSNotification * 参数）

- (void)applicationWillResignActiveNotification:(NSNotification *)notification {
    // 应用即将进入后台时，如果 PiP 还没有启动，提前准备
    // 添加严格的 nil 检查，避免崩溃
    if (!self.pipWindow) {
        return;
    }
    if (!self.pipWindow.pipViewController) {
        return;
    }

    // 如果 pipController 不存在，尝试设置播放器
    if (!self.pipWindow.pipViewController.pipController) {
        [self.pipWindow.pipViewController setupPlayerWhenNeeded];

        // 等待一下让播放器设置完成，然后再次尝试
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self applicationWillResignActiveNotification:notification];
        });
        return;
    }
    
    BOOL pipActive = self.pipWindow.pipViewController.pipController.isPictureInPictureActive;
    
    if (!pipActive) {
        // PiP 已准备好但未启动，尝试启动
        if ([self.pipWindow.pipViewController.pipController isPictureInPicturePossible]) {
            NSError *error = nil;
            [self.pipWindow.pipViewController.pipController startPictureInPicture];
            if (error) {
            }
        } else {
        }
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    // 应用进入后台时，自动启动画中画
    if (!self.pipWindow) {
        return;
    }
    
    if (!self.pipWindow.pipViewController) {
        return;
    }

    // 如果 pipController 不存在，尝试设置播放器
    if (!self.pipWindow.pipViewController.pipController) {
        [self.pipWindow.pipViewController setupPlayerWhenNeeded];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self applicationDidEnterBackgroundNotification:notification];
        });
        return;
    }
    
    BOOL pipActive = self.pipWindow.pipViewController.pipController.isPictureInPictureActive;
    
    if (!pipActive) {
        BOOL pipSupported = [AVPictureInPictureController isPictureInPictureSupported];
        
        if (pipSupported) {
            BOOL pipPossible = [self.pipWindow.pipViewController.pipController isPictureInPicturePossible];
            
            if (pipPossible) {
                @try {
                    [self.pipWindow.pipViewController.pipController startPictureInPicture];
                } @catch (NSException *exception) {
                    // 忽略异常
                }
            } else {
                if (!self.pipWindow.pipViewController.pipController.playerLayer) {
                    [self setupPip];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (self.pipWindow && 
                            self.pipWindow.pipViewController && 
                            self.pipWindow.pipViewController.pipController &&
                            [self.pipWindow.pipViewController.pipController isPictureInPicturePossible]) {
                            [self.pipWindow.pipViewController.pipController startPictureInPicture];
                        }
                    });
                }
            }
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // 结束后台任务（参考 f3transpro）
    [self endBackgroundTask];
    
    // 添加严格的 nil 检查，避免崩溃
    if (!self.pipWindow) {
        return;
    }
    if (!self.pipWindow.pipViewController) {
        return;
    }
    if (!self.pipWindow.pipViewController.pipController) {
        return;
    }
    
    // 检查 PiP 是否还在运行
    BOOL pipActive = self.pipWindow.pipViewController.pipController.isPictureInPictureActive;
    
    if (!pipActive) {
        [self removeFloatingView];
        
        // 确保主 window 恢复
        UIWindow *mainWindow = [UIApplication sharedApplication].windows.firstObject;
        if (mainWindow && !mainWindow.isKeyWindow) {
            [mainWindow makeKeyAndVisible];
        }
        
        // 隐藏 PiP window
        if (self.pipWindow && !self.pipWindow.hidden) {
            self.pipWindow.hidden = YES;
        }
    }
}

// UniApp 方法导出宏
UNI_EXPORT_METHOD(@selector(isSupported:))
UNI_EXPORT_METHOD(@selector(showPictureInPicture:callback:))
UNI_EXPORT_METHOD(@selector(hidePictureInPicture:))
UNI_EXPORT_METHOD(@selector(updateFirstText:))
UNI_EXPORT_METHOD(@selector(updateSecondText:))
UNI_EXPORT_METHOD(@selector(updateTipText:))
UNI_EXPORT_METHOD(@selector(showRecording:))
UNI_EXPORT_METHOD(@selector(showContent:))
UNI_EXPORT_METHOD(@selector(showLoading:))
UNI_EXPORT_METHOD(@selector(hiddenLoading:))
UNI_EXPORT_METHOD(@selector(uploadFile:callback:))
UNI_EXPORT_METHOD(@selector(getVersion:))

#pragma mark - UniApp 导出方法

// 检查是否支持 PiP
- (void)isSupported:(UniModuleKeepAliveCallback)callback {
    BOOL supported = [AVPictureInPictureController isPictureInPictureSupported];
    if (callback) {
        callback(@{@"success": @YES, @"data": @(supported)}, NO);
    }
}

// 显示画中画
- (void)showPictureInPicture:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    NSMutableArray *logs = [NSMutableArray array];
    void (^addLog)(NSString *) = ^(NSString *log) {
        [logs addObject:log];
    };
    
    addLog(@"PictureInPictureModule: showPictureInPicture called");
    addLog([NSString stringWithFormat:@"PictureInPictureModule: callback is %@", callback ? @"NOT NULL" : @"NULL"]);
    addLog([NSString stringWithFormat:@"PictureInPictureModule: options: %@", options]);
    
    // UniApp 模块方法默认在主线程执行，但为了确保，强制切换到主线程
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showPictureInPicture:options callback:callback];
        });
        return;
    }
    
    @try {
        if (!self.pipWindow) {
            addLog(@"PictureInPictureModule: Creating pipWindow");
            // 使用屏幕边界初始化 window
            CGRect screenBounds = [UIScreen mainScreen].bounds;
            self.pipWindow = [[UniAppPipWindow alloc] initWithFrame:screenBounds];
            if (!self.pipWindow) {
                addLog(@"ERROR: Failed to create pipWindow");
                if (callback) {
                    callback(@{
                        @"success": @NO,
                        @"message": @"Failed to create pipWindow",
                        @"logs": logs
                    }, NO);
                }
                return;
            }
        }

        // 重要：pipWindow需要可见以支持PiP功能，但不能遮挡主应用
        // 设置为透明且不在最前面，这样既支持PiP又不会影响用户体验
        self.pipWindow.hidden = NO;
        self.pipWindow.backgroundColor = [UIColor clearColor];
        // 确保pipWindow不会成为keyWindow，避免遮挡主应用
        // 不调用makeKeyAndVisible
        addLog(@"PictureInPictureModule: pipWindow created and visible but transparent (ready for PiP)");
        
        // 权限检查和初始化现在在 UniAppPipViewController 的 viewDidLoad 中处理
        // 这里只需要调用 setupPip，它会触发 viewDidLoad
        if (@available(iOS 15.0, *)) {
            addLog(@"PictureInPictureModule: iOS version OK (15.0+), calling setupPip");
            [self setupPipWithCallback:^(NSArray *setupLogs) {
                [logs addObjectsFromArray:setupLogs];
                if (callback) {
                    callback(@{
                        @"success": @YES,
                        @"message": @"showPictureInPicture completed",
                        @"logs": logs
                    }, NO);
                }
            }];
        } else {
            NSString *errorMsg = @"iOS version too low (need 15.0+)";
            addLog([@"PictureInPictureModule: " stringByAppendingString:errorMsg]);
            if (callback) {
                callback(@{
                    @"success": @NO,
                    @"message": errorMsg,
                    @"logs": logs
                }, NO);
            }
        }
    } @catch (NSException *exception) {
        NSString *errorMsg = [NSString stringWithFormat:@"ERROR in showPictureInPicture: %@", exception.reason];
        addLog(errorMsg);
        addLog([NSString stringWithFormat:@"Exception stack: %@", exception.callStackSymbols]);
        if (callback) {
            callback(@{
                @"success": @NO,
                @"message": errorMsg,
                @"logs": logs
            }, NO);
        }
    }
}

// 隐藏画中画
- (void)hidePictureInPicture:(NSDictionary *)options {
    // 用户明确隐藏时，完全销毁
    [self destroyPip];
    self.pipWindow = nil;
    self.floatingView = nil;
}

// 更新第一行文本
- (void)updateFirstText:(NSDictionary *)options {
    NSString *text = options[@"text"] ?: @"";
    if (!text || [text isEqualToString:@""]) {
        return;
    }
    // 如果floatingView不存在，尝试创建它
    if (!self.floatingView) {
        [self ensureFloatingViewExists];
    }

    if (self.floatingView) {
        // 🔧 修复：参考 f3transpro，更新第一条文本时保留第二条文本的状态
        // 只清除状态标志和提示文本，保留第二条文本
        self.savedRecordingState = NO;
        self.savedContentState = NO;
        self.savedLoadingState = NO;
        self.savedTipText = nil;
        // 保留第二条文本的状态
        self.savedFirstText = text;
        // 统一通过refreshFloatingViewDisplay()来设置UI，确保状态一致性
        [self refreshFloatingViewDisplay];
    } else {
        // 即使floatingView不存在，也要保存文本状态（保留第二条文本）
        self.savedRecordingState = NO;
        self.savedContentState = NO;
        self.savedLoadingState = NO;
        self.savedTipText = nil;
        self.savedFirstText = text;
    }
}

// 更新第二行文本
- (void)updateSecondText:(NSDictionary *)options {
    NSString *text = options[@"text"] ?: @"";
    if (!text || [text isEqualToString:@""]) {
        return;
    }
    // 如果floatingView不存在，尝试创建它
    if (!self.floatingView) {
        [self ensureFloatingViewExists];
    }

    if (self.floatingView) {
        // 🔧 修复：参考 f3transpro，更新第二条文本时保留第一条文本的状态
        // 只清除状态标志和提示文本，保留第一条文本
        self.savedRecordingState = NO;
        self.savedContentState = NO;
        self.savedLoadingState = NO;
        self.savedTipText = nil;
        // 保留第一条文本的状态
        self.savedSecondText = text;
        // 统一通过refreshFloatingViewDisplay()来设置UI，确保状态一致性
        [self refreshFloatingViewDisplay];
    } else {
        // 即使floatingView不存在，也要保存文本状态（保留第一条文本）
        self.savedRecordingState = NO;
        self.savedContentState = NO;
        self.savedLoadingState = NO;
        self.savedTipText = nil;
        self.savedSecondText = text;
    }
}

// 更新提示文本
- (void)updateTipText:(NSDictionary *)options {
    NSString *text = options[@"text"] ?: @"";
    // 如果floatingView不存在，尝试创建它
    if (!self.floatingView) {
        [self ensureFloatingViewExists];
    }

    if (self.floatingView) {
        // 🔧 修复：完整的状态管理：清除其他状态，只保留当前状态
        // 只保存状态，不直接调用floatingView的更新方法，统一由refreshFloatingViewDisplay()来设置UI
        [self clearAllSavedStates];
        self.savedTipText = text;
        // 统一通过refreshFloatingViewDisplay()来设置UI，确保状态一致性
        [self refreshFloatingViewDisplay];
    } else {
        // 即使floatingView不存在，也要保存文本状态
        [self clearAllSavedStates];
        self.savedTipText = text;
    }
}

// 显示录音状态
- (void)showRecording:(NSDictionary *)options {
    // 保存状态
    self.savedRecordingState = YES;
    self.savedContentState = NO;
    self.savedLoadingState = NO;

    if (self.floatingView) {
        [self.floatingView showRecording];
        [self refreshFloatingViewDisplay];
    } else {
    }
}

// 显示内容状态
- (void)showContent:(NSDictionary *)options {
    // 保存状态
    self.savedRecordingState = NO;
    self.savedContentState = YES;
    self.savedLoadingState = NO;

    if (self.floatingView) {
        [self.floatingView showContent];
        [self refreshFloatingViewDisplay];
    } else {
    }
}

// 显示加载状态
- (void)showLoading:(NSDictionary *)options {
    // 保存状态
    self.savedRecordingState = NO;
    self.savedContentState = NO;
    self.savedLoadingState = YES;

    if (self.floatingView) {
        [self.floatingView showLoading];
        [self refreshFloatingViewDisplay];
    } else {
    }
}

// 隐藏加载状态
- (void)hiddenLoading:(NSDictionary *)options {
    if (self.floatingView) {
        [self.floatingView hiddenLoading];
        [self refreshFloatingViewDisplay];
    } else {
    }
}

// 上传文件（单文件上传，参考 UTSNetwork.uploadFile 格式）
- (void)uploadFile:(NSDictionary *)options callback:(UniModuleKeepAliveCallback)callback {
    // 解析参数
    NSString *urlString = options[@"url"];
    NSString *method = options[@"method"] ?: @"POST";
    NSString *filePath = options[@"filePath"];  // 文件路径
    NSString *name = options[@"name"] ?: @"file";  // 文件字段名
    NSDictionary *formData = options[@"formData"] ?: @{};
    NSDictionary *header = options[@"header"] ?: @{};
    NSNumber *timeoutNumber = options[@"timeout"];
    NSTimeInterval timeout = timeoutNumber ? timeoutNumber.doubleValue : 60.0;
    // 参数验证
    if (!urlString || urlString.length == 0) {
        if (callback) {
            callback(@{@"success": @NO, @"errMsg": @"uploadFile:fail url is required"}, NO);
        }
        return;
    }
    
    if (!filePath || filePath.length == 0) {
        if (callback) {
            callback(@{@"success": @NO, @"errMsg": @"uploadFile:fail filePath is required"}, NO);
        }
        return;
    }
    
    // 创建 URL
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (callback) {
            callback(@{@"success": @NO, @"errMsg": @"uploadFile:fail invalid URL"}, NO);
        }
        return;
    }
    
    // 检查文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        // 如果文件不存在，尝试处理 UniApp 资源路径
        // 如果路径以 /static/ 开头，尝试从 bundle 中查找
        if ([filePath hasPrefix:@"/static/"] || [filePath hasPrefix:@"static/"]) {
            NSString *fileName = [filePath lastPathComponent];
            NSString *resourcePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] 
                                                                      ofType:[fileName pathExtension]
                                                                 inDirectory:@"static"];
            if (resourcePath && [fileManager fileExistsAtPath:resourcePath]) {
                filePath = resourcePath;
            } else {
                // 尝试直接查找文件名（不指定目录）
                resourcePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] 
                                                                ofType:[fileName pathExtension]];
                if (resourcePath && [fileManager fileExistsAtPath:resourcePath]) {
                    filePath = resourcePath;
                } else {
                    if (callback) {
                        callback(@{@"success": @NO, @"errMsg": [NSString stringWithFormat:@"uploadFile:fail file not found at path: %@", filePath]}, NO);
                    }
                    return;
                }
            }
        } else {
            if (callback) {
                callback(@{@"success": @NO, @"errMsg": [NSString stringWithFormat:@"uploadFile:fail file not found at path: %@", filePath]}, NO);
            }
            return;
        }
    }
    
    // 读取文件数据
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!fileData) {
        if (callback) {
            callback(@{@"success": @NO, @"errMsg": @"uploadFile:fail failed to read file"}, NO);
        }
        return;
    }
    
    // 创建 multipart/form-data 请求体
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    NSMutableData *body = [NSMutableData data];
    
    // 添加文件到请求体
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, [filePath lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 添加 formData 参数
    for (NSString *key in formData) {
        id value = formData[key];
        NSString *valueString = [value isKindOfClass:[NSString class]] ? value : [value description];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[valueString dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // 结束边界
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:timeout];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)body.length] forHTTPHeaderField:@"Content-Length"];
    
    // 添加自定义请求头
    for (NSString *key in header) {
        id value = header[key];
        NSString *valueString = [value isKindOfClass:[NSString class]] ? value : [value description];
        // 注意：如果 header 中设置了 Content-Type，会被上面的设置覆盖
        if (![key isEqualToString:@"Content-Type"]) {
            [request setValue:valueString forHTTPHeaderField:key];
        }
    }
    
    // 注意：使用 uploadTaskWithRequest:fromData: 时，不要设置 HTTPBody
    // 因为 fromData 参数会自动处理 body，设置 HTTPBody 会导致警告
    
    // 使用默认会话配置（参考 f3transpro 实现）
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.waitsForConnectivity = YES;
    configuration.timeoutIntervalForRequest = timeout;
    configuration.timeoutIntervalForResource = timeout + 30;
    configuration.allowsCellularAccess = YES;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // 存储回调
    if (callback) {
        @synchronized(self) {
            if (!self.uploadCallbacks) {
                self.uploadCallbacks = [NSMutableDictionary dictionary];
            }
        }
    }
    
    // 使用 completionHandler 方式（参考 f3transpro）
    // 保存 URL 用于匹配回调
    NSString *requestURLString = urlString;
    
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:body completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 结束后台任务
        [self endBackgroundTask];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResponse ? httpResponse.statusCode : 0;
        
        // 获取回调（通过 URL 匹配，因为 completionHandler 中无法直接访问 task.taskIdentifier）
        UniModuleKeepAliveCallback taskCallback = nil;
        @synchronized(self) {
            // 通过 URL 匹配回调（简化实现，如果有多个相同 URL 的上传任务，可能需要更复杂的匹配机制）
            // 这里假设每个 URL 只有一个上传任务，直接获取第一个回调
            if (self.uploadCallbacks.count > 0) {
                NSArray *allKeys = [self.uploadCallbacks allKeys];
                if (allKeys.count > 0) {
                    NSNumber *firstKey = allKeys.firstObject;
                    taskCallback = self.uploadCallbacks[firstKey];
                    [self.uploadCallbacks removeObjectForKey:firstKey];
                }
            }
        }
        
        if (error) {
            if (taskCallback) {
                NSDictionary *result = @{
                    @"success": @NO,
                    @"statusCode": @(statusCode),
                    @"errMsg": [NSString stringWithFormat:@"uploadFile:fail %@", error.localizedDescription]
                };
                taskCallback(result, NO);
            }
            return;
        }
        
        NSString *responseString = @"";
        if (data) {
            responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (!responseString) {
                responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }
        }
        
        NSMutableDictionary *responseHeaders = [NSMutableDictionary dictionary];
        if (httpResponse && httpResponse.allHeaderFields) {
            for (NSString *key in httpResponse.allHeaderFields) {
                id value = httpResponse.allHeaderFields[key];
                NSString *valueString = [value isKindOfClass:[NSString class]] ? value : [value description];
                responseHeaders[key] = valueString;
            }
        }
        if (taskCallback) {
            NSDictionary *result = @{
                @"success": @(statusCode == 200),
                @"statusCode": @(statusCode),
                @"data": responseString ?: @"",
                @"header": responseHeaders,
                @"errMsg": statusCode == 200 ? @"uploadFile:ok" : [NSString stringWithFormat:@"uploadFile:fail statusCode=%ld", (long)statusCode]
            };
            taskCallback(result, NO);
        }
    }];
    
    // 存储回调
    if (callback) {
        @synchronized(self) {
            self.uploadCallbacks[@(task.taskIdentifier)] = callback;
        }
    }
    [task resume];
}

// 获取插件版本号
- (void)getVersion:(UniModuleKeepAliveCallback)callback {
    // 从 Framework 的 bundle 中读取 Info.plist 的版本号
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[PictureInPictureModule class]];
    NSString *version = [frameworkBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    // 如果 CFBundleShortVersionString 不存在，尝试读取 CFBundleVersion
    if (!version || version.length == 0) {
        version = [frameworkBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    
    // 如果还是获取不到，使用默认值
    if (!version || version.length == 0) {
        version = @"1.0.0";
    }
    
    if (callback) {
        callback(@{
            @"success": @YES,
            @"version": version,
            @"errMsg": @"getVersion:ok"
        }, NO);
    }
}

#pragma mark - 后台任务管理（参考 f3transpro）

/**
 * 结束后台任务（参考 f3transpro）
 */
- (void)endBackgroundTask {
    if (self.bgTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
        self.bgTaskId = UIBackgroundTaskInvalid;
    }
}

#pragma mark - Private Methods

- (void)ensureFloatingViewExists {
    // 如果floatingView已经存在，直接返回
    if (self.floatingView) {
        return;
    }

    // 如果pipWindow不存在，尝试创建它
    if (!self.pipWindow) {
        [self createPipInfrastructure];
    }

    // 检查pipWindow是否可用
    if (!self.pipWindow || !self.pipWindow.pipViewController) {
        return;
    }

    // 创建floatingView，设置初始frame避免约束冲突
    self.floatingView = [[UniAppCustomFloatingView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    // 如果pipController存在，设置代理
    if (self.pipWindow.pipViewController.pipController) {
        self.pipWindow.pipViewController.pipController.delegate = self;
    }
}

- (void)createPipInfrastructure {
    // 创建pipWindow
    self.pipWindow = [[UniAppPipWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.pipWindow.backgroundColor = [UIColor clearColor];
    self.pipWindow.hidden = NO;
    self.pipWindow.windowLevel = UIWindowLevelNormal - 1;

    // 创建pipViewController
    self.pipWindow.pipViewController = [[UniAppPipViewController alloc] init];
    self.pipWindow.rootViewController = self.pipWindow.pipViewController;
    // 设置PiP
    [self setupPip];
}

- (void)setupPip {
    [self setupPipWithCallback:nil];
}

- (void)setupPipWithCallback:(void(^)(NSArray *logs))callback {
    NSMutableArray *logs = [NSMutableArray array];
    void (^addLog)(NSString *) = ^(NSString *log) {
        [logs addObject:log];
    };
    
    addLog(@"PictureInPictureModule: setupPip called");

    // 确保在主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            // 确保 pipWindow 和 pipViewController 存在
            if (!self.pipWindow || !self.pipWindow.pipViewController) {
                addLog(@"ERROR: pipWindow or pipViewController is nil");
                if (callback) {
                    callback(logs);
                }
                return;
            }

            addLog(@"PictureInPictureModule: pipWindow and pipViewController exist");

            // 确保 viewDidLoad 已经执行（触发视图加载）
            [self.pipWindow.pipViewController view];
            addLog(@"PictureInPictureModule: pipViewController view loaded");

            // 如果需要，设置播放器（这在权限刚刚被授予的情况下很重要）
            [self.pipWindow.pipViewController setupPlayerWhenNeeded];
            addLog(@"PictureInPictureModule: setupPlayerWhenNeeded called");

            // 等待一下，确保 setupPlayer 完成
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @try {
                    // 检查 pipController 是否存在
                    if (!self.pipWindow.pipViewController.pipController) {
                        addLog(@"WARNING: pipController is nil, player may not be set up yet. Will auto-setup when needed.");
                        // 不要返回，继续执行，PiP 会在应用进入后台时自动启动
                    } else {
                        addLog(@"PictureInPictureModule: pipController exists");
                    }

                    // 只有在floatingView不存在时才创建
                    if (!self.floatingView) {
                        // 创建自定义浮窗视图，设置初始frame避免约束冲突
                        self.floatingView = [[UniAppCustomFloatingView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
                        addLog(@"PictureInPictureModule: Created floatingView in setupPip with frame");
                    } else {
                        addLog(@"PictureInPictureModule: floatingView already exists");
                    }

                    // 设置 PiP 控制器代理
                    if (self.pipWindow.pipViewController.pipController) {
                        self.pipWindow.pipViewController.pipController.delegate = self;
                        addLog(@"PictureInPictureModule: Set pipController delegate");
                    }
                    
                    // 检查 playerLayer 和 player
                    if (!self.pipWindow.pipViewController.pipController.playerLayer) {
                        addLog(@"ERROR: playerLayer is nil");
                        if (callback) {
                            callback(logs);
                        }
                        return;
                    }
                    addLog(@"PictureInPictureModule: playerLayer exists");
                    
                    if (!self.pipWindow.pipViewController.pipController.playerLayer.player) {
                        addLog(@"ERROR: player is nil");
                        if (callback) {
                            callback(logs);
                        }
                        return;
                    }
                    addLog(@"PictureInPictureModule: player exists");
                    
                    // 开始播放视频（和 f3transpro 一样）
                    [self.pipWindow.pipViewController.pipController.playerLayer.player play];
                    addLog(@"PictureInPictureModule: Video started playing");
                    
                    // 只在 pipController 完全初始化后才注册应用生命周期监听器
                    // 避免在初始化过程中触发监听器导致崩溃
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        // 监听应用回到前台
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(applicationDidBecomeActive:)
                                                                     name:UIApplicationDidBecomeActiveNotification
                                                                   object:nil];
                        
                        // 监听应用进入后台 - 自动启动画中画
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(applicationDidEnterBackgroundNotification:)
                                                                     name:UIApplicationDidEnterBackgroundNotification
                                                                   object:nil];
                        
                        // 监听应用即将进入后台 - 提前准备画中画
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(applicationWillResignActiveNotification:)
                                                                     name:UIApplicationWillResignActiveNotification
                                                                   object:nil];
                        
                        addLog(@"PictureInPictureModule: Application lifecycle observers registered");
                    });

                    // 检查应用当前是否已经在后台，如果是，延迟启动 PiP
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIApplicationState currentAppState = [[UIApplication sharedApplication] applicationState];
                        if (currentAppState == UIApplicationStateBackground &&
                            self.pipWindow &&
                            self.pipWindow.pipViewController &&
                            self.pipWindow.pipViewController.pipController) {

                            BOOL pipActive = [self.pipWindow.pipViewController.pipController isPictureInPictureActive];
                            if (!pipActive && [self.pipWindow.pipViewController.pipController isPictureInPicturePossible]) {
                                addLog(@"PictureInPictureModule: App already in background after setup, starting PiP immediately");
                                [self.pipWindow.pipViewController.pipController startPictureInPicture];
                            }
                        }
                    });

                    addLog(@"PictureInPictureModule: setupPip completed successfully");
                    // 注意：PiP 会在应用进入后台时自动启动（canStartPictureInPictureAutomaticallyFromInline = YES）
                    
                    // 如果有回调，返回日志
                    if (callback) {
                        callback(logs);
                    }
                } @catch (NSException *exception) {
                    NSString *errorMsg = [NSString stringWithFormat:@"ERROR: Exception in setupPip (inner): %@", exception.reason];
                    addLog(errorMsg);
                    if (callback) {
                        callback(logs);
                    }
                }
            });
        } @catch (NSException *exception) {
            NSString *errorMsg = [NSString stringWithFormat:@"ERROR: Exception in setupPip (outer): %@", exception.reason];
            addLog(errorMsg);
            if (callback) {
                callback(logs);
            }
        }
    });
}

- (void)destroyPip {
    if (self.pipWindow && self.pipWindow.pipViewController && self.pipWindow.pipViewController.pipController) {
        @try {
            self.pipWindow.pipViewController.pipController.delegate = nil;
            if (self.pipWindow.pipViewController.pipController.playerLayer && 
                self.pipWindow.pipViewController.pipController.playerLayer.player) {
                [self.pipWindow.pipViewController.pipController.playerLayer.player pause];
            }
            [self.pipWindow.pipViewController.pipController stopPictureInPicture];
        } @catch (NSException *exception) {
        }
    }
    [self removeFloatingView];
    // 注意：不要销毁 pipWindow，因为 PiP 可能会自动重新启动
    // 只有在用户明确调用 hidePictureInPicture 时才应该完全销毁
    // self.pipWindow = nil;
}

- (void)removeFloatingView {
    if (self.floatingView && self.floatingView.superview) {
        [self.floatingView removeFromSuperview];
        // 注意：不要将 floatingView 设置为 nil，因为 PiP 可能会自动重新启动
        // 如果设置为 nil，下次启动时就没有视图了
        // self.floatingView = nil;
    } else {
    }
}

// 清理所有保存的状态
- (void)clearAllSavedStates {
    self.savedFirstText = nil;
    self.savedSecondText = nil;
    self.savedTipText = nil;
    self.savedRecordingState = NO;
    self.savedContentState = NO;
    self.savedLoadingState = NO;
}

- (void)restoreFloatingViewState {
    if (!self.floatingView) {
        return;
    }

    // 🔧 优化恢复逻辑：直接设置UI状态，避免重复调用update方法
    // 因为refreshFloatingViewDisplay会根据保存的状态正确设置UI
    // 直接调用refreshFloatingViewDisplay，它会根据保存的状态正确设置UI
    // 这样避免了状态重复设置和可能的冲突
    [self refreshFloatingViewDisplay];
}

#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    // 先尝试立即添加（和 f3transpro 一样）
    [self tryAddFloatingView];
    
    // 延迟再次尝试，确保PiP窗口已经创建
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tryAddFloatingView];
    });
    
    // 再延迟一次，确保窗口完全准备好
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tryAddFloatingView];
    });
}

- (void)tryAddFloatingView {
    // 如果 floatingView 不存在，重新创建（PiP 可能自动重新启动）
    if (!self.floatingView) {
        self.floatingView = [[UniAppCustomFloatingView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    }

    // 恢复保存的文本状态（无论floatingView是否已存在）
    [self restoreFloatingViewState];
    
    // 注意：floatingView 应该添加到 PiP 小窗口（firstWindow），而不是主应用的 window
    // 这是为了在 PiP 小窗口中显示自定义视图内容
    NSArray *allWindows = [UIApplication sharedApplication].windows;
    UIWindow *pipWindow = nil;
    
    for (NSInteger i = 0; i < allWindows.count; i++) {
        UIWindow *win = allWindows[i];
        CGRect winFrame = win.frame;
        CGFloat winArea = winFrame.size.width * winFrame.size.height;
        NSString *className = NSStringFromClass([win class]);
        // 跳过 UniAppPipWindow（这是 PiP 的后台 window，不是小窗口）和 text effects window
        if ([className containsString:@"UniAppPipWindow"] ||
            [className containsString:@"UITextEffectsWindow"]) {
            continue;
        }

        // PiP 小窗口的特点是：面积适中（5000-100000之间），且不是主应用 window
        // 根据日志，PiP 小窗口的面积是 54263
        if (winArea > 5000 && winArea < 100000) {
            pipWindow = win;
            break;
        }
    }
    
    // 如果没找到 PiP 小窗口，使用 firstWindow（和 f3transpro 一样）
    if (!pipWindow) {
        pipWindow = allWindows.firstObject;
        if (pipWindow) {
            CGRect winFrame = pipWindow.frame;
            CGFloat winArea = winFrame.size.width * winFrame.size.height;
        }
    } else {
    }
    
    if (!pipWindow) {
    }
    
    if (pipWindow && self.floatingView) {
        // 如果已经添加过，先移除再添加（确保在最上层）
        if (self.floatingView.superview) {
            [self.floatingView removeFromSuperview];
        }
        
        // 确保窗口背景是白色
        pipWindow.backgroundColor = [UIColor whiteColor];
        
        // 把自定义view放到 PiP 小窗口上（和 f3transpro 一样）
        [pipWindow addSubview:self.floatingView];
        [pipWindow bringSubviewToFront:self.floatingView]; // 确保在最上层
        self.floatingView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 确保自定义视图背景是白色（和 f3transpro 一样）
        self.floatingView.backgroundColor = [UIColor whiteColor];
        self.floatingView.layer.backgroundColor = [UIColor whiteColor].CGColor; // 确保 layer 背景也是白色
        
        [NSLayoutConstraint activateConstraints:@[
            [self.floatingView.topAnchor constraintEqualToAnchor:pipWindow.topAnchor],
            [self.floatingView.leftAnchor constraintEqualToAnchor:pipWindow.leftAnchor],
            [self.floatingView.rightAnchor constraintEqualToAnchor:pipWindow.rightAnchor],
            [self.floatingView.bottomAnchor constraintEqualToAnchor:pipWindow.bottomAnchor]
        ]];
        
        // 🔧 修复：不再根据UI当前状态重新设置，因为 restoreFloatingViewState() 已经根据保存的状态设置了UI
        // 这里只需要确保视图刷新即可，避免状态覆盖导致的不同步问题
        
        // 强制刷新视图（确保背景色生效）
        [self.floatingView setNeedsDisplay];
        [self.floatingView setNeedsLayout];
        [self.floatingView layoutIfNeeded];
        
        // 强制布局窗口
        [pipWindow setNeedsLayout];
        [pipWindow layoutIfNeeded];
        // 检查 tipLabel 的父视图层级
        UIView *currentView = self.floatingView.tipLabel;
        NSInteger level = 0;
        while (currentView) {
            currentView = currentView.superview;
            level++;
        }
    } else {
    }
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    // PiP 启动后，再次尝试添加视图（确保窗口已经准备好）
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tryAddFloatingView];
    });
    
    // 延迟再次尝试，确保窗口完全准备好
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tryAddFloatingView];
    });
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self removeFloatingView];
    
    // 应用回到前台时，确保主应用的 window 恢复
    dispatch_async(dispatch_get_main_queue(), ^{
        // 确保主应用的 window 重新成为 keyWindow
        UIWindow *mainWindow = [UIApplication sharedApplication].windows.firstObject;
        if (mainWindow && !mainWindow.isKeyWindow) {
            [mainWindow makeKeyAndVisible];
        }
        
        // 隐藏 PiP window（如果还存在）
        if (self.pipWindow && !self.pipWindow.hidden) {
            self.pipWindow.hidden = YES;
        }
    });
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    [self removeFloatingView];
}

#pragma mark - Display Refresh Methods

- (void)refreshFloatingViewDisplay {
    if (!self.floatingView) {
        return;
    }

    UniAppCustomFloatingView *floatingView = self.floatingView;

    // 🔧 修复：确保在主线程同步执行，避免异步导致的时序问题
    // 如果已经在主线程，直接执行；否则同步等待主线程执行完成
    if ([NSThread isMainThread]) {
        [self doRefreshFloatingViewDisplay];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self doRefreshFloatingViewDisplay];
        });
    }
}

- (void)doRefreshFloatingViewDisplay {
    if (!self.floatingView) {
        return;
    }

    UniAppCustomFloatingView *floatingView = self.floatingView;

    // 🔧 关键修复：基于保存的状态进行判断，而不是UI组件的当前内容
    // 这确保了业务逻辑状态与UI显示的一致性
    BOOL hasCustomTipText = self.savedTipText && ![self.savedTipText isEqualToString:@""];
    BOOL hasFirstText = self.savedFirstText && ![self.savedFirstText isEqualToString:@""];
    BOOL hasSecondText = self.savedSecondText && ![self.savedSecondText isEqualToString:@""];
    BOOL hasRecordingState = self.savedRecordingState;
    BOOL hasContentState = self.savedContentState;
    BOOL hasLoadingState = self.savedLoadingState;
    // 根据保存的状态决定显示逻辑
    // 优先级：录音状态 > 内容状态 > 加载状态 > 自定义提示文本 > (第一行文本 || 第二行文本) > 默认提示文本
    // 🔧 修复：参考 f3transpro，第一条和第二条文本应该共存，而不是互斥

    if (hasRecordingState) {
        // 录音状态优先级最高
        [floatingView showRecording];
    } else if (hasContentState) {
        // 内容状态
        [floatingView showContent];
    } else if (hasLoadingState) {
        // 加载状态
        [floatingView showLoading];
    } else if (hasCustomTipText) {
        // 有自定义提示文本，显示提示文本，隐藏内容视图
        floatingView.bgView.hidden = YES;
        floatingView.tipLabel.hidden = NO;
        floatingView.tipLabel.text = self.savedTipText;
    } else if (hasFirstText || hasSecondText) {
        // 🔧 修复：参考 f3transpro 的逻辑，第一条和第二条文本应该共存
        // 有第一行或第二行文本时，显示内容视图，隐藏提示文本
        floatingView.bgView.hidden = NO;
        floatingView.tipLabel.hidden = YES;
        // 设置第一条文本（如果存在）
        floatingView.firstLabel.text = self.savedFirstText ?: @"";
        // 设置第二条文本（如果存在）
        floatingView.secondLabel.text = self.savedSecondText ?: @"";
    } else {
        // 没有自定义内容，显示默认提示文本，隐藏内容视图
        floatingView.bgView.hidden = YES;
        floatingView.tipLabel.hidden = NO;
        floatingView.tipLabel.text = @"按住说话";
    }

    // 强制刷新布局
    [floatingView setNeedsLayout];
    [floatingView layoutIfNeeded];
}

@end
