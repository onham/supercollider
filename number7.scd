
(
SynthDef(\quan2, {
		|out, sustain=1, speed=1, decay=0.2, dens, begin=0, end=1, pan, accelerate, offset, gate=1.0, width=0.75, clamp=1, res=1|
	    var sig, trig, freq, tone, env, line;
		line = Line.ar(begin,end,sustain, doneAction: Done.freeSelf);
	    freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	    trig = Dust.kr(2);
	    sig = (Pulse.ar(freq, line)+Pulse.ar(freq*1.01, line)+Pulse.ar(freq*0.99, line))/3;
	env = Env.perc(0.01, decay);
	    sig = sig * EnvGen.kr(env, trig);
	    sig = Pan2.ar(sig, LFNoise1.kr(10));
	    Out.ar(out, sig);
}).add;
)

(
SynthDef(\quanverb, {
	|in, out=0|
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5,0.8,0.2);
	Out.ar(out, sig);
}).add;
)

~reverbBus = Bus.audio(s, 1);

x = Synth.new(\quanverb, [\in, ~reverbBus]);

8.do{
	Synth.new(\quan2, [\out, ~reverbBus]);
}

x.free;
y.free;
