/**
	{
        "id": "co.ameba.Esse.ExternalFunctions.MDToJira",
        "name": "Markdown to Jira",
        "description": "Converts GitHub flavored markdown to Jira Markup",
	    "category":"Convert",
	    "author":"Ameba Labs",
	}
**/

//adopted from https://github.com/FokkeZB/J2M

function main(input) {
  // remove sections that shouldn't be recursively processed
  var START = 'J2MBLOCKPLACEHOLDER';
  var replacementsList = [];
  var counter = 0;
  
  input = input.replace(/`{3,}(\w+)?((?:\n|.)+?)`{3,}/g, function(match, synt, content) {
    var code = '{code';
  
    if (synt) {
      code += ':' + synt;
    }
  
    code += '}' + content + '{code}';
    var key = START + counter++ + '%%';
    replacementsList.push({key: key, value: code});
    return key;
  });
  
  input = input.replace(/`([^`]+)`/g, function(match, content) {
    var code = '{{'+ content + '}}';
    var key = START + counter++ + '%%';
    replacementsList.push({key: key, value: code});
    return key;
  });

  input = input.replace(/`([^`]+)`/g, '{{$1}}');

  input = input.replace(/^(.*?)\n([=-])+$/gm, function (match,content,level) {
    return 'h' + (level[0] === '=' ? 1 : 2) + '. ' + content;
  });

  input = input.replace(/^([#]+)(.*?)$/gm, function (match,level,content) {
    return 'h' + level.length + '.' + content;
  });

  input = input.replace(/([*_]+)(.*?)\1/g, function (match,wrapper,content) {
    var to = (wrapper.length === 1) ? '_' : '*';
    return to + content + to;
  });

  // multi-level bulleted list
  input = input.replace(/^(\s*)- (.*)$/gm, function (match,level,content) {
    var len = 2;
    if(level.length > 0) {
      len = parseInt(level.length/4.0) + 2;
    }
    return Array(len).join("-") + ' ' + content;
  });

  // multi-level numbered list
  input = input.replace(/^(\s+)1. (.*)$/gm, function (match, level, content) {
    var len = 2;
    if (level.length > 1) {
      len = parseInt(level.length / 4) + 2;
    }
    return Array(len).join("#") + ' ' + content;
  });

  var map = {
    cite: '??',
    del: '-',
    ins: '+',
    sup: '^',
    sub: '~'
  };

  input = input.replace(new RegExp('<(' + Object.keys(map).join('|') + ')>(.*?)<\/\\1>', 'g'), function (match,from,content) {
    //console.log(from);
    var to = map[from];
    return to + content + to;
  });

  input = input.replace(/<span style="color:(#[^"]+)">([^]*?)<\/span>/gm, '{color:$1}$2{color}');

  input = input.replace(/~~(.*?)~~/g, '-$1-');

  // Images without alt
  input = input.replace(/!\[\]\(([^)\n\s]+)\)/g, '!$1!');
  // Images with alt
  input = input.replace(/!\[([^\]\n]+)\]\(([^)\n\s]+)\)/g, '!$2|alt=$1!');
  
  input = input.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '[$1|$2]');
  input = input.replace(/<([^>]+)>/g, '[$1]');

  // restore extracted sections
  for(var i =0; i < replacementsList.length; i++){
    var sub = replacementsList[i];
    input = input.replace(sub["key"], sub["value"]);
  }

  // Convert header rows of tables by splitting input on lines
  lines = input.split(/\r?\n/gm);
  lines_to_remove = []
  for (var i = 0; i < lines.length; i++) {
    line_content = lines[i];

    if (line_content.match(/\|---/g) != null) {
      lines[i-1] = lines[i-1].replace(/\|/g, "||")
      lines.splice(i, 1)
    }
  }

  // Join the split lines back
  input = ""
  for (var i = 0; i < lines.length; i++) {
    input += lines[i] + "\n"
  }
  return input;
}