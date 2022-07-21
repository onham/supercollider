(
SynthDef(\test1, {
	|out, pan|
	var sig, amp, env, outAudio;
	env = EnvGen.kr(Env.new([0,1,1,0],[10,20,10],[1,0,-1]),doneAction:2);
	amp = SinOsc.kr({ExpRand(0.2,12)}!8).range(0,1);
	sig = SinOsc.ar({ExpRand(50,1200)}!8);
	sig = sig*amp*env;
	sig = Splay.ar(sig)*0.5;
	outAudio = RLPF.ar(sig, 880);
	OffsetOut.ar(out, DirtPan.ar(outAudio, ~dirt.numChannels, pan, amp));
}).add;
)

x = Synth.new(\test1);

x.free;