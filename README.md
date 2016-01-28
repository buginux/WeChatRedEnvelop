# iOS版微信抢红包插件Tweak

这个插件是我学习[iOS应用逆向工程](http://www.amazon.cn/iOS%E5%BA%94%E7%94%A8%E9%80%86%E5%90%91%E5%B7%A5%E7%A8%8B-%E6%B2%99%E6%A2%93%E7%A4%BE/dp/B00VFDVY7E/ref=sr_1_1?ie=UTF8&qid=1453170509&sr=8-1&keywords=ios%E9%80%86%E5%90%91%E5%B7%A5%E7%A8%8B)后做的一个练手的小插件。

只要你的手机已经越狱，并且安装了这个 Tweak，登录你的微信后就可以自动抢红包，不需要任何的手动操作。

**本插件只用于学习目的，请勿使用于别的用途**

## 安装方法

有很多小伙伴都反应说不知道怎么安装，因此写了一篇博客来说明如何从源码安装 tweak。

[教程地址](http://www.swiftyper.com/ios-tweak-install-guide/)

## 反馈

这个插件在我和我同事的设备上运行良好，但是有童鞋反馈说他们装上了没有反应，如果你也有类似的情况，可以直接提 issue 并说明设备版本，系统版本以及微信的版本，我会尽快着手修复的。

根据到目前为止的总结，插件无效的原因可能如下：

### 1. ldid 无效

ldid 是用于对 tweak 进行签名的，如果 ldid 无效，则 tweak 是不起作用的。

确认 ldid 是否有错误的步骤：

1. 在 cydia 上搜索安装 syslogd to /var/log/syslog，安装后重启手机
2. 重装安装 tweak
3. 查看 /var/log/syslog 文件中是否有类似信息：
```
binary not signed (use ldid -S)
failure to check WeChatRedEnvelop.dylib
```
如果确认是 ldid 有问题，请重新下载新版本进行安装。


## 特别感谢

[狗神](https://github.com/iosre)，即 [iOS应用逆向工程](http://www.amazon.cn/iOS%E5%BA%94%E7%94%A8%E9%80%86%E5%90%91%E5%B7%A5%E7%A8%8B-%E6%B2%99%E6%A2%93%E7%A4%BE/dp/B00VFDVY7E/ref=sr_1_1?ie=UTF8&qid=1453170509&sr=8-1&keywords=ios%E9%80%86%E5%90%91%E5%B7%A5%E7%A8%8B)的作者。

有了狗神的亲手指导，我才得以能快速完成这个 Tweak 的开发，感谢！

