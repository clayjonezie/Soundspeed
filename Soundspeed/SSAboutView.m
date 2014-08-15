//
//  SSAboutView.m
//  Soundspeed
//
//  Created by Clay on 8/5/14.
//  Copyright (c) 2014 Clay Jones. All rights reserved.
//

#import "SSAboutView.h"

@interface SSAboutView ()

@property (nonatomic) UITextView *textView;

@end

@implementation SSAboutView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      _textView = [[UITextView alloc] initWithFrame:frame];
      [_textView setFont:[SSStylesheet primaryFontLarge]];
      [_textView setTextColor:[SSStylesheet primaryColor]];
      [_textView setTextAlignment:NSTextAlignmentNatural];
      CGFloat inset = 15.0f;
      [_textView setTextContainerInset:UIEdgeInsetsMake(inset, inset, inset, inset)];
      [_textView setEditable:NO];
      [_textView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
      [_textView setText:@"Soundspeed was created by Clay Jones. Send suggestions, compliments, and complaints to @clay_jones on Twitter. \n\nSoundspeed requires a Dropbox account to store your recordings. This lets you access them from anywhere. Go to Dropbox.com to sign up for a free account. \n\nThe ability to delete recordings from Dropbox will come in the next version. You can currently do this in the Dropbox app, or at www.dropbox.com. \n\nThank you for purchasing Soundspeed. All proceeds go directly to my tuition. And coffee. \n\nIf you enjoy Soundspeed, please support independent software by telling everybody you know, and submitting a review in the App Store."];
      [self addSubview:_textView];
    }
    return self;
}



@end
