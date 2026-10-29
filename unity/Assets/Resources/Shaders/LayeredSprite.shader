Shader "SunnyValley/LayeredSprite" {
 Properties { [PerRendererData] _MainTex("Sprite",2D)="white"{} _Color("Tint",Color)=(1,1,1,1) }
 SubShader {Tags {"Queue"="Transparent" "RenderType"="Transparent" "CanUseSpriteAtlas"="True"} Cull Off ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 sampler2D _MainTex;float4 _Color;float4 _ValleyAmbient;float4 _ValleyLights[24];int _ValleyLightCount;
 struct appdata {float4 vertex:POSITION;float2 uv:TEXCOORD0;float4 color:COLOR;};
 struct v2f {float4 vertex:SV_POSITION;float2 uv:TEXCOORD0;float4 color:COLOR;float2 world:TEXCOORD1;};
 v2f vert(appdata v){v2f o;o.vertex=UnityObjectToClipPos(v.vertex);o.world=mul(unity_ObjectToWorld,v.vertex).xy;o.uv=v.uv;o.color=v.color*_Color;return o;}
 fixed4 frag(v2f i):SV_Target {fixed4 c=tex2D(_MainTex,i.uv)*i.color;float3 light=_ValleyAmbient.rgb;for(int n=0;n<_ValleyLightCount;n++){float4 l=_ValleyLights[n];float d=saturate(1-distance(i.world,l.xy)/l.z);light+=float3(1,.78,.48)*d*d*l.w;}c.rgb*=min(light,float3(1.2,1.15,1.1));return c;}
 ENDCG}
 }
}
