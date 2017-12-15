package com.alexisfacques.xtext;

import java.util.ArrayList;
import java.util.List;

import com.alexisfacques.xtext.featureDiagram.Feature;

/*
 * Clauses consist of literals joined by OR.
 */
public class Clause {
	// Total number of expressed clauses.
	static int i = 1;
	
	// Clause id.
	private int id;
	
	// Literals composing the clause.
	private List<Literal> literals;
	
	Clause(){
		this.id = i++;
		this.literals = new ArrayList<Literal>();
	}
	
	Clause(List<Literal> l){
		this.id = i++;
		this.literals = l;
	}
	
	public Clause isRoot(Feature f) {
		this.literals.add( new Literal(f,true) );
		return this;
	}
	
	/*
	 * Creates an implication.
	 * Truth table | p => q <==> DNF : NOT p OR q
	 */
	public Clause implication(Feature f1, Feature f2) {
		this.literals.addAll(new ArrayList<Literal>() {{
			add( new Literal(f1, false) );
			add( new Literal(f2, true) );
		}});
		
		return this;
	}
	
	/*
	 * Creates an implication.
	 * Truth table | p => q OR s <==> DNF : NOT p OR q OR s
	 */
	public Clause implication(Feature f1, List<Feature> features) {
		this.literals.add(new Literal(f1, false));
		for( Feature feature : features) {
			this.literals.add(new Literal(feature, true));
		}
		
		return this;
	}
	
	/*
	 * implication() towards a list of feature spead alias.
	 */
	public Clause implication(Feature f1, Feature ...features) {
		return this.implication(f1, features);
	}
	
	/*
	 * implication() using literals.
	 */
	public Clause implication(Literal l1, Literal l2) {
		this.literals.add( new Literal(l1.getFeature(), !l1.getValue() ) );
		this.literals.add(l2);
		
		return this;
	}
	
	/*
	 * Alias of implication() towards a list a feature.
	 * A ORGROUP(B,C) | A => (B OR C)
	 */
	public Clause orGroup(Feature root, List<Feature> features) {
		return this.implication(root, features);
	}
	
	/*
	 * XOR Group.
	 * Truth table | A => (B XOR C) <==> NOT A OR B OR C AND NOT A OR NOT B OR NOT C
	 */
	public List<Clause> xorGroup(Feature root, List<Feature> features) {
		// XOR Groups are limited to size 2.
		if(features.size() != 2) throw new Error("XOR Groups must be of size 2");
		
		// XOR Groups consist in two clauses (CNF).
		List<Clause> ret = new ArrayList<Clause>();

		List<Literal> literals1 = new ArrayList<Literal>();
		// Implication relation.
		literals1.add( new Literal(root, false) );
		
		List<Literal> literals2 = new ArrayList<Literal>();
		// Implication relation.
		literals2.add( new Literal(root, false) );

		for(Feature feature: features) {
			// See truth table...
			// First clause consist in all features being 0.
			literals1.add( new Literal(feature,false) );
			// Second clause consist in all features being 1.
			literals2.add( new Literal(feature,true) );
		}
		
		
		ret.addAll(new ArrayList<Clause>() {{
			add( new Clause(literals1) );
			add( new Clause(literals2) );
		}});
		
		return ret;
	}
	
	/*
	 * Alias of implicaiton(). Creates a mandatory relation.
	 * root -- MANDATORY f | root => f
	 */
	public Clause mandatory(Feature root, Feature f) {
		return this.implication(root,f);
	}
		
	/*
	 * Returns stringified clause in natural language.
	 */
	public String toNatural() {
		List<String> ret = new ArrayList<String>();
		for(Literal literal : this.literals) {
			ret.add(literal.toNatural());
		}
		    
		return "(" + String.join(" OR ", ret) + ")";
	}
	
	/*
	 * Returns stringified clause in CNF format.
	 */
	public String toCNF() {
		List<String> ret = new ArrayList<String>();
		for(Literal literal: this.literals) {
			ret.add(literal.toCNF());
		}
		
		return String.join(" ",ret) + " 0";
	}
}
