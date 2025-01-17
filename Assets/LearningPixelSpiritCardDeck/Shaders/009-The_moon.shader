Shader "Unlit/009-The_moon"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        [Vector2]_StartPointMoon("StartPointMoon", Vector) = (0,0,0,0)
        _WidthMoon("WidthMoon", Float) = 0.75
        
        [Space(12)]
        [Vector2]_StartPointHideMoon("StartPointHideMoon", Vector) = (0.25,0.25,0,0)
        _WidthHideMoon("WidthHideMoon", Float) = 0.2

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

            float2 _StartPointMoon;
            float _WidthMoon;

            float2 _StartPointHideMoon;
            float _WidthHideMoon;

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

                resultColor += Fill(CircleSDF(scaleUV-_StartPointMoon), _WidthMoon);
                resultColor -= Fill(CircleSDF(scaleUV-_StartPointHideMoon), _WidthHideMoon);

                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
