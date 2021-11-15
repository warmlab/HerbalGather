//
//  FoodAboutViewController.m
//  HerbalGather
//
//  Created by 狼 恶 on 11-11-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FoodAboutViewController.h"
#import "FoodSettings.h"

@implementation FoodAboutViewController {
	NSInteger fontSize;
}

//@synthesize delegate = _delegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	fontSize = [FoodSettings fontSizeFromSetting];

	// Do any additional setup after loading the view, typically from a nib.
    [about_view setText: @"       中医从食物的性味归经认识食物的功效，并从整体上认识每种食物的养生保健作用，"
     "还结合春暖夏热秋燥冬寒的四时变化，每个人的体质属性，五脏寒热虚实状况和食物之间的相宜相克来把握食物养生的法则。\n"
     "       本软件收录了上百种食物，详细介绍了每种食物的性味归经、功效及其食疗价值和部分食物的相宜相克。\n"
     "       本软件所介绍的食物中，有些食物属国家保护生物或极不常见，可食性意义不大，在这里仅作为传统饮食文化加以介绍。\n"
     "       感谢您的下载使用，如果您在使用过程中有任何问题或者建议，欢迎随时email至warmlab@me.com，真诚期待您的建议和反馈。"
     ];
	[about_view setFont: [UIFont fontWithName: @"Helvetica" size: fontSize]];
	self.navigationItem.title = @"关于";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
