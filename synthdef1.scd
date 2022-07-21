(
SynthDef(\superprimes, {|out, pan, freq, sustain, accelerate, rate=1, detune=0, voice=0, speed=1|
	var env, sound, primes, trig, phase, i, r, d;
	freq = freq * DirtFreqScale.kr(speed, accelerate, sustain);
	env = EnvGen.ar(Env.sine(1.0,0.5), timeScale:sustain, doneAction:2);
	primes = [2, 3, 5, 7, 11];
	trig = Impulse.ar(30.0/primes/sustain * rate);
	phase = Phasor.kr(trig, 1.0/primes/ControlRate.ir);
	sound = SinOsc.ar(freq * (1..primes.size)*[1+(detune/12),1-(detune/12)] / 2.0, phase)
	* LPF.ar(Decay.ar(trig, (primes+3)*sustain/10), voice.linexp(0,2,30,18000));
	sound = GVerb.ar(sound.softclip, 10*voice.linexp(0,5,1,0.01), 10).cosh;
	Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);

s.freeAll;

x = Synth.new(\superprimes);

x.free;

(
SynthDef(\superspook, {|out, pan, freq, sustain, accelerate, rate=1, detune=0, voice=0, speed=1, resonance=0|
	var env, sound, primes, trig, phase, i, r, d;
	freq = freq * DirtFreqScale.kr(speed, accelerate, sustain);
	env = EnvGen.ar(Env.sine(1.0,3.0), timeScale:sustain, doneAction:2);
	primes = [2, 3, 5, 7, 11, 13, 17, 19, 23];
	trig = Impulse.ar(30.0/primes/sustain * rate);
	phase = Phasor.kr(trig, 1.0/primes/ControlRate.ir);
	sound = PMOsc.ar(freq * (1..primes.size)*[1+(detune/12),1-(detune/12)] / 2.0, phase)
	* LPF.ar(Decay2.ar(trig, 0.01, (primes+3)*sustain/10), voice.linexp(0,2,30,18000));
	i = TIRand.kr(0, 3, Impulse.kr(sustain/8).dup(8));
	r = primes/8;
	detune = min(detune,1.5);
	d = Rand(1.6*i - detune, 1.7*i + detune).round(0.25);
	sound = Resonz.ar(trig, freq*r*d, 0.01 + voice.linexp(0,1,1e-3,1));
	sound = HPF.ar(Limiter.ar(55 * GVerb.ar(sound, resonance.linexp(0,1,99,0.1),10) ), 30).sanitize;
	sound = GVerb.ar(sound.softclip, 10*voice.linexp(0,5,1,0.01), 10).atan;
	Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env));
}).add;
);


SynthDef(\quan2, {
		|out, sustain=1, speed=1, begin=0, end=1, pan, accelerate, offset, gate=1.0, width=0.75, clamp=1, res=1|
		var line = Line.ar(begin,end,sustain, doneAction: Done.freeSelf);
		var env = Env.new(levels: [0, 1, 0.9, 0], times: [0.1, 0.9, 1], curve: [-5, 1, -5]);
	    var freq = XLine.kr(880,110,sustain,doneAction:0);
		var volume = IEnvGen.ar(env, line);
	    var tone = Pulse.ar(freq);
		var outAudio = RLPF.ar(tone*volume, 20000*clamp*volume, res);
		OffsetOut.ar(out, DirtPan.ar(outAudio, ~dirt.numChannels, pan, volume));
	}).add;

(
SynthDef(\test1, {
	var sig, amp, env;
	env = EnvGen.kr(
		Env.new([0,1,0],[10,10],[1,-1]),
		doneAction:2
	);
	amp = SinOsc.kr({ExpRand(0.2,12)}!4).range(0,1);
	sig = SinOsc.ar({ExpRand(50,1200)}!4);
	sig = sig*amp*env;
	sig = Splay.ar(sig)*0.5;
	Out.ar(0,sig);
}).add;
)