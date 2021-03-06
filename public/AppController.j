/*
 * The MIT License
 * 
 * Copyright (c) 2009, 2010 Leif Singer
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */

@import <Foundation/CPObject.j>
@import "UpdateConnection.j"

@implementation AppController : CPObject
{
    CPView _contentView;
    CPString _nickname;
    CPTextField _nicknameTextField;
    CPTextField _chatTextField;
    CPScrollView _chatPanel;
    CPPanel _nicknameHUD;
    CPArray _messages @accessors;
    CPCollectionView _messagesCollectionView @accessors;
    CPWindow _theWindow;
    CPTableView _tableView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    CPLogRegister(CPLogConsole);
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
        _contentView = [theWindow contentView];
    var bounds = [_contentView bounds];
    _theWindow = theWindow;

    _messages = [];
    
    [_contentView setBackgroundColor:[CPColor colorWithHexString:@"A8C0D1"]];
    
    var _nicknameHUD = [[CPPanel alloc] initWithContentRect:CGRectMake(25, 50, 225, 125) styleMask:CPHUDBackgroundWindowMask];
    [_nicknameHUD setTitle:@"Please enter a nickname"];
    [_nicknameHUD setFrameOrigin: CGPointMake([_contentView center].x - CGRectGetWidth([[_nicknameHUD contentView] bounds])/2, [_contentView center].y - CGRectGetHeight([[_nicknameHUD contentView] bounds])/2)];
    [_nicknameHUD setAutoresizingMask: CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
    [_nicknameHUD setFloatingPanel:YES];
    [_nicknameHUD orderFront:self];
    
    var panelContentView = [_nicknameHUD contentView],
        centerX = (CGRectGetWidth([panelContentView bounds]) - 135.0) / 2.0;
    
    // add the nickname textfield
    _nicknameTextField = [CPTextField roundedTextFieldWithStringValue:@"" placeholder:@"Nickname" width:150.0];
    [_nicknameTextField setFrameOrigin:CGPointMake(37, 20)];
    [_nicknameTextField setAction:@selector(saveNickname)];
    [panelContentView addSubview:_nicknameTextField];
    
    // add the save nickname button
    var saveNicknameButton = [[CPButton alloc] initWithFrame:CGRectMake(85, 60, 50, 24)];
    [saveNicknameButton setTitle:@"OK"];
    [saveNicknameButton setTarget:self];
    [saveNicknameButton setAction:@selector(saveNickname)];
    [panelContentView addSubview:saveNicknameButton];
    
    // Add the chat panel
    _chatPanel = [[CPScrollView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(bounds)-20, CGRectGetHeight(bounds)-60)];
    [_chatPanel setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [_chatPanel setBackgroundColor:[CPColor whiteColor]];
    [_chatPanel setAutohidesScrollers:YES];
    [_chatPanel setHasHorizontalScroller:NO];
    
    // Add shadow to the chat panel
    var chatPanelShadow = [[CPShadowView alloc] initWithFrame:CGRectMakeZero()];
    [chatPanelShadow setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [chatPanelShadow setFrameForContentFrame:[_chatPanel frame]];
    [_contentView addSubview:chatPanelShadow];
    [_contentView addSubview:_chatPanel];
    
    _tableView = [[CPTableView alloc] initWithFrame: [_chatPanel bounds]];
    [_chatPanel setDocumentView: _tableView];
    
    var senderCol = [[CPTableColumn alloc] initWithIdentifier: @"sender"];
    [[senderCol headerView] setStringValue: @"Sender"];
    [senderCol setWidth: 125.0];
    [_tableView addTableColumn: senderCol];
    
    var bodyCol = [[CPTableColumn alloc] initWithIdentifier: @"body"];
    [[bodyCol headerView] setStringValue: @"Message"];
    [bodyCol setWidth: CGRectGetWidth([_tableView bounds])-125];
    [[bodyCol headerView] setAutoresizingMask: CPViewWidthSizable];
    [_tableView addTableColumn: bodyCol];
    
    [_tableView setDataSource: self];
    [_tableView setUsesAlternatingRowBackgroundColors: YES];
    [_tableView setHeaderView: nil];
    [_tableView setCornerView: nil];
    
    // Add the chat Textfield
    _chatTextField = [CPTextField roundedTextFieldWithStringValue:@"" placeholder:@"Enter a message. " width:CGRectGetWidth(bounds)-20];
    [_chatTextField setAction:@selector(postMessage)];
    [_chatTextField setAutoresizingMask: CPViewWidthSizable | CPViewMinYMargin];
    [_chatTextField setFrameOrigin:CGPointMake(10, CGRectGetHeight(bounds)-45)];
    [_chatTextField setHidden:YES];
    [_contentView addSubview:_chatTextField];
    
    // add Play! badge
    var playBadge = [[CPImageView alloc] initWithFrame: CGRectMake(CGRectGetWidth(bounds)-139, 15, 124, 25)];
    [playBadge setImage: [[CPImage alloc] initWithContentsOfFile: @"Resources/play.png" size: CGSizeMake(124, 25)]];
    [playBadge setAutoresizingMask: CPViewMinXMargin | CPViewMaxYMargin];
    [_contentView addSubview: playBadge];
    
    [theWindow orderFront: self];
    //[theWindow makeFirstResponder: _nicknameTextField];
}

- (void)saveNickname {
    var theNickname = [_nicknameTextField objectValue];
    if ( theNickname ) {
        _nickname = theNickname;
        [_nicknameHUD orderOut:YES];
        [_chatTextField setHidden:NO];
        [_theWindow orderFront: self];
        //[_theWindow makeFirstResponder:_chatTextField];
        var initialConnection = [[UpdateConnection alloc] init];
    }
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
}

- (void)postMessage
{
    // Encodes the data for submission to the server
    var theSender = encodeURI(_nickname);
    var theBody = encodeURI([_chatTextField objectValue]);
    [_chatTextField setObjectValue: @""];
    var messageHTTP = "m.sender=" + theSender + "&m.body=" + theBody;
    
    // Sends the new message to the server
    var url = "/messages/add";
    var request = [[CPURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:messageHTTP];
    [request setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:"Content-Type"];
    var connection = [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)renderUpdates:(CPArray)anArray
{
    for (i=0; i<[anArray count]; i++) {
        _messages = [_messages arrayByAddingObject:anArray[i]];
    }
    [_tableView reloadData];
    [_messagesCollectionView setContent:_messages];
    // scroll down
    [[_chatPanel documentView] scrollRectToVisible: CGRectMake(0, CGRectGetHeight([[_chatPanel documentView] bounds])-1, 1, 1)];
}

// ---
// CPTableView delegate methods

- (int)numberOfRowsInTableView: (CPTableView)tableView
{
    return [_messages count];
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
    if ( [tableColumn identifier] === @"sender" ) {
        return _messages[row].sender;
    } else {
        return _messages[row].body;
    }
}

@end
