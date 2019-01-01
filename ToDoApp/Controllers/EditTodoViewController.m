//
//  EditTodoViewController.m
//  FireList
//
//  Created by Developer on 2/7/15.
//  Copyright (c) 2015 JDare. All rights reserved.
//

#import "EditTodoViewController.h"
#import "TodoItem.h"

@interface EditTodoViewController (){
//    TodoItem *todo;
}

@end

@implementation EditTodoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.todoTextField setText:_todo.text];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be rec(nonatomic) reated.
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
        if (_todo == nil) {
            _todo = [[TodoItem alloc] initWithText: self.todoTextField.text];
        } else {
            _todo.text = self.todoTextField.text;
        }
        [self.delegate saveUpdatedTodoItem:_todo];
        [self dismissViewControllerAnimated:YES completion:nil];

    }
}

@end
