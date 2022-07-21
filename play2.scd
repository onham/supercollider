(
SynthDef(\babbl, { |out=0, amp=0.1, pan=0.0|
	var env = EnvGen.kr(
		Env.new([0,1,0],[20,20],[1,-1]),
		doneAction:2
	);
	var son =
	    ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 14) * 400 + 500, 0.03, 0.003)}!2)
	    + ({RHPF.ar(OnePole.ar(BrownNoise.ar, 0.99), LPF.ar(BrownNoise.ar, 20)* 800 + 1000, 0.03, 0.005)}!2) * 4;
	var outAudio = Splay.ar(son)*env;
	Out.ar(out, DirtPan.ar(outAudio * (amp * 20), ~dirt.numChannels, pan))
}).add;
);


(
SynthDef(\beating, { |freq=440, amp=0.1, art=1, pan=0.0, sustain=1, speed=1, accelerate=0|
	var env = EnvGen.ar(Env.perc(0.01, art), doneAction: 2);
  var basefreq = freq * DirtFreqScale.kr(speed, accelerate, sustain);
	var snd1 = SinOsc.ar(basefreq);
	var snd2 = SinOsc.ar(Line.kr(basefreq+15, basefreq, art));

	Out.ar(0, DirtPan.ar(Mix([snd1 , snd2]), ~dirt.numChannels, pan, env))
}).add;
);


(
SynthDef(\blowbotl, { | out=0, amp=1.0, freq=440, rq=0.1, gate=1, noise=0.1, vibFreq=5.2, vibGain=0.9, pan=0.0, sustain=1, speed=1, accelerate=0|
	var lastOut = LocalIn.ar(1);
	var env = EnvGen.ar(Env.adsr(0.005, 0.01, 1.0, 0.010), gate, doneAction: 2);
	var vibrato = SinOsc.ar(vibFreq, 0, vibGain);
	var pressureDiff = vibrato - lastOut;
	var jet = (pressureDiff * (pressureDiff.squared - 1.0)).clip2(1.0);
	var randPressure = WhiteNoise.ar(noise)*(1.0 + pressureDiff);
  var basefreq = freq * DirtFreqScale.kr(speed, accelerate, sustain);
	var resonator = Resonz.ar(randPressure - (jet*pressureDiff), basefreq, rq) * 4;
	LocalOut.ar(resonator);

	Out.ar(out, DirtPan.ar(LeakDC.ar(resonator), ~dirt.numChannels, pan, env))
}).add;
);


(
SynthDef(\forestbird, { |out=0, pan=0|
	var signal = BPF.ar(BrownNoise.ar,SinOsc.kr(LFNoise2.kr(50,50,50),0,100,2000),0.001,10);
	Out.ar(out, DirtPan.ar(signal, ~dirt.numChannels, pan));
}).add;
);

x = Synth.new(\forestbird);

x.free;