(
SynthDef(\iter, {
	|out,sustain=1,pan|
	var temp,sum,env,outAudio,freq;
	sum = 0;
	freq = {ExpRand(660,1000)};
	env = EnvGen.kr(Env.new([0,1,1,0],[10,20,10],[1,0,-1]),doneAction:2);
	// env = EnvGen.ar(Env.sine(1.0), timeScale:sustain, doneAction:2);
	8.do{
		temp = VarSaw.ar(
			freq*({ExpRand(0.35,1.2)}!4).range(0,1),
			{Rand(0.0,1.0)}!4,
			({ExpRand(0.05,0.5)}!4).range(0,2)
		);
		temp = temp * LFNoise1.kr({Rand(0.5,2)}!4).exprange(0.1,1);
		sum = sum + temp;
	};
	sum = Splay.ar(sum)*0.5*env;
	outAudio = RLPF.ar(sum, 1200);
	Out.ar(out, DirtPan.ar(outAudio, ~dirt.numChannels, pan, env));
}).add;
)

x = Synth.new(\iter);

x.free;