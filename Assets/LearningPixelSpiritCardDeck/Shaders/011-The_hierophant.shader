Shader "Unlit/011-The_hierophant"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _FirstStartPointOutside("FirstStartPointOutside", Float) = 0.75
        _FirstOutsideRectSize("FirstOutsideRectSize", Float) = 0.1

        [Space(12)]
        _SecondStartPointOutside("SecondStartPointOutside", Float) = 0.75
        _SecondOutsideRectSize("SecondOutsideRectSize", Float) = 0.1

        [Space(12)]
        [Vector2] _CrossSize("CrossSize", Vector) = (0.2,0.6,0,0)
        [Vector2] _CrossBlankSize("CrossBlankSize", Vector) = (0.3,0.6,0,0)

        [Space(12)]
        _RepeatedPatternRegionSize("RepeatedPatternRegionSize", Float) = 0.6
        _RepeatedPatternFrequency("RepeatedPatternFrequency", Float) = 3.0

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

            float _FirstStartPointOutside;
            float _FirstOutsideRectSize;

            float _SecondStartPointOutside;
            float _SecondOutsideRectSize;

            float2 _CrossSize;
            float2 _CrossBlankSize;

            float _RepeatedPatternRegionSize;
            float _RepeatedPatternFrequency;


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

                float rectSDF = RectSDF(scaleUV, 1.0);
                float crossSDF = CrossSDF(scaleUV, _CrossSize);
                float crossBlankSDF = CrossSDF(scaleUV, _CrossSize + _CrossBlankSize);

                //mark center to draw repeated pattern
                resultColor += Fill(rectSDF, _RepeatedPatternRegionSize);
                resultColor *= step(frac(crossSDF * _RepeatedPatternFrequency), 0.5);
                resultColor *= step(1.0, crossBlankSDF);
                
                //draw 2 stroke for outside rect
                resultColor += Stroke(rectSDF, _FirstStartPointOutside, _FirstOutsideRectSize);
                resultColor += Stroke(rectSDF, _SecondStartPointOutside, _SecondOutsideRectSize);

                //draw center cross
                resultColor += Fill(crossSDF, 1);

                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
