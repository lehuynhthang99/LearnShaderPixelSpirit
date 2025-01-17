static const float PI               = 3.1415926538;
static const float TWO_PI           = 6.2831853076;
static const float SQRT_OF_3        = 1.73205080757;
static const float HALF_SQRT_OF_3   = 0.86602540378;

half4 GetColor()
{
    return half4(0,0,0,1);
}

float2 GetUVKeepingAspectRatio(float2 uv, float2 resolution)
{
    if (resolution.y > resolution.x ) 
    {
        uv.y *= resolution.y/resolution.x;
    }
    else 
    {
        uv.x *= resolution.x/resolution.y;
    }

    return uv; 
}

float Stroke(float inputFragment, float startPoint, float width)
{
    //this is a line
    //____________________________[startPoint]____________________[startPoint + width]____________________________
    //{_____Remove this part_____}{_________________Get this part____________________}{_____Remove this part_____}
    //make conditional statement for remove part

    float isLeftPart = step(inputFragment, startPoint);
    float isRightPart = step(startPoint + width, inputFragment);

    //reverse for the result
    return 1 - (isLeftPart + isRightPart);
}

float Fill(float input, float size)
{
    return step(input, size);
}

float CircleSDF(float2 uv)
{
    return length(uv);
}

float RectSDF(float2 uv, float2 size) 
{
    size/=2;

    return max( abs(uv.x/size.x),
                abs(uv.y/size.y) );
}

float RectExactSDF(float2 uv, float2 size) 
{
    size/=2;
    float2 delta = float2(size.x - size.y, size.y - size.x);
    delta = max(delta, 0);
    size -= delta;
    return max(max(abs(uv.x) - delta.x, 0) / size.x,
                max(abs(uv.y) - delta.y, 0) / size.y);
}

float CrossSDF(float2 uv, float2 size)
{
    return min( RectSDF(uv, size.xy), 
                RectSDF(uv, size.yx) );
}

float VesicaSDF(float2 uv, float circlePivotDistance, float signAndOr)
{
    //signIncludeExclude: 
    //0: or function
    //1: and function
    float2 offset = float2(circlePivotDistance*.5,0);
    float firstCircle = CircleSDF(uv - offset);
    float secondCircle = CircleSDF(uv + offset);
    return (1 - signAndOr) * min(firstCircle, secondCircle) + signAndOr * max(firstCircle, secondCircle);
}

float EquilateralTriangleSDF(float2 uv)
{
    //          A
    //          .              _  
    //        . . .             |
    //      .   .   .           |=>this is the result of the output (aka: the radius of the circle where the triangle belong to) --> calculate this
    //    .     . O   .--------_|------->center of the triangle is at (0,0)   
    //  .               .
    //. . . . . . . . . . .
    
    //split the triangle into 3 section: 1/3 left, 1/3 right and 1/3 bot
    //use cos to define the current uv is in which section (the original direction is point above: (0, 1)):
    //  [-1, -0.5]: 1/3 bot
    //  (-0.5, 1): 1/3 left and 1/3 right (cause center is at (0,0), left part and right part can use the same calculation by using abs)

    //calculation for 1/3 bot
    //the y scale is equal to 1/3 the height of the triangle, the radius of the triangle is equal to 2/3 the height of the triangle --> y scale is equal to 1/2 the radius
    float botSideResult = -2 * uv.y;

    //calculation for 1/3 left and 1/3 right 
    //project the uv point onto the Oy axis, calling it H
    //the radius is equal to scale(AH) + uv.y -->(including the sign in uv.y)
    //scale(AH) = tan(60 degreee) * abs(uv.x) --> use abs cause we have both side
    float leftAndRightSideResult = SQRT_OF_3 * abs(uv.x) + uv.y;

    //check which side to get correct result
    float isBotSide = step( normalize(uv).y , -0.5);
    return isBotSide * botSideResult + (1 - isBotSide) * leftAndRightSideResult;
}

