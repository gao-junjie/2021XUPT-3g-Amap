//
//  SearchViewController.h
//  GaodeMap
//
//  Created by mac on 2021/12/6.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : UIViewController <UITextFieldDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate>

@property (strong, nonatomic) NSString* searchString;
@property (strong, nonatomic) UISearchController* searchController;
@property (strong, nonatomic) UITableView* searchTableView;
@property (strong, nonatomic) NSMutableArray* listArray;
@property (strong, nonatomic) NSMutableArray* listNameArray;
@property (strong, nonatomic) AMapSearchAPI* searchAPI;
@end

NS_ASSUME_NONNULL_END
