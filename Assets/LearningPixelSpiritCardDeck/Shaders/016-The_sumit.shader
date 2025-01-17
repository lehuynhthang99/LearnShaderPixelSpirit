Shader "Unlit/016-The_sumit"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _FirstTriangleSize("FirstTriangleSize", Float) = 1
        _SecondTriangleSize("SecondTriangleSize", Float) = 1
        [Vector2] _TriangleOffset("TriangleOffset", Vector) = (0, 0, 0, 0)

        [Space(12)]
        _CircleStartStroke("CircleStartStroke", Float) = 0.8
        _CircleStrokeWidth("CircleStrokeWidth", Float) = 0.1
        [Vector2] _CircleOffset("CircleOffset", Vector) = (0, 0, 0, 0)
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

            float _FirstTriangleSize;
            float _SecondTriangleSize;
            float2 _TriangleOffset;

            float _CircleStartStroke;
            float _CircleStrokeWidth;
            float2 _CircleOffset;

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

                float triangleSDF = EquilateralTriangleSDF(scaleUV + _TriangleOffset);
                float circleSDF = CircleSDF(scaleUV + _CircleOffset);

                float finalFactor = Stroke(circleSDF, _CircleStartStroke, _CircleStrokeWidth);
                finalFactor *= 1 - Fill(triangleSDF, _FirstTriangleSize);
                finalFactor += Fill(triangleSDF, _SecondTriangleSize);

                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
