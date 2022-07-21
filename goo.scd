(
SynthDef(\goeyfx, { | out=0, pan=0.0 |
	var combDelays = 2; // number of comb delays
	var allpassDelays = 3; // number of allpass delays

	var in = In.ar(0,2);
	// reverb predelay time :
	var delay = DelayN.ar(in, 0.048,0.048);

	//for delaytime if want modulation-	//LFNoise1.kr(0.1.rand, 0.04, 0.05)
	var y = Mix.arFill(combDelays,{CombL.ar(delay,0.1,rrand(0.01, 0.1),5)});

	// chain of 4 allpass delays on each of two channels (8 total) :
	allpassDelays.do {
		y = AllpassN.ar(y, 0.051, [rrand(0.01, 0.05),rrand(0.01, 0.05)], 1)
	};

	Out.ar(out, DirtPan.ar(y, ~dirt.numChannels, pan));
}).add;
);


(
SynthDef(\yazoodelayeffect, {|out=0 gate=1 pan= 0.1|
	var source = In.ar(out,2);
	var env = Linen.kr(gate, 0.0, 1, 0.1, 2);
	var delay= DelayC.ar(source[0].distort,0.25,0.25);

	Out.ar(out, DirtPan.ar(delay, ~dirt.numChannels, pan, env))
}).add;
);



x = Synth.new(\goeyfx);

x.free;
