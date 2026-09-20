/**
 * Mathtype-kh - 64-bit Native C++ / Objective-C Edition
 * Powered by LaTeX Kernel (/Library/TeX/texbin/latex + dvipng + dvisvgm)
 * With Microsoft Word Auto-Insertion & True Baseline Alignment
 */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#include <iostream>
#include <string>
#include <vector>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

@interface TeXResult : NSObject
@property (assign, nonatomic) BOOL success;
@property (copy, nonatomic) NSString *pngPath;
@property (copy, nonatomic) NSString *svgPath;
@property (copy, nonatomic) NSString *pdfPath;
@property (assign, nonatomic) double depth;
@property (assign, nonatomic) double height;
@property (assign, nonatomic) double width;
@property (assign, nonatomic) double ratio;
@property (copy, nonatomic) NSString *errorMessage;
@end

@implementation TeXResult
- (instancetype)init {
    self = [super init];
    if (self) {
        _success = NO;
        _pngPath = @"";
        _svgPath = @"";
        _pdfPath = @"";
        _depth = 3.5;
        _height = 14.0;
        _width = 70.0;
        _ratio = 0.22;
        _errorMessage = @"";
    }
    return self;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, WKScriptMessageHandler>
@property (strong, nonatomic) NSWindow *window;
@property (strong, nonatomic) WKWebView *webView;
- (TeXResult *)compileWithLaTeXKernel:(NSString *)latex fontSize:(double)fontSize;
+ (BOOL)renderPDF:(NSString *)pdfPath toPNG:(NSString *)pngPath dpi:(double)dpi;
- (void)insertEquationIntoWord:(TeXResult *)texRes latex:(NSString *)latex;
- (void)handleToggleTeX;
- (void)toggleTeXMenu:(id)sender;
- (NSString *)currentTeXPreamble;
- (NSString *)currentTeXEngine;
- (void)showLaTeXPreambleConfig:(id)sender;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // 1. Setup Standard macOS Menus
    NSMenu *mainMenu = [[NSMenu alloc] init];
    
    // Application Menu
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Mathtype-kh"];
    [appMenu addItemWithTitle:@"About Mathtype-kh" action:@selector(showAbout:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Hide Mathtype-kh" action:@selector(hide:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:@"Quit Mathtype-kh" action:@selector(terminate:) keyEquivalent:@"q"];
    [appMenuItem setSubmenu:appMenu];
    [mainMenu addItem:appMenuItem];
    
    // File Menu
    NSMenuItem *fileMenuItem = [[NSMenuItem alloc] init];
    NSMenu *fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    [fileMenu addItemWithTitle:@"New Equation" action:@selector(newEquation:) keyEquivalent:@"n"];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Open Microsoft Word" action:@selector(openWordMenu:) keyEquivalent:@"o"];
    [fileMenu addItemWithTitle:@"Insert into Word" action:@selector(insertToWordMenu:) keyEquivalent:@"i"];
    [fileMenu addItemWithTitle:@"Toggle TeX (From Word Selection)" action:@selector(toggleTeXMenu:) keyEquivalent:@"\\"];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Save as PNG Image..." action:@selector(savePNG:) keyEquivalent:@"s"];
    [fileMenu addItemWithTitle:@"Save as SVG..." action:@selector(saveSVG:) keyEquivalent:@""];
    [fileMenu addItemWithTitle:@"Save as Vector PDF..." action:@selector(savePDF:) keyEquivalent:@""];
    [fileMenu addItemWithTitle:@"Save as LaTeX..." action:@selector(saveLaTeX:) keyEquivalent:@""];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle:@"Close Window" action:@selector(performClose:) keyEquivalent:@"w"];
    [fileMenuItem setSubmenu:fileMenu];
    [mainMenu addItem:fileMenuItem];
    
    // Edit Menu
    NSMenuItem *editMenuItem = [[NSMenuItem alloc] init];
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy to Word" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Toggle TeX" action:@selector(toggleTeXMenu:) keyEquivalent:@"\\"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Insert Khmer Text..." action:@selector(insertKhmerTextMenu:) keyEquivalent:@"T"];
    [editMenu addItemWithTitle:@"Equation History..." action:@selector(historyMenu:) keyEquivalent:@"H"];
    [editMenu addItemWithTitle:@"Favorites..." action:@selector(favoritesMenu:) keyEquivalent:@""];
    [editMenuItem setSubmenu:editMenu];
    [mainMenu addItem:editMenuItem];

    // Help Menu
    NSMenuItem *helpMenuItem = [[NSMenuItem alloc] init];
    NSMenu *helpMenu = [[NSMenu alloc] initWithTitle:@"Help"];
    [helpMenu addItemWithTitle:@"Keyboard Shortcuts Guide..." action:@selector(showHelp:) keyEquivalent:@"?"];
    [helpMenu addItemWithTitle:@"Configure LaTeX Path..." action:@selector(showLaTeXConfig:) keyEquivalent:@""];
    [helpMenu addItemWithTitle:@"Configure LaTeX Preamble..." action:@selector(showLaTeXPreambleConfig:) keyEquivalent:@""];
    [helpMenu addItem:[NSMenuItem separatorItem]];
    [helpMenu addItemWithTitle:@"Check for Updates..." action:@selector(checkForUpdatesMenu:) keyEquivalent:@""];
    [helpMenu addItem:[NSMenuItem separatorItem]];
    [helpMenu addItemWithTitle:@"About Mathtype-kh..." action:@selector(showAbout:) keyEquivalent:@""];
    [helpMenuItem setSubmenu:helpMenu];
    [mainMenu addItem:helpMenuItem];
    
    [NSApp setMainMenu:mainMenu];

    // 2. Setup Native Window
    NSRect screenRect = [[NSScreen mainScreen] visibleFrame];
    CGFloat width = 1180;
    CGFloat height = 780;
    CGFloat x = (screenRect.size.width - width) / 2;
    CGFloat y = (screenRect.size.height - height) / 2;

    NSRect frame = NSMakeRect(x, y, width, height);
    NSUInteger style = NSWindowStyleMaskTitled |
                       NSWindowStyleMaskClosable |
                       NSWindowStyleMaskMiniaturizable |
                       NSWindowStyleMaskResizable;
    
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:style
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Mathtype-kh"];
    [self.window setMinSize:NSMakeSize(800, 500)];
    [self.window setDelegate:self];
    
    // 3. Setup WKWebView with Script Message Handler
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
    @try {
        [config.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
        [config setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    } @catch (NSException *e) {
        std::cerr << "Config warning: " << [[e reason] UTF8String] << std::endl;
    }
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    [userController addScriptMessageHandler:self name:@"nativeApp"];
    config.userContentController = userController;
    
    self.webView = [[WKWebView alloc] initWithFrame:[self.window.contentView bounds] configuration:config];
    [self.webView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.window.contentView addSubview:self.webView];

    // 4. Locate and load local bundle
    NSURL *bundleResourceURL = [[NSBundle mainBundle] resourceURL];
    NSURL *appIndexURL = [bundleResourceURL URLByAppendingPathComponent:@"app/index.html"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[appIndexURL path]]) {
        [self.webView loadFileURL:appIndexURL allowingReadAccessToURL:bundleResourceURL];
    } else {
        NSString *altPath = @"/Users/heng/Downloads/Update mathtype/app/index.html";
        NSURL *altURL = [NSURL fileURLWithPath:altPath];
        [self.webView loadFileURL:altURL allowingReadAccessToURL:[altURL URLByDeletingLastPathComponent]];
    }

    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    [self startLocalServer];
}

#pragma mark - Local Word Integration Server (127.0.0.1:45678)

- (void)startLocalServer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int server_fd = socket(AF_INET, SOCK_STREAM, 0);
        if (server_fd < 0) {
            std::cerr << "[Local Server] Failed to create socket" << std::endl;
            return;
        }
        int opt = 1;
        setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
        
        struct sockaddr_in address;
        memset(&address, 0, sizeof(address));
        address.sin_family = AF_INET;
        address.sin_addr.s_addr = inet_addr("127.0.0.1");
        address.sin_port = htons(45678);
        
        if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
            std::cerr << "[Local Server] Port 45678 already bound or in use" << std::endl;
            close(server_fd);
            return;
        }
        
        if (listen(server_fd, 10) < 0) {
            close(server_fd);
            return;
        }
        std::cout << "[Local Server] Mathtype-kh Word Integration server listening on 127.0.0.1:45678" << std::endl;
        
        while (true) {
            struct sockaddr_in client_addr;
            socklen_t client_len = sizeof(client_addr);
            int client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
            if (client_fd < 0) continue;
            
            char buffer[16384];
            ssize_t bytes_read = recv(client_fd, buffer, sizeof(buffer) - 1, 0);
            if (bytes_read > 0) {
                buffer[bytes_read] = '\0';
                NSString *request = [NSString stringWithUTF8String:buffer];
                if (!request) request = [[NSString alloc] initWithBytes:buffer length:bytes_read encoding:NSISOLatin1StringEncoding];
                [self handleHTTPRequest:request clientFD:client_fd];
            } else {
                close(client_fd);
            }
        }
    });
}

