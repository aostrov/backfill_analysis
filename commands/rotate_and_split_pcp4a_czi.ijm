// outdir = "D:/joao/images/"

requires("1.33s"); 
dir = getDirectory("Choose a stacks directory");
outputDir = getDirectory("Select output directory");
setBatchMode(true);
count = 0;
countFiles(dir); //output dir should not be subfolder of input dir!
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
    for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/"))
            processFiles(""+dir+list[i], outputDir);
        else {
		showProgress(n++, count);
              processFile(dir,outputDir,list[i]);
        }
    }
}

function processFile(dir,outputDir,file) {

	run("Bio-Formats Importer", 
		"open=" + dir + file + 
		" autoscale color_mode=Composite rois_import=[ROI manager]" + 
		" view=Hyperstack stack_order=XYCZT");
	makeRectangle(0, 0, 1248, 725);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	print(mean);
	
	makeRectangle(0, 726, 1248, 725);
	getRawStatistics(nPixels, mean2, min, max, std, histogram);
	print(mean2);
	run("Select None");
	
	if (mean2>mean) {
		run("Rotate... ", "angle=180 grid=1 interpolation=Bilinear");
	}
	
	
	outdir = "E:/Joao/mauthner_backfills/pcp4a/images/";
	current = getTitle();
	refChannel = "C2-" + current;
	secondChannel = "C1-" + current; 
	run("Split Channels");
	
	// current = getTitle();
	outfile = substring(current, 0, lastIndexOf(current, ".czi"));
	// print(out_ref);
	selectImage(refChannel);
	setKeyDown('alt');
	run("Nrrd ... ", "nrrd=" + outputDir + outfile + "_01.nrrd");
	setKeyDown('none');
	close();
	
	selectImage(secondChannel);
	setKeyDown('alt');
	run("Nrrd ... ", "nrrd=" + outputDir + outfile + "_02.nrrd");
	setKeyDown('none');
	close();

}




//open("E:/Joao/mauthner_backfills/pcp4a/images_raw/PCP4a_backfill_E58.czi");

