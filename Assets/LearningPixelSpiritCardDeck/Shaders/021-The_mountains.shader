Shader "Unlit/021-The_mountains"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _RectCenterSize("RectCenterSize", Float) = 0.6
        _RectCenterPaddingSize("RectCenterPaddingSize", Float) = 0.015

        [Space(12)]
        _RectSideSize("RectSideSize", Float) = 0.35
        [Vector2] _RectSideOffset("RectSideOffset", Vector) = (0.4,0.4,0,0)

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

            float _RectCenterSize;
            float _RectCenterPaddingSize;
            
            float _RectSideSize;
            float2 _RectSideOffset;

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

                float finalFactor = Fill(RectSDF(scaleUV + _RectSideOffset, 1), _RectSideSize);
                finalFactor += Fill(RectSDF(scaleUV - _RectSideOffset, 1), _RectSideSize);

                float rectCenterSDF = RectSDF(scaleUV, 1);
                finalFactor *= 1 - Fill(rectCenterSDF, _RectCenterSize + _RectCenterPaddingSize);
                finalFactor += Fill(rectCenterSDF, _RectCenterSize);
                
                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