- (void)handleHTTPRequest:(NSString *)request clientFD:(int)client_fd {
    NSString *responseBody = @"{\"status\":\"ok\"}";
    
    if ([request containsString:@"/new-inline"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp activateIgnoringOtherApps:YES];
            [self.window makeKeyAndOrderFront:nil];
            [self.webView evaluateJavaScript:@"actionClear()" completionHandler:nil];
        });
    } else if ([request containsString:@"/edit"]) {
        // Parse JSON payload
        NSRange bodyRange = [request rangeOfString:@"\r\n\r\n"];
        if (bodyRange.location == NSNotFound) {
            bodyRange = [request rangeOfString:@"\n\n"];
        }
        NSString *body = @"";
        if (bodyRange.location != NSNotFound) {
            body = [request substringFromIndex:bodyRange.location + bodyRange.length];
        }
        
        NSString *latex = @"";
        if ([body length] > 0) {
            NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && json[@"latex"]) {
                latex = [NSString stringWithFormat:@"%@", json[@"latex"]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp activateIgnoringOtherApps:YES];
            [self.window makeKeyAndOrderFront:nil];
            if ([latex length] > 0) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[latex] options:0 error:nil];
                NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSString *js = [NSString stringWithFormat:@"loadLatexFromWord(%@[0])", jsonArray];
                [self.webView evaluateJavaScript:js completionHandler:nil];
            }
        });
    } else if ([request containsString:@"/toggle-tex"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleToggleTeX];
        });
    } else if ([request containsString:@"/eval"]) {
        NSRange bodyRange = [request rangeOfString:@"\r\n\r\n"];
        if (bodyRange.location == NSNotFound) bodyRange = [request rangeOfString:@"\n\n"];
        NSString *body = @"";
        if (bodyRange.location != NSNotFound) {
            body = [request substringFromIndex:bodyRange.location + bodyRange.length];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:body completionHandler:nil];
        });
    }
    
    NSString *httpResponse = [NSString stringWithFormat:
        @"HTTP/1.1 200 OK\r\n"
        @"Content-Type: application/json\r\n"
        @"Access-Control-Allow-Origin: *\r\n"
        @"Content-Length: %lu\r\n"
        @"Connection: close\r\n\r\n%@",
        (unsigned long)[responseBody lengthOfBytesUsingEncoding:NSUTF8StringEncoding],
        responseBody];
        
    send(client_fd, [httpResponse UTF8String], [httpResponse lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 0);
    close(client_fd);
}

#pragma mark - LaTeX Kernel Compilation Engine

- (NSString *)currentTeXBinPath {
    NSString *custom = [[NSUserDefaults standardUserDefaults] stringForKey:@"TeXBinPath"];
    if (custom && [custom length] > 0) {
        return custom;
    }
    NSArray<NSString *> *candidates = @[
        @"/Library/TeX/texbin",
        @"/opt/homebrew/bin",
        @"/usr/local/bin",
        @"/usr/bin"
    ];
    for (NSString *candidate in candidates) {
        NSString *latex = [candidate stringByAppendingPathComponent:@"latex"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:latex]) {
            return candidate;
        }
    }
    return @"/Library/TeX/texbin";
}

+ (BOOL)renderPDF:(NSString *)pdfPath toPNG:(NSString *)pngPath dpi:(double)dpi {
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdfPath]) return NO;
    NSURL *url = [NSURL fileURLWithPath:pdfPath];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
    if (!pdf) return NO;
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 1);
    if (!page) {
        CGPDFDocumentRelease(pdf);
        return NO;
    }
    CGRect box = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    if (CGRectIsEmpty(box)) box = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
    if (CGRectIsEmpty(box)) {
        CGPDFDocumentRelease(pdf);
        return NO;
    }
    
    double scale = dpi / 72.0;
    size_t width = (size_t)ceil(box.size.width * scale);
    size_t height = (size_t)ceil(box.size.height * scale);
    if (width == 0 || height == 0) {
        CGPDFDocumentRelease(pdf);
        return NO;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    if (!ctx) {
        CGPDFDocumentRelease(pdf);
        return NO;
    }
    
    CGContextClearRect(ctx, CGRectMake(0, 0, width, height));
    CGContextScaleCTM(ctx, scale, scale);
    CGContextTranslateCTM(ctx, -box.origin.x, -box.origin.y);
    CGContextDrawPDFPage(ctx, page);
    
    CGImageRef img = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGPDFDocumentRelease(pdf);
    if (!img) return NO;
    
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:img];
    [rep setSize:NSMakeSize(box.size.width, box.size.height)];
    NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    CGImageRelease(img);
    if (!pngData) return NO;
    return [pngData writeToFile:pngPath atomically:YES];
}

