function gotoHome () {
	if (location.pathname[location.pathname.length-1] == '/') {
		location.pathname = location.pathname + '../';
	} else {
		location.pathname = location.pathname + '/../';
	}
}
$(document).ready(function () {
	var homeComponent = $('<div id="home-button" onclick="gotoHome()"><i class="fa fa-home fa-lg"></i></div>');
	$('#content').prepend(homeComponent);
});
