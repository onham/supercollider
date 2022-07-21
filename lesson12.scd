(
SynthDef(\draft, {
	|pan, freq=440, sustain=1, resonance=0.0005, rate=1, detune=0.001, voice=0.001, out|
	var sig, amp, d, temp, env, sum, primes, trig, phase, freqmod, widthmod, sound, outAudio, r, n=3;
	sum = 0;
	r = [3,5,8,9]/8;
	detune = min(detune, 1);

	primes = [11, 3, 2, 5];

	trig = Impulse.ar(30.0/primes/sustain * rate);
	phase = Phasor.kr(trig, 1.0/primes/ControlRate.ir);

	i = TIRand.kr(0, 1, trig);
	d = Rand(0.99*i - detune, 1.01*i + detune);

	env = EnvGen.kr(Env.new([0,1,1,0],[10,20,10],[1,1,-1]),doneAction:2);

	// env = EnvGen.ar(Env.sine(1.0), timeScale:sustain, doneAction:2);

	8.do{
		freqmod = SinOsc.kr(LFNoise0.kr(1)).range(1-detune, 1+detune);
		widthmod = SinOsc.kr(LFNoise0.kr(1)).range(0.35, 0.65);

		temp = LFCub.ar((freq*freqmod*(1..primes.size)*[1+(detune/12),1-(detune/12)] / 2.0)*({ExpRand(0.35,1.2)}!8).range(0,1), {phase*widthmod}!8);

		temp = temp * LFNoise0.kr({ExpRand(0.5,2)}!8).exprange(0.1,1);
		sum = sum + temp;
	};

	sound = Splay.ar(sum);

	sound = Resonz.ar(sound, freq*r*d, 0.01 + voice.linexp(0,1,1e-3,1));

	sound = HPF.ar(Limiter.ar(55 * GVerb.ar(sound, resonance.linexp(0,1,99,0.1),10) ), 30).sanitize;

	sound = SplayAz.ar(primes.size, sound.flat, center:LFNoise2.kr(sustain).range(0,primes.size-1));

	outAudio = RLPF.ar(sound, 2400);

	Out.ar(out, DirtPan.ar(outAudio, ~dirt.numChannels, pan, env));
}).add;
)


x = Synth.new(\draft);

x.free;