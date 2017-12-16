package com.alexisfacques.xtext

import com.alexisfacques.xtext.featureDiagram.FeatureDiagramModel
import com.alexisfacques.xtext.featureDiagram.Declaration
import com.alexisfacques.xtext.featureDiagram.Feature
import com.alexisfacques.xtext.featureDiagram.Constraint
import com.alexisfacques.xtext.featureDiagram.FeatureDefinition
import com.alexisfacques.xtext.featureDiagram.FeatureGroup
import com.alexisfacques.xtext.featureDiagram.ExtendedFeature

import java.util.List
import java.util.ArrayList

import org.eclipse.emf.common.util.URI

class FeatureDiagramToMZN extends FeatureDiagramUtils {
	static def void transform(String input, String output) {
		// Loading the feature diagram model.
		var FeatureDiagramModel featureDiagram = loadFeatureDiagram(URI.createURI(input));	

		var String mzn = toMZN(featureDiagram);
		writeToFile(output,mzn);
	}	
	
	static def String toMZN(FeatureDiagramModel featureDiagram) {
		// Model transformation		
		var List<String> ret = new ArrayList<String>();
		
		for (Declaration declaration : featureDiagram.declarations) {
			if (declaration instanceof Feature) {
				ret.addAll(parseAllVars(declaration));
				ret.addAll(getImplicationClauses(declaration,declaration))
			}
			else if (declaration instanceof Constraint) {
				var String when = declaration.when.name;
				var String then = declaration.then.name;
				
				if(declaration.notWhen) {
					when = 'not ' + when;
				}
				if(declaration.notThen) {
					when = 'not ' + then;
				}
				
				ret.add(_getImplicationClause(when,then))
			}
		}
		
		return String.join("\r\n", ret) + "\r\nsolve satisfy;";
	}
	
	private static def List<String> parseAllVars(Feature feature) {
		var List<String> ret = new ArrayList<String>();
		
		ret.add(_getVariableDeclaration(feature.name));
		
		for (FeatureDefinition definition : feature.children) {
			if(definition instanceof FeatureGroup) {
				for (Feature child : definition.children) {
					ret.addAll(parseAllVars(child));
				}
			}
			else if (definition instanceof ExtendedFeature) {
				ret.addAll(parseAllVars(definition.feature));
			}
		}	
			
		return ret;
	}
	
	private static def List<String> getImplicationClauses(Feature feature, Feature root) {
		var List<String> ret = new ArrayList<String>();
		
		// Root declaration.
		if( feature == root ) {
			ret.add(_getConstraint(feature.name));	
		}	
		// Child-Parent relation.
		else {
			ret.add(_getImplicationClause(feature.name,root.name));	
		}
		
		// Handling children.
		for (FeatureDefinition definition : feature.children) {
			if (definition instanceof ExtendedFeature) {
				// If feature is mandatory, adding an implication
				if(!definition.isOptional) {
					ret.add(_getImplicationClause(feature.name,definition.feature.name))
				}
				// Recursive call, to build Child-Parent relations as well as propositionnal relations.
				ret.addAll(getImplicationClauses(definition.feature,feature));
			}
			else if(definition instanceof FeatureGroup) {
				var List<String> children = new ArrayList<String>();
				for(Feature child : definition.children) {
					ret.addAll(getImplicationClauses(child,feature));
					children.add(child.name);
				}
				if(definition.isExclusive) {
					ret.add(_getImplicationClause(feature.name,String.join(" xor ", children)));
				}
				else {
					ret.add(_getImplicationClause(feature.name,String.join(" \b/ ", children)))
				}
			}
		}
		
		return ret;
	}
	
	private static def String _getConstraint(String f1) {
		return "constraint " + f1 + ";";
	}
	
	private static def String _getVariableDeclaration(String f1) {
		return "var bool: " + f1 + ";";
	}
	
	private static def String _getImplicationClause(String f1, String f2) {
		return "constraint " + f1 + " -> " + f2 + ";";
	}
}