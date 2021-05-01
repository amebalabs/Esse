/**
	{
        "id": "co.perlovs.Esse.ExternalFunctions.addQuotesToCommaSeparatedList",
		"name":"Add Quotes to a Comma Separated List",
		"description":"Takes in a comma-separated list and adds single quotes around each item",
		"category":"Convert",
		"author":"Perlovs",
	}
**/

function main(input) {
	if (input !== '') {
		return "'" + input.split(',').map(s => s.trim()).join("','") + "'";
	}

	return input
}