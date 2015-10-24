//
//  DetailViewController.m
//  AudioNote
//
//  Created by lijunjie on 15/10/15.
//  Copyright © 2015年 Intfocus. All rights reserved.
//

#import "DetailViewController.h"
#import "Version.h"
#import "FileUtils.h"
#import "const.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>
#import <dlfcn.h>

@interface DetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *listView;

@property (strong, nonatomic) NSArray *dataList;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _dataList = [NSArray array];
    NSString *title = @"notset";
    
    switch(_indexPath) {
        case SettingsAppInfo: {
            NSString *ssID  = @"Not Found";
            NSString *macIP = @"Not Found";
            CFArrayRef myArray = CNCopySupportedInterfaces();
            if (myArray) {
                CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
                if (myDict) {
                    NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
                    
                    ssID = [dict valueForKey:@"SSID"];
                    macIP = [dict valueForKey:@"BSSID"];
                }
            }
            
            Version *version = [[Version alloc] init];
            _dataList = @[
                          @[@"应用信息",
                            @[
                              @[@"应用名称", version.appName],
                              @[@"当前版本", version.current],
                              ]
                            ],
                          @[@"设备信息",
                            @[
                              @[@"系统语言", version.lang],
                              @[@"设备名称", [Version machineHuman]],
                              @[@"系统空间", [FileUtils humanFileSize:version.fileSystemSize]],
                              @[@"可用空间", [FileUtils humanFileSize:version.fileSystemFreeSize]]
                              ]
                            ],
                          @[@"通用信息",
                            @[
                              @[@"SSID", ssID],
                              @[@"MAC IP", macIP],
                              @[@"MAC 地址", [self macaddress]],
                              @[@"WLAN MAC 地址", [self localWiFiIPAddress]]
                             ]
                            ]
                          ];
            title = @"应用信息";
            break;
        }
        default:
            break;
    }
    
    self.navigationItem.title = title;
    
    
    self.listView.backgroundColor = [UIColor whiteColor];
    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor whiteColor]];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentLeft];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor grayColor]];
}

- (NSString *)macaddress {
    int                 mib[6];
    size_t              len;
    char *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    //NSString *outstring = [NSString stringWithFormat:@"xxxxxx", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

- (NSString *) localWiFiIPAddress
{
    BOOL success;
    struct ifaddrs * addrs;
    const struct ifaddrs * cursor;
    
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            // the second test keeps from picking up the loopback address
            if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
            {
                NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
                if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
                    return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_dataList count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return _dataList[section][0];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataList[section][1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSArray *infos = _dataList[section][1][row];
    
    cell.textLabel.text = infos[0];
    cell.detailTextLabel.text = infos[1];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [UIColor whiteColor];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0;
}
@end
