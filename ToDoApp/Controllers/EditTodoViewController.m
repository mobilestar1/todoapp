//
//  EditTodoViewController.m
//  FireList
//
//  Created by Developer on 2/7/15.
//  Copyright (c) 2015 JDare. All rights reserved.
//

#import "EditTodoViewController.h"
#import "TodoItem.h"

@interface EditTodoViewController ()

@end

@implementation EditTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneBtnPressed:(id)sender {
    if (self.todoTextField.text.length > 0)
    {
        TodoItem *todo = [[TodoItem alloc] initWithText:self.todoTextField.text];
        [self.delegate saveUpdatedTodoItem:todo];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}
@end
