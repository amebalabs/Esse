/**
	{
        "id": "co.ameba.Esse.ExternalFunctions.SpongeBobCase",
		"name":"SpongeBob Case",
		"description":"cOnVeRt yOuR tExT tO sPoNgEbOb cAsE!",
		"category":"Case",
		"author":"Ameba Labs",
	}
**/


function main(input) {
	result = '';
	for (let i = 0; i < input.length; i += 1) {
            // skip adding lowercase/uppercase to space characters
            if (input[i] === ' ') {
                result += ' ';
            }
            // apply lowercase to odd indexes
            if ((i + 1) % 2 === 0) {
                result += input[i].toUpperCase();
            }
            // apply uppercase to even indexes
            if (i % 2 === 0) {
                result += input[i].toLowerCase();
            }
        }
	return result;
}