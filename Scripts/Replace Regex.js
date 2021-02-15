/**
	{
        "id": "co.ameba.Esse.ExternalFunctions.ReplaceRegex",
		"name":"Replace with Regex",
		"description":"Find and Replace. This is a custom script, please edit to your liking",
		"category":"Other",
		"author":"Ameba Labs",
	}
**/

const searchRegExp = /\s/g; // find all spaces, 'g' is important to enforce 'replace all'
const replaceWith = '-';

function main(input) {
	return input.split(searchRegExp).join(replaceWith);
}