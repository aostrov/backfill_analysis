// "BatchConvertAnyToNrrd"
//
// This macro batch all of the files in a folder hierarchy
//   to nrrd format

// Adapted by Greg Jefferis from code at
// http://rsb.info.nih.gov/ij/macros/BatchProcessFolders.txt

// jefferis@gmail.com

/* Run from the command line as follows
fiji -eval '
runMacro("/Volumes/JData/JPeople/Common/CommonCode/ImageJMacros/BatchConvertAnyToNrrd.txt",
"/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/images.unsorted/,/Volumes/JData/JPeople/Sebastian/fruitless/Registration/IS2Reg/images.unflipped/SAJ/");
' -batch --headless
*/

requires("1.42k"); 
file = getArgument;
dir=""
outputDir=""

//print("file = "+file);
if (file!=""){
	arg = split(file,",");
		if (arg.length!=2) {
		exit();
	} else if(arg[0]=="" || arg[1]==""){
		exit();
	} else {
		outputDir=arg[1];
		if(!endsWith(outputDir,"/")) outputDir=outputDir+"/";

		if(File.isDirectory(arg[0])) {
			// we're dealing with a directory
			dir=arg[0];
			if(!endsWith(dir,"/")) dir=dir+"/";
		} else {
			// single file
			dir=File.getParent(arg[0])+"/";
			file=File.getName(arg[0]);
			processFile(dir,outputDir,file);
			exit();
		}
	}
}

if(dir=="") dir = getDirectory("stacks directory");
if(outputDir=="") outputDir = getDirectory("output directory");

setBatchMode(true);
count = 0;
countFiles(dir);
print("Total files: "+count);
n = 0;
processFiles(dir, outputDir);

function countFiles(dir) {
	list = getFileList(dir);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
            countFiles(""+dir+list[i]);
	else
		count++;
	}
}

function processFiles(dir,outputDir) {
	list = getFileList(dir);
	// Stops multiple processes racing each other to do the same file
	shuffle(list);
	for (i=0; i<list.length; i++) {
		if (endsWith(list[i], "/"))
			processFiles(""+dir+list[i], outputDir+list[i]);
		else {
			showProgress(n++, count);
			processFile(dir,outputDir,list[i]);
		}
	}
}

function processFile(dir,outputDir,file) {
	open(dir + file);
	print(file);

	if (bitDepth() == 32) {
		setSlice(120);
		resetMinAndMax();
		run("16-bit");
		resetMinAndMax();
	}

	cum_mean = 0;
	cum_std = 0;

	if (file.contains("6dpf")) {
		meanAndSd = stats3d(65, 150, 297, 51, 579, 351);
	} else {
		meanAndSd = stats3d(50, 170, 318, 6, 579, 351);	
	}
	cum_mean = cum_mean + meanAndSd[0];
	cum_std = cum_std + meanAndSd[1];
	
	if (file.contains("6dpf")) {
		meanAndSd = stats3d(40, 150, 144, 621, 918, 288);
	} else {
		meanAndSd = stats3d(40, 220, 166, 550, 918, 364);
	}
	cum_mean = cum_mean + meanAndSd[0];
	cum_std = cum_std + meanAndSd[1];

	if (file.contains("6dpf")) {
		meanAndSd = stats3d(115, 165, 288, 903, 606, 183);
	} else {
		meanAndSd = stats3d(145, 230, 328, 880, 606, 183);
	}
	cum_mean = cum_mean + meanAndSd[0];
	cum_std = cum_std + meanAndSd[1];

	cum_mean = cum_mean / 3;
	cum_std = cum_std / 3;
	
	lower = round(cum_mean + 1.5 * cum_std);
	setThreshold(lower, 65535);
	run("Make Binary", "method=Huang background=Dark black");
	run("Divide...", "value=255 stack");

	setKeyDown("alt");
	run("Nrrd ... ", "nrrd=[" + outputDir + file + "-" + lower + "_binary.nrrd]");
	setKeyDown("none");
	close("*");
}

function processImage(fileName,outpath) {
	// You can make any changes to the image that you want in here
	// eg flip, reverse etc
	//current = getTitle();
	run("Split Channels");

	setKeyDown("alt");
	run("Nrrd ... ","nrrd=[" + outpath + fileName + "_02.nrrd]");
	setKeyDown("none");
	close();

}

function shuffle(array) {
   n = array.length;  // The number of items left to shuffle (loop invariant).
   while (n > 1) {
      k = randomInt(n);     // 0 <= k < n.
      n--;                  // n is now the last pertinent index;
      temp = array[n];  // swap array[n] with array[k] (does nothing if k==n).
      array[n] = array[k];
      array[k] = temp;
   }
}

// returns a random number, 0 <= k < n
function randomInt(n) {
   return n * random();
}

function stats3d(z0, z1, x, y, width, height) {
	avg_mean = 0;
	avg_std = 0;
	difference= z1 - z0;
	makeRectangle(x, y, width, height);
	for (thisSlice = 0 ; thisSlice<difference ; thisSlice++){
		setSlice(z0 + thisSlice);		
		getStatistics(area, mean, min, max, std, histogram);
		avg_mean = avg_mean + mean;
		avg_std = avg_std + std;
	}
	innerResult = newArray(2);
	innerResult[0] = avg_mean / difference;
	innerResult[1] = avg_std / difference;
	return innerResult;
}