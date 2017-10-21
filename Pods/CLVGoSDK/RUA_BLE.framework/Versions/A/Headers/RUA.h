//
//  RUA.h
//  RUA
//
//  Created by Russell Kondaveti on 10/9/13.
//  Copyright (c) 2013 ROAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUADeviceManager.h"
#import "RUAReaderVersionInfo.h"

#define RUA_DEBUG 1
#ifdef RUA_DEBUG
#define RUA_DEBUG_LOG(...) NSLog(__VA_ARGS__)
#else
#define RUA_DEBUG_LOG(...)
#endif

static NSString *RUA_Version = @"1.7.1.384";

@interface RUA : NSObject

/**
 Enables RUA log messages
 @param enable, TRUE to enable logging
 */
+ (void)enableDebugLogMessages:(BOOL)enable;

/**
 * Sets if the ROAMreaderUnifiedAPI has to operate in production mode.<br>
 *
 * By default, the production mode is enabled.
 *
 * Note: For now, debug logging cannot be enabled only if ROAMreaderUnified API is operating in production mode
 *
 * @param enable boolean to indicate that this is production mode
 *
 */
+ (void)setProductionMode:(BOOL)enable;

/**
 Returns true if RUA log messages are enabled
 */
+ (BOOL)debugLogEnabled;

/**
 Returns the list of roam device types that are supported by the RUA
 <p>
 Usage: <br>
 <code>
 NSArray *supportedDevices = [RUA getSupportedDevices];
 </code>
 </p>
 @return NSArray containing the enumerations of reader types that are supported.
 @see RUADeviceType
 */
+ (NSArray *)getSupportedDevices;

/**
 Returns an instance of the device manager for the connected device and this auto detection works with the readers that have audio jack interface.
 @param RUADeviceType roam reader type enumeration
 @return RUADeviceManager device manager for the device type specified
 @see RUADeviceType
 */
+ (id <RUADeviceManager> )getDeviceManager:(RUADeviceType)type;


/**
 Returns an instance of the device manager for the device type specified.
 <p>
 Usage: <br>
 <code>
 id<RUADeviceManager> mRP750xReader = [RUA getDeviceManager:RUADeviceTypeRP750x];
 </code>
 </p>
 @param RUADeviceType roam reader type enumeration
 @return RUADeviceManager device manager for the device type specified
 @see RUADeviceType
 */

+ (id <RUADeviceManager> )getAutoDetectDeviceManager:(NSArray*)type;

/**
 Returns an version of ROAMReaderUnifiedAPI (RUA)
 @return RUADeviceManager device manager for the device type specified
 */
+ (NSString *) versionString __deprecated_msg("use RUA_Version instead");

/**
 * Returns a list of file version descriptions for each file
 * contained within the specified UNS file.
 * @see RUAFileVersionInfo
 *
 */

+ (NSArray*)getUnsFileVersionInfo:(NSString*)filePath;

@end
