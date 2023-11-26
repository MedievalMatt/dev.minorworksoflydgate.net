console.log(sessionStorage['deco_cookie']);
var decoValue = sessionStorage.getItem("deco_cookie");

console.log(decoValue);

if (sessionStorage['deco_cookie']) {

	console.log("deco_cookie exists");
} else {
	console.log("deco_cookie does not exist");
}

if (decoValue == "not decorated") {
	var deco_disable = document.getElementById("decoToggle");
	var deco_background = document.getElementsByClassName("decoFile");
	deco_disable.removeAttribute("disabled");
} else {}

/*Beginning of Function Block */
/*Manuscript Structure*/
function structure_model(f, side, g, total_g, q) {
	console.log(f); /*The folio (leaf) in question*/
	console.log(side); /*is it the recto or verso side? Recto=1, Verso=2 */
	console.log(g); /*which gathering is it? */
	console.log(total_g);/*How many gatherings total are in the item*/
	console.log(q); /* how many leaves are in a quire? */

	var i;
	var old_f2;
	// var m1;
	// var m2;
	// var c1;
	// var c2;
	// var d1;
	// var d2;
	// var e1;
	// var e2;
	// var f1;
	// var f2;

	function isOdd(num) {
		if (num % 2 == 0) {
			color = "#CCCCCC";
		} else {
			color = "#EEFFFF";
		}
		
		document.write('<!-- Gathering ' + num + ' is ' + color + ' -->');

		return color;
	}

	document.write('<svg width="100%" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 110">');

	console.log("color is " + isOdd(i));
	
	for (i = 1; i <= total_g; i++) {
		var folio;
		if (total_g % 2 == 0) {
			console.log (total_g + " is even");
		}
		else {
			console.log (total_g + " is odd");
		}

		//console.log('<div>');
		if (!m1) {
			var m1 = 80;
			var m2 = 100;
			var c1 = 100;
			var c2 = 95;
			var d1 = 120;
			var d2 = 100;
			var e1 = 150;
			var e2 = 100;
			var f1 = 180;
			var f2 = 100;
			//console.log('m1 does not exist, so the other elements probably don\'t either.  Fixing that for you');

			//       document.write(': numbers are ' + m1 + ', ' + m2 );

		}


		if (i < g) {
			document.write('<!-- Gathering ' + i + ' is before the folio. -->');

			c1 = 60;
			d1 = 40;
			e1 = 10;
			f1 = -20;

			tm1 = m1;
			tc1 = c1;
			td1 = d1;
			te1 = e1;
			tf1 = f1;
			tm2 = m2;
			tc2 = c2;
			td2 = d2;
			te2 = e2;
			tf2 = f2;
			console.log('tm1: ' + tm1);
			console.log('tc1: ' + tc1);
			console.log('td1: ' + td1);
			console.log('te1: ' + te1);
			console.log('tf1: ' + tf1);
			console.log('tm2: ' + tm2);
			console.log('tc2: ' + tc2);
			console.log('td2: ' + td2);
			console.log('te2: ' + te2);
			console.log('tf2: ' + tf2);

		} else if (i > g) {
			document.write('<!-- Gathering ' + i + ' is after the folio. -->');
			console.log(i + " is the gathering");

			c1 = 100;
			d1 = 120;
			e1 = 150;
			f1 = 180;

			xm1 = m1;
			xc1 = c1;
			xd1 = d1;
			xe1 = e1;
			xf1 = f1;
			xm2 = m2;
			xc2 = c2;
			xd2 = d2;
			xe2 = e2;
			xf2 = f2;

			console.log('xm1: ' + xm1);
			console.log('xc1: ' + xc1);
			console.log('xd1: ' + xd1);
			console.log('xe1: ' + xe1);
			console.log('xf1: ' + xf1);
			console.log('xm2: ' + xm2);
			console.log('xc2: ' + xc2);
			console.log('xd2: ' + xd2);
			console.log('xe2: ' + xe2);
			console.log('xf2: ' + xf2);
		} else if (i == g)  {

			old_f2 = f2;
			m2 = 100;
			c2 = 95;
			d2 = 100;
			e2 = 100;
			f2 = 100;
		}
		else {}

		if (i == g) {
			folio = i;
		} else {
			var diff = old_f2 - 80;
			//console.log(diff);
			new_c2 = c2 - (diff / 2);
			//console.log(f2 + ", " + old_f2);
			if (f2 < old_f2) {

				document.write('<path d="M ' + m1 + ' ' + old_f2 + ' C ' + c1 + ' ' + new_c2 + ', ' + d1 + ' ' + d2 + ', ' + e1 + ' ' + e2 + ', ' + f1 + ' ' + f2 + '" stroke="' + isOdd(i) + '" stroke-width="1.5%" stroke-linecap="round" fill="transparent"/> ');

				document.write('<!-- d="M ' + m1 + ' ' + old_f2 + ' C ' + c1 + ' ' + new_c2 + ', ' + d1 + ' ' + d2 + ', ' + e1 + ' ' + e2 + ', ' + f1 + ' ' + f2 + '" stroke="' + isOdd(i) + '" stroke-width="1.5%" stroke-linecap="round" fill="transparent"--/> ');
			
			} else {
				document.write('<path d="M ' + m1 + ' ' + m2 + ' C ' + c1 + ' ' + c2 + ', ' + d1 + ' ' + d2 + ', ' + e1 + ' ' + e2 + ', ' + f1 + ' ' + f2 + '" stroke="' + isOdd(i) + '" stroke-width="1.5%" stroke-linecap="round" fill="transparent"/> ');

				document.write('<!-- d="M ' + m1 + ' ' + m2 + ' C ' + c1 + ' ' + c2 + ', ' + d1 + ' ' + d2 + ', ' + e1 + ' ' + e2 + ', ' + f1 + ' ' + f2 + '" stroke="' + isOdd(i) + '" stroke-width="1.5%" stroke-linecap="round" fill="transparent"--/> ');
			}

			m2 = m2 - 2;
			c2 = c2 - 2;
			d2 = d2 - 2;
			e2 = e2 - 2;
			f2 = f2 - 2;

		}

	}
	//console.log(old_f2);

	var start = q * (g-1);
	var end = start + q;

	var d=1;
	var e=1;
	for (j = start; j < end; j++) {

			document.write('<!-- tc2 is ' + tc2 + '-->');
			document.write('<!-- xc2 is ' + xc2 + '-->');

		if (!fm1) {

			var diff = old_f2 - 80;
			//console.log(diff);
			var fm1 = 80;
			var fm2 = old_f2;
			var fc1 = 100;
			var fc2 = 55 - diff;
			var fd1 = 120;
			var fd2 = 80;
			var fe1 = 150;
			var fe2 = 80;
			var ff1 = 180;
			var ff2 = 80;

			console.log(fm1);
			console.log(fm2);
			console.log(fc1);
			console.log(fc2);
			console.log(fd1);
			console.log(fd2);
			console.log(fe1);
			console.log(fe2);
			console.log(ff1);
			console.log(ff2);			

		}

		if (j < f) {
		console.log (j + ' is less than' + f);
			if (d == 1) {
				fc2 = tc2 - 10; 
				fd2 = tc2 - 15;
				fe2 = te2 - 10;
				d++;
			}
			
			fc1 = 60;
			fd1 = 40;
			fe1 = 10;
			ff1 = -20;
		} else if (j > f) {
		console.log (j + ' is more than' + f);
			if (e == 1) {
				fc2 = xc2 - 10;
				fd2 = xd2 - 15;
				fe2 = xe2 - 10;
				e++;
			}

			fc1 = 100;
			fd1 = 120;
			fe1 = 150;
			ff1 = 180;
		} else {

		}

		if (j == f) {
		console.log(j + " equals " + f);
			fm2 = old_f2;
			fc2 = 55;
			fd2 = 80;
			fe2 = 80;
			ff2 = 80;

			lm1 = 80;
			lm2 = old_f2;
			lc1 = 80;
			lc2 = 60;
			ld1 = 80;
			ld2 = 40;
			le1 = 80;
			le2 = 10;
			lf1 = 80;
			lf2 = -20;

			switch (side) {
				case 1:
					pm1 = lm1 - 5;
					pc1 = lc1 - 5;
					pd1 = ld1 - 5;
					pe1 = le1 - 5;
					pf1 = lf1 - 5;
					break;

				case 2:
					pm1 = lm1 + 5;
					pc1 = lc1 + 5;
					pd1 = ld1 + 5;
					pe1 = le1 + 5;
					pf1 = lf1 + 5;
					break;
			}

			console.log('side = ' + side + ' and lm1 = ' + lm1 + ', but pm1 = ' + pm1);

			pm2 = 40;
			pc2 = 30;
			pd2 = 20;
			pe2 = 10;
			pf2 = 0;

			document.write('<!-- M lm1 lm2 C lc1 lc2 , ld1 ld2 , le1 le2 , lf1 lf2 -->');
			document.write('<path d="M ' + lm1 + ' ' + lm2 + ' C ' + lc1 + ' ' + lc2 + ', ' + ld1 + ' ' + ld2 + ', ' + le1 + ' ' + le2 + ', ' + lf1 + ' ' + lf2 + '" stroke="' + isOdd(folio) + '" stroke-width=".5%" stroke-linecap="round" fill="transparent"/> ');
			document.write('<!-- M pm1 pm2 C pc1 pc2 , pd1 pd2 , pe1 pe2 , pf1 pf2 -->');
			document.write('<path d="M ' + pm1 + ' ' + pm2 + ' C ' + pc1 + ' ' + pc2 + ', ' + pd1 + ' ' + pd2 + ', ' + pe1 + ' ' + pe2 + ', ' + pf1 + ' ' + pf2 + '" stroke="#39ff14" stroke-width=".25%" stroke-linecap="round" fill="transparent"/> ');

		} else {
			document.write('<!-- M fm1 fm2 C fc1 fc2 , fd1 fd2 , fe1 fe2 , ff1 ff2 -->');
			document.write('<path d="M ' + fm1 + ' ' + fm2 + ' C ' + fc1 + ' ' + fc2 + ', ' + fd1 + ' ' + fd2 + ', ' + fe1 + ' ' + fe2 + ', ' + ff1 + ' ' + ff2 + '" stroke="' + isOdd(folio) + '" stroke-width=".5%" stroke-linecap="round" fill="transparent"/> ');

			//console.log('<path d="M ' + fm1 + ' ' + fm2 + ' C ' + fc1 + ' ' + fc2 + ', ' + fd1 + ' ' + fd2 + ', ' + fe1 + ' ' + fe2 + ', ' + ff1 + ' ' + ff2 + '" stroke="' + band + '" stroke-width=".5%" stroke-linecap="round" fill="transparent"/> ');
		}

		//fm2 = fm2 - 5;
		fc2 = fc2 - 5;
		fd2 = fd2 - 5;
		fe2 = fe2 - 5;
		ff2 = ff2 - 5;

	}

	document.write('</svg>');
}

