#!/bin/sh
security unlock-keychain login.keychain
xcodebuild build-for-testing -project /opt/apps/appium/node_modules/appium-xcuitest-driver/WebDriverAgent/WebDriverAgent.xcodeproj -scheme WebDriverAgentRunner -xcconfig /opt/apps/ios-sdk/isign/appium.xcconfig

ios-deploy -c | grep ' Found ' | awk '{print $3}' | xargs -I {} ios-deploy -i {} -9 -1 com.apple.test.WebDriverAgentRunner-Runner