- (TeXResult *)compileWithLaTeXKernel:(NSString *)latex fontSize:(double)fontSize {
    TeXResult *result = [[TeXResult alloc] init];
    if (fontSize <= 0) fontSize = 12.0;

    NSString *texBin = [self currentTeXBinPath];
    NSString *latexBin = [texBin stringByAppendingPathComponent:@"latex"];
    NSString *xelatexBin = [texBin stringByAppendingPathComponent:@"xelatex"];
    NSString *xdvipdfmxBin = [texBin stringByAppendingPathComponent:@"xdvipdfmx"];
    NSString *dvipngBin = [texBin stringByAppendingPathComponent:@"dvipng"];
    NSString *dvisvgmBin = [texBin stringByAppendingPathComponent:@"dvisvgm"];
    NSString *dvipdfmxBin = [texBin stringByAppendingPathComponent:@"dvipdfmx"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:latexBin] && ![[NSFileManager defaultManager] fileExistsAtPath:xelatexBin]) {
        result.errorMessage = [NSString stringWithFormat:@"LaTeX/XeLaTeX binary not found in %@", texBin];
        std::cerr << "[TeX Engine Error] " << [result.errorMessage UTF8String] << std::endl;
        return result;
    }

    BOOL hasUnicode = NO;
    for (NSUInteger i = 0; i < [latex length]; i++) {
        if ([latex characterAtIndex:i] > 127) {
            hasUnicode = YES;
            break;
        }
    }

    // Create a temporary workspace directory
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *texFile = [tempDir stringByAppendingPathComponent:@"equation.tex"];

    NSString *trimmed = [latex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *bodyContent = @"";
    if ([trimmed hasPrefix:@"\\begin{align"] || [trimmed hasPrefix:@"\\begin{equation"] || [trimmed hasPrefix:@"\\["]) {
        bodyContent = trimmed;
    } else {
        bodyContent = [NSString stringWithFormat:@"$ \\displaystyle %@ $", trimmed];
    }

    double baselineSkip = fontSize * 1.25;
    NSDictionary *env = @{
        @"PATH": [NSString stringWithFormat:@"%@:/usr/bin:/bin:/usr/sbin:/sbin", texBin]
    };

    NSString *pngFile = [tempDir stringByAppendingPathComponent:@"equation.png"];
    NSString *svgFile = [tempDir stringByAppendingPathComponent:@"equation.svg"];
    NSString *pdfFile = [tempDir stringByAppendingPathComponent:@"equation.pdf"];

    NSString *configuredEngine = [self currentTeXEngine];
    NSString *userPreamble = [self currentTeXPreamble];
    BOOL useXeLaTeX = NO;
    if ([configuredEngine isEqualToString:@"xelatex"]) {
        useXeLaTeX = YES;
    } else if ([configuredEngine isEqualToString:@"pdflatex"]) {
        useXeLaTeX = NO;
    } else {
        // "auto": if equation contains Unicode/Khmer, or preamble uses fontspec/XeTeX, use XeLaTeX!
        if (hasUnicode || [userPreamble containsString:@"fontspec"] || [userPreamble containsString:@"\\setmainfont"]) {
            useXeLaTeX = YES;
        } else {
            useXeLaTeX = NO;
        }
    }

    if (useXeLaTeX && ![[NSFileManager defaultManager] fileExistsAtPath:xelatexBin]) {
        std::cerr << "[TeX Engine] Warning: XeLaTeX requested but binary not found at " << [xelatexBin UTF8String] << ". Falling back to LaTeX." << std::endl;
        useXeLaTeX = NO;
    }

    if (useXeLaTeX) {
        std::cout << "[TeX Engine] Compiling with XeLaTeX (Engine: " << [configuredEngine UTF8String] << ") at " << fontSize << "pt..." << std::endl;
        NSString *xePreamble = userPreamble;
        xePreamble = [xePreamble stringByReplacingOccurrencesOfString:@"\\usepackage{lmodern}\n" withString:@""];
        xePreamble = [xePreamble stringByReplacingOccurrencesOfString:@"\\usepackage{lmodern}" withString:@""];
        if (![xePreamble containsString:@"fontspec"] && ![xePreamble containsString:@"\\setmainfont"]) {
            xePreamble = [NSString stringWithFormat:
                @"%@\n"
                @"\\usepackage{fontspec}\n"
                @"\\IfFontExistsTF{Khmer OS Battambang}{\n"
                @"    \\setmainfont{Khmer OS Battambang}\n"
                @"}{\n"
                @"    \\IfFontExistsTF{Khmer OS}{\n"
                @"        \\setmainfont{Khmer OS}\n"
                @"    }{\n"
                @"        \\IfFontExistsTF{Noto Sans Khmer}{\n"
                @"            \\setmainfont{Noto Sans Khmer}\n"
                @"        }{\n"
                @"            \\IfFontExistsTF{Khmer Sangam MN}{\n"
                @"                \\setmainfont{Khmer Sangam MN}\n"
                @"            }{\n"
                @"                \\setmainfont{Khmer MN}\n"
                @"            }\n"
                @"        }\n"
                @"    }\n"
                @"}\n", xePreamble];
        }

        NSString *texSource = [NSString stringWithFormat:
            @"\\documentclass[preview,border=0pt]{standalone}\n"
            @"%@\n"
            @"\\begin{document}\n"
            @"\\fontsize{%.1fpt}{%.1fpt}\\selectfont\n"
            @"%@\n"
            @"\\end{document}\n", xePreamble, fontSize, baselineSkip, bodyContent];

        [texSource writeToFile:texFile atomically:YES encoding:NSUTF8StringEncoding error:nil];

        // 1. Run xelatex -no-pdf to produce equation.xdv
        NSTask *xeTask = [[NSTask alloc] init];
        xeTask.environment = env;
        xeTask.currentDirectoryPath = tempDir;
        xeTask.launchPath = xelatexBin;
        xeTask.arguments = @[@"-no-pdf", @"-interaction=nonstopmode", @"equation.tex"];
        [xeTask launch];
        [xeTask waitUntilExit];

        NSString *xdvFile = [tempDir stringByAppendingPathComponent:@"equation.xdv"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:xdvFile]) {
            // 2. Convert xdv to pdf using xdvipdfmx
            if ([[NSFileManager defaultManager] fileExistsAtPath:xdvipdfmxBin]) {
                NSTask *pdfTask = [[NSTask alloc] init];
                pdfTask.environment = env;
                pdfTask.currentDirectoryPath = tempDir;
                pdfTask.launchPath = xdvipdfmxBin;
                pdfTask.arguments = @[@"-o", @"equation.pdf", @"equation.xdv"];
                [pdfTask launch];
                [pdfTask waitUntilExit];
            }
            // 3. Convert xdv to svg using dvisvgm
            if ([[NSFileManager defaultManager] fileExistsAtPath:dvisvgmBin]) {
                NSTask *svgTask = [[NSTask alloc] init];
                svgTask.environment = env;
                svgTask.currentDirectoryPath = tempDir;
                svgTask.launchPath = dvisvgmBin;
                svgTask.arguments = @[@"--no-styles", @"--exact-bbox", @"equation.xdv", @"-o", @"equation.svg"];
                [svgTask launch];
                [svgTask waitUntilExit];
            }
            // 4. Render pdf to 300 DPI transparent png
            if ([[NSFileManager defaultManager] fileExistsAtPath:pdfFile]) {
                result.pdfPath = pdfFile;
                [AppDelegate renderPDF:pdfFile toPNG:pngFile dpi:300.0];
            }
        }
    } else {
        // Standard LaTeX (pdftex)
        // Clean fontspec and Khmer font blocks so pdfLaTeX NEVER crashes
        NSString *preamble = userPreamble;
        if ([preamble containsString:@"fontspec"] || [preamble containsString:@"\\setmainfont"]) {
            NSMutableArray *filteredLines = [NSMutableArray array];
            NSArray *lines = [preamble componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            for (NSString *l in lines) {
                NSString *tl = [l stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if ([tl containsString:@"fontspec"] || [tl containsString:@"\\setmainfont"] || [tl containsString:@"\\IfFontExistsTF"] || [tl containsString:@"Khmer"]) {
                    continue;
                }
                [filteredLines addObject:l];
            }
            preamble = [filteredLines componentsJoinedByString:@"\n"];
        }
        if (![preamble containsString:@"\\usepackage{lmodern}"]) {
            preamble = [NSString stringWithFormat:@"\\usepackage{lmodern}\n%@", preamble];
        }

        NSString *texSource = [NSString stringWithFormat:
            @"\\documentclass[preview,border=0pt]{standalone}\n"
            @"%@\n"
            @"\\begin{document}\n"
            @"\\fontsize{%.1fpt}{%.1fpt}\\selectfont\n"
            @"%@\n"
            @"\\end{document}\n", preamble, fontSize, baselineSkip, bodyContent];

        [texSource writeToFile:texFile atomically:YES encoding:NSUTF8StringEncoding error:nil];

        std::cout << "[TeX Engine] Compiling LaTeX at " << fontSize << "pt (Path: " << [texBin UTF8String] << ")..." << std::endl;

        // 1. Run latex to generate equation.dvi
        NSTask *latexTask = [[NSTask alloc] init];
        latexTask.environment = env;
        latexTask.currentDirectoryPath = tempDir;
        latexTask.launchPath = latexBin;
        latexTask.arguments = @[@"-interaction=nonstopmode", @"equation.tex"];
        [latexTask launch];
        [latexTask waitUntilExit];

        NSString *dviFile = [tempDir stringByAppendingPathComponent:@"equation.dvi"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dviFile]) {
            // 2. Run dvipng (300 DPI Transparent Image)
            if ([[NSFileManager defaultManager] fileExistsAtPath:dvipngBin]) {
                NSTask *dvipngTask = [[NSTask alloc] init];
                dvipngTask.environment = env;
                dvipngTask.currentDirectoryPath = tempDir;
                dvipngTask.launchPath = dvipngBin;
                dvipngTask.arguments = @[@"-D", @"300", @"-T", @"tight", @"-bg", @"Transparent", @"-o", @"equation.png", @"equation.dvi"];
                [dvipngTask launch];
                [dvipngTask waitUntilExit];
            }

            // 3. Run dvisvgm
            if ([[NSFileManager defaultManager] fileExistsAtPath:dvisvgmBin]) {
                NSTask *dvisvgmTask = [[NSTask alloc] init];
                dvisvgmTask.environment = env;
                dvisvgmTask.currentDirectoryPath = tempDir;
                dvisvgmTask.launchPath = dvisvgmBin;
                dvisvgmTask.arguments = @[@"--no-styles", @"--no-fonts", @"--exact-bbox", @"equation.dvi", @"-o", @"equation.svg"];
                [dvisvgmTask launch];
                [dvisvgmTask waitUntilExit];
            }

            // 3b. Run dvipdfmx to generate standalone vector PDF
            if ([[NSFileManager defaultManager] fileExistsAtPath:dvipdfmxBin]) {
                NSTask *dvipdfmxTask = [[NSTask alloc] init];
                dvipdfmxTask.environment = env;
                dvipdfmxTask.currentDirectoryPath = tempDir;
                dvipdfmxTask.launchPath = dvipdfmxBin;
                dvipdfmxTask.arguments = @[@"-o", @"equation.pdf", @"equation.dvi"];
                [dvipdfmxTask launch];
                [dvipdfmxTask waitUntilExit];

                if ([[NSFileManager defaultManager] fileExistsAtPath:pdfFile]) {
                    result.pdfPath = pdfFile;
                }
            }
        }
    }

    // Extract SVG bounding box & baseline depth
    if ([[NSFileManager defaultManager] fileExistsAtPath:svgFile]) {
        result.svgPath = svgFile;
        NSString *svgContent = [NSString stringWithContentsOfFile:svgFile encoding:NSUTF8StringEncoding error:nil];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"viewBox\\s*=\\s*['\"]\\s*([-\\d.]+)\\s+([-\\d.]+)\\s+([-\\d.]+)\\s+([-\\d.]+)" options:0 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:svgContent options:0 range:NSMakeRange(0, [svgContent length])];
        if (match && match.numberOfRanges >= 5) {
            double minY = [[svgContent substringWithRange:[match rangeAtIndex:2]] doubleValue];
            double w = [[svgContent substringWithRange:[match rangeAtIndex:3]] doubleValue];
            double h = [[svgContent substringWithRange:[match rangeAtIndex:4]] doubleValue];
            double depth = minY + h;
            result.width = w;
            result.height = h;
            result.depth = depth;
            if (h > 0) {
                double rawRatio = depth / h;
                if (rawRatio >= 0.0 && rawRatio <= 0.85) {
                    result.ratio = rawRatio;
                } else {
                    result.ratio = 0.22;
                }
            }
            std::cout << "[TeX Engine] Exact Bounding Box: width=" << w << "pt, height=" << h << "pt, depth=" << depth << "pt, ratio=" << result.ratio << std::endl;
        }
    }

    // 4. Save PNG to Microsoft Word's own sandbox tmp folder to prevent "Grant File Access" prompt!
    if ([[NSFileManager defaultManager] fileExistsAtPath:pngFile]) {
        // Derive exact point size from generated PNG image if SVG did not provide it
        NSImage *renderedImg = [[NSImage alloc] initWithContentsOfFile:pngFile];
        if (renderedImg) {
            NSImageRep *firstRep = [[renderedImg representations] firstObject];
            if (firstRep && [firstRep isKindOfClass:[NSBitmapImageRep class]]) {
                NSBitmapImageRep *rep = (NSBitmapImageRep *)firstRep;
                if (result.width <= 0) result.width = [rep pixelsWide] * 72.0 / 300.0;
                if (result.height <= 0) result.height = [rep pixelsHigh] * 72.0 / 300.0;
            } else {
                if (result.width <= 0) result.width = renderedImg.size.width * 72.0 / 300.0;
                if (result.height <= 0) result.height = renderedImg.size.height * 72.0 / 300.0;
            }
        }
        if (result.width <= 0) result.width = 70.0;
        if (result.height <= 0) result.height = 20.0;
        if (result.ratio <= 0.0 || result.ratio > 0.85) result.ratio = 0.22;

        NSString *wordTmpDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Containers/com.microsoft.Word/Data/tmp"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:wordTmpDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:wordTmpDir withIntermediateDirectories:YES attributes:nil error:nil];
        }

        // Fallback directory in Group Containers if needed
        if (![[NSFileManager defaultManager] fileExistsAtPath:wordTmpDir]) {
            wordTmpDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Group Containers/UBF8T346G9.Office"];
            [[NSFileManager defaultManager] createDirectoryAtPath:wordTmpDir withIntermediateDirectories:YES attributes:nil error:nil];
        }

        unsigned long long timestamp = (unsigned long long)([[NSDate date] timeIntervalSince1970] * 1000);
        NSString *destFilename = [NSString stringWithFormat:@"mathtype_eq_%llu.png", timestamp];
        NSString *destPath = [wordTmpDir stringByAppendingPathComponent:destFilename];
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
        [[NSFileManager defaultManager] copyItemAtPath:pngFile toPath:destPath error:nil];
        
        result.pngPath = destPath;
        result.success = YES;
        std::cout << "[TeX Engine] Saved 300 DPI PNG in Word Sandbox tmp: " << [destPath UTF8String] << std::endl;
    } else {
        result.errorMessage = @"dvipng failed to produce equation.png";
    }

    return result;
}

