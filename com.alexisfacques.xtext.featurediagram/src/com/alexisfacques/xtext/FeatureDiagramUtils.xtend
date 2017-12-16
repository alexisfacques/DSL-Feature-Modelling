package com.alexisfacques.xtext

import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource

import com.alexisfacques.xtext.featureDiagram.FeatureDiagramModel

import java.util.HashMap
import java.io.BufferedWriter
import java.io.FileWriter

import com.alexisfacques.xtext.featureDiagram.Feature
import com.alexisfacques.xtext.featureDiagram.FeatureGroup
import com.alexisfacques.xtext.featureDiagram.ExtendedFeature

class FeatureDiagramUtils {
	/*
	 * Populate features with custom mapped ID, for CNF model transformation. 
	 */
	protected static var i = 1;
	static def void populateIds(FeatureDiagramModel featureDiagram) {
		i = 1;
		featureDiagram.declarations.forEach[declaration | {
			if(declaration instanceof Feature) {
				populateIds(declaration);
			}	
		}]
	}
	
	static def void populateIds(Feature feature) {
		feature.id = i++;		
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
	
	/*
	 * Loads the FeatureDiagramModel.
	 */
	static def loadFeatureDiagram(URI uri) {
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
	static def saveFeatureDiagram(URI uri, FeatureDiagramModel featureDiagramModel) {		
		try{
			var Resource rs = new ResourceSetImpl().createResource(uri);
			rs.getContents.add(featureDiagramModel);
			rs.save(new HashMap());
		} catch(Exception e) {
			System.out.println("Error while saving to" + uri.toString());
		}
		
	}

	/*
	 * Writes a string to a file. 
	 */
	static def writeToFile(String fileName, String content) {
	   	try{
		    var BufferedWriter writer = new BufferedWriter(new FileWriter(fileName));
		    writer.write(content);
		    writer.close();	
		} catch(Exception e) {
			System.out.println("Error while saving to" + fileName);
		}
	} 
}