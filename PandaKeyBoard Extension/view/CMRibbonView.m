//
//  CMRibbonView.m
//  PandaKeyboard
//
//  Created by 姚宗超 on 2017/8/21.
//  Copyright © 2017年 CMCM. All rights reserved.
//

#import "CMRibbonView.h"
#import <GLKit/GLKit.h>
#import "CMKeyboardManager.h"
#import "CMThemeManager.h"
#import "CMNotificationConstants.h"

@interface CMRibbonView () <SCNProgramDelegate>
@property (strong, nonatomic)SCNPlane* ribbonPlane;

@property (nonatomic, assign)BOOL isInitialed;

@end

@implementation CMRibbonView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame options:(NSDictionary<NSString *,id> *)options {
    if (self = [super initWithFrame:frame options:options]) {
        _isInitialed = NO;
        
        self.eaglContext = kCMKeyboardManager.themeManager.context;
        
        if ([UIDevice systemMajorVersion] < 10 || ([UIDevice systemMajorVersion] == 10 && [UIDevice systemMinorVersion] < 2)) {
            AVAudioEngine *audioEngine = self.audioEngine; // https://stackoverflow.com/questions/39543083/avfaudio-playback-crash-on-ios-10
            //        [self audioEngine];
        }
//        self.backgroundColor = [UIColor colorWithHexString:@"090519"];
        self.backgroundColor = [UIColor clearColor];
        self.allowsCameraControl = NO;
#ifdef DEBUG
        self.showsStatistics = NO;
#else
        self.showsStatistics = NO;
#endif
        SCNNode *cameraNode = [SCNNode node];
        cameraNode.camera = [SCNCamera camera];
        cameraNode.camera.zFar = 800.f;
        cameraNode.camera.zNear = 0.001f;
        cameraNode.position = SCNVector3Make(10.f, 0, 150.f);
        
        self.ribbonPlane = [SCNPlane planeWithWidth:CGRectGetWidth(frame)*1.1f height:CGRectGetHeight(frame)*0.5f];
        self.ribbonPlane.cornerRadius = 0.0f;
        self.ribbonPlane.widthSegmentCount = 130;
//        self.ribbonPlane.heightSegmentCount = 200;
        
        // Create a shader program and assign the shaders
        SCNProgram *program = [SCNProgram program];
        program.vertexShader   = kCMKeyboardManager.themeManager.ribbonVertexShader;
        program.fragmentShader = kCMKeyboardManager.themeManager.ribbonFragmentShader;
        
        // Become the program delegate (to get runtime compilation errors)
        program.delegate = self;
        
        // Associate geometry and node data with the attributes and uniforms
        // -----------------------------------------------------------------
        
        // Attributes (position, normal, texture coordinate)
        [program setSemantic:SCNGeometrySourceSemanticVertex
                   forSymbol:@"a_position"
                     options:nil];
        //    [program setSemantic:SCNGeometrySourceSemanticNormal
        //               forSymbol:@"normal"
        //                 options:nil];
        [program setSemantic:SCNGeometrySourceSemanticTexcoord
                   forSymbol:@"a_texCoord"
                     options:nil];
        
        // Uniforms (the three different transformation matrices)
        [program setSemantic:SCNModelViewProjectionTransform
                   forSymbol:@"modelViewProjection"
                     options:nil];
        
        SCNMaterial* material = [SCNMaterial material];
        
        material.program = program;
        material.doubleSided = YES;
        
        CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
        [material handleBindingOfSymbol:@"CC_Time" usingBlock:^(unsigned int programID, unsigned int location, SCNNode * _Nullable renderedNode, SCNRenderer * _Nonnull renderer) {
            glUniform1f(location, CFAbsoluteTimeGetCurrent() - startTime);
        }];
        
        [material handleBindingOfSymbol:@"u_texture0" usingBlock:^(unsigned int programID, unsigned int location, SCNNode * _Nullable renderedNode, SCNRenderer * _Nonnull renderer) {
            if(kCMKeyboardManager.themeManager.ribbonTexture) {
                // Handle the error
//                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
                glBindTexture(GL_TEXTURE_2D, kCMKeyboardManager.themeManager.ribbonTexture.name);
            }
        }];
        
        self.ribbonPlane.firstMaterial = material;
        
        SCNNode* ribbonPlaneNode = [SCNNode nodeWithGeometry:self.ribbonPlane];
        
        SCNScene* mainScene = [SCNScene scene];
        
        [mainScene.rootNode addChildNode:cameraNode];
        [mainScene.rootNode addChildNode:ribbonPlaneNode];
        
        self.scene = mainScene;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame options:@{SCNPreferredRenderingAPIKey: @(SCNRenderingAPIOpenGLES2)}];
}

- (void)didMoveToWindow {
    if (self.window) {
        // 注册通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:kNotificationOrientationTransit object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - update constraints
- (void)handleOrientationNotification:(NSNotification *)notify {
    id<UIViewControllerTransitionCoordinator> coordinator = [notify object];
    self.bounds = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, [CMKeyboardManager keyboardHeight]);
    self.ribbonPlane.width = CGRectGetWidth(self.bounds) * 1.1f;
    self.ribbonPlane.height = CGRectGetHeight(self.bounds) * 0.5f;
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [self layoutIfNeeded];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        }];
    }
    else {
        [self layoutIfNeeded];
    }
}

- (void)dealloc {
    kLogTrace();
    self.playing = NO;
    [self.scene.rootNode enumerateChildNodesUsingBlock:^(SCNNode * _Nonnull node, BOOL * _Nonnull stop) {
        [node removeFromParentNode];
        node.geometry = nil;
        node = nil;
    }];
    [self removeAllAnimation];
}

- (void)startPlay {
    if (!self.isPlaying && self.superview) {
        self.playing = YES;
    }
}

- (void)pausePlay {
    if (self.isPlaying) {
        self.playing = NO;
    }
}


#pragma mark - setter/getter

#pragma mark - SCNProgramDelegate

- (void)program:(SCNProgram *)program
    handleError:(NSError *)error
{
    // Handle the error.
    kLogError(@"%@", error.localizedDescription);
}

@end
