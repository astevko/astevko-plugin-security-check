#import "SC.h"
#import <Cordova/CDVPlugin.h>
#import "SecurityCheck.h"

@implementation SC

// callback from checks
typedef void (^cbBlock) ();

/**
 * CONST debugger check timer delay in seconds
 */
static const float timerDelaySeconds = 5.0;

/**
 * during pluginInitialize register watchForBreak
 */
- (void)pluginInitialize {
    NSLog(@"pluginInitialize SC");	
    [self watchForBreak:nil];
	NSLog(@"SecurityCheck init done");
}

/**
 * Register DidBecomeActive and WillEnterForegroud event notifications
 * calls testForBreak
 */
- (void)watchForBreak:(CDVInvokedUrlCommand*)command {
    __weak id weakSelf = self;
    if (weakSelf) {
	
		cbBlock exitOnBreak = ^{
			__weak id weakSelf = self;
			if (weakSelf) {
				NSLog(@"SECURITY VIOLATION detected! Exiting...");
				exit(1);
			};
		};

		//-----------------------------------
		// jailbreak detection
		//-----------------------------------
		NSLog(@"SecurityCheck testing for jailbreak");
		checkFork(exitOnBreak);
		checkFiles(exitOnBreak);
		checkLinks(exitOnBreak);	

		NSLog(@"SecurityCheck registering notification handlers");
        // onAppActive
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(testForBreak) 
                                                     name:UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
        // onAppForeground
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(testForBreak) 
                                                     name:UIApplicationWillEnterForegroundNotification 
                                                   object:nil];
        [self testForBreak];

		// run testForBreak every 5 seconds
		// 	cribbed from http://stackoverflow.com/questions/22340394/ios-timer-loop-that-executes-a-certain-action-every-x-minutes
		if (![NSThread isMainThread]) {

			dispatch_async(dispatch_get_main_queue(), ^{
				[NSTimer scheduledTimerWithTimeInterval:timerDelaySeconds
												 target:self
											   selector:@selector(testForBreak)
											   userInfo:nil
												repeats:YES];
				});
		}
		else{
			[NSTimer scheduledTimerWithTimeInterval:timerDelaySeconds
											 target:self
										   selector:@selector(testForBreak)
										   userInfo:nil
											repeats:YES];
		}
    }
};

/**
 * testing for debugger and jailbreak
 */
- (void)testForBreak {
    
    cbBlock exitOnBreak = ^{
        __weak id weakSelf = self;
        if (weakSelf) {
            NSLog(@"SECURITY VIOLATION detected! Exiting...");
            exit(1);
        };
    };

    //-----------------------------------
    // debugger detection
    //-----------------------------------
    NSLog(@"SecurityCheck testing for debugger");
    dbgCheck(exitOnBreak);    
};

/**
 * check for debugger
 */ 
 - (void)debuggerCheck:(CDVInvokedUrlCommand*)command {
    cbBlock dbChkCallback = ^{
        __weak id weakSelf = self;
        if (weakSelf) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    };

    dbgCheck(dbChkCallback);    
};

/**
 * check for jailbreak
 */
- (void)jailbreakCheck:(CDVInvokedUrlCommand*)command {
   cbBlock jbChkCallback = ^{
        __weak id weakSelf = self;
        if (weakSelf) {
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    };
   
    //-----------------------------------
    // jailbreak detection
    //-----------------------------------
    checkFork(jbChkCallback);
    checkFiles(jbChkCallback);
    checkLinks(jbChkCallback);
};
@end