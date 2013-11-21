//
//  record_audio_testViewController.m
//  record_audio_test
//
//  Created by jinhu zhang on 11-1-5.
//  Copyright 2011 no. All rights reserved.
//

#import "record_audio_testViewController.h"

#import "ObjectAL.h"

/*
#import "SoundManager.h"

// For Playing
SoundManager *sharedSoundManager;

// For GameLoop
NSTimer			*levelTimer;
*/


@implementation record_audio_testViewController

//@synthesize m_pLongMusicPlayer;
//@synthesize m_pRecordPlayer;

- (void) startAudioRecord:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

	//Instanciate an instance of the AVAudioSession object.
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];

	//Setup the audioSession for playback and record.
	//We could just use record and then switch it to playback leter, but
	//since we are going to do both lets set it up once.
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];

    NSString* callbackID = [arguments pop];
    [callbackID retain];

    // 背景音樂檔案路徑
    NSString *musicFile = [arguments objectAtIndex:0];
    [musicFile retain];
    NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
    [basePath retain];
    NSString* musicFilePath = [NSString stringWithFormat:@"%@/%@", basePath, musicFile];
    [musicFilePath retain];
    NSLog( @"musicFilePath(%@)", musicFilePath);


    //NSURL *musicURL = [[NSURL alloc] initFileURLWithPath:musicFilePath];
    //NSLog(@"test 4");
	//m_pLongMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    //[m_pLongMusicPlayer play];


    ALBuffer* buffer = [[OALSimpleAudio sharedInstance] preloadEffect:@"she.caf" reduceToMono:YES];
	[musicSource play:buffer loop:YES];
    

    NSLog(@"test 6");
 
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    //录音使用的苹果无损格式
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
    //设置采样率为44100hz
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    //设置录音的通道数目
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //设置位深
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //设置格式是否为大字节序编码
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    //设置音频格式是否位浮点型
    [recordSetting setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    //Encoder Settings (Only necessary if you want to change it.)
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    [recordSetting setValue:[NSNumber numberWithInt:96] forKey:AVEncoderBitRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVEncoderBitDepthHintKey];
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVSampleRateConverterAudioQualityKey];

    NSLog(@"test 7");

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//获得存储路径，
    NSString *documentDirectory = [paths objectAtIndex:0];//获得路径的第0个元素

    NSLog(@"test 8");

    recordedTmpFile = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", @"record", @"caf"]]];
    NSLog(@"Using File called: %@",recordedTmpFile);

    recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];

    NSLog(@"test 9");

    //[recorder setDelegate:self];

    NSLog(@"test 10");

    [recorder prepareToRecord];

    NSLog(@"test 11");

    [recorder record];

    NSLog(@"test 12");
    
    startTime = CFAbsoluteTimeGetCurrent();
    

    [callbackID release];
    [basePath release];
    [musicFile release];
    [musicFilePath release];
    NSLog(@"test 12.1");
}


- (void)stopAudioRecord:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    NSLog(@"A 1");

    //[m_pLongMusicPlayer stop];
    [musicSource stop];

    NSLog(@"Using File called: %@",recordedTmpFile);
    if([recorder isRecording]) {
        [recorder stop];
    }

    NSLog(@"A 6");
}

