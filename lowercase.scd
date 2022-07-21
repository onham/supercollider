(//floating point errors
{ var pink;
	pink = PinkNoise.ar().range(0.08, 0.12)!2;
	0.5*LeakDC.ar(Median.ar(2, Limiter.ar(99999999*(SawDPW.ar(pink, 0) + SawDPW.ar(pink, pi)), 0.9)))}.play;
{ var pink;
	pink = PinkNoise.ar().range(0.0999/3, 0.1001/3)!2;
	0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink, 0) + SawDPW.ar(pink, pi)), 0.9)))}.play;
{var pink;
	pink = PinkNoise.ar().range(0.00999, 0.01001)!2;
	(0.5*Median.ar(20,
	Limiter.ar(999999*LeakDC.ar(SawDPW.ar(pink, 0+(pi/2)) + SawDPW.ar(pink, pi+(pi/2))), 0.1)))}.play;
{0.5*Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(0.005, 0) + SinOsc.ar(0.005, pi)), 0.05)))!2}.play;
{0.5*SVF.ar((Median.ar(10, Limiter.ar(999999*LeakDC.ar(LFPulse.ar(0.5, 0) + LFPulse.ar(0.5, pi)), 0.6))), 800)!2}.play;
)

SynthDef(\lowercase, {
	|amp=1, out=0, pan|
	var sig;
	var pink;
	pink = WhiteNoise.ar().range(0.00999, 0.01001)!2;
	sig = 0.5*Median.ar(20, Limiter.ar(999999*LeakDC.ar(SawDPW.ar(pink, 0+(pi/2)) + SawDPW.ar(pink, pi+(pi/2))), 0.1));
	sig = sig * amp;
	Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

x = Synth.new(\lowercase);

s.freeAll;