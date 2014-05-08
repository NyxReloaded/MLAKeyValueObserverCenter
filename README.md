Key Value Observer Center
================

KeyValueObserverCenter allows you to use Key Value Observer as you will do with NSNotificationCenter.

Its purpose is to make K.V.O notification more flexible.
* Selectors and blocks as callback
* Safe remove on observer
* Allow retrieve observers for a given object’s keyPath

### How to use it ?

```objective-c
[[MLAKeyValueObserverCenter defaultCenter] addObserver:self selector:@selector(titleDidChange:) keyPath:@"title" object:self.person];
```


```objective-c
- (void)titleDidChange:(NSDictionary *)change
{
   // implementation go here
}
```

### Using block 

```objective-c
id observer = [[MLAKeyValueObserverCenter defaultCenter] addObserverForKeyPath:@"name" object:self usingBlock:^(NSDictionary *changes) {
        NSLog(@« Name has changed ! »);
    }];
```