- (void) merge2wav:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSLog( @"合成 錄音 與 背景音樂");
    //CDVPluginResult* pluginResult;
    NSString* callbackID = [arguments pop];
    [callbackID retain];
    
    // 錄音檔案路徑
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);//获得存储路径，
    NSString *documentDirectory = [paths objectAtIndex:0];//获得路径的第0个元素
    NSURL *fileURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.%@", @"record", @"caf"]]];
    NSString* path1 = [fileURL path];
    [path1 retain];
    NSLog( @"path1 => %@", path1 );
    
    // 背景音樂檔案路徑
    NSString *assetPath2 = [arguments objectAtIndex:0];
    [assetPath2 retain];
    NSString* basePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"www"];
    [basePath retain];
    NSString* path2 = [NSString stringWithFormat:@"%@/%@", basePath, assetPath2];
    [path2 retain];
    NSLog( @"path2(%@)", path2);
    
    // 輸出檔案路徑
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *outputFileURL = [[tmpDirURL URLByAppendingPathComponent:@"output"] URLByAppendingPathExtension:@"m4a"];
    NSString* path3 = [outputFileURL path];
    [path3 retain];
    NSLog( @"path3(%@)", path3);
    
    //====================================================================================================
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    audioMixParams = [[NSMutableArray alloc] initWithObjects:nil];
    
    //Add Audio Tracks to Composition
    NSString *URLPath1 = path1;
    NSURL *assetURL1 = [NSURL fileURLWithPath:URLPath1];
    [self setUpAndAddAudioAtPath:assetURL1 toComposition:composition];
    
    NSString *URLPath2 = path2;
    NSURL *assetURL2 = [NSURL fileURLWithPath:URLPath2];
    [self setUpAndAddAudioAtPath:assetURL2 toComposition:composition];
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    audioMix.inputParameters = [NSArray arrayWithArray:audioMixParams];
    
    //If you need to query what formats you can export to, here's a way to find out
    NSLog (@"compatible presets for songAsset: %@",
           [AVAssetExportSession exportPresetsCompatibleWithAsset:composition]);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: composition
                                      presetName: AVAssetExportPresetAppleM4A];
    /*
     AVAssetExportPresetAppleM4A,
     AVAssetExportPreset960x540,
     AVAssetExportPresetLowQuality,
     AVAssetExportPresetMediumQuality,
     AVAssetExportPreset640x480,
     AVAssetExportPresetHighestQuality,
     AVAssetExportPreset1280x720
     */
    
    exporter.audioMix = audioMix;
    exporter.outputFileType = @"com.apple.m4a-audio";
    //NSString *fileName = @"someFilename";
    NSString *exportFile = path3;//[[self getDocumentsDirectory] stringByAppendingFormat: @"/%@.m4a", fileName];
    NSLog( @"exportFile: %@", exportFile );
    
    // set up export
    //myDeleteFile(exportFile);
    NSLog( @"test 0");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog( @"test 1");
    [fileManager removeItemAtPath:exportFile error:nil];
    NSLog( @"test 2");
    
    NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = exportURL;
    NSLog( @"exportURL: %@", exporter.outputURL );
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed:
                //NSError *exportError = exporter.error;
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exporter.error);
                break;
                
            case AVAssetExportSessionStatusCompleted:
                
                NSLog (@"AVAssetExportSessionStatusCompleted");
                
                [self merge2wavDone];
                
                break;
            case AVAssetExportSessionStatusUnknown: NSLog (@"AVAssetExportSessionStatusUnknown"); break;
            case AVAssetExportSessionStatusExporting: NSLog (@"AVAssetExportSessionStatusExporting"); break;
            case AVAssetExportSessionStatusCancelled: NSLog (@"AVAssetExportSessionStatusCancelled"); break;
            case AVAssetExportSessionStatusWaiting: NSLog (@"AVAssetExportSessionStatusWaiting"); break;
            default:  NSLog (@"didn't get export status"); break;
        }
    }];
    
    [callbackID release];
    [path1 release];
    [path2 release];
    [path3 release];
}

