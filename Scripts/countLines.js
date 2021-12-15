/**
	{
        "id": "com.perlovs.Esse.ExternalFunctions.countLines",
		"name":"Count Lines",
		"description":"Replaces Test with the Lines Count",
		"category":"Other",
		"author":"Perlovs",
	}
**/

function main(input) {
	if (input !== '') {
		return input.split(/\r\n|\r|\n/).length;
	}

	return 0
}