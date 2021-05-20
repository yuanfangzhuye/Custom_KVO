//
//  NSObject+KVO.h
//  Custom_KVO
//
//  Created by lab team on 2021/5/20.
//

#import <Foundation/Foundation.h>

typedef void(^CustomKVOBlock)(id _Nullable observer,NSString * _Nullable keyPath,id _Nonnull oldValue,id _Nullable newValue);

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)


- (void)lc_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

- (void)lc_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;

- (void)lc_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
