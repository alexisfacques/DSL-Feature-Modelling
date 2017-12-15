package com.alexisfacques.sat4j;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.sat4j.core.VecInt;
import org.sat4j.minisat.SolverFactory;
import org.sat4j.reader.DimacsReader;
import org.sat4j.reader.InstanceReader;
import org.sat4j.reader.ParseFormatException;
import org.sat4j.reader.Reader;
import org.sat4j.specs.ContradictionException;
import org.sat4j.specs.IProblem;
import org.sat4j.specs.ISolver;
import org.sat4j.specs.IVecInt;
import org.sat4j.specs.TimeoutException;
import org.sat4j.tools.ModelIterator;

public class Sat4JSolver {
    public static void main(String[] args) {
		    	try{        	
		    		long startTime = System.nanoTime();
			 	switch(args[0]) {
			   		case "all":
		 	   			if(args.length > 2) {
		 	   				getAllModels(args[1], args[2].split(","));
		 	   			}
		 	   			else {
				   			getAllModels(args[1]);
		 	   			}
			   			break;
		 	   		case "satisfy":
		 	   			if(args.length > 2) {
		 	   				getSatisfiability(args[1], args[2].split(","));
		 	   			}
		 	   			else {
			 	   			getSatisfiability(args[1]);
		 	   			}
		 	   			break;
		 	   		case "locked":
		 	   			if(args.length > 2) {
		 	   				getLockedFeatures(args[1], args[2].split(","));
		 	   			}
		 	   			else {
		 	   				getLockedFeatures(args[1]);
		 	   			}
		 	   			break;
		 	   		default:
		 	   			System.err.println("Command not supported");
			 	}
			 	long endTime = System.nanoTime();
			 	long durationMs = (endTime - startTime) / 1000000;

			 	System.out.println("Execution time : " + Long.toString(durationMs) + "ms" );
		    	} catch(ArrayIndexOutOfBoundsException e){
			    	System.err.println("Missing arguments");
		    	} catch (ContradictionException e) {
		    		System.out.println ("Unsatisfiable");
		    	} catch (TimeoutException e) {
		    		System.err.println ("Timeout");
		    	} catch(FileNotFoundException e) {
		    		System.err.println("Input file not found");
		    	} catch (Exception e) {
		    		e.printStackTrace();
		    	}
    }

    private static void getAllModels(String input) throws ParseFormatException, IOException, ContradictionException, TimeoutException {
    		getAllModels(input, new String[0]);
    }

    private static void getSatisfiability(String input) throws ParseFormatException, IOException, ContradictionException, TimeoutException {
    		getSatisfiability(input, new String[0]);
    	}
   
    private static void getLockedFeatures(String input) throws TimeoutException, ParseFormatException, IOException, ContradictionException {
    		getLockedFeatures(input, new String[0]);
    }
  
    private static void getAllModels(String input, String[] assumps) throws ParseFormatException, IOException, ContradictionException, TimeoutException {
        ISolver solver = SolverFactory.newDefault();
        ModelIterator mi = new ModelIterator(solver);
        solver.setTimeout(3600);
        Reader reader = new InstanceReader(mi);
        	
        IVecInt assumptions = new VecInt(Arrays.stream(assumps).mapToInt(Integer::parseInt).toArray());

        boolean unSatisfied = true;
        IProblem problem = reader.parseInstance(input);
        
        while (problem.isSatisfiable(assumptions)) {
        		unSatisfied = false;
        		int[] model = problem.model();
        		
			System.out.println(Arrays.stream(model)
			        .mapToObj(String::valueOf)
			        .collect(Collectors.joining(",")));
        }
        if (unSatisfied) {
        		System.err.println("Unsatisfiable");
        }
    }
    
    private static void getSatisfiability(String input, String[] assumps) throws ParseFormatException, IOException, ContradictionException, TimeoutException {
	    	ISolver solver = SolverFactory.newDefault();
	    	solver.setTimeout(3600);
	    	Reader reader = new DimacsReader(solver);
	    	
	    	IVecInt assumptions = new VecInt(Arrays.stream(assumps).mapToInt(Integer::parseInt).toArray());
	    		
	    	IProblem problem = reader.parseInstance(input);
	    	
	    	if (problem.isSatisfiable(assumptions)) {
	    		System.out.println("Satisfiable");
	    	}
	    	else {
	    		System.out.println("Unsatisfiable");
	    	}
    }
    
    private static void getLockedFeatures(String input, String[] assumps) throws TimeoutException, ParseFormatException, IOException, ContradictionException {
		ISolver solver = SolverFactory.newDefault();
		solver.setTimeout(3600);
		Reader reader = new DimacsReader(solver);
	    	IProblem problem = reader.parseInstance(input);
	    	IVecInt assumptions = new VecInt(Arrays.stream(assumps).mapToInt(Integer::parseInt).toArray());
	    	
	    	List<String> res = new ArrayList<String>();
	    	
    		if (problem.isSatisfiable(assumptions)) {
    	    		for(int i = 1; i <= problem.nVars(); i++) {
    	    			int isLocked = _isLockedFeature(problem,assumptions,i);
    	    			if(isLocked != 0) res.add(Integer.toString(isLocked * i));
   			}
    	    		
    	    		System.out.println(String.join(",", res));
    		}
    		else {
    			System.err.println("Unsatisfiable");
    		}
    }
 
    private static int _isLockedFeature(IProblem problem, IVecInt assumptions, int val) throws TimeoutException {
		int ret = 0;
		if(_isCoreFeature(problem,assumptions,val)) ret++;
		if(_isDeadlockFeature(problem,assumptions,val)) ret--;
		return ret;
    }
    
    private static boolean _isDeadlockFeature(IProblem problem, IVecInt asms, int val) throws TimeoutException {
    		if(asms.contains(val)) return false;
    		
    	
    		IVecInt assumptions = new VecInt();
    		asms.copyTo(assumptions);
    		assumptions.insertFirst(val);
    		
		return !problem.isSatisfiable(assumptions);
    }
    
    private static boolean _isCoreFeature(IProblem problem, IVecInt asms, int val) throws TimeoutException {
		if(asms.contains(-val)) return false;

		IVecInt assumptions = new VecInt();
		asms.copyTo(assumptions);
		assumptions.insertFirst(-val);
	
		return !problem.isSatisfiable(assumptions);
    }
 
}
