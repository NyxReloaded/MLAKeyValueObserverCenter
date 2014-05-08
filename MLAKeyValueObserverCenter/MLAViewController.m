//
//  MLAViewController.m
//  MLAKeyValueObserverCenter
//
//  Created by Nyx on 08/05/2014.
//  Copyright (c) 2014 Nyx. All rights reserved.
//

#import "MLAViewController.h"

#import "MLAKeyValueObserverCenter.h"

@interface MLAViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *title;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) MLAKeyValueObserverCenter *anotherCenter;
@property (strong, nonatomic) id observer;
@property (strong, nonatomic) id observer2;

@end

@implementation MLAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // In order to show that the selector can have no paramaters
    [[MLAKeyValueObserverCenter defaultCenter] addObserver:self selector:@selector(titleChanged) keyPath:@"title" object:self];
    
    self.anotherCenter = [[MLAKeyValueObserverCenter alloc] init];
    self.observer2 = [self.anotherCenter addObserverForKeyPath:@"name" object:self usingBlock:^(NSDictionary *changes) {
        NSLog(@"name changed using another center is used..");
    }];
    
    [self addObserverWithBlock:nil];
    [self addObserverWithSelector:nil];
}

- (void)dealloc
{
    [[MLAKeyValueObserverCenter defaultCenter] removeObserver:self];
    [[MLAKeyValueObserverCenter defaultCenter] removeObserver:self.observer];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.name = textField.text;
    self.title = @"aTitle";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
#pragma mark - 

- (void)nameDidChange:(NSDictionary *)change
{
    NSLog(@"SELECTOR nameDidChange: => name did change !!");
//    NSLog(@"old value = %@ / new value = %@",change[NSKeyValueChangeOldKey],change[NSKeyValueChangeNewKey]);
}

- (void)titleChanged
{
    NSLog(@"SELECTOR titleChanged => title did change !!");
}

#pragma mark - IBActions

- (IBAction)addObserverWithSelector:(id)sender
{
    [[MLAKeyValueObserverCenter defaultCenter] addObserver:self selector:@selector(nameDidChange:) keyPath:@"name" object:self];
}

- (IBAction)addObserverWithBlock:(id)sender
{
    [[MLAKeyValueObserverCenter defaultCenter] removeObserver:self.observer];
    self.observer = [[MLAKeyValueObserverCenter defaultCenter] addObserverForKeyPath:@"name" object:self usingBlock:^(NSDictionary *changes) {
        NSLog(@"BLOCK => name did change !!");
//        NSLog(@"old value = %@ / new value = %@",changes[NSKeyValueChangeOldKey],changes[NSKeyValueChangeNewKey]);
    }];
}

- (IBAction)removeObserverWithSelector:(id)sender
{
    [[MLAKeyValueObserverCenter defaultCenter] removeObserver:self keyPath:@"name" object:self];
}

- (IBAction)removeObserverWithBlock:(id)sender
{
    [[MLAKeyValueObserverCenter defaultCenter] removeObserver:self.observer];
}

- (IBAction)removeAllObservers:(id)sender
{
    [[MLAKeyValueObserverCenter defaultCenter] removeAllObserversForKeyPath:@"name" object:self];
}
@end
