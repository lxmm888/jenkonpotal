//
//  ApiRespModel.h
//  jenkonportal
//
//  Created by 冯文林  on 2017/5/11.
//  Copyright © 2017年 com.xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiRespModel : NSObject

@property (assign, nonatomic) NSInteger errno_;
@property (copy, nonatomic) NSString *errmsg;
@property (strong, nonatomic) id resultset;

@end
