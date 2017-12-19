package com.alexisfacques.xtext

import com.alexisfacques.xtext.featureDiagram.Constraint
import com.alexisfacques.xtext.featureDiagram.Declaration
import com.alexisfacques.xtext.featureDiagram.ExtendedFeature
import com.alexisfacques.xtext.featureDiagram.Feature
import com.alexisfacques.xtext.featureDiagram.FeatureDefinition
import com.alexisfacques.xtext.featureDiagram.FeatureDiagramModel
import com.alexisfacques.xtext.featureDiagram.FeatureGroup

import java.util.List
import java.util.ArrayList

class FeatureDiagramToCNF extends FeatureDiagramUtils {	
	static def void transform(String input, String output) {
		// Loading the feature diagram model.
		var FeatureDiagramModel featureDiagram = loadFeatureDiagram(input)		

		// Populating features with an id.
		populateIds(featureDiagram);

		// Stingified CNF clauses.
		var String cnfClauses = toCNF(featureDiagram);
				
		// Printing JSON structure onto the console.
		var json = FeatureDiagramToJSON.toJSON(featureDiagram);
		System.out.println(json);
		
		// Serializing
		saveFeatureDiagram("serialized.diagram", featureDiagram);
		writeToFile(output,cnfClauses);
	}	

	private static def String toCNF(FeatureDiagramModel featureDiagram) {
		// Model transformation		
		var List<String> ret = new ArrayList<String>();
		
		for (Declaration declaration : featureDiagram.declarations) {
			// This is the feature diagram's root feature.
			if (declaration instanceof Feature) {							
				var List<Clause> clauses = getImplicationClauses(declaration, declaration);				
				for(Clause clause: clauses) {
					ret.add(clause.toCNF());
				}
			}
			// This are the constraints of the feature diagrams
			else if (declaration instanceof Constraint) {
				// Constraints can be expressed as logic implications.	
				ret.add( new Clause().implication( 
					_getWhenFromConstraint(declaration),
					_getThenFromConstraint(declaration)
				).toCNF() );
			}
		}
			
		return "p cnf " + Integer.toString(i - 1) + " " + Integer.toString(ret.size()) + "\r\n" + String.join("\r\n", ret)
	}
	
	private static def Literal _getWhenFromConstraint(Constraint constraint) {		
		return new Literal(constraint.when,!constraint.notWhen);
	}
	
	private static def Literal _getThenFromConstraint(Constraint constraint) {
		return new Literal(constraint.then,!constraint.notThen);
	}
	
	private static def List<Clause> getImplicationClauses(Feature feature, Feature root) {		
		// All relation clauses between child and parent features will be pushed here.
		var List<Clause> ret = new ArrayList<Clause>();
		
		// Root feature is mandatory.
		if( feature == root ) {
			ret.add( new Clause().isRoot(feature) );
		}
		
		// Child-Parent relation.
		else {
			ret.add( new Clause().implication(feature,root) );
		}
		
		// Parsing the subtree representing the current feature's children.
		for (FeatureDefinition definition : feature.children) {
			// If the current child is a group of features ( OR / XOR )...
			if(definition instanceof FeatureGroup) {
				// If group is an XOR group			
				if(definition.isExclusive){
					ret.addAll( new Clause().xorGroup(feature,definition.children) );
				} 
				// Else group is a regular OR group
				else {
					ret.add( new Clause().orGroup(feature,definition.children) );
				}
				
				for (Feature child : definition.children) {
					ret.addAll(getImplicationClauses(child,feature));
				}
			}
			// Else it a feature, then no need to parse.
			else if (definition instanceof ExtendedFeature) {
				// If feature is mandatory, then we push the corresponding Clause		
				if(!definition.isOptional) {
					ret.add( new Clause().mandatory(feature,definition.feature) );
				}
				
				ret.addAll(getImplicationClauses(definition.feature,feature));
			}
		}

		// Returning the resulting clauses.
		return ret;
	}
}


