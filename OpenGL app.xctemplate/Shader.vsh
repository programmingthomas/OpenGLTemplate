//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

attribute vec4 position;
attribute vec3 normal;

varying lowp vec3 normalOut;

uniform mat4 modelViewProjectionMatrix;

void main() {
    gl_Position = modelViewProjectionMatrix * position;
    normalOut = normal;
}
