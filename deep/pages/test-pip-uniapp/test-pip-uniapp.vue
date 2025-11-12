<template>
	<view class="container">
		<view class="header">
			<text class="title">PiPPlugin 完整测试</text>
		</view>
		
		<view class="content">
			<!-- 插件状态卡片 -->
			<view class="card">
				<text class="card-title">插件状态</text>
				<view class="status-grid">
					<view class="status-item">
						<text class="status-label">可用:</text>
						<text class="status-value" :class="{ success: pluginStatus.available }">
							{{ pluginStatus.available ? '✓' : '✗' }}
						</text>
					</view>
					<view class="status-item">
						<text class="status-label">已加载:</text>
						<text class="status-value" :class="{ success: pluginStatus.loaded }">
							{{ pluginStatus.loaded ? '✓' : '✗' }}
						</text>
					</view>
					<view class="status-item">
						<text class="status-label">设备支持:</text>
						<text class="status-value" :class="{ success: deviceSupported === true }">
							{{ deviceSupported === null ? '?' : (deviceSupported ? '✓' : '✗') }}
						</text>
					</view>
				</view>
			</view>
			
			<!-- 快速操作 -->
			<view class="card">
				<text class="card-title">快速操作</text>
				<view class="button-group">
					<button class="btn-primary" @click="quickStart">快速启动</button>
					<button class="btn-secondary" @click="quickStop">快速停止</button>
				</view>
			</view>
			
			<!-- 画中画控制 -->
			<view class="card">
				<text class="card-title">画中画控制</text>
				<view class="button-group">
					<button class="btn" @click="checkSupport">检查支持</button>
					<button class="btn" @click="showPiP">显示画中画</button>
					<button class="btn" @click="hidePiP">隐藏画中画</button>
				</view>
			</view>
			
			<!-- 文本更新 -->
			<view class="card">
				<text class="card-title">文本更新</text>
				<view class="input-group">
					<input class="input" v-model="firstText" placeholder="第一行文本" />
					<input class="input" v-model="secondText" placeholder="第二行文本" />
					<input class="input" v-model="tipText" placeholder="提示文本" />
				</view>
				<view class="button-group">
					<button class="btn" @click="updateAllTexts">更新所有文本</button>
					<button class="btn" @click="updateFirstText">更新第一行</button>
					<button class="btn" @click="updateSecondText">更新第二行</button>
					<button class="btn" @click="updateTipText">更新提示</button>
				</view>
			</view>
			
			<!-- 状态显示 -->
			<view class="card">
				<text class="card-title">状态显示</text>
				<view class="button-group">
					<button class="btn-status" @click="showRecording">录音状态</button>
					<button class="btn-status" @click="showContent">内容状态</button>
					<button class="btn-status" @click="showLoading">加载状态</button>
					<button class="btn-status" @click="hideLoading">隐藏加载</button>
				</view>
			</view>
			
			<!-- 文件上传 -->
			<view class="card">
				<text class="card-title">文件上传测试</text>
				<view class="input-group">
					<input class="input" v-model="uploadUrl" placeholder="上传地址" />
					<input class="input" v-model="filePath" placeholder="文件路径" />
				</view>
				<button class="btn-upload" @click="uploadFile">上传文件</button>
			</view>
			
			<!-- 日志输出 -->
			<view class="card">
				<text class="card-title">操作日志</text>
				<view class="log-header">
					<button class="btn-clear" @click="clearLogs">清空日志</button>
				</view>
				<scroll-view class="log-container" scroll-y scroll-top="{{scrollTop}}">
					<view v-for="(log, index) in logs" :key="index" class="log-item">
						<text class="log-time">{{ log.time }}</text>
						<text class="log-message" :class="log.type">{{ log.message }}</text>
					</view>
				</scroll-view>
			</view>
		</view>
	</view>
</template>

<script>
import PiPPlugin from '@/nativeplugins/PiPPlugin/index.js'