#pragma mark - WKScriptMessageHandler & Microsoft Word Integration

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.body isKindOfClass:[NSDictionary class]]) return;
    
    NSDictionary *body = (NSDictionary *)message.body;
    NSString *type = [NSString stringWithFormat:@"%@", body[@"type"] ?: @""];

    if ([type isEqualToString:@"openWord"]) {
        NSURL *wordURL = [NSURL fileURLWithPath:@"/Applications/Microsoft Word.app"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[wordURL path]]) {
            [[NSWorkspace sharedWorkspace] openApplicationAtURL:wordURL
                                                  configuration:[NSWorkspaceOpenConfiguration configuration]
                                              completionHandler:nil];
        } else {
            system("open -a 'Microsoft Word'");
        }
        std::cout << "[Native App] Opened Microsoft Word." << std::endl;
    } else if ([type isEqualToString:@"compileAndInsertWord"] || [type isEqualToString:@"insertIntoWord"] ||
               [type isEqualToString:@"compileAndCopyWord"] || [type isEqualToString:@"copyImage"] || [type isEqualToString:@"copyPNG"]) {
        
        BOOL isInsert = [type isEqualToString:@"compileAndInsertWord"] || [type isEqualToString:@"insertIntoWord"];
        NSString *rawLatex = body[@"latex"] ? [NSString stringWithFormat:@"%@", body[@"latex"]] : @"x=0";
        double fontSize = body[@"fontSize"] ? [body[@"fontSize"] doubleValue] : 14.0;
        if (fontSize <= 0) fontSize = 14.0;
        NSString *fallbackData = body[@"fallbackData"] ? [NSString stringWithFormat:@"%@", body[@"fallbackData"]] : nil;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                // 1. Compile with local TeX Live / MacTeX LaTeX Kernel at requested font size!
                TeXResult *texRes = [self compileWithLaTeXKernel:rawLatex fontSize:fontSize];
                
                // Fallback if TeX kernel failed
                NSData *pngData = nil;
                if (texRes.success && texRes.pngPath && [[NSFileManager defaultManager] fileExistsAtPath:texRes.pngPath]) {
                    pngData = [NSData dataWithContentsOfFile:texRes.pngPath];
                } else if (fallbackData) {
                    NSString *b64 = fallbackData;
                    if ([b64 containsString:@","]) b64 = [b64 componentsSeparatedByString:@","][1];
                    pngData = [[NSData alloc] initWithBase64EncodedString:b64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    NSString *wordTmpDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Containers/com.microsoft.Word/Data/tmp"];
                    [[NSFileManager defaultManager] createDirectoryAtPath:wordTmpDir withIntermediateDirectories:YES attributes:nil error:nil];
                    NSString *destPath = [wordTmpDir stringByAppendingPathComponent:@"mathtype_equation_temp.png"];
                    [pngData writeToFile:destPath atomically:YES];
                    texRes.pngPath = destPath;
                    texRes.success = YES;
                }

                if (pngData) {
                    // Retain path, size, and latex for main queue dispatch
                    NSString *savedPath = [texRes.pngPath copy];
                    double savedRatio = texRes.ratio;
                    double savedW = texRes.width;
                    double savedH = texRes.height;
                    NSString *savedLatex = [rawLatex copy];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        @try {
                            NSPasteboard *pb = [NSPasteboard generalPasteboard];
                            [pb clearContents];

                            // Compute exact point dimensions (matching LaTeX font size / Word inline shape)
                            NSSize pointSize = NSMakeSize(savedW, savedH);
                            if (pointSize.width <= 0 || pointSize.height <= 0) {
                                NSImage *tmp = [[NSImage alloc] initWithData:pngData];
                                if (tmp) {
                                    pointSize = NSMakeSize(tmp.size.width * 72.0 / 300.0, tmp.size.height * 72.0 / 300.0);
                                }
                            }

                            // 1. Prepare NSBitmapImageRep with exact point size
                            NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:pngData];
                            if (rep) {
                                [rep setSize:pointSize];
                            }

                            // 2. Prepare NSImage with exact point dimensions (so Word doesn't blow it up)
                            NSImage *img = [[NSImage alloc] initWithSize:pointSize];
                            if (rep) {
                                [img addRepresentation:rep];
                            } else {
                                img = [[NSImage alloc] initWithData:pngData];
                                [img setSize:pointSize];
                            }

                            // Write Image & File URL objects to pasteboard
                            if (savedPath && [[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
                                [pb writeObjects:@[img, [NSURL fileURLWithPath:savedPath]]];
                            } else {
                                [pb writeObjects:@[img]];
                            }

                            // 3. Write real TIFF data with exact 300 DPI point dimensions
                            NSData *tiffData = rep ? [rep TIFFRepresentation] : [img TIFFRepresentation];
                            if (tiffData) {
                                [pb setData:tiffData forType:NSPasteboardTypeTIFF];
                            }

                            // 4. Write PNG representation with exact point dimensions
                            NSData *rescaledPng = rep ? [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}] : pngData;
                            [pb setData:(rescaledPng ?: pngData) forType:NSPasteboardTypePNG];

                            // 5. Write HTML snippet with exact width, height, vertical alignment, and alt metadata
                            NSString *base64PNG = [(rescaledPng ?: pngData) base64EncodedStringWithOptions:0];
                            double actualDepth = pointSize.height * savedRatio;
                            NSString *htmlSnippet = [NSString stringWithFormat:
                                @"<img src=\"data:image/png;base64,%@\" width=\"%.2f\" height=\"%.2f\" style=\"vertical-align: -%.2fpt;\" alt=\"ratio:%.4f|latex:%@\">",
                                base64PNG, pointSize.width, pointSize.height, actualDepth, savedRatio, savedLatex];
                            [pb setString:htmlSnippet forType:NSPasteboardTypeHTML];

                            // 6. Write plain text LaTeX
                            [pb setString:savedLatex forType:NSPasteboardTypeString];

                            std::cout << "[Clipboard] TeX equation copied with exact size: " << pointSize.width << "x" << pointSize.height << " pt (ratio: " << savedRatio << ")" << std::endl;

                            // If it's insert, run Word AppleScript!
                            if (isInsert) {
                                TeXResult *mainRes = [[TeXResult alloc] init];
                                mainRes.pngPath = savedPath;
                                mainRes.ratio = (savedRatio > 0.0 && savedRatio <= 0.85) ? savedRatio : 0.22;
                                mainRes.width = (pointSize.width > 0) ? pointSize.width : (savedW > 0 ? savedW : 70.0);
                                mainRes.height = (pointSize.height > 0) ? pointSize.height : (savedH > 0 ? savedH : 20.0);
                                mainRes.success = YES;
                                [self insertEquationIntoWord:mainRes latex:savedLatex];
                            }
                        } @catch (NSException *innerEx) {
                            std::cerr << "[Error in pasteboard] " << [[innerEx reason] UTF8String] << std::endl;
                        }
                    });
                }
            } @catch (NSException *ex) {
                std::cerr << "[Error in TeX compilation block] " << [[ex reason] UTF8String] << std::endl;
            }
        });
    } else if ([type isEqualToString:@"copyMathML"]) {
        NSString *mathml = body[@"data"];
        if (mathml) {
            NSPasteboard *pb = [NSPasteboard generalPasteboard];
            [pb clearContents];
            [pb setString:mathml forType:NSPasteboardTypeString];
        }
    } else if ([type isEqualToString:@"copyLaTeX"]) {
        NSString *latex = body[@"data"];
        if (latex) {
            NSPasteboard *pb = [NSPasteboard generalPasteboard];
            [pb clearContents];
            [pb setString:latex forType:NSPasteboardTypeString];
        }
    } else if ([type isEqualToString:@"toggleTeX"]) {
        [self handleToggleTeX];
    } else if ([type isEqualToString:@"checkTeXPath"]) {
        NSString *path = [NSString stringWithFormat:@"%@", body[@"path"] ?: @""];
        if ([path length] == 0) path = [self currentTeXBinPath];
        
        BOOL hasLatex = [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"latex"]];
        BOOL hasDvipng = [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"dvipng"]];
        BOOL hasDvisvgm = [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"dvisvgm"]];
        
        NSString *js = [NSString stringWithFormat:@"updateLaTeXConfigStatus({ latex: %@, dvipng: %@, dvisvgm: %@, path: '%@' })",
                        hasLatex ? @"true" : @"false",
                        hasDvipng ? @"true" : @"false",
                        hasDvisvgm ? @"true" : @"false",
                        path];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:js completionHandler:nil];
        });
    } else if ([type isEqualToString:@"setTeXPath"]) {
        NSString *path = [NSString stringWithFormat:@"%@", body[@"path"] ?: @""];
        if ([path length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"TeXBinPath"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            std::cout << "[LaTeX Config] Updated TeX bin path to: " << [path UTF8String] << std::endl;
        }
    } else if ([type isEqualToString:@"setPreamble"]) {
        NSString *preamble = [NSString stringWithFormat:@"%@", body[@"preamble"] ?: @""];
        NSString *engine = [NSString stringWithFormat:@"%@", body[@"engine"] ?: @"auto"].lowercaseString;
        if (![engine isEqualToString:@"xelatex"] && ![engine isEqualToString:@"pdflatex"] && ![engine isEqualToString:@"auto"]) {
            engine = @"auto";
        }
        [[NSUserDefaults standardUserDefaults] setObject:engine forKey:@"CustomTeXEngine"];

        NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dir = [appSupport stringByAppendingPathComponent:@"Mathtype-kh"];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];

        NSString *enginePath = [dir stringByAppendingPathComponent:@"engine.txt"];
        [engine writeToFile:enginePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

        if ([preamble length] > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:preamble forKey:@"CustomTeXPreamble"];
            NSString *filePath = [dir stringByAppendingPathComponent:@"preamble.tex"];
            [preamble writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        std::cout << "[LaTeX Config] Updated LaTeX preamble and engine: " << [engine UTF8String] << std::endl;
    } else if ([type isEqualToString:@"saveSVG"]) {
        NSString *rawLatex = body[@"latex"] ? [NSString stringWithFormat:@"%@", body[@"latex"]] : @"";
        double fontSize = body[@"fontSize"] ? [body[@"fontSize"] doubleValue] : 14.0;
        if (fontSize <= 0) fontSize = 14.0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TeXResult *texRes = [self compileWithLaTeXKernel:rawLatex fontSize:fontSize];
            if (texRes.svgPath && [[NSFileManager defaultManager] fileExistsAtPath:texRes.svgPath]) {
                NSData *svgData = [NSData dataWithContentsOfFile:texRes.svgPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSSavePanel *savePanel = [NSSavePanel savePanel];
                    [savePanel setNameFieldStringValue:@"equation.svg"];
                    [savePanel setAllowedFileTypes:@[@"svg"]];
                    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
                        if (result == NSModalResponseOK) {
                            NSURL *url = [savePanel URL];
                            [svgData writeToURL:url atomically:YES];
                            [self.webView evaluateJavaScript:@"showStatus('✓ បានរក្សាទុកជា SVG រួចរាល់!', true)" completionHandler:nil];
                        }
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:@"showStatus('កំហុសក្នុងការបង្កើត SVG', false)" completionHandler:nil];
                });
            }
        });
    } else if ([type isEqualToString:@"savePDF"]) {
        NSString *rawLatex = body[@"latex"] ? [NSString stringWithFormat:@"%@", body[@"latex"]] : @"";
        double fontSize = body[@"fontSize"] ? [body[@"fontSize"] doubleValue] : 14.0;
        if (fontSize <= 0) fontSize = 14.0;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TeXResult *texRes = [self compileWithLaTeXKernel:rawLatex fontSize:fontSize];
            if (texRes.pdfPath && [[NSFileManager defaultManager] fileExistsAtPath:texRes.pdfPath]) {
                NSData *pdfData = [NSData dataWithContentsOfFile:texRes.pdfPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSSavePanel *savePanel = [NSSavePanel savePanel];
                    [savePanel setNameFieldStringValue:@"equation.pdf"];
                    [savePanel setAllowedFileTypes:@[@"pdf"]];
                    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
                        if (result == NSModalResponseOK) {
                            NSURL *url = [savePanel URL];
                            [pdfData writeToURL:url atomically:YES];
                            [self.webView evaluateJavaScript:@"showStatus('✓ បានរក្សាទុកជា Vector PDF រួចរាល់!', true)" completionHandler:nil];
                        }
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView evaluateJavaScript:@"showStatus('កំហុសក្នុងការបង្កើត PDF', false)" completionHandler:nil];
                });
            }
        });
    } else if ([type isEqualToString:@"openURL"]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@", body[@"url"] ?: @""];
        if ([urlStr length] > 0) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlStr]];
        }
    } else if ([type isEqualToString:@"getPreamble"]) {
        NSString *preamble = [self currentTeXPreamble];
        NSString *engine = [self currentTeXEngine];
        NSDictionary *dataDict = @{
            @"preamble": preamble,
            @"engine": engine
        };
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *js = [NSString stringWithFormat:@"updateLaTeXPreambleAndEngine(%@)", jsonStr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView evaluateJavaScript:js completionHandler:nil];
        });
    }
}