//function edit_toggle_visibility() {
//    var e = document.getElementById('EditNotes');
//    var f = document.getElementById('EditLink');
//    var g = document.getElementById('EditWrapper');
//
//    if (e.style.display == 'block') {
//        g.style.display = 'none';
//        e.style.display = 'none';
//        f.style.display = 'inline';
//    } else {
//        g.style.display = 'block';
//        e.style.display = 'block';
//        f.style.display = 'none';
//    }
//}


/*function supplied_toggle_visibility() {
	var supplied = document.getElementById("supplied");
	//   suppliedContent = supplied.innerHTML;
	supplied.innerHTML = "TEST TEST TEST";
}*/

/*Toggle whether or not manuscript decorations appear */
function deco_toggle_visibility() {
	var deco = document.getElementById("decoToggle");

	//   suppliedContent = supplied.innerHTML;
	if (deco.hasAttribute("disabled")) {
		deco.removeAttribute("disabled");
		sessionStorage.setItem("deco_cookie", "not decorated");
	} else {
		deco.setAttribute("disabled", "disabled");
		sessionStorage.setItem("deco_cookie", "decorated");
	}
}

/*toggle the comparison block*/
function compare_toggle_visibility(id, line, collection) {
	var position = $(window).scrollTop();
	var e = document.getElementById(id);
	var surfaceHeight = $(".surface").height();

	e.style.display = ((e.style.display != 'block') ? 'block' : 'none');
	$(window).scrollTop(position);
	$(e).html("Loading Comparison...");
	var loadingHeight = $(".surface").height() - $(e).height();

	console.log($(".surface").height());
	console.log($(".zone").height());
	console.log($(e).height());
	console.log(surfaceHeight);
	console.log(loadingHeight);

	if (surfaceHeight == loadingHeight) {
		$(".surface").height(loadingHeight);
	}

	console.log('/XML/XQuery/test_command_line.php' + '?collection=' + collection + '&zone=' + id + '&line=' + line);

	$.get('/XML/XQuery/test_command_line.php' + '?collection=' + collection + '&zone=' + id + '&line=' + line, function(responseTxt) {
		//    $(window).scrollTop(position+30);
		// console.log(responseTxt);
		$(e).html(responseTxt);

		var newHeight = $(".surface").height() - $(e).height();

		//       console.log($(".surface").height());
		//console.log($(".zone").height());
		//   console.log($(e).height());
		//   console.log(surfaceHeight);
		//       console.log(newHeight);

		//       $(".surface").height(newHeight);

		if (surfaceHeight == newHeight) {
			$(".surface").height(newHeight);
		}
	});
}

