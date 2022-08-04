
SynthDef(\digi1, {|out, pan, freq, sustain, accelerate, rate=0.25, detune=0, voice=0, speed=1|
	var scale = [0, 7, 2, 3, 10, 3, 2, 5, 0, -2, 2, -5, -4, 0, 3, 7, 8, 12, 14, 15];
	var mix = 0;
	var env = Env.adsr(4,0,1,4).kr(2,Trig1.kr(1,56));
	2.do { |i|
		var root = LFPulse.kr(1/scale.size).range(48,55);
		var note = root + Select.kr(
			LFSaw.kr(1/LFPulse.kr(1/4).range(2,4)/scale.size, 1).range(0, scale.size),
			scale
		);
		var primes = [2, 3, 5, 7, 11, 13, 17, 19, 23];
		var trig = Impulse.ar(30.0/primes/sustain * rate);
		var phase = Phasor.kr(trig, 1.0/primes/ControlRate.ir);
		var p = TIRand.kr(0, 3, Impulse.kr(sustain/8).dup(8));
		var r = primes/8;
		var d = Rand(1.6*p - detune, 1.7*p + detune).round(0.25);
		var sig = Select.ar(i, [
			PMOsc.ar(note.midicps),
		]);
		sig = (sig*LFNoise0.kr(4.5).exprange(1,30)).sin;
		sig = RLPF.ar(sig, (note+24).midicps, 0.8);
		sig = Normalizer.ar(sig, 0.2);
		sig = sig + CombL.ar(
			RLPF.ar(
				Select.ar(i, [
					Saw.ar((note - 12 + 5).midicps, mul:0.5),
					Pulse.ar((note + 12 + 7).midicps, mul: LFTri.kr(1/4).range(0.4,0.5)),]) * LFTri.kr(1/2),
				LFTri.kr(1).exprange(600,800),0.8), 1, 1/8);
		sig = Pan2.ar(sig, LFTri.kr(1/2, 2*i, mul: 0.5), 0.5);
		mix = mix + DelayN.ar(sig, 1, i, mul: 1 - (i/2));
	};
	// mix = XFade2.ar(mix, NHHall.ar(mix,3,modRate:0.1,modDepth:0.9), -1/4);
		Out.ar(out, DirtPan.ar(mix, ~dirt.numChannels, pan, env));
}).add;