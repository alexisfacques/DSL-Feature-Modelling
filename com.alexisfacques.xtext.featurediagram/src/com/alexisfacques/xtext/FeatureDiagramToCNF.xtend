package com.alexisfacques.xtext

import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource

import com.alexisfacques.xtext.featureDiagram.Constraint
import com.alexisfacques.xtext.featureDiagram.Declaration
import com.alexisfacques.xtext.featureDiagram.ExtendedFeature
import com.alexisfacques.xtext.featureDiagram.Feature
import com.alexisfacques.xtext.featureDiagram.FeatureDefinition
import com.alexisfacques.xtext.featureDiagram.FeatureDiagramModel
import com.alexisfacques.xtext.featureDiagram.FeatureGroup

import java.util.List
import java.util.ArrayList
import java.util.HashMap
import java.io.BufferedWriter
import java.io.FileWriter

class FeatureDiagramToCNF {	
	/*
	 * Loads the FeatureDiagramModel.
	 */
	def static loadFeatureDiagram(URI uri) {
		try{
			new FeatureDiagramStandaloneSetupGenerated().createInjectorAndDoEMFRegistration()
			var res = new ResourceSetImpl().getResource(uri, true);
			res.contents.get(0) as FeatureDiagramModel;	
		} catch(Exception e) {
			System.out.println("Input file not found");
		}
	}
	
	/*
	 * Saves the FeatureDiagramModel.
	 */
	def static saveFeatureDiagram(URI uri, FeatureDiagramModel featureDiagramModel) {		
		try{
			var Resource rs = new ResourceSetImpl().createResource(uri);
			rs.getContents.add(featureDiagramModel);
			rs.save(new HashMap());
		} catch(Exception e) {
			System.out.println("Error while saving to" + uri.toString());
		}
		
	}

	def static void writeToFile(String fileName, String content) {
	   	try{
		    var BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
		    writer.write(content);
		    writer.close();	
		} catch(Exception e) {
			System.out.println("Error while saving to" + fileName);
		}
	} 

	/*
	 * ModelTransformation
	 */
	def static modelTransformation(String input, String output) {
		// Loading the feature diagram model.
		var FeatureDiagramModel featureDiagram = loadFeatureDiagram(URI.createURI(input))		
			
		// Stingified CNF clauses.
		var String cnfClauses = toCNF(featureDiagram);
				
		// Printing JSON structure.
		var json = FeatureDiagramToJSON.toJSON(featureDiagram);
		System.out.println(json);
		
		// Serializing
		saveFeatureDiagram(URI.createURI("serialized.diagram"), featureDiagram);
		writeToFile(output,cnfClauses);
		
		//System.out.println(cnfClauses);
	}	

	private static def String toCNF(FeatureDiagramModel featureDiagram) {
		// Model transformation		
		var List<String> ret = new ArrayList<String>();
		
		for (Declaration declaration : featureDiagram.declarations) {
			// This is the feature diagram's root feature.
			if (declaration instanceof Feature) {
				// Populating feature ids.
				populateIds(declaration);
								
				// Relational clauses are the expression of Child-Parent relations in boolean algebra.
				var List<Clause> relational = getChildParentClauses(declaration, declaration);				
				for(Clause clause: relational) {
					ret.add(clause.toCNF());
				}
				
				// Propotional clauses are the expression of Feature relations (OR, MANDATORY, XOR...) in boolean algebra.
				var List<Clause> propositional = getPropositionalClauses(declaration, declaration);
				for(Clause clause: propositional) {
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
	
		
	/*
	 * Populate features with custom mapped ID, for CNF model transformation. 
	 */
	static var i = 1;
	private static def void populateIds(Feature feature) {
		feature.id = i++;		
		if(feature.children.length == 0) return;
		
		feature.children.forEach[definition | {
			// If the current child is a group of features ( OR / XOR )...
			if(definition instanceof FeatureGroup) {
				definition.children.forEach[child | {
					populateIds(child);
				}];
			}
			// Else it a feature, then no need to parse.
			else if (definition instanceof ExtendedFeature) {
				populateIds(definition.feature);
			}
		}];
	}
	
	
	
	private static def Literal _getWhenFromConstraint(Constraint constraint) {		
		return new Literal(constraint.when,!constraint.notWhen);
	}
	
	private static def Literal _getThenFromConstraint(Constraint constraint) {
		return new Literal(constraint.then,!constraint.notThen);
	}
	
	private static def List<Clause> getChildParentClauses(Feature feature, Feature root) {		
		// All relation clauses between child and parent features will be pushed here.
		var List<Clause> ret = new ArrayList<Clause>();
		
		if( feature == root ) ret.add( new Clause().isRoot(feature) );	
				
		// Current feature is a leaf.
		if(feature.children.length == 0) {
			if( feature == root ) return ret;
			ret.add( new Clause().implication(feature,root) );
		}
		
		// Current feature has children.
		else {
			// Parsing the subtree representing the current feature's children.
			for (FeatureDefinition definition : feature.children) {
				// If the current child is a group of features ( OR / XOR )...
				if(definition instanceof FeatureGroup) {
					// ... we need to parse each of them recursively.
					for (Feature child : definition.children) {
						ret.addAll(getChildParentClauses(child,feature));
					}
				}
				// Else it a feature, then no need to parse.
				else if (definition instanceof ExtendedFeature) {
					ret.addAll(getChildParentClauses(definition.feature,feature));
				}
			}
		}

		// Returning the resulting clauses.
		return ret;
	}
	
	private static def List<Clause> getPropositionalClauses(Feature feature, Feature root) {
		// All propotional clauses will be pushed here.
		var List<Clause> ret = new ArrayList<Clause>();
			
		// Current feature is a leaf, there is no more propotional clauses to express.
		if(feature.children.length == 0) {
			return ret;
		}
		
		// Current feature has children. Parsing the subtree representing the current feature's children.
		for(FeatureDefinition definition : feature.children) {
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
				
				// Recursively parsing the children of the features
				for(Feature child: definition.children){
					ret.addAll( getPropositionalClauses(child,feature) );
				}
				
			}
			// Else it a feature, then no need to parse.
			else if (definition instanceof ExtendedFeature) {
				// If feature is mandatory, then we push the corresponding Clause		
				if(!definition.isOptional) {
					ret.add( new Clause().mandatory(feature,definition.feature) );
				}
				
				// Recursively parsing the children of the feature
				ret.addAll( getPropositionalClauses(definition.feature,feature) );
			}
		}
		
		return ret;
	}
}