/*variables for page height adjust*/

var surfaceHeight = $(".surface").height();
var footerHeight = $(".footer").height();
var imageHeight = $(".facsimage").height();
var headerHeight = $(".header").height();
var notesHeight = $(".notes").height();
var viewportHeight = document.documentElement.clientHeight;
var footerHeight = $(".footer").height();

console.log(headerHeight);
console.log(surfaceHeight);
console.log(imageHeight);
console.log(notesHeight);
console.log(footerHeight);
console.log(viewportHeight);
console.log(document.documentElement.clientHeight);

/*adjust the page height if necessary */
function adjustPageHeight() {
	var surfaceHeight = $(".surface").height();
	var footerHeight = $(".footer").height();
	var imageHeight = $(".facsimage").height();
	var headerHeight = $(".header").height();
	var notesHeight = $(".notes").height();
	var viewportHeight = document.documentElement.clientHeight;
	var footerHeight = $(".footer").height();

	var notesHeight = (typeof notesHeight === 'undefined') ? 0 : notesHeight

	console.log(headerHeight);
	console.log(surfaceHeight);
	console.log(imageHeight);
	console.log(notesHeight);
	console.log(footerHeight);
	console.log(viewportHeight);

	const surface = document.querySelector('.surface');
	const style = getComputedStyle(surface);
	const flex = style.flexDirection;

	console.log(flex);

	var pageHeight = headerHeight + surfaceHeight + notesHeight + footerHeight;
	console.log(pageHeight);

	if (flex == 'column') {
		console.log("column so javascript not firing.")

	} else {
		console.log("javascript firing.")
		var newHeight = viewportHeight - surfaceHeight;
		console.log(newHeight);
		if (surfaceHeight < newHeight) {
			$(".surface").height(newHeight);
		}
	}
}

