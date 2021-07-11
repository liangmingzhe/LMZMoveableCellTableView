//
//  LMZCellModel.h
//  LMZMoveableCellTableView
//
//  Created by lmz on 2021/7/11.
//

#import <Foundation/Foundation.h>
@class PlanModel;
NS_ASSUME_NONNULL_BEGIN

@interface LMZCellModel : NSObject
@property (nonatomic ,copy) NSString *title;                // section title

@property (nonatomic ,strong) NSMutableArray<PlanModel *> *cellArray;    // cell

@end


@interface PlanModel : NSObject

@end

NS_ASSUME_NONNULL_END