float EquilateralTriangleRemoveBotSDF(float2 uv)
{
    //          A
    //          .              _  
    //        . . .             |
    //      .   .   .           |=>this is the result of the output (aka: the radius of the circle where the triangle belong to) --> calculate this
    //    .     . O   .--------_|------->center of the triangle is at (0,0)   
    //  .               .
    //. . . . . . . . . . .
    
    //split the triangle into 3 section: 1/3 left, 1/3 right and 1/3 bot
    //use cos to define the current uv is in which section (the original direction is point above: (0, 1)):
    //  [-1, -0.5]: 1/3 bot
    //  (-0.5, 1): 1/3 left and 1/3 right (cause center is at (0,0), left part and right part can use the same calculation by using abs)

    //calculation for 1/3 bot
    //the y scale is equal to 1/3 the height of the triangle, the radius of the triangle is equal to 2/3 the height of the triangle --> y scale is equal to 1/2 the radius
    float botSideResult = 100;

    //calculation for 1/3 left and 1/3 right 
    //project the uv point onto the Oy axis, calling it H
    //the radius is equal to scale(AH) + uv.y -->(including the sign in uv.y)
    //scale(AH) = tan(60 degreee) * abs(uv.x) --> use abs cause we have both side
    float leftAndRightSideResult = SQRT_OF_3 * abs(uv.x) + uv.y;

    //check which side to get correct result
    float isBotSide = step(normalize(uv).y, -0.5);
    return isBotSide * botSideResult + (1 - isBotSide) * leftAndRightSideResult;
}

float RhombSDF(float2 uv)
{
    //return max(EquilateralTriangleSDF(uv),
    //            EquilateralTriangleSDF(float2(uv.x, -uv.y)));    
    
    float isBottomSide = step(uv.y, 0);
    float result = (1 - isBottomSide) * EquilateralTriangleSDF(uv) + isBottomSide * EquilateralTriangleSDF(float2(uv.x, -uv.y));
    return result * 2;

}

float PolygonSDF(float2 uv, float vertices)
{
    //see more explanation at folder PolySDFExplaination_026
    float angle = atan2(uv.x, uv.y) + PI;
    float radius = length(uv);
    float cornerAngle = TWO_PI / vertices;
    float vertexIndex = floor(angle / cornerAngle);
    float angleDiff = (angle - vertexIndex * cornerAngle) - cornerAngle / 2.0;
    float height = cos(angleDiff) * radius;
    return height / cos(cornerAngle / 2.0);

}

float HexSDF(float2 uv)
{
    //similar to EquilateralTriangleSDF
    //          .              
    //        .   .            
    //      . . . . .          
    //    .     .     .        
    //  .       .       .
    //. . . . . .O. . . . .--------------->center of the triangle is at (0,0)   
    //  .       .       .  A
    //    .     .     .        
    //      . . . . .          
    //          |__________|
    //          result of the SDF
    
    uv = abs(uv);
    
    float isSidePart = step(normalize(uv).y, HALF_SQRT_OF_3);
    
    float sideResult = uv.x + uv.y / SQRT_OF_3; //tan 60
    float upperResult = uv.y / HALF_SQRT_OF_3;  //sin 60
    
    //return isSidePart;
    
    return isSidePart * sideResult + (1 - isSidePart) * upperResult;

}

float StarSDF(float2 uv, float vertices, float starAngle)
{
    float angle = atan2(uv.x, uv.y) + PI;
    float radius = length(uv);
    float cornerAngle = TWO_PI / vertices;
    float vertexIndex = floor(angle / cornerAngle);
    float angleDiff = (angle - vertexIndex * cornerAngle) - cornerAngle / 2.0;
    angleDiff = (cornerAngle / 2.0) - abs(angleDiff);
    float height = sin(angleDiff) * radius;
    return cos(angleDiff) * radius + height/tan(starAngle);

}

float XOr(float x, float y)
{
    return (x + y) * (1 - x * y);
}

float2 Rotate(float2 uv, float radianRotation)
{
    float2x2 matrixRotation = {cos(radianRotation), -sin(radianRotation),
                               sin(radianRotation), cos(radianRotation)};
    uv = mul(matrixRotation , uv);
    return uv;
}