export default {
	data() {
		return {
			pluginStatus: {
				available: false,
				loaded: false
			},
			deviceSupported: null,
			firstText: '第一行文本',
			secondText: '第二行文本',
			tipText: '提示信息',
			uploadUrl: 'http://14.103.175.207:5000/upload',
			filePath: '/static/test_audio.mp3',
			logs: [],
			scrollTop: 0
		}
	},
	onLoad() {
		this.initPlugin()
	},
	methods: {
		async initPlugin() {
			try {
				// 检查插件是否可用
				this.pluginStatus.available = !!PiPPlugin;
				this.pluginStatus.loaded = typeof PiPPlugin === 'object' && PiPPlugin !== null;
				
				// 检查设备支持
				try {
					this.deviceSupported = await PiPPlugin.isSupported();
					this.addLog('设备支持画中画: ' + (this.deviceSupported ? '是' : '否'), this.deviceSupported ? 'success' : 'error');
				} catch (error) {
					this.addLog('检查设备支持失败: ' + error.message, 'error');
				}
				
				this.addLog('插件初始化成功', 'success');
				this.addLog('插件状态: ' + JSON.stringify(this.pluginStatus), 'info');
			} catch (error) {
				this.addLog('插件初始化失败: ' + error.message, 'error');
			}
		},
		
		addLog(message, type = 'info') {
			const timestamp = new Date().toLocaleTimeString()
			this.logs.unshift({
				time: timestamp,
				message: message,
				type: type
			})
			if (this.logs.length > 100) {
				this.logs.pop()
			}
			// 自动滚动到底部
			this.$nextTick(() => {
				this.scrollTop = 0
			})
		},
		
		clearLogs() {
			this.logs = []
			uni.showToast({
				title: '日志已清空',
				icon: 'success'
			})
		},
		
		async quickStart() {
			try {
				this.addLog('快速启动画中画...', 'info')
				const supported = await PiPPlugin.isSupported()
				if (!supported) {
					this.addLog('设备不支持画中画', 'error')
					uni.showToast({
						title: '设备不支持',
						icon: 'none'
					})
					return
				}
				
				PiPPlugin.showPictureInPicture({}, (result) => {
					if (result && result.success) {
						this.addLog('画中画启动成功', 'success')
						if (result.logs && result.logs.length > 0) {
							this.addLog('启动日志: ' + result.logs.join('; '), 'info')
						}
					} else {
						this.addLog('画中画启动失败: ' + (result?.message || '未知错误'), 'error')
					}
				})
				
				// 更新文本
				PiPPlugin.updateFirstText(this.firstText)
				PiPPlugin.updateSecondText(this.secondText)
				PiPPlugin.updateTipText(this.tipText)
				PiPPlugin.showContent()
				
				uni.showToast({
					title: '启动中...',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('启动失败: ' + error.message, 'error')
				uni.showToast({
					title: '启动失败',
					icon: 'error'
				})
			}
		},
		
		quickStop() {
			try {
				this.addLog('停止画中画...', 'info')
				PiPPlugin.hidePictureInPicture()
				this.addLog('画中画已停止', 'success')
				uni.showToast({
					title: '已停止',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('停止失败: ' + error.message, 'error')
				uni.showToast({
					title: '停止失败',
					icon: 'error'
				})
			}
		},
		
		async checkSupport() {
			try {
				this.addLog('检查设备支持...', 'info')
				const supported = await PiPPlugin.isSupported()
				this.deviceSupported = supported
				this.addLog('设备支持: ' + (supported ? '是' : '否'), supported ? 'success' : 'error')
				uni.showToast({
					title: supported ? '支持' : '不支持',
					icon: supported ? 'success' : 'none'
				})
			} catch (error) {
				this.addLog('检查失败: ' + error.message, 'error')
				uni.showToast({
					title: '检查失败',
					icon: 'error'
				})
			}
		},
		
		showPiP() {
			try {
				this.addLog('显示画中画...', 'info')
				PiPPlugin.showPictureInPicture({}, (result) => {
					if (result && result.success) {
						this.addLog('显示成功', 'success')
						if (result.logs && result.logs.length > 0) {
							this.addLog('日志: ' + result.logs.join('; '), 'info')
						}
					} else {
						this.addLog('显示失败: ' + (result?.message || '未知错误'), 'error')
					}
				})
				uni.showToast({
					title: '显示中...',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('显示失败: ' + error.message, 'error')
				uni.showToast({
					title: '显示失败',
					icon: 'error'
				})
			}
		},
		
		hidePiP() {
			try {
				this.addLog('隐藏画中画...', 'info')
				PiPPlugin.hidePictureInPicture()
				this.addLog('隐藏成功', 'success')
				uni.showToast({
					title: '已隐藏',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('隐藏失败: ' + error.message, 'error')
				uni.showToast({
					title: '隐藏失败',
					icon: 'error'
				})
			}
		},
		
		updateAllTexts() {
			try {
				this.addLog('更新所有文本...', 'info')
				PiPPlugin.updateFirstText(this.firstText)
				PiPPlugin.updateSecondText(this.secondText)
				PiPPlugin.updateTipText(this.tipText)
				this.addLog('所有文本已更新', 'success')
				uni.showToast({
					title: '已更新',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('更新失败: ' + error.message, 'error')
				uni.showToast({
					title: '更新失败',
					icon: 'error'
				})
			}
		},
		
		updateFirstText() {
			try {
				this.addLog('更新第一行: ' + this.firstText, 'info')
				PiPPlugin.updateFirstText(this.firstText)
				this.addLog('更新成功', 'success')
				uni.showToast({
					title: '已更新',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('更新失败: ' + error.message, 'error')
				uni.showToast({
					title: '更新失败',
					icon: 'error'
				})
			}
		},
		
		updateSecondText() {
			try {
				this.addLog('更新第二行: ' + this.secondText, 'info')
				PiPPlugin.updateSecondText(this.secondText)
				this.addLog('更新成功', 'success')
				uni.showToast({
					title: '已更新',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('更新失败: ' + error.message, 'error')
				uni.showToast({
					title: '更新失败',
					icon: 'error'
				})
			}
		},
		
		updateTipText() {
			try {
				this.addLog('更新提示: ' + this.tipText, 'info')
				PiPPlugin.updateTipText(this.tipText)
				this.addLog('更新成功', 'success')
				uni.showToast({
					title: '已更新',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('更新失败: ' + error.message, 'error')
				uni.showToast({
					title: '更新失败',
					icon: 'error'
				})
			}
		},
		
		showRecording() {
			try {
				this.addLog('显示录音状态', 'info')
				PiPPlugin.showRecording()
				this.addLog('显示成功', 'success')
				uni.showToast({
					title: '已显示',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('显示失败: ' + error.message, 'error')
				uni.showToast({
					title: '显示失败',
					icon: 'error'
				})
			}
		},
		
		showContent() {
			try {
				this.addLog('显示内容状态', 'info')
				PiPPlugin.showContent()
				this.addLog('显示成功', 'success')
				uni.showToast({
					title: '已显示',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('显示失败: ' + error.message, 'error')
				uni.showToast({
					title: '显示失败',
					icon: 'error'
				})
			}
		},
		
		showLoading() {
			try {
				this.addLog('显示加载状态', 'info')
				PiPPlugin.showLoading()
				this.addLog('显示成功', 'success')
				uni.showToast({
					title: '已显示',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('显示失败: ' + error.message, 'error')
				uni.showToast({
					title: '显示失败',
					icon: 'error'
				})
			}
		},
		
		hideLoading() {
			try {
				this.addLog('隐藏加载状态', 'info')
				PiPPlugin.hiddenLoading()
				this.addLog('隐藏成功', 'success')
				uni.showToast({
					title: '已隐藏',
					icon: 'success'
				})
			} catch (error) {
				this.addLog('隐藏失败: ' + error.message, 'error')
				uni.showToast({
					title: '隐藏失败',
					icon: 'error'
				})
			}
		},
		
		async uploadFile() {
			if (!this.uploadUrl || !this.filePath) {
				uni.showToast({
					title: '请填写上传地址和文件路径',
					icon: 'none'
				})
				return
			}
			
			try {
				this.addLog('开始上传文件...', 'info')
				this.addLog('地址: ' + this.uploadUrl, 'info')
				this.addLog('文件: ' + this.filePath, 'info')
				
				// 在 UniApp 中，static 目录的文件需要转换为实际文件路径
				let filePath = this.filePath;
				
				// #ifdef APP-PLUS
				// 在 App 中，需要将 _www 路径转换为实际文件路径
				if (typeof plus !== 'undefined' && plus.io) {
					if (filePath.startsWith('/static/')) {
						filePath = plus.io.convertLocalFileSystemURL('_www' + filePath);
						this.addLog('转换后路径: ' + filePath, 'info')
					}
				} else {
					this.addLog('⚠️ plus.io 不可用，使用原始路径', 'info')
				}
				// #endif
				
				// 验证参数
				if (!filePath) {
					throw new Error('文件路径不能为空');
				}
				
				// 验证插件方法是否存在
				if (!PiPPlugin || typeof PiPPlugin.uploadFile !== 'function') {
					throw new Error('PiPPlugin.uploadFile 方法不存在');
				}
				
				const uploadOptions = {
					url: this.uploadUrl, // 后台接口地址
					filePath: filePath, // 录音文件路径
					name: 'audio', // 文件字段名称，根据后台需求修改
					formData: {
						// 可以传其他的表单数据
						language: 'AUTOandPTP'
					},
					header: {
						'Content-Type': 'multipart/form-data'
					}
				};
				
				this.addLog('📤 上传参数: ' + JSON.stringify(uploadOptions), 'info')
				
				await PiPPlugin.showLoading()
				
				const result = await PiPPlugin.uploadFile(uploadOptions)
				
				await PiPPlugin.hiddenLoading()
				
				// 解析返回的数据（格式：识别文本$^$语言代码）
				if (result && result.data) {
					if (result.data.includes('$^$')) {
						const parts = result.data.split('$^$');
						const text = parts[0];
						const lang = parts[1];
						this.addLog('✅ 上传成功！', 'success');
						this.addLog('📝 识别结果: ' + text, 'success');
						this.addLog('🌐 语言代码: ' + lang, 'info');
						uni.showToast({
							title: '上传成功：' + text.substring(0, 10) + (text.length > 10 ? '...' : ''),
							icon: 'success',
							duration: 3000
						});
					} else {
						this.addLog('✅ 上传成功！', 'success');
						this.addLog('📄 返回数据: ' + result.data, 'info');
						uni.showToast({
							title: '上传成功',
							icon: 'success'
						});
					}
				} else {
					this.addLog('✅ 上传成功！', 'success');
					this.addLog('⚠️ 服务器未返回数据', 'info');
					uni.showToast({
						title: '上传成功（无返回数据）',
						icon: 'success'
					});
				}
				
				// 显示完整的返回结果（用于调试）
				this.addLog('📦 完整结果: ' + JSON.stringify(result), 'info')
			} catch (error) {
				try {
					await PiPPlugin.hiddenLoading()
				} catch (e) {
					// 忽略隐藏加载失败
				}
				this.addLog('上传失败: ' + error.message, 'error')
				uni.showToast({
					title: '上传失败',
					icon: 'error'
				})
			}
		}
	}
}
</script>

<style>
.container {
	padding: 20rpx;
	background-color: #f5f5f5;
	min-height: 100vh;
}

.header {
	text-align: center;
	padding: 30rpx 0;
	background-color: #fff;
	margin-bottom: 20rpx;
	border-radius: 10rpx;
}

.title {
	font-size: 36rpx;
	font-weight: bold;
	color: #333;
}

.content {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
}

.card {
	background-color: #fff;
	border-radius: 10rpx;
	padding: 30rpx;
}

.card-title {
	font-size: 32rpx;
	font-weight: bold;
	color: #333;
	margin-bottom: 20rpx;
	display: block;
}

.status-grid {
	display: flex;
	flex-direction: column;
	gap: 15rpx;
}

.status-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 15rpx;
	background-color: #f8f8f8;
	border-radius: 8rpx;
}

.status-label {
	font-size: 28rpx;
	color: #666;
}

.status-value {
	font-size: 32rpx;
	font-weight: bold;
	color: #f56c6c;
}

.status-value.success {
	color: #67c23a;
}

.button-group {
	display: flex;
	flex-direction: column;
	gap: 15rpx;
}

.btn {
	width: 100%;
	padding: 20rpx;
	background-color: #007aff;
	color: #fff;
	border-radius: 8rpx;
	font-size: 28rpx;
	border: none;
}

.btn-primary {
	background-color: #007aff;
}

.btn-secondary {
	background-color: #909399;
}

.btn-status {
	background-color: #409eff;
}

.btn-upload {
	background-color: #67c23a;
	margin-top: 20rpx;
}

.btn-clear {
	background-color: #f56c6c;
	padding: 10rpx 20rpx;
	font-size: 24rpx;
	border-radius: 6rpx;
	color: #fff;
	border: none;
}

.input-group {
	display: flex;
	flex-direction: column;
	gap: 15rpx;
	margin-bottom: 20rpx;
}

.input {
	width: 100%;
	padding: 20rpx;
	border: 1px solid #dcdfe6;
	border-radius: 8rpx;
	font-size: 28rpx;
	background-color: #fff;
}

.log-header {
	display: flex;
	justify-content: flex-end;
	margin-bottom: 15rpx;
}

.log-container {
	max-height: 500rpx;
	background-color: #1e1e1e;
	border-radius: 8rpx;
	padding: 20rpx;
}

.log-item {
	display: flex;
	flex-direction: column;
	margin-bottom: 15rpx;
	padding-bottom: 15rpx;
	border-bottom: 1px solid #333;
}

.log-item:last-child {
	border-bottom: none;
	margin-bottom: 0;
	padding-bottom: 0;
}

.log-time {
	font-size: 22rpx;
	color: #888;
	margin-bottom: 5rpx;
}

.log-message {
	font-size: 24rpx;
	color: #fff;
	word-break: break-all;
	font-family: monospace;
}

.log-message.success {
	color: #67c23a;
}

.log-message.error {
	color: #f56c6c;
}

.log-message.info {
	color: #409eff;
}
</style>

