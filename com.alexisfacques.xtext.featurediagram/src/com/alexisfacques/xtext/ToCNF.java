package com.alexisfacques.xtext;

public class ToCNF {
    public static void main(String[] args) {
	    	try{        
    	 	   String input = args[0];
    	 	   String output = args[1];
    	 	   FeatureDiagramToCNF.modelTransformation(input,output);
	    	} catch(Exception e){
	    		if(e instanceof ArrayIndexOutOfBoundsException) {
		    		System.out.println("Missing arguments");
	    		}
	    	}
	}
}
