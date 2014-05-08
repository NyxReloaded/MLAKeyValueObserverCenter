//
//  MLAKeyValueObserver.h
//  MLAKeyValueObserverCenter
//
//  Created by Nyx on 08/05/2014.
//  Copyright (c) 2014 Nyx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MLAKeyValueObserverBlock)(NSDictionary *changes);

@interface MLAKeyValueObserver : NSObject

@property (weak, nonatomic) id observedObject;
@property (weak, nonatomic) id observer;
@property (copy, nonatomic) NSString *keyPath;
@property (nonatomic) SEL selector;
@property (strong, nonatomic) MLAKeyValueObserverBlock block;

@end
