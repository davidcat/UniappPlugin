if (typeof Promise !== "undefined" && !Promise.prototype.finally) {
  Promise.prototype.finally = function(callback) {
    const promise = this.constructor;
    return this.then(
      (value) => promise.resolve(callback()).then(() => value),
      (reason) => promise.resolve(callback()).then(() => {
        throw reason;
      })
    );
  };
}
;
if (typeof uni !== "undefined" && uni && uni.requireGlobal) {
  const global = uni.requireGlobal();
  ArrayBuffer = global.ArrayBuffer;
  Int8Array = global.Int8Array;
  Uint8Array = global.Uint8Array;
  Uint8ClampedArray = global.Uint8ClampedArray;
  Int16Array = global.Int16Array;
  Uint16Array = global.Uint16Array;
  Int32Array = global.Int32Array;
  Uint32Array = global.Uint32Array;
  Float32Array = global.Float32Array;
  Float64Array = global.Float64Array;
  BigInt64Array = global.BigInt64Array;
  BigUint64Array = global.BigUint64Array;
}
;
if (uni.restoreGlobal) {
  uni.restoreGlobal(Vue, weex, plus, setTimeout, clearTimeout, setInterval, clearInterval);
}
(function(vue) {
  "use strict";
  function requireNativePlugin(name) {
    return weex.requireModule(name);
  }
  function formatAppLog(type, filename, ...args) {
    if (uni.__log__) {
      uni.__log__(type, filename, ...args);
    } else {
      console[type].apply(console, [...args, filename]);
    }
  }
  const PictureInPictureModule = requireNativePlugin("PiPPlugin");
  function isSupported() {
    return new Promise((resolve, reject) => {
      if (!PictureInPictureModule) {
        reject(new Error("PictureInPictureModule not found"));
        return;
      }
      PictureInPictureModule.isSupported((result) => {
        if (result && result.success) {
          resolve(result.data === true);
        } else {
          reject(new Error((result == null ? void 0 : result.message) || "Unknown error"));
        }
      });
    });
  }
  function showPictureInPicture(options = {}, callback) {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:50", "PictureInPictureModule not found");
      if (callback) {
        callback({ success: false, message: "PictureInPictureModule not found" });
      }
      return;
    }
    if (callback && typeof callback === "function") {
      PictureInPictureModule.showPictureInPicture(options, callback);
    } else {
      PictureInPictureModule.showPictureInPicture(options);
    }
  }
  function hidePictureInPicture() {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:73", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.hidePictureInPicture({});
  }
  function updateFirstText(text) {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:87", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.updateFirstText({ text: text || "" });
  }
  function updateSecondText(text) {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:101", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.updateSecondText({ text: text || "" });
  }
  function updateTipText(text) {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:115", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.updateTipText({ text: text || "" });
  }
  function showRecording() {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:128", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.showRecording({});
  }
  function showContent() {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:141", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.showContent({});
  }
  function showLoading() {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:154", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.showLoading({});
  }
  function hiddenLoading() {
    if (!PictureInPictureModule) {
      formatAppLog("error", "at nativeplugins/PiPPlugin/index.js:167", "PictureInPictureModule not found");
      return;
    }
    PictureInPictureModule.hiddenLoading({});
  }
  function uploadFile(options) {
    return new Promise((resolve, reject) => {
      if (!PictureInPictureModule) {
        reject(new Error("PictureInPictureModule not found"));
        return;
      }
      if (!options || !options.url || !options.filePath) {
        reject(new Error("url and filePath are required"));
        return;
      }
      PictureInPictureModule.uploadFile(options, (result, keepAlive) => {
        if (result && result.success) {
          resolve(result);
        } else {
          reject(new Error((result == null ? void 0 : result.errMsg) || "Upload failed"));
        }
      });
    });
  }
  const PiPPlugin = {
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
    uploadFile
  };
  const _imports_0 = "/static/logo.png";
  const _export_sfc = (sfc, props) => {
    const target = sfc.__vccOpts || sfc;
    for (const [key, val] of props) {
      target[key] = val;
    }
    return target;
  };
  formatAppLog("log", "at pages/index/index.vue:38", "PiPPlugin loaded:", !!PiPPlugin);
  formatAppLog("log", "at pages/index/index.vue:39", "PiPPlugin methods:", Object.keys(PiPPlugin));
  const _sfc_main$2 = {
    data() {
      return {
        title: "PiPPlugin 测试",
        statusText: "准备就绪"
      };
    },
    methods: {
      // 检查是否支持画中画
      async checkSupport() {
        try {
          formatAppLog("log", "at pages/index/index.vue:52", "Checking PiP support...");
          const supported = await PiPPlugin.isSupported();
          formatAppLog("log", "at pages/index/index.vue:56", "Supported result:", supported);
          const isSupported2 = supported === true;
          this.statusText = isSupported2 ? "设备支持画中画" : "设备不支持画中画";
          uni.showToast({
            title: this.statusText,
            icon: "none"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:65", "检查失败:", error);
          this.statusText = "检查失败：" + error.message;
          uni.showToast({
            title: "检查失败",
            icon: "none"
          });
        }
      },
      // 显示画中画
      showPiP() {
        try {
          PiPPlugin.showPictureInPicture({}, (result) => {
            if (result && result.success) {
              formatAppLog("log", "at pages/index/index.vue:79", "画中画启动成功:", result);
              if (result.logs && result.logs.length > 0) {
                formatAppLog("log", "at pages/index/index.vue:81", "启动日志:", result.logs);
              }
            } else {
              formatAppLog("error", "at pages/index/index.vue:84", "画中画启动失败:", result);
            }
          });
          this.statusText = "显示画中画（带回调）";
          uni.showToast({
            title: "显示画中画",
            icon: "success"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:93", "显示画中画失败:", error);
          this.statusText = "显示画中画失败：" + error.message;
          uni.showToast({
            title: "显示失败",
            icon: "none"
          });
        }
      },
      // 隐藏画中画
      hidePiP() {
        try {
          PiPPlugin.hidePictureInPicture();
          this.statusText = "隐藏画中画";
          uni.showToast({
            title: "隐藏画中画",
            icon: "success"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:112", "隐藏画中画失败:", error);
          this.statusText = "隐藏画中画失败：" + error.message;
          uni.showToast({
            title: "隐藏失败",
            icon: "none"
          });
        }
      },
      // 更新文本
      updateText() {
        try {
          PiPPlugin.updateFirstText("第一行文本");
          PiPPlugin.updateSecondText("第二行文本");
          this.statusText = "更新文本";
          uni.showToast({
            title: "更新文本",
            icon: "success"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:132", "更新文本失败:", error);
          this.statusText = "更新文本失败：" + error.message;
          uni.showToast({
            title: "更新失败",
            icon: "none"
          });
        }
      },
      // 显示录音状态
      showRecordingState() {
        try {
          PiPPlugin.showRecording();
          this.statusText = "显示录音状态";
          setTimeout(() => {
            try {
              PiPPlugin.showContent();
              this.statusText = "录音结束";
            } catch (error) {
              formatAppLog("error", "at pages/index/index.vue:153", "显示内容失败:", error);
            }
          }, 3e3);
          uni.showToast({
            title: "显示录音状态",
            icon: "success"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:162", "显示录音状态失败:", error);
          this.statusText = "显示录音状态失败：" + error.message;
          uni.showToast({
            title: "显示失败",
            icon: "none"
          });
        }
      },
      // 显示内容状态
      showContentState() {
        try {
          PiPPlugin.updateFirstText("第一行内容");
          PiPPlugin.updateSecondText("第二行内容");
          PiPPlugin.showContent();
          this.statusText = "显示内容状态";
          uni.showToast({
            title: "显示内容状态",
            icon: "success"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:183", "显示内容状态失败:", error);
          this.statusText = "显示内容状态失败：" + error.message;
          uni.showToast({
            title: "显示失败",
            icon: "none"
          });
        }
      },
      // 显示加载状态
      showLoadingState() {
        try {
          PiPPlugin.showLoading();
          this.statusText = "显示加载状态";
          setTimeout(() => {
            try {
              PiPPlugin.hiddenLoading();
              PiPPlugin.updateFirstText("加载完成");
              PiPPlugin.updateSecondText("这是测试结果");
              PiPPlugin.showContent();
              this.statusText = "加载完成，显示内容";
            } catch (error) {
              formatAppLog("error", "at pages/index/index.vue:207", "加载完成处理失败:", error);
            }
          }, 3e3);
          uni.showToast({
            title: "显示加载状态",
            icon: "success"
          });
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:216", "显示加载状态失败:", error);
          this.statusText = "显示加载状态失败：" + error.message;
          uni.showToast({
            title: "显示失败",
            icon: "none"
          });
        }
      },
      // 测试上传本地文件
      async testUploadWithLocalFile() {
        try {
          this.statusText = "开始上传本地文件...";
          let filePath = "/static/test_audio.mp3";
          if (typeof plus !== "undefined" && plus.io) {
            if (filePath.startsWith("/static/")) {
              filePath = plus.io.convertLocalFileSystemURL("_www" + filePath);
              formatAppLog("log", "at pages/index/index.vue:240", "转换后的文件路径:", filePath);
            }
          } else {
            formatAppLog("warn", "at pages/index/index.vue:243", "plus.io 不可用，使用原始路径");
          }
          if (!filePath) {
            throw new Error("文件路径不能为空");
          }
          const options = {
            url: "http://14.103.175.207:5000/upload",
            // 后台接口地址
            filePath,
            // 录音文件路径
            name: "audio",
            // 文件字段名称，根据后台需求修改
            formData: {
              // 可以传其他的表单数据
              language: "AUTOandPTP"
            },
            header: {
              "Content-Type": "multipart/form-data"
            }
          };
          this.statusText = "正在上传本地文件...";
          formatAppLog("log", "at pages/index/index.vue:266", "上传参数:", JSON.stringify(options, null, 2));
          formatAppLog("log", "at pages/index/index.vue:267", "上传文件路径:", filePath);
          if (!PiPPlugin || typeof PiPPlugin.uploadFile !== "function") {
            throw new Error("PiPPlugin.uploadFile 方法不存在");
          }
          const result = await PiPPlugin.uploadFile(options);
          formatAppLog("log", "at pages/index/index.vue:276", "Upload result:", result);
          if (result && result.data) {
            if (result.data.includes("$^$")) {
              const parts = result.data.split("$^$");
              const text = parts[0];
              const lang = parts[1];
              this.statusText = `上传成功！
识别结果: ${text}
语言: ${lang}`;
              formatAppLog("log", "at pages/index/index.vue:285", "识别结果:", text, "语言:", lang);
              uni.showToast({
                title: "上传成功",
                icon: "success",
                duration: 3e3
              });
            } else {
              this.statusText = `上传成功！
返回数据: ${result.data}`;
              formatAppLog("log", "at pages/index/index.vue:293", "返回数据:", result.data);
              uni.showToast({
                title: "上传成功",
                icon: "success"
              });
            }
          } else {
            this.statusText = "上传成功！\n但服务器未返回数据";
            formatAppLog("warn", "at pages/index/index.vue:301", "上传成功但没有返回数据:", result);
            uni.showToast({
              title: "上传成功（无返回数据）",
              icon: "success"
            });
          }
        } catch (error) {
          formatAppLog("error", "at pages/index/index.vue:308", "上传失败:", error);
          this.statusText = "上传失败：" + error.message;
          uni.showToast({
            title: "上传失败",
            icon: "none"
          });
        }
      }
    }
  };
  function _sfc_render$1(_ctx, _cache, $props, $setup, $data, $options) {
    return vue.openBlock(), vue.createElementBlock("view", { class: "content" }, [
      vue.createElementVNode("image", {
        class: "logo",
        src: _imports_0
      }),
      vue.createElementVNode("view", { class: "text-area" }, [
        vue.createElementVNode(
          "text",
          { class: "title" },
          vue.toDisplayString($data.title),
          1
          /* TEXT */
        )
      ]),
      vue.createElementVNode("view", { class: "pip-container" }, [
        vue.createElementVNode("text", { class: "section-title" }, "PiPPlugin 测试"),
        vue.createElementVNode("view", { class: "button-group" }, [
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[0] || (_cache[0] = (...args) => $options.checkSupport && $options.checkSupport(...args))
          }, "检查支持"),
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[1] || (_cache[1] = (...args) => $options.showPiP && $options.showPiP(...args))
          }, "显示画中画"),
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[2] || (_cache[2] = (...args) => $options.hidePiP && $options.hidePiP(...args))
          }, "隐藏画中画")
        ]),
        vue.createElementVNode("view", { class: "button-group" }, [
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[3] || (_cache[3] = (...args) => $options.updateText && $options.updateText(...args))
          }, "更新文本"),
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[4] || (_cache[4] = (...args) => $options.showRecordingState && $options.showRecordingState(...args))
          }, "显示录音状态"),
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[5] || (_cache[5] = (...args) => $options.showContentState && $options.showContentState(...args))
          }, "显示内容状态")
        ]),
        vue.createElementVNode("view", { class: "button-group" }, [
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[6] || (_cache[6] = (...args) => $options.showLoadingState && $options.showLoadingState(...args))
          }, "显示加载状态"),
          vue.createElementVNode("button", {
            class: "test-button",
            onClick: _cache[7] || (_cache[7] = (...args) => $options.testUploadWithLocalFile && $options.testUploadWithLocalFile(...args))
          }, "测试上传")
        ]),
        vue.createElementVNode("view", { class: "status-display" }, [
          vue.createElementVNode(
            "text",
            {
              class: "status-text",
              decode: true
            },
            vue.toDisplayString($data.statusText),
            1
            /* TEXT */
          )
        ])
      ])
    ]);
  }
  const PagesIndexIndex = /* @__PURE__ */ _export_sfc(_sfc_main$2, [["render", _sfc_render$1], ["__file", "/Users/wang/Desktop/1108/1111/上传/deep/pages/index/index.vue"]]);
  const _sfc_main$1 = {
    data() {
      return {
        pluginStatus: {
          available: false,
          loaded: false
        },
        deviceSupported: null,
        firstText: "第一行文本",
        secondText: "第二行文本",
        tipText: "提示信息",
        uploadUrl: "http://14.103.175.207:5000/upload",
        filePath: "/static/test_audio.mp3",
        logs: [],
        scrollTop: 0
      };
    },
    onLoad() {
      this.initPlugin();
    },
    methods: {
      async initPlugin() {
        try {
          this.pluginStatus.available = !!PiPPlugin;
          this.pluginStatus.loaded = typeof PiPPlugin === "object" && PiPPlugin !== null;
          try {
            this.deviceSupported = await PiPPlugin.isSupported();
            this.addLog("设备支持画中画: " + (this.deviceSupported ? "是" : "否"), this.deviceSupported ? "success" : "error");
          } catch (error) {
            this.addLog("检查设备支持失败: " + error.message, "error");
          }
          this.addLog("插件初始化成功", "success");
          this.addLog("插件状态: " + JSON.stringify(this.pluginStatus), "info");
        } catch (error) {
          this.addLog("插件初始化失败: " + error.message, "error");
        }
      },
      addLog(message, type = "info") {
        const timestamp = (/* @__PURE__ */ new Date()).toLocaleTimeString();
        this.logs.unshift({
          time: timestamp,
          message,
          type
        });
        if (this.logs.length > 100) {
          this.logs.pop();
        }
        this.$nextTick(() => {
          this.scrollTop = 0;
        });
      },
      clearLogs() {
        this.logs = [];
        uni.showToast({
          title: "日志已清空",
          icon: "success"
        });
      },
      async quickStart() {
        try {
          this.addLog("快速启动画中画...", "info");
          const supported = await PiPPlugin.isSupported();
          if (!supported) {
            this.addLog("设备不支持画中画", "error");
            uni.showToast({
              title: "设备不支持",
              icon: "none"
            });
            return;
          }
          PiPPlugin.showPictureInPicture({}, (result) => {
            if (result && result.success) {
              this.addLog("画中画启动成功", "success");
              if (result.logs && result.logs.length > 0) {
                this.addLog("启动日志: " + result.logs.join("; "), "info");
              }
            } else {
              this.addLog("画中画启动失败: " + ((result == null ? void 0 : result.message) || "未知错误"), "error");
            }
          });
          PiPPlugin.updateFirstText(this.firstText);
          PiPPlugin.updateSecondText(this.secondText);
          PiPPlugin.updateTipText(this.tipText);
          PiPPlugin.showContent();
          uni.showToast({
            title: "启动中...",
            icon: "success"
          });
        } catch (error) {
          this.addLog("启动失败: " + error.message, "error");
          uni.showToast({
            title: "启动失败",
            icon: "error"
          });
        }
      },
      quickStop() {
        try {
          this.addLog("停止画中画...", "info");
          PiPPlugin.hidePictureInPicture();
          this.addLog("画中画已停止", "success");
          uni.showToast({
            title: "已停止",
            icon: "success"
          });
        } catch (error) {
          this.addLog("停止失败: " + error.message, "error");
          uni.showToast({
            title: "停止失败",
            icon: "error"
          });
        }
      },
      async checkSupport() {
        try {
          this.addLog("检查设备支持...", "info");
          const supported = await PiPPlugin.isSupported();
          this.deviceSupported = supported;
          this.addLog("设备支持: " + (supported ? "是" : "否"), supported ? "success" : "error");
          uni.showToast({
            title: supported ? "支持" : "不支持",
            icon: supported ? "success" : "none"
          });
        } catch (error) {
          this.addLog("检查失败: " + error.message, "error");
          uni.showToast({
            title: "检查失败",
            icon: "error"
          });
        }
      },
      showPiP() {
        try {
          this.addLog("显示画中画...", "info");
          PiPPlugin.showPictureInPicture({}, (result) => {
            if (result && result.success) {
              this.addLog("显示成功", "success");
              if (result.logs && result.logs.length > 0) {
                this.addLog("日志: " + result.logs.join("; "), "info");
              }
            } else {
              this.addLog("显示失败: " + ((result == null ? void 0 : result.message) || "未知错误"), "error");
            }
          });
          uni.showToast({
            title: "显示中...",
            icon: "success"
          });
        } catch (error) {
          this.addLog("显示失败: " + error.message, "error");
          uni.showToast({
            title: "显示失败",
            icon: "error"
          });
        }
      },
      hidePiP() {
        try {
          this.addLog("隐藏画中画...", "info");
          PiPPlugin.hidePictureInPicture();
          this.addLog("隐藏成功", "success");
          uni.showToast({
            title: "已隐藏",
            icon: "success"
          });
        } catch (error) {
          this.addLog("隐藏失败: " + error.message, "error");
          uni.showToast({
            title: "隐藏失败",
            icon: "error"
          });
        }
      },
      updateAllTexts() {
        try {
          this.addLog("更新所有文本...", "info");
          PiPPlugin.updateFirstText(this.firstText);
          PiPPlugin.updateSecondText(this.secondText);
          PiPPlugin.updateTipText(this.tipText);
          this.addLog("所有文本已更新", "success");
          uni.showToast({
            title: "已更新",
            icon: "success"
          });
        } catch (error) {
          this.addLog("更新失败: " + error.message, "error");
          uni.showToast({
            title: "更新失败",
            icon: "error"
          });
        }
      },
      updateFirstText() {
        try {
          this.addLog("更新第一行: " + this.firstText, "info");
          PiPPlugin.updateFirstText(this.firstText);
          this.addLog("更新成功", "success");
          uni.showToast({
            title: "已更新",
            icon: "success"
          });
        } catch (error) {
          this.addLog("更新失败: " + error.message, "error");
          uni.showToast({
            title: "更新失败",
            icon: "error"
          });
        }
      },
      updateSecondText() {
        try {
          this.addLog("更新第二行: " + this.secondText, "info");
          PiPPlugin.updateSecondText(this.secondText);
          this.addLog("更新成功", "success");
          uni.showToast({
            title: "已更新",
            icon: "success"
          });
        } catch (error) {
          this.addLog("更新失败: " + error.message, "error");
          uni.showToast({
            title: "更新失败",
            icon: "error"
          });
        }
      },
      updateTipText() {
        try {
          this.addLog("更新提示: " + this.tipText, "info");
          PiPPlugin.updateTipText(this.tipText);
          this.addLog("更新成功", "success");
          uni.showToast({
            title: "已更新",
            icon: "success"
          });
        } catch (error) {
          this.addLog("更新失败: " + error.message, "error");
          uni.showToast({
            title: "更新失败",
            icon: "error"
          });
        }
      },
      showRecording() {
        try {
          this.addLog("显示录音状态", "info");
          PiPPlugin.showRecording();
          this.addLog("显示成功", "success");
          uni.showToast({
            title: "已显示",
            icon: "success"
          });
        } catch (error) {
          this.addLog("显示失败: " + error.message, "error");
          uni.showToast({
            title: "显示失败",
            icon: "error"
          });
        }
      },
      showContent() {
        try {
          this.addLog("显示内容状态", "info");
          PiPPlugin.showContent();
          this.addLog("显示成功", "success");
          uni.showToast({
            title: "已显示",
            icon: "success"
          });
        } catch (error) {
          this.addLog("显示失败: " + error.message, "error");
          uni.showToast({
            title: "显示失败",
            icon: "error"
          });
        }
      },
      showLoading() {
        try {
          this.addLog("显示加载状态", "info");
          PiPPlugin.showLoading();
          this.addLog("显示成功", "success");
          uni.showToast({
            title: "已显示",
            icon: "success"
          });
        } catch (error) {
          this.addLog("显示失败: " + error.message, "error");
          uni.showToast({
            title: "显示失败",
            icon: "error"
          });
        }
      },
      hideLoading() {
        try {
          this.addLog("隐藏加载状态", "info");
          PiPPlugin.hiddenLoading();
          this.addLog("隐藏成功", "success");
          uni.showToast({
            title: "已隐藏",
            icon: "success"
          });
        } catch (error) {
          this.addLog("隐藏失败: " + error.message, "error");
          uni.showToast({
            title: "隐藏失败",
            icon: "error"
          });
        }
      },
      async uploadFile() {
        if (!this.uploadUrl || !this.filePath) {
          uni.showToast({
            title: "请填写上传地址和文件路径",
            icon: "none"
          });
          return;
        }
        try {
          this.addLog("开始上传文件...", "info");
          this.addLog("地址: " + this.uploadUrl, "info");
          this.addLog("文件: " + this.filePath, "info");
          let filePath = this.filePath;
          if (typeof plus !== "undefined" && plus.io) {
            if (filePath.startsWith("/static/")) {
              filePath = plus.io.convertLocalFileSystemURL("_www" + filePath);
              this.addLog("转换后路径: " + filePath, "info");
            }
          } else {
            this.addLog("⚠️ plus.io 不可用，使用原始路径", "info");
          }
          if (!filePath) {
            throw new Error("文件路径不能为空");
          }
          if (!PiPPlugin || typeof PiPPlugin.uploadFile !== "function") {
            throw new Error("PiPPlugin.uploadFile 方法不存在");
          }
          const uploadOptions = {
            url: this.uploadUrl,
            // 后台接口地址
            filePath,
            // 录音文件路径
            name: "audio",
            // 文件字段名称，根据后台需求修改
            formData: {
              // 可以传其他的表单数据
              language: "AUTOandPTP"
            },
            header: {
              "Content-Type": "multipart/form-data"
            }
          };
          this.addLog("📤 上传参数: " + JSON.stringify(uploadOptions), "info");
          await PiPPlugin.showLoading();
          const result = await PiPPlugin.uploadFile(uploadOptions);
          await PiPPlugin.hiddenLoading();
          if (result && result.data) {
            if (result.data.includes("$^$")) {
              const parts = result.data.split("$^$");
              const text = parts[0];
              const lang = parts[1];
              this.addLog("✅ 上传成功！", "success");
              this.addLog("📝 识别结果: " + text, "success");
              this.addLog("🌐 语言代码: " + lang, "info");
              uni.showToast({
                title: "上传成功：" + text.substring(0, 10) + (text.length > 10 ? "..." : ""),
                icon: "success",
                duration: 3e3
              });
            } else {
              this.addLog("✅ 上传成功！", "success");
              this.addLog("📄 返回数据: " + result.data, "info");
              uni.showToast({
                title: "上传成功",
                icon: "success"
              });
            }
          } else {
            this.addLog("✅ 上传成功！", "success");
            this.addLog("⚠️ 服务器未返回数据", "info");
            uni.showToast({
              title: "上传成功（无返回数据）",
              icon: "success"
            });
          }
          this.addLog("📦 完整结果: " + JSON.stringify(result), "info");
        } catch (error) {
          try {
            await PiPPlugin.hiddenLoading();
          } catch (e) {
          }
          this.addLog("上传失败: " + error.message, "error");
          uni.showToast({
            title: "上传失败",
            icon: "error"
          });
        }
      }
    }
  };
  function _sfc_render(_ctx, _cache, $props, $setup, $data, $options) {
    return vue.openBlock(), vue.createElementBlock("view", { class: "container" }, [
      vue.createElementVNode("view", { class: "header" }, [
        vue.createElementVNode("text", { class: "title" }, "PiPPlugin 完整测试")
      ]),
      vue.createElementVNode("view", { class: "content" }, [
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "插件状态"),
          vue.createElementVNode("view", { class: "status-grid" }, [
            vue.createElementVNode("view", { class: "status-item" }, [
              vue.createElementVNode("text", { class: "status-label" }, "可用:"),
              vue.createElementVNode(
                "text",
                {
                  class: vue.normalizeClass(["status-value", { success: $data.pluginStatus.available }])
                },
                vue.toDisplayString($data.pluginStatus.available ? "✓" : "✗"),
                3
                /* TEXT, CLASS */
              )
            ]),
            vue.createElementVNode("view", { class: "status-item" }, [
              vue.createElementVNode("text", { class: "status-label" }, "已加载:"),
              vue.createElementVNode(
                "text",
                {
                  class: vue.normalizeClass(["status-value", { success: $data.pluginStatus.loaded }])
                },
                vue.toDisplayString($data.pluginStatus.loaded ? "✓" : "✗"),
                3
                /* TEXT, CLASS */
              )
            ]),
            vue.createElementVNode("view", { class: "status-item" }, [
              vue.createElementVNode("text", { class: "status-label" }, "设备支持:"),
              vue.createElementVNode(
                "text",
                {
                  class: vue.normalizeClass(["status-value", { success: $data.deviceSupported === true }])
                },
                vue.toDisplayString($data.deviceSupported === null ? "?" : $data.deviceSupported ? "✓" : "✗"),
                3
                /* TEXT, CLASS */
              )
            ])
          ])
        ]),
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "快速操作"),
          vue.createElementVNode("view", { class: "button-group" }, [
            vue.createElementVNode("button", {
              class: "btn-primary",
              onClick: _cache[0] || (_cache[0] = (...args) => $options.quickStart && $options.quickStart(...args))
            }, "快速启动"),
            vue.createElementVNode("button", {
              class: "btn-secondary",
              onClick: _cache[1] || (_cache[1] = (...args) => $options.quickStop && $options.quickStop(...args))
            }, "快速停止")
          ])
        ]),
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "画中画控制"),
          vue.createElementVNode("view", { class: "button-group" }, [
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[2] || (_cache[2] = (...args) => $options.checkSupport && $options.checkSupport(...args))
            }, "检查支持"),
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[3] || (_cache[3] = (...args) => $options.showPiP && $options.showPiP(...args))
            }, "显示画中画"),
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[4] || (_cache[4] = (...args) => $options.hidePiP && $options.hidePiP(...args))
            }, "隐藏画中画")
          ])
        ]),
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "文本更新"),
          vue.createElementVNode("view", { class: "input-group" }, [
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "input",
                "onUpdate:modelValue": _cache[5] || (_cache[5] = ($event) => $data.firstText = $event),
                placeholder: "第一行文本"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.firstText]
            ]),
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "input",
                "onUpdate:modelValue": _cache[6] || (_cache[6] = ($event) => $data.secondText = $event),
                placeholder: "第二行文本"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.secondText]
            ]),
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "input",
                "onUpdate:modelValue": _cache[7] || (_cache[7] = ($event) => $data.tipText = $event),
                placeholder: "提示文本"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.tipText]
            ])
          ]),
          vue.createElementVNode("view", { class: "button-group" }, [
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[8] || (_cache[8] = (...args) => $options.updateAllTexts && $options.updateAllTexts(...args))
            }, "更新所有文本"),
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[9] || (_cache[9] = (...args) => $options.updateFirstText && $options.updateFirstText(...args))
            }, "更新第一行"),
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[10] || (_cache[10] = (...args) => $options.updateSecondText && $options.updateSecondText(...args))
            }, "更新第二行"),
            vue.createElementVNode("button", {
              class: "btn",
              onClick: _cache[11] || (_cache[11] = (...args) => $options.updateTipText && $options.updateTipText(...args))
            }, "更新提示")
          ])
        ]),
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "状态显示"),
          vue.createElementVNode("view", { class: "button-group" }, [
            vue.createElementVNode("button", {
              class: "btn-status",
              onClick: _cache[12] || (_cache[12] = (...args) => $options.showRecording && $options.showRecording(...args))
            }, "录音状态"),
            vue.createElementVNode("button", {
              class: "btn-status",
              onClick: _cache[13] || (_cache[13] = (...args) => $options.showContent && $options.showContent(...args))
            }, "内容状态"),
            vue.createElementVNode("button", {
              class: "btn-status",
              onClick: _cache[14] || (_cache[14] = (...args) => $options.showLoading && $options.showLoading(...args))
            }, "加载状态"),
            vue.createElementVNode("button", {
              class: "btn-status",
              onClick: _cache[15] || (_cache[15] = (...args) => $options.hideLoading && $options.hideLoading(...args))
            }, "隐藏加载")
          ])
        ]),
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "文件上传测试"),
          vue.createElementVNode("view", { class: "input-group" }, [
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "input",
                "onUpdate:modelValue": _cache[16] || (_cache[16] = ($event) => $data.uploadUrl = $event),
                placeholder: "上传地址"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.uploadUrl]
            ]),
            vue.withDirectives(vue.createElementVNode(
              "input",
              {
                class: "input",
                "onUpdate:modelValue": _cache[17] || (_cache[17] = ($event) => $data.filePath = $event),
                placeholder: "文件路径"
              },
              null,
              512
              /* NEED_PATCH */
            ), [
              [vue.vModelText, $data.filePath]
            ])
          ]),
          vue.createElementVNode("button", {
            class: "btn-upload",
            onClick: _cache[18] || (_cache[18] = (...args) => $options.uploadFile && $options.uploadFile(...args))
          }, "上传文件")
        ]),
        vue.createElementVNode("view", { class: "card" }, [
          vue.createElementVNode("text", { class: "card-title" }, "操作日志"),
          vue.createElementVNode("view", { class: "log-header" }, [
            vue.createElementVNode("button", {
              class: "btn-clear",
              onClick: _cache[19] || (_cache[19] = (...args) => $options.clearLogs && $options.clearLogs(...args))
            }, "清空日志")
          ]),
          vue.createElementVNode("scroll-view", {
            class: "log-container",
            "scroll-y": "",
            "scroll-top": "{{scrollTop}}"
          }, [
            (vue.openBlock(true), vue.createElementBlock(
              vue.Fragment,
              null,
              vue.renderList($data.logs, (log, index) => {
                return vue.openBlock(), vue.createElementBlock("view", {
                  key: index,
                  class: "log-item"
                }, [
                  vue.createElementVNode(
                    "text",
                    { class: "log-time" },
                    vue.toDisplayString(log.time),
                    1
                    /* TEXT */
                  ),
                  vue.createElementVNode(
                    "text",
                    {
                      class: vue.normalizeClass(["log-message", log.type])
                    },
                    vue.toDisplayString(log.message),
                    3
                    /* TEXT, CLASS */
                  )
                ]);
              }),
              128
              /* KEYED_FRAGMENT */
            ))
          ])
        ])
      ])
    ]);
  }
  const PagesTestPipUniappTestPipUniapp = /* @__PURE__ */ _export_sfc(_sfc_main$1, [["render", _sfc_render], ["__file", "/Users/wang/Desktop/1108/1111/上传/deep/pages/test-pip-uniapp/test-pip-uniapp.vue"]]);
  __definePage("pages/index/index", PagesIndexIndex);
  __definePage("pages/test-pip-uniapp/test-pip-uniapp", PagesTestPipUniappTestPipUniapp);
  const _sfc_main = {
    onLaunch: function() {
      formatAppLog("log", "at App.vue:4", "App Launch");
    },
    onShow: function() {
      formatAppLog("log", "at App.vue:7", "App Show");
    },
    onHide: function() {
      formatAppLog("log", "at App.vue:10", "App Hide");
    }
  };
  const App = /* @__PURE__ */ _export_sfc(_sfc_main, [["__file", "/Users/wang/Desktop/1108/1111/上传/deep/App.vue"]]);
  function createApp() {
    const app = vue.createVueApp(App);
    return {
      app
    };
  }
  const { app: __app__, Vuex: __Vuex__, Pinia: __Pinia__ } = createApp();
  uni.Vuex = __Vuex__;
  uni.Pinia = __Pinia__;
  __app__.provide("__globalStyles", __uniConfig.styles);
  __app__._component.mpType = "app";
  __app__._component.render = () => {
  };
  __app__.mount("#app");
})(Vue);
