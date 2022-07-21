(
	var g = Group.basicNew(s,1);

	var stereoBuffer1L = Buffer.alloc(s, s.sampleRate*3, 1);
	var stereoBuffer1R = Buffer.alloc(s, s.sampleRate*3, 1);

    var monoBuffer1 = Buffer.alloc(s, s.sampleRate*2, 1);

	var rootPitch = 24;										// Start on a C

	var stopTranspose = 0;
	var transposeCount = 30;									//Wait a while after transposing to minimise semitone clashes

    var thisSemitone = Scale.chromatic.semitones;
	var thisPitch = thisSemitone.choose * rootPitch.midicps;

// var svf = Synth.tail(g, \Filters);
var d = Synth.tail(g, \StereoModDelay);

	stereoBuffer1L.zero;
	stereoBuffer1R.zero;
	d.set(\bufferL, stereoBuffer1L);
	d.set(\bufferR, stereoBuffer1R);

	//First few notes have a slow attack and longer interval
	{4.do
		{
		Synth.head(g, \ChMach,
			[\f, thisPitch,
			\width, rrand(0,1),
			\pan, rrand(-1,1),
			\aTime, rrand(5,15),
			\rTime, rrand(7,20),
			\filter, rrand(4,10),
			\filterQ, rrand(0,3.7),
			\modFreq, rrand(0.7,1.5)]);
		  rrand(1,3).wait;
		}
	};

	//Pick a note from the scale with somewhat random settings and slowly noodle around the circle of fifths
	{32.do
		{
		thisPitch = thisSemitone.choose * rootPitch.midicps;
		stopTranspose = stopTranspose + 1;
		Synth.head(g, \ChMach,
			[\f, thisPitch,
			\width, rrand(0,1),
			\pan, rrand(-1,1),
			\aTime, rrand(0.01,15),
			\rTime, rrand(7,20),
			\filter, rrand(4,10),
			\filterQ, rrand(0,3.7),
			\modFreq, rrand(0.7,1.5)]);
		if ((0.04.coin) && (stopTranspose > transposeCount)) {
			stopTranspose = 0;
			rootPitch = rootPitch + 7;
			if (rootPitch > 47) {rootPitch = rootPitch - 12};
			rootPitch.postln;
			};
		   rrand(0.1,2).wait;
		   }
	}.fork;
)

// s.freeAll;