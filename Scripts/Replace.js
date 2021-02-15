/**
	{
        "id": "co.ameba.Esse.ExternalFunctions.Replace",
		"name":"Replace",
		"description":"Find and Replace. This is a custom script, please edit to your liking",
		"category":"Other",
		"author":"Ameba Labs",
	}
**/

const search = '&';
const replaceWith = ' and ';


function main(input) {
	return input.split(search).join(replaceWith);
}