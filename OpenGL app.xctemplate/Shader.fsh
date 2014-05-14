//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

uniform lowp mat3 normalMatrix;
uniform lowp vec4 diffuseColor;
varying lowp vec3 normalOut;

void main() {
    lowp vec3 eyeNormal = normalize(normalMatrix * normalOut);
    lowp vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    
    lowp float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    gl_FragColor = vec4(diffuseColor.xyz * nDotVP, diffuseColor.a);
}
