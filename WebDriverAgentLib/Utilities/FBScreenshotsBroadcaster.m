/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBScreenshotsBroadcaster.h"
#import "XCUIDevice+FBHelpers.h"
@import CocoaAsyncSocket;

static const NSTimeInterval FPS = 10;

@interface FBScreenshotsBroadcaster()

@property (nonatomic) NSTimer *mainTimer;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@property (nonatomic) NSMutableArray<GCDAsyncSocket *> *activeClients;

@end

@implementation FBScreenshotsBroadcaster

- (instancetype)init
{
  if ((self = [super init])) {
    _activeClients = [NSMutableArray array];
    _backgroundQueue = dispatch_queue_create("Background screenshoting", DISPATCH_QUEUE_SERIAL);
    _mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / FPS repeats:YES block:^(NSTimer * _Nonnull timer) {
      @synchronized (self.activeClients) {
        if (0 == self.activeClients.count) {
          return;
        }
      }

      NSError *error;
      NSData *screenshotData = [[XCUIDevice sharedDevice] fb_rawScreenshotWithQuality:2 error:&error];
      if (nil == screenshotData) {
        return;
      }

      dispatch_async(self.backgroundQueue, ^{
        @synchronized (self.activeClients) {
          for (GCDAsyncSocket *client in self.activeClients) {
            [client writeData:screenshotData withTimeout:-1 tag:0];
          }
        }
      });
    }];
  }
  return self;
}

- (void)didClientConnect:(NSArray<GCDAsyncSocket *> *)activeClients
{
  if (0 == activeClients.count) {
    return;
  }

  @synchronized (self.activeClients) {
    [self.activeClients removeAllObjects];
    [self.activeClients addObjectsFromArray:activeClients];
  }
}

- (void)didClientDisconnect:(NSArray<GCDAsyncSocket *> *)activeClients
{
  @synchronized (self.activeClients) {
    [self.activeClients removeAllObjects];
    [self.activeClients addObjectsFromArray:activeClients];
  }
}

@end
