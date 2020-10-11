/**
	{
        "id": "co.ameba.Esse.ExternalFunctions.AppendCommaAtLineEnd",
		"name":"Append Comma at Line End",
		"description":"Appends comma to each line",
		"category":"Convert",
		"author":"Ameba Labs",
	}
**/

function main(input) {
	return input.replace(/\n/g, ',\n');
}