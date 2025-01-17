Shader "Unlit/017-The-diamond"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Vector2] _Resolution("Resolution", Vector) = (400,400,0,0)
        
        [Space(12)]
        _RhombStartSize("RhombStartSize", Float) = 1
        _RhombOffsetSize("RhombOffsetSize", Float) = 0.07
        _RhombStrokeSize("RhombStrokeSize", Float) = 0.08
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

            float _RhombStartSize;
            float _RhombOffsetSize;
            float _RhombStrokeSize;
            
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

                float rhombSDF = RhombSDF(scaleUV);

                float finalFactor = Fill(rhombSDF, _RhombStartSize);
                float nextStartSize = _RhombStartSize + _RhombOffsetSize;
                finalFactor += Stroke(rhombSDF, nextStartSize, _RhombStrokeSize);
                nextStartSize += _RhombOffsetSize + _RhombStrokeSize;
                finalFactor += Stroke(rhombSDF, nextStartSize, _RhombStrokeSize);

                resultColor = finalFactor;
                resultColor.a = 1.0;

                return resultColor;
            }
            ENDHLSL
        }
    }
}
