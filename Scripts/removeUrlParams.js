/**
	{
        "id": "com.perlovs.Esse.ExternalFunctions.removeUrlParams",
		"name":"Remove Url Params",
		"description":"Takes in a URL and returns it without ?param=value...",
		"category":"Convert",
		"author":"Perlovs",
	}
**/

function main(input) {
	if (input !== '') {
		return input.split('?')[0];;
	}

	return input
}