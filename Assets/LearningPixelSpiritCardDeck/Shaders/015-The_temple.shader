Shader "Unlit/015-The_temple"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _FirstTriangleSize("FirstTriangleSize", Float) = 1
        [Vector2] _FirstTriangleOffset("FirstTriangleOffset", Vector) = (0, 0, 0, 0)
        
        [Space(12)]
        _SecondTriangleSize("SecondTriangleSize", Float) = 1
        [Vector2] _SecondTriangleOffset("SecondTriangleOffset", Vector) = (0, 0, 0, 0)
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
            float2 _FirstTriangleOffset;

            float _SecondTriangleSize;
            float2 _SecondTriangleOffset;

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

                float firstTriangleSDF = EquilateralTriangleSDF(scaleUV + _FirstTriangleOffset);
                float finalFactor = Fill(firstTriangleSDF, _FirstTriangleSize);

                float secondTriangleSDF = EquilateralTriangleSDF(float2(scaleUV.x, -scaleUV.y) + _SecondTriangleOffset);
                finalFactor -= Fill(secondTriangleSDF, _SecondTriangleSize);

                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
