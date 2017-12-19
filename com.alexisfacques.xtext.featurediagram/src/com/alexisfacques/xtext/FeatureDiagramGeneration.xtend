package com.alexisfacques.xtext

import com.alexisfacques.xtext.featureDiagram.impl.FeatureDiagramFactoryImpl
import com.alexisfacques.xtext.featureDiagram.FeatureDiagramFactory
import com.alexisfacques.xtext.featureDiagram.FeatureDiagramModel
import com.alexisfacques.xtext.featureDiagram.FeatureDefinition
import com.alexisfacques.xtext.featureDiagram.FeatureGroup
import com.alexisfacques.xtext.featureDiagram.ExtendedFeature
import com.alexisfacques.xtext.featureDiagram.Feature

import java.util.List
import java.util.ArrayList
import com.alexisfacques.xtext.featureDiagram.Constraint
import java.util.Random

class FeatureDiagramGeneration extends FeatureDiagramUtils {
	static var FeatureDiagramFactory factory = FeatureDiagramFactoryImpl.init();
	
	static def void generate( int max, int maxConstraints, String fileName ) {
		new FeatureDiagramStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
		
		var FeatureDiagramModel featureDiagram = factory.createFeatureDiagramModel();
		
		var Feature root = factory.createFeature();
		root.setName("root");
		root.getChildren().addAll(generateChildren(max));
		
		featureDiagram.getDeclarations().add(root);
		
		for (var int i = 0 ;  i < maxConstraints ; i++){
			featureDiagram.getDeclarations().add(generateRandomConstraint());
		}
	
		saveFeatureDiagram(fileName,featureDiagram);
	}
	
	private static var int i = 0;
	private static def List<FeatureDefinition> generateChildren(int max) {
		i++;
		
		var List<FeatureDefinition> ret = new ArrayList<FeatureDefinition>();
		
		ret.add(getFeatureGroup(false,i));
		ret.add(getFeatureGroup(true,i));
		ret.add(getExtendedFeature(true,i));
		
		if(i < max) {
			ret.add(getExtendedFeature(false,i,generateChildren(max)))
		}
		else {
			ret.add(getExtendedFeature(false,i));
		}
		
		return ret;
	}
	
	private static def FeatureGroup getFeatureGroup(boolean isExclusive, int id) {
		var FeatureGroup ret = factory.createFeatureGroup();
		ret.setIsExclusive(isExclusive);
		
		var String featureName = "OR";
		if(isExclusive) {
			featureName = "XOR";
		}
						
		var Feature f1 = factory.createFeature();
		f1.setName(featureName + id + "1");
		ret.getChildren().add(f1);
		createdFeatures.add(f1);
		
		var Feature f2 = factory.createFeature();
		f2.setName(featureName + id + "2");
		ret.getChildren().add(f2);
		createdFeatures.add(f2);

		return ret;
	}
	
	private static def ExtendedFeature getExtendedFeature(boolean isOptional, int id) {
		return getExtendedFeature(isOptional,id,new ArrayList<FeatureDefinition>());
	}
	
	private static def ExtendedFeature getExtendedFeature(boolean isOptional, int id, List<FeatureDefinition> children) {
		var ExtendedFeature ret = factory.createExtendedFeature();
		ret.setIsOptional(isOptional);
				
		var String featureName = "Mandatory";
		if(isOptional) {
			featureName = "Optional";
		}
		
		var Feature f = factory.createFeature();
		f.setName(featureName + id);
		f.getChildren().addAll(children);
		
		ret.setFeature(f);
		createdFeatures.add(f);
		
		return ret;
	}
	
	private static var List<Feature> createdFeatures = new ArrayList<Feature>();
	private static def Constraint generateRandomConstraint() {		
		var Constraint ret = factory.createConstraint();
		var int idx1 = new Random().nextInt(createdFeatures.size() - 1);
		var int idx2 = new Random().nextInt(createdFeatures.size() - 1);

		ret.setWhen(createdFeatures.get(idx1));
		ret.setThen(createdFeatures.get(idx2));
		
		return ret;
	}
}