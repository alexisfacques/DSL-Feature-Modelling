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
		 	   		case "core":
		 	   			getCoreOrDeadlock(args[1],true);
		 	   			break;
		 	   		case "dead":
		 	   			getCoreOrDeadlock(args[1],false);
		 	   			break;
		 	   		case "satisfy":
		 	   			if(args.length > 2) {
		 	   				getSatisfiability(args[1], args[2].split(","));
		 	   			}
		 	   			else {
			 	   			getSatisfiability(args[1]);
		 	   			}
		 	   			break;
		 	   		default:
		 	   			System.err.println("Command not supported");
			 	}
			 	long endTime = System.nanoTime();
			 	long durationMs = (endTime - startTime) / 1000000;

			 	System.out.println("Execution time : " + Long.toString(durationMs) + "ms" );
		    	} catch(Exception e){
		    		if(e instanceof ArrayIndexOutOfBoundsException) {
			    		System.err.println("Missing arguments");
		    		}
		    	}
    }
    
    private static void getAllModels(String input) {
    		getAllModels(input, new String[0]);
    }

    private static void getSatisfiability(String input) {
    		getSatisfiability(input, new String[0]);
    	}

    private static void getAllModels(String input, String[] assumps) {
        ISolver solver = SolverFactory.newDefault();
        ModelIterator mi = new ModelIterator(solver);
        solver.setTimeout(3600); // 1 hour timeout
        Reader reader = new InstanceReader(mi);

        try {
        		IVecInt assumptions = new VecInt(Arrays.stream(assumps).mapToInt(Integer::parseInt).toArray());

            boolean unsat = true;
            IProblem problem = reader.parseInstance(input);
            while (problem.isSatisfiable(assumptions)) {
            		unsat = false;
            		int [] model = problem.model();
   				System.out.println(Arrays.stream(model)
   				        .mapToObj(String::valueOf)
   				        .collect(Collectors.joining(",")));
            }
            if (unsat) {
            		System.err.println("Unsatisfiable");
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (ParseFormatException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ContradictionException e) {
            System.err.println("Unsatisfiable");
        } catch (TimeoutException e) {
            System.err.println("Timeout");
        }
    }
    
    private static void getSatisfiability(String input, String[] assumps) {
	    	ISolver solver = SolverFactory.newDefault();
	    	solver.setTimeout(3600); // 1 hour timeout
	    	
	    	Reader reader = new DimacsReader(solver);
	    	try {
	    		IVecInt assumptions = new VecInt(Arrays.stream(assumps).mapToInt(Integer::parseInt).toArray());
	    		
	    		IProblem problem = reader.parseInstance(input);
	    		if (problem.isSatisfiable(assumptions)) {
	    			System.out.println("Satisfiable");
	    		}
	    		else {
	    			System.out.println("Unsatisfiable");
	    		}
	    	} catch (FileNotFoundException e) {
	    		e.printStackTrace();
	    	} catch (ParseFormatException e) {
	        e.printStackTrace();
	    	} catch (IOException e) {
	        e.printStackTrace();
	    	} catch (ContradictionException e) {
	    		System.out.println ("Unsatisfiable");
	    	} catch ( TimeoutException e) {
	    		System.err.println ("Timeout");
	    	}
    }
    
    private static void getCoreOrDeadlock(String input, boolean core) {
    		ISolver solver = SolverFactory.newDefault();
    		solver.setTimeout(3600); // 1 hour timeout
    	
    		Reader reader = new DimacsReader(solver);
	    	try {
	    		List<String> res = new ArrayList<String>();
	    		
	    		IProblem problem = reader.parseInstance(input);
	    		
	    		if (problem.isSatisfiable()) {
    			    int[] var = new int[1];
	    			for(int i = 1; i <= problem.nVars(); i++) {
	    			    if(core) {
	    			    		var[0] = -i;
	    			    }
	    			    else {
	    			    		var[0] = i;
	    			    }
	    			    
	    				IVecInt assump = new VecInt(var);
	    				
	    		        if (!solver.isSatisfiable(assump)) {
	    		            res.add(Integer.toString(i));
	    		        }
	    			}
	    			
   				System.out.println(String.join(",", res));
	    		}
	    		else {
	    			System.err.println("Unsatisfiable");
	    		}
	    	} catch (FileNotFoundException e) {
	    		e.printStackTrace();
	    	} catch (ParseFormatException e) {
	        e.printStackTrace();
	    	} catch (IOException e) {
	        e.printStackTrace();
	    	} catch (ContradictionException e) {
	    		System.err.println ("Unsatisfiable");
	    	} catch ( TimeoutException e) {
	    		System.err.println ("Timeout");
	    	}
    }
}