/**
 * Executes AppleScript to activate Word and insert picture directly with exact LaTeX baseline alignment
 */
- (void)insertEquationIntoWord:(TeXResult *)texRes latex:(NSString *)latex {
    NSString *escapedLatex = [latex stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    escapedLatex = [escapedLatex stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    if (texRes.width <= 0) texRes.width = 70.0;
    if (texRes.height <= 0) texRes.height = 20.0;
    if (texRes.ratio <= 0.0 || texRes.ratio > 0.85) texRes.ratio = 0.22;
    double actualDepth = texRes.height * texRes.ratio;

    NSString *appleScript = [NSString stringWithFormat:
        @"tell application \"Microsoft Word\"\n"
        @"    activate\n"
        @"    if (count of documents) is 0 then\n"
        @"        make new document\n"
        @"    end if\n"
        @"    set doc to active document\n"
        @"    set sel to selection\n"
        @"    set selText to text object of sel\n"
        @"    try\n"
        @"        if (count (inline shapes of sel)) > 0 then\n"
        @"            delete (inline shape 1 of sel)\n"
        @"        else if (count (inline shapes of selText)) > 0 then\n"
        @"            delete (inline shape 1 of selText)\n"
        @"        end if\n"
        @"    end try\n"
        @"    set didInsert to false\n"
        @"    try\n"
        @"        set sPos to start of content of (text object of sel)\n"
        @"        make new inline picture at (text object of sel) with properties {file name:\"%@\"}\n"
        @"        set didInsert to true\n"
        @"        set thePic to missing value\n"
        @"        try\n"
        @"            set totalShapes to count of inline shapes of doc\n"
        @"            repeat with i from 1 to totalShapes\n"
        @"                set p to inline shape i of doc\n"
        @"                set pStart to start of content of (text object of p)\n"
        @"                if pStart >= sPos and pStart <= (sPos + 2) then\n"
        @"                    set thePic to p\n"
        @"                    exit repeat\n"
        @"                end if\n"
        @"            end repeat\n"
        @"        end try\n"
        @"        if thePic is missing value and (count of inline shapes of doc) > 0 then\n"
        @"            set thePic to last inline shape of doc\n"
        @"        end if\n"
        @"        if thePic is not missing value then\n"
        @"            try\n"
        @"                set width of thePic to %.2f\n"
        @"                set height of thePic to %.2f\n"
        @"                set alternative text of thePic to \"ratio:%.4f|latex:%@\"\n"
        @"                set font position of font object of (text object of thePic) to -%.2f\n"
        @"            end try\n"
        @"            try\n"
        @"                set theRange to text object of thePic\n"
        @"                collapse range theRange direction collapse end\n"
        @"                select theRange\n"
        @"            end try\n"
        @"        end if\n"
        @"    end try\n"
        @"    if didInsert is false then\n"
        @"        try\n"
        @"            paste object text object of sel\n"
        @"            set didInsert to true\n"
        @"        on error\n"
        @"            tell application \"System Events\" to keystroke \"v\" using command down\n"
        @"        end try\n"
        @"    end if\n"
        @"end tell\n", texRes.pngPath, texRes.width, texRes.height, texRes.ratio, escapedLatex, actualDepth];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/osascript";
            task.arguments = @[@"-e", appleScript];
            NSPipe *outPipe = [NSPipe pipe];
            NSPipe *errPipe = [NSPipe pipe];
            task.standardOutput = outPipe;
            task.standardError = errPipe;
            [task launch];
            [task waitUntilExit];
            
            NSData *errData = [[errPipe fileHandleForReading] readDataToEndOfFile];
            if ([errData length] > 0) {
                NSString *errStr = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
                std::cerr << "[Word Automation Error] " << [errStr UTF8String] << std::endl;
            } else {
                std::cout << "[Word Automation] Equation inserted successfully into Word! TeX ratio: " << texRes.ratio << std::endl;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView evaluateJavaScript:@"showStatus('✓ បានបញ្ចូលសមីការទៅ Word រួចរាល់!', true)" completionHandler:nil];
            });
        } @catch (NSException *e) {
            std::cerr << "[Error in Word automation task] " << [[e reason] UTF8String] << std::endl;
        }
    });
}

