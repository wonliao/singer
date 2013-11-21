//
//  record_audio_testViewController.h
//  record_audio_test
//
//  Created by jinhu zhang on 11-1-5.
//  Copyright 2011 no. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

#import <Cordova/CDVSound.h>


#import "ObjectAL.h"


@interface record_audio_testViewController : CDVSound <AVAudioRecorderDelegate> {

	//Variables setup for access in the class:
	NSURL * recordedTmpFile;
	AVAudioRecorder * recorder;
	NSError * error;

	//AVAudioPlayer *m_pLongMusicPlayer;
    //AVAudioPlayer *m_pRecordPlayer;

    NSMutableArray* audioMixParams;

    // OpenAL
    ALSource* musicSource;
    ALSource* recordSource;

    NSMutableArray* roomTypeOrder;
    NSMutableDictionary* roomTypeNames;
    int roomIndex;

    CFTimeInterval startTime;
}

//@property (nonatomic,retain)AVAudioPlayer *m_pLongMusicPlayer;
@property (nonatomic,retain)AVAudioPlayer *m_pRecordPlayer;

- (void)startAudioRecord:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)stopAudioRecord:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)merge2wav:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)playOutputAudio:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)stopOutputAudio:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)getCurrentTime:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)initPlayOpenAL:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)setRoomType:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
