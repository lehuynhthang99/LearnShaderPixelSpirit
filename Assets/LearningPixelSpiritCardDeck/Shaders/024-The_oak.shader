Shader "Unlit/024-The_oak"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _TotalEffectSize("TotalEffectSize", Float) = 0.6
        _LShapeWidth("LShapeWidth", Float) = 0.6
        _StrokeWidth("StrokeWidth", Float) = 0.6
        _SmallRectWidth("SmallRectWidth", Float) = 0.6
        
        [Space(12)]
        _EffectRotation("EffectRotation", Float) = 45
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "/CustomLib/PixelSpiritLib.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            
            float2 _Resolution;

            float _TotalEffectSize;
            float _LShapeWidth;
            float _StrokeWidth;
            float _SmallRectWidth;

            float _EffectRotation;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog

                //uv will now from [-1;1] instead of [0;1]
                float2 scaleUV = (i.uv - 0.5) * 2;
                scaleUV = GetUVKeepingAspectRatio(scaleUV, _Resolution);
                half4 resultColor = (half4)0.0;

                scaleUV = Rotate(scaleUV, radians(_EffectRotation));

                float2 offset = float2(0, (_TotalEffectSize - _LShapeWidth) / 2.0 );
                float2 rectSize = float2(_TotalEffectSize, _LShapeWidth);
                float firstRectLShapeSDF = RectExactSDF(scaleUV + offset, rectSize);

                offset = offset.yx;
                rectSize = rectSize.yx;
                float secondRectLShapeSDF = RectExactSDF(scaleUV + offset, rectSize);

                // float finalFactor = firstRectLShapeSDF;

                float strokeWidthInSDF = _StrokeWidth / _LShapeWidth;

                float finalFactor = Stroke(firstRectLShapeSDF, 1-strokeWidthInSDF,strokeWidthInSDF);
                finalFactor += Stroke(secondRectLShapeSDF, 1-strokeWidthInSDF, strokeWidthInSDF);

                finalFactor *= 1 - Fill(firstRectLShapeSDF, 1-strokeWidthInSDF);
                finalFactor *= 1 - Fill(secondRectLShapeSDF, 1-strokeWidthInSDF);

                offset = (_TotalEffectSize - _SmallRectWidth) / 2.0;
                float emptyRectSDF = RectExactSDF(scaleUV - offset, _SmallRectWidth);
                strokeWidthInSDF = _StrokeWidth / _SmallRectWidth;
                finalFactor += Stroke(emptyRectSDF, 1-strokeWidthInSDF,strokeWidthInSDF);
                
                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