- (void)openWordMenu:(id)sender {
    NSURL *wordURL = [NSURL fileURLWithPath:@"/Applications/Microsoft Word.app"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[wordURL path]]) {
        [[NSWorkspace sharedWorkspace] openApplicationAtURL:wordURL
                                              configuration:[NSWorkspaceOpenConfiguration configuration]
                                          completionHandler:nil];
    } else {
        system("open -a 'Microsoft Word'");
    }
}

- (void)insertToWordMenu:(id)sender {
    [self.webView evaluateJavaScript:@"actionInsertIntoWord()" completionHandler:nil];
}

- (void)newEquation:(id)sender {
    [self.webView evaluateJavaScript:@"actionNew()" completionHandler:nil];
}

- (void)savePNG:(id)sender {
    [self.webView evaluateJavaScript:@"actionSavePNG()" completionHandler:nil];
}

- (void)saveSVG:(id)sender {
    [self.webView evaluateJavaScript:@"actionSaveSVG()" completionHandler:nil];
}

- (void)savePDF:(id)sender {
    [self.webView evaluateJavaScript:@"actionSavePDF()" completionHandler:nil];
}

- (void)saveLaTeX:(id)sender {
    [self.webView evaluateJavaScript:@"actionSaveLaTeX()" completionHandler:nil];
}

