//
//  TrackManager.m
//  AudioPro
//
//  Created by curso-vivelab on 11/01/15.
//  Copyright (c) 2015 benllycast. All rights reserved.
//
#import "SuperpoweredAdvancedAudioPlayer.h"
#import "SuperpoweredFilter.h"
#import "SuperpoweredRoll.h"
#import "SuperpoweredFlanger.h"
#import "SuperpoweredIOSAudioOutput.h"
#import "SuperpoweredMixer.h"
#import <stdlib.h>
#import <pthread.h>
#import "TrackManager.h"
#import "FxManager.h"

#define HEADROOM_DECIBEL 3.0f
static const float headroom = powf(10.0f, -HEADROOM_DECIBEL * 0.025);

@implementation TrackManager{
    SuperpoweredAdvancedAudioPlayer *playerA, *playerB;
    SuperpoweredIOSAudioOutput *output;
    SuperpoweredStereoMixer *mixer;
    FxManager * fxManager;
    bool isLoadPlayerA, isLoadPlayerB;
    unsigned char activeFx;
    float *stereoBuffer, *stereoBufferB, crossValue, volA, volB;
    unsigned int lastSamplerate;
    pthread_mutex_t mutex;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        lastSamplerate = activeFx = 0;
        crossValue = volB = 0.5f;
        volA = 1.0f * headroom;
        pthread_mutex_init(&mutex, NULL); // This will keep our player volumes and playback states in sync.
        if (posix_memalign((void **)&stereoBuffer, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.
        if (posix_memalign((void **)&stereoBufferB, 16, 4096 + 128) != 0) abort(); // Allocating memory, aligned to 16.

        playerA = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackA, 44100, 0);
        playerB = new SuperpoweredAdvancedAudioPlayer((__bridge void *)self, playerEventCallbackB, 44100, 0);
        playerA->syncMode = playerB->syncMode = SuperpoweredAdvancedAudioPlayerSyncMode_TempoAndBeat;

        fxManager = [[FxManager alloc] init];

        mixer = new SuperpoweredStereoMixer();
        output = [[SuperpoweredIOSAudioOutput alloc] initWithDelegate:(id<SuperpoweredIOSAudioIODelegate>)self preferredBufferSize:12 preferredMinimumSamplerate:44100 audioSessionCategory:AVAudioSessionCategoryPlayback multiChannels:2 fixReceiver:true];
        [output start];
    }
    return self;
}

void playerEventCallbackA(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        TrackManager *self = (__bridge TrackManager *)clientData;
        self->playerA->setBpm(126.0f);
        self->playerA->setFirstBeatMs(353);
        self->playerA->setPosition(self->playerA->firstBeatMs, false, false);
    };
}

void playerEventCallbackB(void *clientData, SuperpoweredAdvancedAudioPlayerEvent event, void *value) {
    if (event == SuperpoweredAdvancedAudioPlayerEvent_LoadSuccess) {
        TrackManager *self = (__bridge TrackManager*)clientData;
        self->playerB->setBpm(123.0f);
        self->playerB->setFirstBeatMs(40);
        self->playerB->setPosition(self->playerB->firstBeatMs, false, false);
    };
}

-(void) loadTrackA:(NSString *) nameFile{
    pthread_mutex_lock(&mutex);
    self->playerA->pause();
    self->playerA->open([nameFile fileSystemRepresentation]);
    playerA->syncMode = playerB->syncMode = SuperpoweredAdvancedAudioPlayerSyncMode_TempoAndBeat;
    self->playerA->play(true);
    isLoadPlayerA = true;
    pthread_mutex_unlock(&mutex);
}
-(void) loadTrackB:(NSString *) nameFile{
    pthread_mutex_lock(&mutex);
    self->playerB->pause();
    self->playerB->open([nameFile fileSystemRepresentation]);
    playerA->syncMode = playerB->syncMode = SuperpoweredAdvancedAudioPlayerSyncMode_TempoAndBeat;
    self->playerB->play(true);
    isLoadPlayerB = true;
    pthread_mutex_unlock(&mutex);
};

