
var json_data = [];

function handleFileSelect(evt) {
    var files = evt.target.files; // FileList object

    // files is a FileList of File objects. List some properties.
	arr = []
    for (var i = 0, f; f = files[i]; i++) {
      console.log(f.name)
	  var obj = {"name":f.name, "size":f.size, "path":f.path};
	  arr.push(obj);
    }
	json_data = JSON.stringify(arr);
	console.log(json_data);
	$("#hidden_data").val(json_data);
}

$(document).ready(function() {
	document.getElementById('files').addEventListener('change', handleFileSelect, false);
});