- (void)checkForUpdatesMenu:(id)sender {
    [self.webView evaluateJavaScript:@"actionCheckUpdates()" completionHandler:nil];
}

- (void)insertKhmerTextMenu:(id)sender {
    [self.webView evaluateJavaScript:@"insertKhmerText()" completionHandler:nil];
}

- (void)historyMenu:(id)sender {
    [self.webView evaluateJavaScript:@"openHistoryModal()" completionHandler:nil];
}

- (void)favoritesMenu:(id)sender {
    [self.webView evaluateJavaScript:@"openFavoritesModal()" completionHandler:nil];
}

- (void)showAbout:(id)sender {
    [self.webView evaluateJavaScript:@"showAboutModal()" completionHandler:nil];
}

- (void)showHelp:(id)sender {
    [self.webView evaluateJavaScript:@"showHelpModal()" completionHandler:nil];
}

- (void)showLaTeXConfig:(id)sender {
    [self.webView evaluateJavaScript:@"showLaTeXConfigModal()" completionHandler:nil];
}

- (void)showLaTeXPreambleConfig:(id)sender {
    [self.webView evaluateJavaScript:@"showLaTeXPreambleModal()" completionHandler:nil];
}

- (NSString *)currentTeXPreamble {
    NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [[appSupport stringByAppendingPathComponent:@"Mathtype-kh"] stringByAppendingPathComponent:@"preamble.tex"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (content && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            return content;
        }
    }
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:@"CustomTeXPreamble"];
    if (saved && [saved stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        return saved;
    }
    return @"\\usepackage{lmodern}\n\\usepackage{amsmath,amssymb,amsfonts}\n\\usepackage[version=4]{mhchem}\n\\usepackage{xcolor}\n\\nopagecolor";
}

