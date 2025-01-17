Shader "Unlit/012-The_tower"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _ALineFactor("ALineFactor", Float) = 1
        _BLineFactor("BLineFactor", Float) = 1
        _CLineStartFactor("CLineStartFactor", Float) = 0
        _LineWidth("LineWidth", Float) = 0.2

        [Space(12)]
        [Vector2] _RectSize("RectSize", Vector) = (0.6,1,0,0)


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
            float2 _RectSize;

            float _ALineFactor;
            float _BLineFactor;
            float _CLineStartFactor;
            float _LineWidth;

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

                float finalFactor = Stroke(_ALineFactor * scaleUV.x + _BLineFactor * scaleUV.y, _CLineStartFactor, _LineWidth);
                float rectSDF = RectSDF(scaleUV, _RectSize);
                finalFactor = XOr(finalFactor, Fill(rectSDF, 1.0));


                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
