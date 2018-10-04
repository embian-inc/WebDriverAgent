#!/bin/sh

ios-deploy -c | grep ' Found ' | awk '{print $3}' | xargs -I {} ios-deploy -i {} -9 -1 com.apple.test.WebDriverAgentRunner-Runner
