//
//  MLAKeyValueObserverCenter.h
//  MLAKeyValueObserverCenter
//
//  Created by Nyx on 08/05/2014.
//  Copyright (c) 2014 Nyx. All rights reserved.
//

#import <Foundation/Foundation.h>

// A NSNotificationCenter like for Key Value Observing
@interface MLAKeyValueObserverCenter : NSObject

+ (instancetype)defaultCenter;
- (instancetype)init; /* designated initializer */

// add observer with a selector without options
- (void)addObserver:(id)observer selector:(SEL)aSelector keyPath:(NSString *)aKeyPath object:(id)obj;
// add observer with a selector
- (void)addObserver:(id)observer selector:(SEL)aSelector keyPath:(NSString *)aKeyPath object:(id)obj options:(NSKeyValueObservingOptions)options;

#if NS_BLOCKS_AVAILABLE
// add observer with a block without options
- (id)addObserverForKeyPath:(NSString *)aKeyPath object:(id)obj usingBlock:(void (^)(NSDictionary *changes))block
NS_AVAILABLE(10_6, 4_0);
// The return value is retained by the system, and should be held onto by the caller in
// order to remove the observer with removeObserver: later, to stop observation.

// add observer with a block
- (id)addObserverForKeyPath:(NSString *)aKeyPath object:(id)obj options:(NSKeyValueObservingOptions)options usingBlock:(void (^)(NSDictionary *changes))block
NS_AVAILABLE(10_6, 4_0);
// The return value is retained by the system, and should be held onto by the caller in
// order to remove the observer with removeObserver: later, to stop observation.
#endif

// stop notify observer
- (void)removeObserver:(id)observer;
// stop notify observer for a given object's key path
- (void)removeObserver:(id)observer keyPath:(NSString *)aKeyPath object:(id)obj;

// stop listening changes on the given object's key path
- (void)removeAllObserversForKeyPath:(NSString *)aKeyPath object:(id)obj;
// stop listening changes on the given object for all key paths
- (void)removeAllObserversForObject:(id)obj;

// Get all observers list for a given listened object's key path
- (NSSet *)observersForKeyPath:(NSString *)aKeyPath object:(id)obj;

@end
