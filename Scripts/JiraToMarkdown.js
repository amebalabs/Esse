/**
	{
        "id": "co.ameba.Esse.ExternalFunctions.JiraToMD",
        "name": "Jira to Markdown",
        "description": "Converts Jira markup to GitHub flavored markdown",
	    "category":"Convert",
	    "author":"Ameba Labs",
	}
**/

//adopted from https://github.com/FokkeZB/J2M

function main(input) {
  input = input.replace(/^bq\.(.*)$/gm, function (match, content) {
    return '> ' + content + "\n";
  });

  input = input.replace(/([*_])(.*)\1/g, function (match,wrapper,content) {
    var to = (wrapper === '*') ? '**' : '*';
    return to + content + to;
  });

  // multi-level numbered list
  input = input.replace(/^((?:#|-|\+|\*)+) (.*)$/gm, function (match, level, content) {
    var len = 2;
    var prefix = '1.';
    if (level.length > 1) {
      len = parseInt((level.length - 1) * 4) + 2;
    }

    // take the last character of the level to determine the replacement
    var prefix = level[level.length - 1];
    if (prefix == '#') prefix = '1.';

    return Array(len).join(" ") + prefix + ' ' + content;
  });

  // headers, must be after numbered lists
  input = input.replace(/^h([0-6])\.(.*)$/gm, function (match,level,content) {
    return Array(parseInt(level) + 1).join('#') + content;
  });

  input = input.replace(/\{\{([^}]+)\}\}/g, '`$1`');
  input = input.replace(/\?\?((?:.[^?]|[^?].)+)\?\?/g, '<cite>$1</cite>');
  input = input.replace(/\+([^+]*)\+/g, '<ins>$1</ins>');
  input = input.replace(/\^([^^]*)\^/g, '<sup>$1</sup>');
  input = input.replace(/~([^~]*)~/g, '<sub>$1</sub>');
  input = input.replace(/-([^-]*)-/g, '-$1-');

  input = input.replace(/\{code(:([a-z]+))?\}([^]*?)\{code\}/gm, '```$2$3```');
  input = input.replace(/\{quote\}([^]*)\{quote\}/gm, function(match, content) {
    lines = content.split(/\r?\n/gm);

    for (var i = 0; i < lines.length; i++) {
      lines[i] = '> ' + lines[i];
    }

    return lines.join("\n");
  });

  // Images with alt= among their parameters
  input = input.replace(/!([^|\n\s]+)\|([^\n!]*)alt=([^\n!\,]+?)(,([^\n!]*))?!/g, '![$3]($1)');
  // Images with just other parameters (ignore them)
  input = input.replace(/!([^|\n\s]+)\|([^\n!]*)!/g, '![]($1)');
  // Images without any parameters or alt
  input = input.replace(/!([^\n\s!]+)!/g, '![]($1)'); 

  input = input.replace(/\[([^|]+)\|(.+?)\]/g, '[$1]($2)');
  input = input.replace(/\[(.+?)\]([^\(]+)/g, '<$1>$2');

  input = input.replace(/{noformat}/g, '```');
  input = input.replace(/{color:([^}]+)}([^]*?){color}/gm, '<span style="color:$1">$2</span>');

  // Convert header rows of tables by splitting input on lines
  lines = input.split(/\r?\n/gm);
  lines_to_remove = []
  for (var i = 0; i < lines.length; i++) {
    line_content = lines[i];

    seperators = line_content.match(/\|\|/g);
    if (seperators != null) {
      lines[i] = lines[i].replace(/\|\|/g, "|");
      console.log(seperators)

      // Add a new line to mark the header in Markdown,
      // we require that at least 3 -'s are between each |
      header_line = "";
      for (var j = 0; j < seperators.length-1; j++) {
        header_line += "|---";
      }

      header_line += "|";

      lines.splice(i+1, 0, header_line);

    }
  }

  // Join the split lines back
  input = ""
  for (var i = 0; i < lines.length; i++) {
    input += lines[i] + "\n"
  }

  return input;
}