- (NSString *)currentTeXEngine {
    NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [[appSupport stringByAppendingPathComponent:@"Mathtype-kh"] stringByAppendingPathComponent:@"engine.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (content && [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
            return [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
        }
    }
    NSString *saved = [[NSUserDefaults standardUserDefaults] stringForKey:@"CustomTeXEngine"];
    if (saved && [saved stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        return [saved stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString;
    }
    return @"auto";
}

- (void)toggleTeXMenu:(id)sender {
    [self handleToggleTeX];
}

- (void)handleToggleTeX {
    std::cout << "[Toggle TeX] Querying selection from Microsoft Word..." << std::endl;
    NSString *appleScript = 
        @"tell application \"Microsoft Word\"\n"
        @"    if (count of documents) is 0 then\n"
        @"        return \"__NO_DOC__\"\n"
        @"    end if\n"
        @"    set sel to selection\n"
        @"    set theType to selection type of sel as text\n"
        @"    set foundLatex to \"\"\n"
        @"    if theType is \"selection inline shape\" then\n"
        @"        try\n"
        @"            set thePic to inline shape 1 of sel\n"
        @"            set altText to alternative text of thePic\n"
        @"            if altText contains \"latex:\" then\n"
        @"                set AppleScript's text item delimiters to \"latex:\"\n"
        @"                set foundLatex to text item 2 of altText\n"
        @"                set AppleScript's text item delimiters to \"\"\n"
        @"            else\n"
        @"                set foundLatex to altText\n"
        @"            end if\n"
        @"        end try\n"
        @"    end if\n"
        @"    if foundLatex is \"\" and (theType is \"selection normal\" or theType is \"selection ip\") then\n"
        @"        try\n"
        @"            set selText to content of text object of sel\n"
        @"            if selText is not missing value and selText is not \"\" then\n"
        @"                set foundLatex to selText\n"
        @"            end if\n"
        @"        end try\n"
        @"    end if\n"
        @"    if foundLatex is \"\" then\n"
        @"        try\n"
        @"            set selStart to start of content of text object of sel\n"
        @"            set picCount to count of inline pictures of active document\n"
        @"            repeat with i from 1 to picCount\n"
        @"                set p to inline picture i of active document\n"
        @"                set pStart to start of content of text object of p\n"
        @"                set pEnd to end of content of text object of p\n"
        @"                if selStart >= pStart and selStart <= (pEnd + 1) then\n"
        @"                    set altText to alternative text of p\n"
        @"                    if altText contains \"latex:\" then\n"
        @"                        set AppleScript's text item delimiters to \"latex:\"\n"
        @"                        set foundLatex to text item 2 of altText\n"
        @"                        set AppleScript's text item delimiters to \"\"\n"
        @"                    end if\n"
        @"                    exit repeat\n"
        @"                end if\n"
        @"            end repeat\n"
        @"        end try\n"
        @"    end if\n"
        @"    return foundLatex\n"
        @"end tell\n";

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/usr/bin/osascript";
            task.arguments = @[@"-e", appleScript];
            NSPipe *outPipe = [NSPipe pipe];
            task.standardOutput = outPipe;
            [task launch];
            [task waitUntilExit];

            NSData *outData = [[outPipe fileHandleForReading] readDataToEndOfFile];
            NSString *rawOutput = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
            NSString *extracted = [rawOutput stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [NSApp activateIgnoringOtherApps:YES];
                [self.window makeKeyAndOrderFront:nil];

                if ([extracted length] > 0 && ![extracted isEqualToString:@"__NO_DOC__"]) {
                    std::cout << "[Toggle TeX] Loaded equation from Word: " << [extracted UTF8String] << std::endl;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[extracted] options:0 error:nil];
                    NSString *jsonArray = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    NSString *js = [NSString stringWithFormat:@"loadLatexFromWord(%@[0])", jsonArray];
                    [self.webView evaluateJavaScript:js completionHandler:nil];
                } else {
                    [self.webView evaluateJavaScript:@"showStatus('សូមជ្រើសរើស (Select) សមីការ ឬ LaTeX ក្នុង Word ជាមុនសិន!', false)" completionHandler:nil];
                }
            });
        } @catch (NSException *e) {
            std::cerr << "[Error in handleToggleTeX] " << [[e reason] UTF8String] << std::endl;
        }
    });
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc >= 4 && strcmp(argv[1], "--render-pdf") == 0) {
            NSString *pdf = [NSString stringWithUTF8String:argv[2]];
            NSString *png = [NSString stringWithUTF8String:argv[3]];
            double dpi = (argc >= 5) ? atof(argv[4]) : 300.0;
            BOOL ok = [AppDelegate renderPDF:pdf toPNG:png dpi:dpi];
            return ok ? 0 : 1;
        }

        std::cout << "[Mathtype-kh LaTeX Kernel] Launching engine (default font size 12pt)..." << std::endl;
        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        AppDelegate *delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return 0;
}