-(void) loadAllTrack{
    playerB->open([[[NSBundle mainBundle] pathForResource:@"nuyorica" ofType:@"m4a"] fileSystemRepresentation]);
    playerA->open([[[NSBundle mainBundle] pathForResource:@"lycka" ofType:@"mp3"] fileSystemRepresentation]);
    playerA->syncMode = playerB->syncMode = SuperpoweredAdvancedAudioPlayerSyncMode_TempoAndBeat;
}

- (void)dealloc {
    delete playerA;
    delete playerB;
    delete mixer;
    free(stereoBuffer);
    pthread_mutex_destroy(&mutex);
#if !__has_feature(objc_arc)
    [fxManager release];
    [output release];
    [super dealloc];
#endif
}

- (void)interruptionEnded { // If a player plays Apple Lossless audio files, then we need this. Otherwise unnecessary.
    playerA->onMediaserverInterrupt();
    playerB->onMediaserverInterrupt();
}

- (bool)audioProcessingCallback:(float **)buffers inputChannels:(unsigned int)inputChannels outputChannels:(unsigned int)outputChannels numberOfSamples:(unsigned int)numberOfSamples samplerate:(unsigned int)samplerate hostTime:(UInt64)hostTime {
    if (samplerate != lastSamplerate) { // Has samplerate changed?
        lastSamplerate = samplerate;
        playerA->setSamplerate(samplerate);
        playerB->setSamplerate(samplerate);
    };

    pthread_mutex_lock(&mutex);

    bool masterIsA = (crossValue <= 0.5f);
    float masterBpm = masterIsA ? playerA->currentBpm : playerB->currentBpm;
    double msElapsedSinceLastBeatA = playerA->msElapsedSinceLastBeat; // When playerB needs it, playerA has already stepped this value, so save it now.

    bool silence = !playerA->process(stereoBuffer, false, numberOfSamples, volA, masterBpm, playerB->msElapsedSinceLastBeat);
    if (playerB->process(stereoBuffer, !silence, numberOfSamples, volB, masterBpm, msElapsedSinceLastBeatA)) silence = false;
    pthread_mutex_unlock(&mutex);
    [fxManager processAllFX:silence inputBuffer:stereoBuffer outputBuffer:stereoBuffer numSamples:numberOfSamples];
    // The stereoBuffer is ready now, let's put the finished audio into the requested buffers.
    float *mixerInputs[4] = { stereoBuffer, NULL, NULL, NULL };
    float mixerInputLevels[8] = { 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
    float mixerOutputLevels[2] = { 1.0f, 1.0f };
    if (!silence) mixer->process(mixerInputs, buffers, mixerInputLevels, mixerOutputLevels, NULL, NULL, numberOfSamples);
    return !silence;
}

- (void)playPause:(id)sender {
    //UIButton *button = (UIButton *)sender;
    pthread_mutex_lock(&mutex);
    if (playerA->playing) {
        playerA->pause();
        playerB->pause();
    } else {
        bool masterIsA = (crossValue <= 0.5f);
        playerA->play(!masterIsA);
        playerB->play(masterIsA);
    };
    pthread_mutex_unlock(&mutex);
    //button.selected = playerA->playing;
}

- (void)crossFadder:(id)sender {
    pthread_mutex_lock(&mutex);
    crossValue = ((UISlider *)sender).value;
    if (crossValue < 0.01f) {
        volA = 1.0f * headroom;
        volB = 0.0f;
    } else if (crossValue > 0.99f) {
        volA = 0.0f;
        volB = 1.0f * headroom;
    } else { // constant power curve
        volA = cosf(M_PI_2 * crossValue) * headroom;
        volB = cosf(M_PI_2 * (1.0f - crossValue)) * headroom;
    };
    pthread_mutex_unlock(&mutex);
}

-(bool) togglFX:(int) index{
    return [fxManager toggleFX:index];
}
-(float *) equ{
    return [fxManager getEquParameter];
}
-(void) setEquParameter:(float) low mid:(float) mid high:(float) hig{
    [fxManager setEQUFX:0 low:low mid:mid high:hig];
}
@end
