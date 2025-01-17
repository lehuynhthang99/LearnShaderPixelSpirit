Shader "Unlit/027-The_bundle"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _StrokeWidth("StrokeWidth", Float) = 0.02
        _StartStroke("StartStroke", Float) = 0.02

        [Space(12)]
        _SmallHexSize("SmallHexSize", Float) = 0.02
        [Vector2] _FirstOffset("FirstOffset", Vector) = (0,0,0,0)
        [Vector2] _SecondOffset("SecondOffset", Vector) = (0,0,0,0)
        [Vector2] _ThirdOffset("ThirdOffset", Vector) = (0,0,0,0)
        

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

            float _StrokeWidth;
            float _StartStroke;

            float _SmallHexSize;
            float2 _FirstOffset;
            float2 _SecondOffset;
            float2 _ThirdOffset;

            
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
                float finalFactor = 0;

                float hexSDF = HexSDF(scaleUV);
                finalFactor = Stroke(hexSDF, _StartStroke, _StrokeWidth);

                hexSDF = HexSDF(scaleUV - _FirstOffset);
                finalFactor += Fill(hexSDF, _SmallHexSize);
                
                hexSDF = HexSDF(scaleUV - _SecondOffset);
                finalFactor += Fill(hexSDF, _SmallHexSize);
                
                hexSDF = HexSDF(scaleUV - _ThirdOffset);
                finalFactor += Fill(hexSDF, _SmallHexSize);

                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
