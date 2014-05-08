//
//  MLAKeyValueObserverCenter.m
//  MLAKeyValueObserverCenter
//
//  Created by Nyx on 08/05/2014.
//  Copyright (c) 2014 Nyx. All rights reserved.
//

#import "MLAKeyValueObserverCenter.h"
#import "MLAKeyValueObserver.h"

#import <objc/message.h>
#import <objc/runtime.h>

static void * MLAKeyValueObserverCenterContext = &MLAKeyValueObserverCenterContext;

@interface MLAKeyValueObserverCenter ()

@property (strong, nonatomic) NSMutableSet *keyValueObservers;

@end

@implementation MLAKeyValueObserverCenter

+ (instancetype)defaultCenter
{
    static MLAKeyValueObserverCenter *defaultCenter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[self alloc] init];
    });
    
    return defaultCenter;
}

 /* designated initializer */
- (instancetype)init
{
    self = [super init];
    if (self) {
        _keyValueObservers = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    // stop listening, clean observers
    NSArray *observers = [self.keyValueObservers valueForKey:@"observer"];
    for (id observer in observers) {
        [self removeObserver:observer];
    }

}

- (void)addObserver:(id)observer selector:(SEL)aSelector keyPath:(NSString *)aKeyPath object:(id)obj
{
    [self addObserver:observer selector:aSelector keyPath:aKeyPath object:obj options:0];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector keyPath:(NSString *)aKeyPath object:(id)obj options:(NSKeyValueObservingOptions)options
{
    @synchronized(self) {

        if ([[self observersForKeyPath:aKeyPath object:obj] count] == 0) {
            // add K.V.O
            [obj addObserver:self forKeyPath:aKeyPath options:options context:MLAKeyValueObserverCenterContext];
        }
        
        // create key value observer item
        MLAKeyValueObserver *aKeyValueObserver = [[MLAKeyValueObserver alloc] init];
        aKeyValueObserver.observedObject = obj;
        aKeyValueObserver.observer = observer;
        aKeyValueObserver.selector = aSelector;
        aKeyValueObserver.keyPath = aKeyPath;
        
        // add to the pending observers queue
        [self.keyValueObservers addObject:aKeyValueObserver];
    }
    
}

- (void)removeAllObserversForKeyPath:(NSString *)aKeyPath object:(id)obj
{
    @synchronized(self) {
        NSSet *observers = [self.keyValueObservers valueForKey:@"observer"];
        for (id observer in observers) {
            [self removeObserver:observer keyPath:aKeyPath object:obj];
        }
    }
}
- (void)removeAllObserversForObject:(id)obj
{
    [self removeAllObserversForKeyPath:nil object:obj];
}

- (void)removeObserver:(id)observer
{
    [self removeObserver:observer keyPath:nil object:nil];
}

- (void)removeObserver:(id)observer keyPath:(NSString *)aKeyPath object:(id)obj
{
    @synchronized(self) {
        
        NSMutableArray *predicates = [NSMutableArray array];
        NSPredicate *observerPredicate = [NSPredicate predicateWithFormat:@"observer == %@",observer];
        [predicates addObject:observerPredicate];
        
        if (obj) {
            NSPredicate *objectPredicate = [NSPredicate predicateWithFormat:@"observedObject == %@",obj];
            [predicates addObject:objectPredicate];
        }
        
        if (aKeyPath) {
            NSPredicate *keyPathPredicate = [NSPredicate predicateWithFormat:@"keyPath == %@",aKeyPath];
            [predicates addObject:keyPathPredicate];
        }
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSSet *filteredKeyValueObservers = [self.keyValueObservers filteredSetUsingPredicate:predicate];
        for (MLAKeyValueObserver *aKeyValueObserver in filteredKeyValueObservers) {
            
            // Are we the last observer forhe the currnet keypath of the current object ?
            if ([[self observersForKeyPath:aKeyValueObserver.keyPath object:aKeyValueObserver.observedObject] count] == 1) {
                // remove K.V.O
                [aKeyValueObserver.observedObject removeObserver:self forKeyPath:aKeyValueObserver.keyPath context:MLAKeyValueObserverCenterContext];
            }
            
            // remove from the pending observer queue
            [self.keyValueObservers removeObject:aKeyValueObserver];
        }
    }
}

- (NSSet *)observersForKeyPath:(NSString *)aKeyPath object:(id)obj
{
    @synchronized(self) {
        NSMutableArray *predicates = [NSMutableArray array];
        
        if (obj) {
            NSPredicate *objectPredicate = [NSPredicate predicateWithFormat:@"observedObject == %@",obj];
            [predicates addObject:objectPredicate];
        }
        
        if (aKeyPath) {
            NSPredicate *keyPathPredicate = [NSPredicate predicateWithFormat:@"keyPath == %@",aKeyPath];
            [predicates addObject:keyPathPredicate];
        }
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSSet *filteredKeyValueObservers = [self.keyValueObservers filteredSetUsingPredicate:predicate];
        
        return [filteredKeyValueObservers valueForKey:@"observer"];
    }
}

#if NS_BLOCKS_AVAILABLE

// The return value is retained by the system, and should be held onto by the caller in
// order to remove the observer with removeObserver: later, to stop observation.
- (id)addObserverForKeyPath:(NSString *)aKeyPath object:(id)obj usingBlock:(void (^)(NSDictionary *changes))block
{
    return [self addObserverForKeyPath:aKeyPath object:obj options:0 usingBlock:block];
}

// The return value is retained by the system, and should be held onto by the caller in
// order to remove the observer with removeObserver: later, to stop observation.
- (id)addObserverForKeyPath:(NSString *)aKeyPath object:(id)obj options:(NSKeyValueObservingOptions)options usingBlock:(void (^)(NSDictionary *changes))block
{
    @synchronized(self) {
        
        // We already observe the keypath of the same object ?
        if ([[self observersForKeyPath:aKeyPath object:obj] count] == 0) {
            // add K.V.O
            [obj addObserver:self forKeyPath:aKeyPath options:options context:MLAKeyValueObserverCenterContext];
        }
        
        // create key value observer item
        MLAKeyValueObserver *aKeyValueObserver = [[MLAKeyValueObserver alloc] init];
        aKeyValueObserver.observer = aKeyValueObserver; // it's ugly !
        aKeyValueObserver.observedObject = obj;
        aKeyValueObserver.block = block;
        aKeyValueObserver.keyPath = aKeyPath;
        
        // add to the pending observers queue
        [self.keyValueObservers addObject:aKeyValueObserver];
        
        return aKeyValueObserver;
    }
}
#endif

#pragma mark - K.V.O

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == MLAKeyValueObserverCenterContext) {
        
        NSMutableArray *predicates = [NSMutableArray array];
        
        if (object) {
            NSPredicate *objectPredicate = [NSPredicate predicateWithFormat:@"observedObject == %@",object];
            [predicates addObject:objectPredicate];
        }
        
        if (keyPath) {
            NSPredicate *keyPathPredicate = [NSPredicate predicateWithFormat:@"keyPath == %@",keyPath];
            [predicates addObject:keyPathPredicate];
        }
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSSet *filteredKeyValueObservers = [self.keyValueObservers filteredSetUsingPredicate:predicate];
        
        for (MLAKeyValueObserver *aKeyValueObserver in filteredKeyValueObservers) {
            // if it has a block, call it
            if (aKeyValueObserver.block) {
                aKeyValueObserver.block(change);
            }
            
            // if it has a selector, call it
            if (aKeyValueObserver.selector) {
                if ([aKeyValueObserver.observer respondsToSelector:aKeyValueObserver.selector]) {
                    objc_msgSend(aKeyValueObserver.observer, aKeyValueObserver.selector,change);
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
