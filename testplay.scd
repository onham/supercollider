(
	var g = Group.basicNew(s,1);

	var stereoBuffer1L = Buffer.alloc(s, s.sampleRate*3, 1);
	var stereoBuffer1R = Buffer.alloc(s, s.sampleRate*3, 1);

    var monoBuffer1 = Buffer.alloc(s, s.sampleRate*2, 1);

// var svf = Synth.tail(g, \Filters);
var d = Synth.tail(g, \StereoModDelay);


	stereoBuffer1L.zero;
	stereoBuffer1R.zero;
	d.set(\bufferL, stereoBuffer1L);
	d.set(\bufferR, stereoBuffer1R);

	{64.do
		{
		Synth.head(g, \ChMach2,
			[\width, rrand(0,1),
			\pan, rrand(-1,1),
			\aTime, rrand(5,5),
			\rTime, rrand(15,15),
			\filter, rrand(5,10),
			\filterQ, rrand(0,3.7),
			\modFreq, rrand(0.7,1.5)]);
		  rrand(1,4).wait;
		}
	}.fork;

)

// s.freeAll;