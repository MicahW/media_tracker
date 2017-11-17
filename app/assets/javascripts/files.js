
function handleFileSelect(evt) {
    var files = evt.target.files; // FileList object

    // files is a FileList of File objects. List some properties.

    for (var i = 0, f; f = files[i]; i++) {
      console.log(f.name)
    }
}

$(document).ready(function() {
	document.getElementById('files').addEventListener('change', handleFileSelect, false);
});
