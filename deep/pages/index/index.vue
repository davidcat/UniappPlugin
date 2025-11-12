<template>
	<view class="content">
		<image class="logo" src="/static/logo.png"></image>
		<view class="text-area">
			<text class="title">{{title}}</text>
		</view>
		
		<view class="pip-container">
			<text class="section-title">PiPPlugin 测试</text>
			<view class="button-group">
				<button class="test-button" @click="checkSupport">检查支持</button>
				<button class="test-button" @click="showPiP">显示画中画</button>
				<button class="test-button" @click="hidePiP">隐藏画中画</button>
			</view>
			
			<view class="button-group">
				<button class="test-button" @click="updateText">更新文本</button>
				<button class="test-button" @click="showRecordingState">显示录音状态</button>
				<button class="test-button" @click="showContentState">显示内容状态</button>
			</view>
			
			<view class="button-group">
				<button class="test-button" @click="showLoadingState">显示加载状态</button>
				<button class="test-button" @click="testUploadWithLocalFile">测试上传</button>
			</view>
			
			<view class="status-display">
				<text class="status-text" :decode="true">{{statusText}}</text>
			</view>
		</view>
	</view>
</template>

<script>
import PiPPlugin from '@/nativeplugins/PiPPlugin/index.js'

// 添加调试信息
console.log('PiPPlugin loaded:', !!PiPPlugin);
console.log('PiPPlugin methods:', Object.keys(PiPPlugin));
	
	export default {
		data() {
			return {
				title: 'PiPPlugin 测试',
				statusText: '准备就绪'
			}
		},
		methods: {
			// 检查是否支持画中画
			async checkSupport() {
				try {
					console.log('Checking PiP support...');
					
					const supported = await PiPPlugin.isSupported();
					
					console.log('Supported result:', supported);
					// 确保supported是布尔值
					const isSupported = supported === true;
					this.statusText = isSupported ? '设备支持画中画' : '设备不支持画中画';
					uni.showToast({
						title: this.statusText,
						icon: 'none'
					});
				} catch (error) {
					console.error('检查失败:', error);
					this.statusText = '检查失败：' + error.message;
					uni.showToast({
						title: '检查失败',
						icon: 'none'
					});
				}
			},
			
			// 显示画中画
			showPiP() {
				try {
					PiPPlugin.showPictureInPicture({}, (result) => {
						if (result && result.success) {
							console.log('画中画启动成功:', result);
							if (result.logs && result.logs.length > 0) {
								console.log('启动日志:', result.logs);
							}
						} else {
							console.error('画中画启动失败:', result);
						}
					});
					this.statusText = '显示画中画（带回调）';
					uni.showToast({
						title: '显示画中画',
						icon: 'success'
					});
				} catch (error) {
					console.error('显示画中画失败:', error);
					this.statusText = '显示画中画失败：' + error.message;
					uni.showToast({
						title: '显示失败',
						icon: 'none'
					});
				}
			},
			
			// 隐藏画中画
			hidePiP() {
				try {
					PiPPlugin.hidePictureInPicture();
					this.statusText = '隐藏画中画';
					uni.showToast({
						title: '隐藏画中画',
						icon: 'success'
					});
				} catch (error) {
					console.error('隐藏画中画失败:', error);
					this.statusText = '隐藏画中画失败：' + error.message;
					uni.showToast({
						title: '隐藏失败',
						icon: 'none'
					});
				}
			},
			
			// 更新文本
			updateText() {
				try {
					PiPPlugin.updateFirstText('第一行文本');
					PiPPlugin.updateSecondText('第二行文本');
					this.statusText = '更新文本';
					uni.showToast({
						title: '更新文本',
						icon: 'success'
					});
				} catch (error) {
					console.error('更新文本失败:', error);
					this.statusText = '更新文本失败：' + error.message;
					uni.showToast({
						title: '更新失败',
						icon: 'none'
					});
				}
			},
			
			// 显示录音状态
			showRecordingState() {
				try {
					PiPPlugin.showRecording();
					this.statusText = '显示录音状态';
					
					// 模拟录音结束
					setTimeout(() => {
						try {
							PiPPlugin.showContent();
							this.statusText = '录音结束';
						} catch (error) {
							console.error('显示内容失败:', error);
						}
					}, 3000);
					
					uni.showToast({
						title: '显示录音状态',
						icon: 'success'
					});
				} catch (error) {
					console.error('显示录音状态失败:', error);
					this.statusText = '显示录音状态失败：' + error.message;
					uni.showToast({
						title: '显示失败',
						icon: 'none'
					});
				}
			},
			
			// 显示内容状态
			showContentState() {
				try {
					PiPPlugin.updateFirstText('第一行内容');
					PiPPlugin.updateSecondText('第二行内容');
					PiPPlugin.showContent();
					this.statusText = '显示内容状态';
					uni.showToast({
						title: '显示内容状态',
						icon: 'success'
					});
				} catch (error) {
					console.error('显示内容状态失败:', error);
					this.statusText = '显示内容状态失败：' + error.message;
					uni.showToast({
						title: '显示失败',
						icon: 'none'
					});
				}
			},
			
			// 显示加载状态
			showLoadingState() {
				try {
					PiPPlugin.showLoading();
					this.statusText = '显示加载状态';
					
					// 模拟加载完成
					setTimeout(() => {
						try {
							PiPPlugin.hiddenLoading();
							PiPPlugin.updateFirstText('加载完成');
							PiPPlugin.updateSecondText('这是测试结果');
							PiPPlugin.showContent();
							this.statusText = '加载完成，显示内容';
						} catch (error) {
							console.error('加载完成处理失败:', error);
						}
					}, 3000);
					
					uni.showToast({
						title: '显示加载状态',
						icon: 'success'
					});
				} catch (error) {
					console.error('显示加载状态失败:', error);
					this.statusText = '显示加载状态失败：' + error.message;
					uni.showToast({
						title: '显示失败',
						icon: 'none'
					});
				}
			},
			
			// 测试上传本地文件
			async testUploadWithLocalFile() {
				try {
					this.statusText = '开始上传本地文件...';
					
					// 在 UniApp 中，static 目录的文件需要转换为实际文件路径
					// 使用 plus.io API 来获取实际文件路径
					let filePath = '/static/test_audio.mp3';
					
					// #ifdef APP-PLUS
					// 在 App 中，需要将 _www 路径转换为实际文件路径
					if (typeof plus !== 'undefined' && plus.io) {
						if (filePath.startsWith('/static/')) {
							// 方式1: 使用 plus.io.convertLocalFileSystemURL
							filePath = plus.io.convertLocalFileSystemURL('_www' + filePath);
							console.log('转换后的文件路径:', filePath);
						}
					} else {
						console.warn('plus.io 不可用，使用原始路径');
					}
					// #endif
					
					// 验证参数
					if (!filePath) {
						throw new Error('文件路径不能为空');
					}
					
				const options = {
					url: 'http://14.103.175.207:5000/upload', // 后台接口地址
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
					
					this.statusText = '正在上传本地文件...';
					console.log('上传参数:', JSON.stringify(options, null, 2));
					console.log('上传文件路径:', filePath);
					
					// 验证插件方法是否存在
					if (!PiPPlugin || typeof PiPPlugin.uploadFile !== 'function') {
						throw new Error('PiPPlugin.uploadFile 方法不存在');
					}
					
					const result = await PiPPlugin.uploadFile(options);
					
					console.log('Upload result:', result);
					
					// 解析返回的数据
					if (result && result.data) {
						if (result.data.includes('$^$')) {
							const parts = result.data.split('$^$');
							const text = parts[0];
							const lang = parts[1];
							this.statusText = `上传成功！\n识别结果: ${text}\n语言: ${lang}`;
							console.log('识别结果:', text, '语言:', lang);
							uni.showToast({
								title: '上传成功',
								icon: 'success',
								duration: 3000
							});
						} else {
							this.statusText = `上传成功！\n返回数据: ${result.data}`;
							console.log('返回数据:', result.data);
							uni.showToast({
								title: '上传成功',
								icon: 'success'
							});
						}
					} else {
						this.statusText = '上传成功！\n但服务器未返回数据';
						console.warn('上传成功但没有返回数据:', result);
						uni.showToast({
							title: '上传成功（无返回数据）',
							icon: 'success'
						});
					}
				} catch (error) {
					console.error('上传失败:', error);
					this.statusText = '上传失败：' + error.message;
					uni.showToast({
						title: '上传失败',
						icon: 'none'
					});
				}
			}
		}
	}
</script>

<style>
	.content {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 20px;
	}
	
	.logo {
		height: 200rpx;
		width: 200rpx;
		margin: 20rpx auto 40rpx auto;
	}
	
	.text-area {
		display: flex;
		justify-content: center;
		margin-bottom: 40rpx;
	}
	
	.title {
		font-size: 36rpx;
		color: #8f8f94;
	}
	
	.pip-container {
		width: 100%;
	}
	
	.section-title {
		font-size: 32rpx;
		font-weight: bold;
		margin-bottom: 20rpx;
		text-align: center;
	}
	
	.button-group {
		display: flex;
		justify-content: space-between;
		margin-bottom: 20rpx;
	}
	
	.test-button {
		flex: 1;
		margin: 0 10rpx;
		padding: 20rpx;
		font-size: 28rpx;
		background-color: #007AFF;
		color: white;
		border-radius: 10rpx;
		border: none;
	}
	
	.status-display {
		margin-top: 30rpx;
		padding: 20rpx;
		background-color: #f0f0f0;
		border-radius: 10rpx;
	}
	
	.status-text {
		font-size: 28rpx;
		color: #333;
		word-wrap: break-word;
		white-space: pre-wrap;
		line-height: 1.6;
	}
</style>