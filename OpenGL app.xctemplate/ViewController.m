//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___VARIABLE_classPrefix:identifier___ViewController.h"
#import "PTGLProgram.h"
#import "___VARIABLE_classPrefix:identifier___ModelData.h"


@interface ___VARIABLE_classPrefix:identifier___ViewController () {
    GLKMatrix4 _cube1ModelViewProjectionMatrix;
    GLKMatrix4 _cube2ModelViewProjectionMatrix;
    
    GLKMatrix3 _cube1NormalMatrix;
    GLKMatrix3 _cube2NormalMatrix;
    
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
}

@property (strong, nonatomic) EAGLContext *context;

@property PTGLProgram * program;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ___VARIABLE_classPrefix:identifier___ViewController

#pragma mark - Teardown methods

- (void)dealloc {
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.program = nil;
}


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //If you're making a 2D game or something that involves sharp edges, you probably want to keep this on
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    //If you can get 60fps, your animations will look buttery smooth. Otherwise stick to 30fps, as this is better for battery
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    self.program = [[PTGLProgram alloc] initWithBundleVertexShaderFile:@"Shader.vsh" fragmentShader:@"Shader.fsh" attributes:@[@"position", @"normal"]];
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(self.program.position);
    glVertexAttribPointer(self.program.position, 3, GL_FLOAT, GL_FALSE, 24, (const GLvoid*)offsetof(VertexData, Position));
    glEnableVertexAttribArray(self.program.normal);
    glVertexAttribPointer(self.program.normal, 3, GL_FLOAT, GL_FALSE, 24, (const GLvoid*)offsetof(VertexData, Normal));
    
    glBindVertexArrayOES(0);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}



#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _cube1ModelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    _cube1NormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    //Second cube adjustments
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _cube2ModelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    _cube2NormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(_vertexArray);
    
    [self.program use];
    
    //Draw the first cube
    glUniformMatrix4fv(self.program.modelViewProjectionMatrix, 1, 0, _cube1ModelViewProjectionMatrix.m);
    glUniformMatrix3fv(self.program.normalMatrix, 1, 0, _cube1NormalMatrix.m);
    glUniform4f(self.program.diffuseColor, 0.4, 0.4, 1, 1);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    //Draw the second cube
    glUniformMatrix4fv(self.program.modelViewProjectionMatrix, 1, 0, _cube2ModelViewProjectionMatrix.m);
    glUniformMatrix3fv(self.program.normalMatrix, 1, 0, _cube2NormalMatrix.m);
    glUniform4f(self.program.diffuseColor, 1, 0.4, 0.4, 1);
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

@end
