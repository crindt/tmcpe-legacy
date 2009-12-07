dojo.provide("tmcpe.ItemVectorLayerReadStore");

dojo.require("dojo.data.util.filter");
dojo.require("dojo.data.util.simpleFetch");
dojo.require("dojo.date.stamp");

dojo.declare("tmcpe.ItemVectorLayerReadStore", null,{
	//	summary:
	//		The ItemFileReadStore implements the dojo.data.api.Read API and reads
	//		data from JSON files that have contents in this format --
	//		{ items: [
	//			{ name:'Kermit', color:'green', age:12, friends:['Gonzo', {_reference:{name:'Fozzie Bear'}}]},
	//			{ name:'Fozzie Bear', wears:['hat', 'tie']},
	//			{ name:'Miss Piggy', pets:'Foo-Foo'}
	//		]}
	//		Note that it can also contain an 'identifer' property that specified which attribute on the items 
	//		in the array of items that acts as the unique identifier for that item.
	//
	constructor: function(/* Object */ keywordParameters){
		//	summary: constructor
		//	keywordParameters: {url: String}
		//	keywordParameters: {data: jsonObject}
		//	keywordParameters: {typeMap: object)
		//		The structure of the typeMap object is as follows:
		//		{
		//			type0: function || object,
		//			type1: function || object,
		//			...
		//			typeN: function || object
		//		}
		//		Where if it is a function, it is assumed to be an object constructor that takes the 
		//		value of _value as the initialization parameters.  If it is an object, then it is assumed
		//		to be an object of general form:
		//		{
		//			type: function, //constructor.
		//			deserialize:	function(value) //The function that parses the value and constructs the object defined by type appropriately.
		//		}
	    this._features = { 'dojo.data.api.Read' : true };
	    this._vectorLayer  = keywordParameters.vectorLayer;
	},
	
	_assertIsItem: function(/* item */ item){
		//	summary:
		//		This function tests whether the item passed in is indeed an item in the store.
		//	item: 
		//		The item to test for being contained by the store.
		if(!this.isItem(item)){ 
			throw new Error("tmcpe.ItemVectorLayerReadStore: Invalid item argument.");
		}
	},

	_assertIsAttribute: function(/* attribute-name-string */ attribute){
		//	summary:
		//		This function tests whether the item passed in is indeed a valid 'attribute' like type for the store.
		//	attribute: 
		//		The attribute to test for being contained by the store.
		if(typeof attribute !== "string"){ 
			throw new Error("tmcpe.ItemVectorLayerReadStore: Invalid attribute argument.");
		}
	},

	getValue: function(	/* item */ item, 
						/* attribute-name-string */ attribute, 
						/* value? */ defaultValue){
		//	summary: 
		//		See dojo.data.api.Read.getValue()
		var values = this.getValues(item, attribute);
		return (values.length > 0)?values[0]:defaultValue; // mixed
	},

	getValues: function(/* item */ item, 
						/* attribute-name-string */ attribute){
		//	summary: 
		//		See dojo.data.api.Read.getValues()

		this._assertIsItem(item);
		this._assertIsAttribute(attribute);
		return [ item.attributes[attribute] ] || []; // Array
	},

	getAttributes: function(/* item */ item){
		//	summary: 
		//		See dojo.data.api.Read.getAttributes()
		this._assertIsItem(item);
		var attributes = [];
		for(var key in item.attributes){
			// Save off only the real item attributes, not the special id marks for O(1) isItem.
			if((key !== this._storeRefPropName) && (key !== this._itemNumPropName) && (key !== this._rootItemPropName) && (key !== this._reverseRefMap)){
				attributes.push(key);
			}
		}
		return attributes; // Array
	},

	hasAttribute: function(	/* item */ item,
							/* attribute-name-string */ attribute){
		//	summary: 
		//		See dojo.data.api.Read.hasAttribute()
		this._assertIsItem(item);
		this._assertIsAttribute(attribute);
		return (attribute in item.attributes);
	},

	containsValue: function(/* item */ item, 
							/* attribute-name-string */ attribute, 
							/* anything */ value){
		//	summary: 
		//		See dojo.data.api.Read.containsValue()
		var regexp = undefined;
		if(typeof value === "string"){
			regexp = dojo.data.util.filter.patternToRegExp(value, false);
		}
		return this._containsValue(item, attribute, value, regexp); //boolean.
	},

	_containsValue: function(	/* item */ item, 
								/* attribute-name-string */ attribute, 
								/* anything */ value,
								/* RegExp?*/ regexp){
		//	summary: 
		//		Internal function for looking at the values contained by the item.
		//	description: 
		//		Internal function for looking at the values contained by the item.  This 
		//		function allows for denoting if the comparison should be case sensitive for
		//		strings or not (for handling filtering cases where string case should not matter)
		//	
		//	item:
		//		The data item to examine for attribute values.
		//	attribute:
		//		The attribute to inspect.
		//	value:	
		//		The value to match.
		//	regexp:
		//		Optional regular expression generated off value if value was of string type to handle wildcarding.
		//		If present and attribute values are string, then it can be used for comparison instead of 'value'
		return dojo.some(this.getValues(item.attributes, attribute), function(possibleValue){
			if(possibleValue !== null && !dojo.isObject(possibleValue) && regexp){
				if(possibleValue.toString().match(regexp)){
					return true; // Boolean
				}
			}else if(value === possibleValue){
				return true; // Boolean
			}
		});
	},

	isItem: function(/* anything */ something){
		//	summary: 
		//		See dojo.data.api.Read.isItem()
/*
		if(something && something[this._storeRefPropName] === this){
			if(this._arrayOfAllItems[something[this._itemNumPropName]] === something){
				return true;
			}
		}
*/
	    if ( something && something instanceof OpenLayers.Feature.Vector /* && something.layer === this._vectorLayer */ )
	    {
		// it's an item if it's a Feature.Vector whose layer is this readstore's layer
		return true;
	    }
	    return false; // Boolean
	},

	isItemLoaded: function(/* anything */ something){
		//	summary: 
		//		See dojo.data.api.Read.isItemLoaded()
		return this.isItem(something); //boolean
	},

	loadItem: function(/* object */ keywordArgs){
		//	summary: 
		//		See dojo.data.api.Read.loadItem()
		this._assertIsItem(keywordArgs.item);
	},

	getFeatures: function(){
		//	summary: 
		//		See dojo.data.api.Read.getFeatures()
		return this._features; //Object
	},

	getLabel: function(/* item */ item){
		//	summary: 
		//		See dojo.data.api.Read.getLabel()
		if(this._labelAttr && this.isItem(item)){
			return this.getValue(item,this._labelAttr); //String
		}
		return undefined; //undefined
	},

	getLabelAttributes: function(/* item */ item){
		//	summary: 
		//		See dojo.data.api.Read.getLabelAttributes()
		if(this._labelAttr){
			return [this._labelAttr]; //array
		}
		return null; //null
	},

	close: function(/*dojo.data.api.Request || keywordArgs || null */ request){
		 //	summary: 
		 //		See dojo.data.api.Read.close()
	},

	_fetchItems: function(	/* Object */ keywordArgs, 
	    /* Function */ findCallback, 
	    /* Function */ errorCallback){
	    //	summary: 
	    //		See dojo.data.util.simpleFetch.fetch()
	    var self = this;
	    var filter = function(requestArgs, arrayOfItems){
		var items = [];
		var i, key;
		if(requestArgs.query){
		    var value;
		    var ignoreCase = requestArgs.queryOptions ? requestArgs.queryOptions.ignoreCase : false; 
		    
		    //See if there are any string values that can be regexp parsed first to avoid multiple regexp gens on the
		    //same value for each item examined.  Much more efficient.
		    var regexpList = {};
		    for(key in requestArgs.query){
			value = requestArgs.query[key];
			if(typeof value === "string"){
			    regexpList[key] = dojo.data.util.filter.patternToRegExp(value, ignoreCase);
			}else if(value instanceof RegExp){
			    regexpList[key] = value;
			}
		    }
		    for(i = 0; i < arrayOfItems.length; ++i){
			var match = true;
			var candidateItem = arrayOfItems[i];
			if(candidateItem === null){
			    match = false;
			}else{
			    for(key in requestArgs.query){
				value = requestArgs.query[key];
				if(!self._containsValue(candidateItem, key, value, regexpList[key])){
				    match = false;
				}
			    }
			}
			if(match){
			    items.push(candidateItem);
			}
		    }
		    findCallback(items, requestArgs);
		}else{
		    // We want a copy to pass back in case the parent wishes to sort the array. 
		    // We shouldn't allow resort of the internal list, so that multiple callers 
		    // can get lists and sort without affecting each other.  We also need to
		    // filter out any null values that have been left as a result of deleteItem()
		    // calls in ItemFileWriteStore.
		    for(i = 0; i < arrayOfItems.length; ++i){
			var item = arrayOfItems[i];
			if(item !== null){
			    items.push(item);
			}
		    }
		    findCallback(items, requestArgs);
		}
	    };
	    // FIXME: check for updated layer
	    filter( keywordArgs, this._vectorLayer.features );
	}
});
//Mix in the simple fetch implementation to this class.
dojo.extend(tmcpe.ItemVectorLayerReadStore,dojo.data.util.simpleFetch);

