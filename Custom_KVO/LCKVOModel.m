//
//  LCKVOModel.m
//  Custom_KVO
//
//  Created by lab team on 2021/5/20.
//

#import "LCKVOModel.h"

@implementation LCKVOModel

- (void)setName:(NSString *)name{
    NSLog(@"来到 CJLPerson 的setter方法 :%@",name);
    _name = name;
}

@end