/*adjust the image height if necessary*/
function adjustHeight() {
	var surfaceHeight = $(".surface").height();
	var footerHeight = $(".footer").height();
	var imageHeight = $(".image").height();
	var headerHeight = $(".header").height();
	var notesHeight = $(".notes").height();
	var footerHeight = $(".footer").height();
	var viewportHeight = document.documentElement.clientHeight;

	console.log(surfaceHeight);
	console.log(imageHeight);
	console.log(headerHeight);
	console.log(notesHeight);
	console.log(footerHeight);
	console.log(viewportHeight);

	if (imageHeight > surfaceHeight) {
		$(".surface").height(imageHeight);
	}
}

/*adjust the mirador viewer window if necessary*/
function adjustViewerHeight() {
	var surfaceHeight = $(".surface").height();
	var footerHeight = $(".footer").height();
	var imageHeight = $(".facsimage").height();
	var headerHeight = $(".header").height();
	var notesHeight = $(".notes").height();
	var footerHeight = $(".footer").height();
	var viewportHeight = document.documentElement.clientHeight;

	var notesHeight = (typeof notesHeight === 'undefined') ? 0 : notesHeight

	console.log(surfaceHeight);
	console.log(imageHeight);
	console.log(headerHeight);
	console.log(notesHeight);
	console.log(footerHeight);
	console.log(viewportHeight);

	if (viewportHeight > surfaceHeight) {
		$(".surface").height(viewportHeight);
	}
}
