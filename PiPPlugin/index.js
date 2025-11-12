/**
 * PictureInPictureModule - UniApp iOS 原生插件
 * 提供画中画（PiP）功能
 * 
 * @module PictureInPictureModule
 */

// UniApp 官方规定：uni.requireNativePlugin 的参数是插件的 ID（package.json 中的 id 字段）
// 根据配置：package.json 中 id 为 "PiPPlugin"，manifest.json 中 nativePlugins 的 key 也是 "PiPPlugin"
// 因此应该使用插件 ID：'PiPPlugin'
const PictureInPictureModule = uni.requireNativePlugin('PiPPlugin');

/**
 * 检查是否支持画中画
 * @returns {Promise<boolean>} 是否支持 PiP
 * @example
 * const supported = await PictureInPicture.isSupported();
 * console.log('PiP supported:', supported);
 */
function isSupported() {
  return new Promise((resolve, reject) => {
    if (!PictureInPictureModule) {
      reject(new Error('PictureInPictureModule not found'));
      return;
    }
    
    PictureInPictureModule.isSupported((result) => {
      if (result && result.success) {
        resolve(result.data === true);
      } else {
        reject(new Error(result?.message || 'Unknown error'));
      }
    });
  });
}

/**
 * 显示画中画
 * @param {Object} options - 可选参数
 * @param {Function} callback - 可选回调函数，返回执行状态和日志
 * @example
 * PictureInPicture.showPictureInPicture();
 * // 或带回调
 * PictureInPicture.showPictureInPicture({}, (result) => {
 *   console.log('Result:', result);
 * });
 */
function showPictureInPicture(options = {}, callback) {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    if (callback) {
      callback({ success: false, message: 'PictureInPictureModule not found' });
    }
    return;
  }
  
  if (callback && typeof callback === 'function') {
    // 如果有回调，使用带回调的调用方式
    PictureInPictureModule.showPictureInPicture(options, callback);
  } else {
    // 无回调的简单调用
    PictureInPictureModule.showPictureInPicture(options);
  }
}

/**
 * 隐藏画中画
 * @example
 * PictureInPicture.hidePictureInPicture();
 */
function hidePictureInPicture() {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.hidePictureInPicture({});
}

/**
 * 更新第一行文本
 * @param {string} text - 文本内容
 * @example
 * PictureInPicture.updateFirstText('第一行文本内容');
 */
function updateFirstText(text) {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.updateFirstText({ text: text || '' });
}

/**
 * 更新第二行文本
 * @param {string} text - 文本内容
 * @example
 * PictureInPicture.updateSecondText('第二行文本内容');
 */
function updateSecondText(text) {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.updateSecondText({ text: text || '' });
}

/**
 * 更新提示文本
 * @param {string} text - 提示文本
 * @example
 * PictureInPicture.updateTipText('按住说话');
 */
function updateTipText(text) {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.updateTipText({ text: text || '' });
}

/**
 * 显示录音状态
 * @example
 * PictureInPicture.showRecording();
 */
function showRecording() {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.showRecording({});
}

/**
 * 显示内容状态
 * @example
 * PictureInPicture.showContent();
 */
function showContent() {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.showContent({});
}

/**
 * 显示加载状态
 * @example
 * PictureInPicture.showLoading();
 */
function showLoading() {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.showLoading({});
}

/**
 * 隐藏加载状态
 * @example
 * PictureInPicture.hiddenLoading();
 */
function hiddenLoading() {
  if (!PictureInPictureModule) {
    console.error('PictureInPictureModule not found');
    return;
  }
  PictureInPictureModule.hiddenLoading({});
}

/**
 * 上传文件（单文件上传）
 * @param {Object} options - 上传参数配置
 * @param {string} options.url - 上传接口地址（必填）
 * @param {string} options.filePath - 文件路径（必填）
 * @param {string} [options.name='file'] - 文件字段名，默认为 "file"
 * @param {Object} [options.formData={}] - 额外的表单数据
 * @param {Object} [options.header={}] - 自定义请求头
 * @param {string} [options.method='POST'] - HTTP 请求方法，默认为 "POST"
 * @param {number} [options.timeout=60] - 超时时间（秒），默认为 60
 * @returns {Promise<Object>} 上传结果
 * @example
 * const result = await PictureInPicture.uploadFile({
 *   url: 'http://example.com/upload',
 *   filePath: '/path/to/file.mp3',
 *   name: 'audio',
 *   formData: { language: 'AUTOandPTP' },
 *   timeout: 60
 * });
 */
function uploadFile(options) {
  return new Promise((resolve, reject) => {
    if (!PictureInPictureModule) {
      reject(new Error('PictureInPictureModule not found'));
      return;
    }
    
    // 参数验证
    if (!options || !options.url || !options.filePath) {
      reject(new Error('url and filePath are required'));
      return;
    }
    
    // 调用原生方法
    PictureInPictureModule.uploadFile(options, (result, keepAlive) => {
      if (result && result.success) {
        resolve(result);
      } else {
        reject(new Error(result?.errMsg || 'Upload failed'));
      }
    });
  });
}

/**
 * 获取插件版本号
 * @returns {Promise<string>} 插件版本号
 * @example
 * const version = await PictureInPicture.getVersion();
 * console.log('Plugin version:', version);
 */
function getVersion() {
  return new Promise((resolve, reject) => {
    if (!PictureInPictureModule) {
      reject(new Error('PictureInPictureModule not found'));
      return;
    }
    
    PictureInPictureModule.getVersion((result) => {
      if (result && result.success) {
        resolve(result.version);
      } else {
        reject(new Error(result?.errMsg || 'Failed to get version'));
      }
    });
  });
}

export default {
  isSupported,
  showPictureInPicture,
  hidePictureInPicture,
  updateFirstText,
  updateSecondText,
  updateTipText,
  showRecording,
  showContent,
  showLoading,
  hiddenLoading,
  uploadFile,
  getVersion
};

