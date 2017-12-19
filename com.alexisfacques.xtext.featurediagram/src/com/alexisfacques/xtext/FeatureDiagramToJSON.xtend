package com.alexisfacques.xtext

import com.alexisfacques.xtext.featureDiagram.ExtendedFeature
import com.alexisfacques.xtext.featureDiagram.Feature
import com.alexisfacques.xtext.featureDiagram.FeatureDefinition
import com.alexisfacques.xtext.featureDiagram.FeatureGroup
import com.alexisfacques.xtext.featureDiagram.FeatureDiagramModel
import com.alexisfacques.xtext.featureDiagram.Declaration

import org.eclipse.emf.common.util.EList

import java.util.HashMap
import java.util.ArrayList
import java.util.List

import com.google.common.collect.Maps
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

class FeatureDiagramToJSON extends FeatureDiagramUtils {
	static def void transform(String input, String output) {
		// Loading the feature diagram model.
		var FeatureDiagramModel featureDiagram = loadFeatureDiagram(input)		

		// Populating features with an id.
		populateIds(featureDiagram);

		// Model transformation
		var String json = toJSON(featureDiagram);
		
		// Serializing
		saveFeatureDiagram("serialized.diagram", featureDiagram);
		writeToFile(output,json);
	}	

	
	static def String toJSON(FeatureDiagramModel featureDiagram) {
		// Model transformation		
		var List<HashMap<Object,Object>> ret = new ArrayList<HashMap<Object,Object>>();
		
		for (Declaration declaration : featureDiagram.declarations) {
			if (declaration instanceof Feature) {				
				ret.add(map(declaration));
			}
		}

		var Gson gson = new GsonBuilder().disableHtmlEscaping().create();		
		return gson.toJson(ret);
	}
	
	static def String toJSON(Feature feature) {	
		var Gson gson = new GsonBuilder().disableHtmlEscaping().create();
		return gson.toJson(map(feature));
	}

	private static def ArrayList<HashMap<Object,Object>> list(EList<FeatureDefinition> definitions){
  		val res = new ArrayList<HashMap<Object,Object>>();
  		
  		definitions.forEach[definition |
  			if(definition instanceof FeatureGroup) {
				definition.children.forEach[child | {
					res.add(map(child));
				}];
			}

			else if (definition instanceof ExtendedFeature) {
				res.add(map(definition.feature));
			}
    		];
    		
    		return res;
  	}
  	
	private static def HashMap<Object,Object> map(Feature feature) {
		val res = Maps::<Object,Object>newHashMap;
		
		res.put("name", feature.name);
		res.put("id",feature.id);
		res.put("children",list(feature.children));

		return res;
	}
}