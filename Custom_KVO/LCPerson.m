//
//  LCPerson.m
//  Custom_KVO
//
//  Created by lab team on 2021/5/19.
//

#import "LCPerson.h"

@implementation LCPerson

//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//    return NO;
//}
//
//- (void)setCount:(NSInteger)count {
//    [self willChangeValueForKey:@"count"];
//    _count = count;
//    [self didChangeValueForKey:@"count"];
//}

//- (void)setNewAge:(NSInteger)age {
//    [self willChangeValueForKey:@"age"];
//    _age = age;
//    [self didChangeValueForKey:@"age"];
//}

// 下载进度 -- writtenData/totalData
// 因为"totalData", @"writtenData"的值的改变，会影响到下载进度，通过这个方法，可以关联监听这两个值
+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"downloadProgress"]) {
        NSArray *affectingKeys = @[@"writedData", @"totalData"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:affectingKeys];
    }
    
    return keyPaths;
}
//
//// 重写 downloadProgress 的 getter 方法
- (NSString *)downloadProgress {
    return [[NSString alloc] initWithFormat:@"%f", 1.0f * self.writedData / self.totalData];
}



@end
