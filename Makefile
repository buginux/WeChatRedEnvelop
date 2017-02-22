THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:7.0

include theos/makefiles/common.mk

TWEAK_NAME = WeChatRedEnvelop
WeChatRedEnvelop_FILES = Tweak.xm WBBaseViewController.m WBSettingViewController.m WBRedEnvelopConfig.m WeChatRedEnvelopParam.m WBReceiveRedEnvelopOperation.m WBRedEnvelopTaskManager.m
WeChatRedEnvelop_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
