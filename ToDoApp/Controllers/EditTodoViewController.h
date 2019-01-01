//
//  EditTodoViewController.h
//  FireList
//
//  Created by Developer on 2/7/15.
//  Copyright (c) 2015 JDare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TodoItem.h"

@protocol EditTodoViewControllerDelegate <NSObject>

- (void) saveUpdatedTodoItem:(TodoItem *)todo;

@end

@interface EditTodoViewController : UIViewController
- (IBAction)cancelBtnPressed:(id)sender;
- (IBAction)doneBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *todoTextField;
@property (weak, nonatomic) id <EditTodoViewControllerDelegate> delegate;

@end
