function TitleCapsEditor(n) {
    const m = 1;
    const d = 2;
    const c = 3;
    const g = 4;
    var j = g;
    var l = "";
    var e = ["about", "above", "across", "after", "against", "along", "among", "around", "at", "before", "behind", "below", "beneath", "beside", "between", "beyond", "but", "by", "despite", "down", "during", "except", "for", "from", "in", "inside", "into", "like", "near", "of", "off", "on", "onto", "out", "outside", "over", "past", "per", "since", "through", "throughout", "till", "to", "toward", "under", "underneath", "until", "up", "upon", "via", "with", "within", "without"];
    var a = ["a", "an", "the"];
    var q = ["and", "but", "or", "nor", "for", "yet", "so"];
    var f = ["if", "en", "as", "vs.", "v[.]?"];
    var i = "(" + (e.concat(a).concat(q).concat(f)).join("|") + ")";
    var k = "([!\"#$%&'()*+,./:;<=>?@[\\\\\\]^_`{|}~-]*)";
    return b(n);
    function b(w) {
        var v = [],
        u = /[:.;?!] |(?: |^)[""]/g,
        t = 0;
        if (j == m) {
            if (!l) {
                l = w
            }
            return l
        }
        while (true) {
            var s = u.exec(w);
            v.push(w.substring(t, s ? s.index : w.length).replace(/\b([A-Za-z][a-z.'"]*)\b/g, function(x) {
                return /[A-Za-z]\.[A-Za-z]/.test(x) ? x : o(x)
            }).replace(/\b([A-Za-z]*[^\u0000-\u007F]+[A-Za-z]*)\b/g, function(x) {
                return o(x)
            }).replace(RegExp("\\b" + i + "\\b", "ig"), function(x) {
                if (j == d) {
                    return x.length >= 4 ? o(x) : r(x)
                } else {
                    if (j == c) {
                        return x.length >= 5 ? o(x) : r(x)
                    } else {
                        return r(x)
                    }
                }
            }).replace(RegExp("^" + k + i + "\\b", "ig"), function(x, y, z) {
                return y + o(z)
            }).replace(RegExp("\\b" + i + k + "$", "ig"), o));
            t = u.lastIndex;
            if (s) {
                v.push(s[0])
            } else {
                break
            }
        }
        return v.join("").replace(/ V(s?)\. /ig, " v$1. ").replace(/(['"])S\b/ig, "$1s").replace(/\b(AT&T|Q&A)\b/ig, function(x) {
            return x.toUpperCase()
        })
    }
    function r(s) {
        return s.toLowerCase()
    }
    function o(s) {
        return s.substr(0, 1).toUpperCase() + s.substr(1).toLowerCase()
    }
}
;
