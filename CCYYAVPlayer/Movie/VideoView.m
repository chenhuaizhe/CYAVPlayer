//
//  VideoView.m
//  CCYYAVPlayer
//
//  Created by CY on 15/11/26.
//  Copyright © 2015年 chenyuan. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView

+(Class)layerClass
{
    return [AVPlayerLayer class];
}

-(AVPlayer *)player
{
    return [(AVPlayerLayer *)self.layer player];
}

-(void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)self.layer setPlayer:player];
}

-(void)setFillMode:(NSString *)fillMode
{
    [(AVPlayerLayer *)self.layer setVideoGravity:fillMode];
}

@end
