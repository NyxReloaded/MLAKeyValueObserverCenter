Key Value Observer Center
================

MLAKeyValueObserverCenter allows you to use K.V.O as you will do with NSNotificationCenter.

Its purpose is to make K.V.O notification more flexible :
* Selectors and blocks as callback
* Safe remove observer
* Allow retrieve observers for a given object’s keyPath

### How to use it ?

```objective-c
[[MLAKeyValueObserverCenter defaultCenter] addObserver:self 
                                              selector:@selector(titleDidChange:) 
                                               keyPath:@"name" 
                                                object:self.person];
```


```objective-c
- (void)titleDidChange:(NSDictionary *)change
{
   // implementation go here
}
```

```objective-c
[[MLAKeyValueObserverCenter defaultCenter] removeObserver:self];
```

### Using block 

```objective-c
id observer = [[MLAKeyValueObserverCenter defaultCenter] addObserverForKeyPath:@"name" 
                                                                        object:self.person 
                                                                    usingBlock:^(NSDictionary *changes) {
        NSLog(@"Name has changed !");
    }];
```





