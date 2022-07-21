(
SynthDef(\drunkDwarf,{
	arg out=0, freq=100, k=0.0, loss=0.999, dur=0.5, pan=0.0, rand=1;
	var sig, env, sub,senv;
	env = EnvGen.ar(Env([0,1,1,0], [0.001] ++ ((dur-0.001)*[0.4, 0.6])), doneAction:2);
	senv = EnvGen.ar(Env([1,1,0,0], [( rand * freq + freq/2 )/SampleRate.ir, 0.0, 1.0]));
	sub = Saw.ar([freq/4, freq/2]/4);
	sig = WhiteNoise.ar(0.5) * senv;
	sig = TwoTube.ar(sig, k, loss, rand+ freq, freq/2);
	sig = (sub/4+(sig).fold(10)*sub).tanh;
	sig = RLPF.ar([sig, sig/2], freq*4 * (LFNoise2.ar(0.5).range(1,10)/pi).lagud([0.2, 0.5]).lagud , 1);
	sig = Compander.ar(sig, SinOsc.ar(dur), 0.7,0.2,1,0.001,0.05);
	sig = LPF.ar(sig, 4000).fold2;
	sig = LPF.ar(sig, 4000);

	Out.ar(out, Splay.ar(sig*env,pan));
}).add;
)

Pbind(\instrument, \drunkDwarf,

			\freq, Pseq([100,1000,200,900,100,1050,200,800,100,750,200,500,100,400,200,300], inf),
	                \rand, Pwhite(1,100,inf),
			\loss, 1,
	                \dur, Pseq([0.25,0.75], inf),
			\pan, 1,
			\k, 1.0005

).stop;

s.freeAll;

