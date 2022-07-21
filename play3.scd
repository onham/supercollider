(
SynthDef(\yazoodelayeffect, {|out=0 gate=1 pan= 0.1|
	var source = In.ar(out,2);
	var env = Linen.kr(gate, 0.0, 1, 0.1, 2);
	var delay= DelayC.ar(source[0].distort,0.25,0.25);

	Out.ar(out, DirtPan.ar(delay, ~dirt.numChannels, pan, env))
}).add;
);