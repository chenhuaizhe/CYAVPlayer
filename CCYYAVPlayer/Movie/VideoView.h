//
//  VideoView.h
//  CCYYAVPlayer
//
//  Created by CY on 15/11/26.
//  Copyright © 2015年 chenyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//----------------------------- 视频播放视图 -----------------------------------

@interface VideoView : UIView

@property (nonatomic,strong) AVPlayer *player;

-(void)setFillMode:(NSString *)fillMode;

@end