// 合成設定
- (void) setUpAndAddAudioAtPath:(NSURL*)assetURL toComposition:(AVMutableComposition *)composition {
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *sourceAudioTrack = [[songAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    NSError *error = nil;
    BOOL ok = NO;
    
    CMTime startTime = CMTimeMakeWithSeconds(0, 1);
    CMTime trackDuration = songAsset.duration;
    //CMTime longestTime = CMTimeMake(848896, 44100); //(19.24 seconds)
    CMTimeRange tRange = CMTimeRangeMake(startTime, trackDuration);
    
    //Set Volume
    AVMutableAudioMixInputParameters *trackMix = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    [trackMix setVolume:0.8f atTime:startTime];
    [audioMixParams addObject:trackMix];
    
    //Insert audio into track
    ok = [track insertTimeRange:tRange ofTrack:sourceAudioTrack atTime:CMTimeMake(0, 44100) error:&error];
}


// 合成ok
- (void) merge2wavDone
{
    NSLog (@"merge2wavDone");
    
    [self performSelector:@selector(writeJavascript:) onThread:[NSThread mainThread] withObject:@"singer.merge2wavDone()" waitUntilDone:NO];
}


- (void)playOutputAudio:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    NSLog(@"B 1");

    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *recordFile = [[tmpDirURL URLByAppendingPathComponent:@"output"] URLByAppendingPathExtension:@"m4a"];

    NSLog(@"B 1.1 recordFile=> %@", [recordFile path] );

    ALBuffer* buffer = [[OALSimpleAudio sharedInstance] preloadEffect:[recordFile path] reduceToMono:YES];
	[musicSource play:buffer loop:YES];

    NSLog(@"B 2");
}

- (void)stopOutputAudio:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    [musicSource stop];
    
    NSLog(@"B 2");
}

- (void)getCurrentTime:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    
    NSString* callbackId = [arguments objectAtIndex:0];
   [callbackId retain];
    
    // id
	NSString* mediaId = [arguments objectAtIndex:1];
    [mediaId retain];
    
    
	// currentTime
    //double currentTime = m_pLongMusicPlayer.currentTime;
    //NSLog( @"currentTime(%f)", currentTime );
  
    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent() - startTime;
    NSLog( @"currentTime(%f)", currentTime );

    NSString* str = [NSString stringWithFormat:@"singer.getCurrentTime(%f)", currentTime ];
    
    NSLog( @"str: %@", str);
    [super writeJavascript:str];

    [callbackId release];
    [mediaId release];
}


- (void)initPlayOpenAL:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    // 設定音場環境
    roomTypeNames = [[NSMutableDictionary alloc] init];
    roomTypeOrder = [[NSMutableArray alloc] init];
    
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_SmallRoom named:@"Small Room"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_MediumRoom named:@"Medium Room"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_LargeRoom named:@"Large Room"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_LargeRoom2 named:@"Large Room 2"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_MediumHall named:@"Medium Hall"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_MediumHall2 named:@"Medium Hall 2"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_MediumHall3 named:@"Medium Hall 3"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_LargeHall named:@"Large Hall"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_LargeHall2 named:@"Large Hall 2"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_MediumChamber named:@"Medium Chamber"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_LargeChamber named:@"Large Chamber"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_Cathedral named:@"Cathedral"];
    [self addRoomType:ALC_ASA_REVERB_ROOM_TYPE_Plate named:@"Plate"];
    
    
    
	[OALSimpleAudio sharedInstance].reservedSources = 0;
    [OALSimpleAudio sharedInstance].context.listener.reverbOn = YES;
    [OALSimpleAudio sharedInstance].context.listener.globalReverbLevel = 0;

	musicSource = [[ALSource source] retain];
    musicSource.reverbSendLevel = 1.0;

    roomIndex = 0;
    [self updateRoomType];

    /*
    ALBuffer* buffer = [[OALSimpleAudio sharedInstance] preloadEffect:@"she.caf" reduceToMono:YES];
	[source play:buffer loop:YES];
    */
}

- (void) addRoomType:(ALint) roomType named:(NSString*) name
{
    NSNumber* roomTypeNumber = [NSNumber numberWithInt:roomType];
    [roomTypeOrder addObject:roomTypeNumber];
    [roomTypeNames setObject:name forKey:roomTypeNumber];
}

- (void) updateRoomType {

    NSLog(@"roomIndex => %i", roomIndex);

    NSNumber* roomType = [roomTypeOrder objectAtIndex:roomIndex];
    [OALSimpleAudio sharedInstance].context.listener.reverbRoomType = [roomType intValue];
}


- (void)setRoomType:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {

    NSString* callbackId = [arguments objectAtIndex:0];
    [callbackId retain];

    roomIndex= [[arguments objectAtIndex:1] integerValue];
    NSLog(@"roomIndex => %i", roomIndex);

    [self updateRoomType];
    
    [callbackId release];    
}

@end