Shader "SunnyValley/Water" {
 Properties {[PerRendererData] _MainTex("Texture",2D)="white"{} }
 SubShader {Tags{"Queue"="Transparent" "RenderType"="Transparent"} Cull Off ZWrite Off Blend SrcAlpha OneMinusSrcAlpha
 Pass {CGPROGRAM
 #pragma vertex vert
 #pragma fragment frag
 #include "UnityCG.cginc"
 sampler2D _MainTex,_ValleyTerrainMap;float4 _ValleyMapSize,_ValleyAmbient;float4 _ValleyLights[24];int _ValleyLightCount;
 struct a{float4 vertex:POSITION;float2 uv:TEXCOORD0;};struct v{float4 pos:SV_POSITION;float2 uv:TEXCOORD0;float2 world:TEXCOORD1;};
 v vert(a i){v o;o.pos=UnityObjectToClipPos(i.vertex);o.uv=i.uv;o.world=mul(unity_ObjectToWorld,i.vertex).xy;return o;}
 float waterAt(float2 p){float2 cell=floor(p/48);float2 uv=(cell+.5)/_ValleyMapSize.zw;uv.y=1-uv.y;return tex2D(_ValleyTerrainMap,uv).r;}
 fixed4 frag(v i):SV_Target{float2 p=floor(i.world*float2(100,-100)/2)*2;p.y-=16;float2 uv=i.uv;uv.x+=floor(sin(p.y*.13+floor(_Time.y*6)*.12)*2)*.001;fixed4 c=tex2D(_MainTex,uv);float ripple=step(.94,sin(p.x*.09+p.y*.24-floor(_Time.y*6)*.14));float shore=1-min(min(waterAt(p+float2(0,48)),waterAt(p-float2(0,48))),min(waterAt(p+float2(48,0)),waterAt(p-float2(48,0))));float edge=min(min(fmod(p.x+48000,48),48-fmod(p.x+48000,48)),min(fmod(p.y+48000,48),48-fmod(p.y+48000,48)));c.rgb=lerp(c.rgb,float3(.25,.58,.68),.35);c.rgb+=ripple*.055;c.rgb+=float3(.08,.15,.16)*shore*(1-smoothstep(0,12,edge));float3 light=_ValleyAmbient.rgb;for(int n=0;n<_ValleyLightCount;n++){float4 l=_ValleyLights[n];float d=saturate(1-distance(i.world,l.xy)/l.z);light+=float3(1,.76,.42)*d*d*l.w;}c.rgb*=min(light,1.3);return c;}
 ENDCG}
 }
}
