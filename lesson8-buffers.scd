~b0 = Buffer.read(s, "/Users/quannham/Desktop/stuff/music/stems/Vroom Vroom (Stems)/TROPHY/CHORDS.wav", 1800000);

~b0.play;

~b0.numFrames;

~b0.zero;

~b0.free;

(
SynthDef(\playbuf_test, {
	|amp=1, out, buf|
	var sig;
	sig = PlayBuf.ar(~dirt.numChannels, buf);
	sig = sig*amp;
	Out.ar(out, sig);
}).add
)

x = Synth.new(\playbuf_test, [\buf, ~b0.bufnum]);

x.free;