requires("1.33s"); 
dir = getDirectory("Choose a stacks directory");
outputDir = getDirectory("Select output directory");
setBatchMode(false);
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
	parts_name = split(file,"_");
	fish = parts_name[2];
	
	age = File.getName(dir);
	mauthner = File.getName(File.getParent(dir));

	newName = fish + "-nefma-" + age + "dpf-" + mauthner + "_01.nrrd";
	
	if ( !endsWith(file, "skip.czi") && !File.exists(outputDir + newName) ) {
	
		print("processing: "+ newName);

		run("Bio-Formats Importer", 
		"open=" + dir + file + 
		" autoscale color_mode=Composite rois_import=[ROI manager] " + 
		"view=Hyperstack stack_order=XYCZT");
		
		current = getTitle();
		print("title: " + current);
		print("filename: " + File.getName(current));

		getDimensions(width, height, channels, slices, frames);
		
		if (channels == 2) {
			run("Split Channels");
			close("C1-" + current);
		}
	
		run("Z Project...", "projection=[Max Intensity]");
		run("Enhance Contrast", "saturated=0.35");
		zproj = getTitle();

	
		// prepare and display dialog
		toFlip=false;
		Dialog.create("Should I flip the image?");
		Dialog.addCheckbox("Flip", true);
		Dialog.show();
		toFlip = Dialog.getCheckbox();
		close(zproj);
		
		if (toFlip == true) {
			
	    	run("Rotate... ", "angle=180 grid=1 interpolation=Bilinear stack");
		}


		setKeyDown("alt");
		run("Nrrd ... ", "nrrd="+outputDir+newName);
		setKeyDown("none");

		close("*");

	} else {
		print("skipping");
	}


	
}

