$(document).ready(function(){
	now.newData = function(stuff){
		newp = document.createElement('p')
		newp.textContent = stuff
		$("#messages").append(newp);
	}
});
