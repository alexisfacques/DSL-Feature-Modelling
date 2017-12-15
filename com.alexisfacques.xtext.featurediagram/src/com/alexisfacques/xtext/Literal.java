package com.alexisfacques.xtext;

import com.alexisfacques.xtext.featureDiagram.Feature;

public class Literal {
	// The corresponding feature.
	private Feature feature;
	
	// Its boolean value in the clause expression.
	private boolean value;
	
	Literal(Feature f, boolean v){
		this.feature = f;
		this.value = v;
	}
	
	/*
	 * Returns stringified literal in natural language.
	 */
	public String toNatural() {
		return (this.value ? "":"NOT ") + this.feature.getName();
	}
	
	/*
	 * Returns stringified literal in CNF format.
	 */
	public String toCNF() {
		return (this.value ? "":"-") + this.feature.getId();
	}
	
	public Feature getFeature() {
		return this.feature;
	}
	
	public boolean getValue() {
		return this.value;
	}
}
