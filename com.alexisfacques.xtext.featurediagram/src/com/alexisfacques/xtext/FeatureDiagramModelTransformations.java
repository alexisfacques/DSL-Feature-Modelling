package com.alexisfacques.xtext;

public class FeatureDiagramModelTransformations {
	public static void main(String[] args) {
		try{  
		 	switch(args[0]) {
		   		case "json":
		   			FeatureDiagramToJSON.transform(args[1],args[2]);
		   			break;
	 	   		case "cnf":
		   			FeatureDiagramToCNF.transform(args[1],args[2]);
	 	   			break;
	 	   		case "mzn":
		   			FeatureDiagramToMZN.transform(args[1],args[2]);
					break;
	 	   		case "generate":
	 	   			FeatureDiagramGeneration.generate(Integer.parseInt(args[1]), Integer.parseInt(args[2]), args[3]);
	 	   			break;
	 	   		default:
	 	   			System.err.println("Command not supported");
	 	   			break;
		 	}
	    	} catch(ArrayIndexOutOfBoundsException e){
		    	System.out.println("Missing arguments");
	    	}
	}
}
