/**
	{
        "id": "co.perlovs.Esse.ExternalFunctions.addQuotesToCommaSeparatedList",
		"name":"Add quotes to a comma separated list",
		"description":"Takes in a comma-separated list and adds single quotes around each item",
		"category":"Convert",
		"author":"Perlovs",
	}
**/

function main(input) {
	return "'" + input.split(',').map(s => s.trim()).join("','") + "'";
}