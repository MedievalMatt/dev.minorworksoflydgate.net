<?php
header("Access-Control-Allow-Origin: *");
set_time_limit(0);
ini_set('memory_limit', '1024M');

    // ----- set mb_http_output encoding to UTF-8 ----- 
    mb_http_output('UTF-8'); 

    // ----- setup php for working with Unicode data ----- 
    mb_internal_encoding('UTF-8');
    mb_http_output('UTF-8');
    mb_http_input('UTF-8');
    mb_language('uni');
    mb_regex_encoding('UTF-8');
    ob_start('mb_output_handler');

    // ---------------

    require_once('encoding.php'); 

    use \ForceUTF8\Encoding; 

    $servername="witnesses.minorworksoflydgate.net";
    $username="mdavislib";
    $password="dr3am3r1";
    $database="witness_lookup";

    $mysqli = new mysqli($servername, $username, $password, $database);
    $work_sql = "select Work.Work as name, Work.id as id, Work.DIMEV_number as DIMEV from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness_work_role_lookup.Person_id = 1 group by Work.id order by case when Work.Work like 'The %' then substring(Work.Work from 5) when Work.Work like 'An %' then substring(Work.Work from 4) when Work.Work like 'A %' then substring(Work.Work from 3) else Work.Work END";
    $result = mysqli_query($mysqli,$work_sql);

function isCommaSeparatedIds($string, $allowEmpty = false) {
    if ($allowEmpty AND $string === '') {
        return true;
    }
    if (!preg_match('#^[1-9][0-9]*(,[1-9][0-9]*)*$#', $string)) {
        return false;
    }
    $idsArray = explode(',', $string);
    return count($idsArray) == count(array_unique($idsArray));
}

    if (!empty($_GET['select'])) 
    	{
    	//  $selection = "json_1.php";
    	//$selection = "json_2.php";
    	$selection = "json.php";
        $conflate_select= implode(",",$_GET['select']);
        
     /*     foreach($conflate_select as $check) {
		//debug_to_console($check)
			if ($check == "50") {
				array_unshift($conflate_select, "128");
			}

			if ($check == "93") {
				array_unshift($conflate_select, "94");
				}
			}*/

		if (isCommaSeparatedIds($conflate_select) == 1)
		{$select =  "?string=" . $conflate_select;}
			else
			{
				//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   		//$selection = "json_full.php";
            	//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C215%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   		$selection = "json.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C215%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   		
    	   		$select = NULL;
    	   	}
    	}
    else 
    	{
    		$conflate_select = NULL;    		
    		
    		//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   	//$selection = "json_full.php";
    	   	//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C215%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   	
    	   	$selection = "json.php";
    	   	$select = NULL;
    	}
    	$url_string = $selection . $select;

      

//      echo $url_string . "<br/>";
?>
<!DOCTYPE html>
<head>
<script async="async" src="https://www.googletagmanager.com/gtag/js?id=UA-60066712-1"></script><script>
                    window.dataLayer = window.dataLayer || [];
                    function gtag(){dataLayer.push(arguments);}
                    gtag('js', new Date());
                
                    gtag('config', 'UA-60066712-1');
                </script>

<meta charset="utf-8">
<style>

.link {
}

.node text {
  font: 1rem serif;
  pointer-events: none;
}

.node circle {
  fill: #ccc;
  stroke: aliceblue;
  stroke-width: 1px;
}

.node rect {
  fill: #ccc;
  stroke: #fff;
  stroke-width: 1px;
}

.spinner {
  position: fixed;
  top: 50%;
  left: 50%;
  z-index:5;
    }
    
 #dropdown {
 margin-left: 16.66%;
 margin-right: auto;
 margin-top: 1%;
 text-align:center;
 width: 60%;
 position:fixed;
 z-index:3;
 background: gainsboro;
 padding: .25%;
 }
 
 #dropdown p { margin:0px; }

 #fixed {
 	position: fixed;
z-index: 3;
padding-left: 1%;
width: 16.66%;
 }
 
 svg {
 position: relative;
 }


</style>
</head>
<body>
<div id="dropdown">
<p>Please select the Lydgate works, by <i>DIMEV</i> title, from the dropdown to limit the visualization of the connections between them (crtl+click on PC, command+click on Mac). Click and drag a node to pin it on the canvas, and rightclick it to unpin it. Node labels can be hidden by clicking on the appropriate text in the legend. Note that it may take some time for the force-directed graph to appear, depending on the number of items chosen.</p><br>	
  <form action="<?php 

  echo "\"" . $selection . $select . "\"";

  ?> method="get" style="display:inline;">
    <select name="select[]" size=3 multiple="multiple">
    	<?php 
    		while($row = $result->fetch_array())
        	{
          		$id = $row['id'];
          		$name = $row['name'];
          		if ($id != "50") {}
          		else {
          			$name = $name . " - DIMEV " . $row['DIMEV'];
          			}

          		if ($id != "128") {}
          		else {
          			$name = $name . " - DIMEV " . $row['DIMEV'];
          			}

          		if ($id != "93") {}
          		else {
          			$name = $name . " - DIMEV " . $row['DIMEV'];
          			}

          		if ($id != "94") {}
          		else {
          			$name = $name . " - DIMEV " . $row['DIMEV'];
          			}

              /* Replace UTF-8 characters.  This is necessary because curly quotations 
              (or so-called "smart quotations") were not rendering properly and instead showed
              up as a question mark. */
               
              $name = str_replace(array("\xe2\x80\x98", "\xe2\x80\x99", "\xe2\x80\x9c", "\xe2\x80\x9d", "\xe2\x80\x93", "\xe2\x80\x94", "\xe2\x80\xa6"), array("'", "'", '"', '"', '-', '--', '...'), $name);
              // Next, to be on the safe side replace their Windows-1252 equivalents.
              $name = str_replace(array(chr(145), chr(146), chr(147), chr(148), chr(150), chr(151), chr(133)), array("'", "'", '"', '"', '-', '--', '...'), $name);

              /* Convert it to UTF-8 if it is not already, and then fix any encoding issues
              with non-English letter forms. */
              if (mb_detect_encoding($name) != "UTF-8") {
                $name = Encoding::toUTF8($name);
                $name = Encoding::fixUTF8($name);
              }
              else {
                $name = Encoding::fixUTF8($name);
              }
            	
            	
            	if (!empty($_GET['select'])) {
              
	          		if (in_array($id, $_GET['select'])) {
	          			echo"<option value='$id' selected>$name</option>";
	          		}
	          		else {
		          		echo"<option value='$id'>$name</option>";
		          		}
		          	}
		       else {
		       		echo"<option value='$id'>$name</option>";
		       	}
		       	
	        }
	     ?>
    </select>
    <input type="submit" value="Submit">
  </form>
  <form action="forcedirect.php" style="display:inline;">
  	<input type ="submit" value="Clear Limits">
  </form>
  <form action="3d_graph/3d_graph.php" style="display:inline;">
  	 <input type= "hidden" name ="select[]" value ="<?php echo $conflate_select;?>">
  	<input type="submit" value="View in 3D">
  </form>
  <form action="<?php echo $selection;?>" style="display:inline;">
    <input type= "hidden" name ="string" value ="<?php echo $conflate_select;?>">
  <input type = "submit" value = "Display JSON">
  </form>
  <!-- put hide instructions text here -->
</div>
<script src="spin.min.js"></script>
<script src="//d3js.org/d3.v3.min.js"></script>
<!--<script src="https://d3js.org/d3.v4.js"></script>-->
<div id="fixed">
<div id="spinner" class="spinner">
<div id="visbox">
<script>

var width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
var height = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
var screen_size = Math.min(width, height || 0 );
var dynamic_weight = (0 - screen_size) / 3;

console.log(width);
console.log(height);
console.log(screen_size);
console.log(dynamic_weight);

      var opts = {
      lines: 11, // The number of lines to draw
      length: 15, // The length of each line
      width: 10, // The line thickness
      radius: 30, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 0, // The rotation offset
      direction: 1, // 1: clockwise, -1: counterclockwise
      color: '#FFF', // #rgb or #rrggbb
      speed: 0.6, // Rounds per second
      trail: 60, // Afterglow percentage
      shadow: false, // Whether to render a shadow
      hwaccel: true, // Whether to use hardware acceleration
      className: 'spinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: 'auto', // Top position relative to parent in px
      left: 'auto' // Left position relative to parent in px
    };

    var spinner = null;
    var spinner_div = document.getElementById('spinner');

    window.addEventListener("load",loader(),false)


    function loader() {
        if(spinner == null) {
          spinner = new Spinner(opts).spin(spinner_div);
        } else {
          spinner.spin(spinner_div);
        }
      }


function nearest(number, floor, increment, offset) {
    var num = Math.ceil((number - offset) / increment ) * increment + offset;

    if (num < floor) {

    return floor;
  }
  else {
      return Math.ceil((number - offset) / increment ) * increment + offset;
}
}





function titleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function textHide(i)
{
}

//redraw graph after zoom
    function redraw_node()
    {
        node.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")");
    }

function contextmenu(d) {
  d3.event.preventDefault();
  console.log("rightclicked");
  d3.select(this).classed("fixed", d.fixed = false);
  force.start();
}

function clicked(event, d) {
    if (event.defaultPrevented) return; // dragged

    d3.select(this).transition()
        .attr("fill", "black")
        .attr("r", radius * 2)
      .transition()
        .attr("r", radius)
        .attr("fill", d3.schemeCategory10[d.index % 10]);
  }

function click(d) {
	console.log("You clicked", d);
}

function clickcancel() {
    var event = d3.dispatch('click', 'dblclick');
    function cc(selection) {
        var down,
            tolerance = 5,
            last,
            wait = null;
        // euclidean distance
        function dist(a, b) {
            return Math.sqrt(Math.pow(a[0] - b[0], 2), Math.pow(a[1] - b[1], 2));
        }
        selection.on('mousedown', function() {
            down = d3.mouse(document.body);
            last = +new Date();
        });
        selection.on('mouseup', function() {
            if (dist(down, d3.mouse(document.body)) > tolerance) {
                return;
            } else {
                if (wait) {
                    window.clearTimeout(wait);
                    wait = null;
                    event.dblclick(d3.event);
                } else {
                    wait = window.setTimeout((function(e) {
                        return function() {
                            event.clicked(e,d);
                            wait = null;
                        };
                    })(d3.event), 300);
                }
            }
        });
    };
    return d3.rebind(cc, event, 'on');
}

function array_search_multidim($array, $column, $key){
    return (array_search($key, array_column($array, $column)));
}



//var clientHeight = document.getElementById('dropdown').clientHeight;


var width = window.innerWidth - 10,
   // height = window.innerHeight - clientHeight;
	height = window.innerHeight - 10;



var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .style("background-color", "#084c8d")
    .call(d3.behavior.zoom().on("zoom", function () {
    svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
  }))
  .append("g");

var force = d3.layout.force()
//    .gravity(0.8)
//        .gravity(0.6)
    .gravity(1)
//.gravity(0.1)
    .distance((screen_size / 5 ))
    .size([width, height]);

var drag = force.drag()
    .on('dragstart', function(d) {
      d3.select(this).classed('fixed', d.fixed = true);
      force.stop();
    });
//    .on('dragend', function() {
//      force.stop();
//    });
//    .on('dblclick', function() {force.start()});

var index = -1;

var cc = clickcancel();

var json_copy;

force.charge(function (d) {return d.size * dynamic_weight;});

d3.json(<?php echo "\"" . $url_string . "\""?>, function(error, json) {
 console.log("PHP invoked");
 json_copy = json;
 //console.log(json_copy);
  if (error) throw error;

//console.log(json);

  force
      .nodes(json.nodes)
      .links(json.links)
      .start();

  spinner.stop();


  var link = svg.selectAll(".link")
      .data(json.links)
    .enter().append("line")
      .attr("class", "link")
      .attr('stroke', function(d) {return d.color; })
      .attr('stroke-width', 1)    
      .on("mouseover", function(d) {
        d3.select(this).attr('stroke-width', 2);      
      })
      .on("mouseout", function(d) {
        d3.select(this).attr('stroke-width',1);
      });

//cc.on('click',function() {console.log("clicked")});
//cc.on('dblclick',function(d){);

  var node = svg.selectAll(".node")
      .data(json.nodes)
      .enter().append("g")
      .attr("class", "node")
      .call(drag)
      .call(cc)
      .on("click", click)
      .on("contextmenu", contextmenu);
//      .call(d3.behavior.zoom().on("zoom", redraw_node));

//document.write(JSON.stringify(node));

//console.log("TEST, " + nearest(1,10,5,10));

node.append("a")
//	.each(function (d) { var URL = d3.select(this);
//		if (d.link != "")
//			URL.attr("xlink:href", function(d){return d.link;});
//		});
//	.attr("xlink:href", function(d){return d.link;})
	.attr("xlink:href", function(d){if (d.link == "") {return "0"} else { d.link;}})
//	.attr("xlink:href", function(d){if d.link == "" return "0";} 
//		else {return d.link;}
//	})
	.append("circle")
    .attr("r", function (d) {
//        console.log(d.weight + ", " + d.name + ", " + d.type)
//     console.log(source)
//    console.log(Math.log(d.weight));
//    console.log(d.weight + ", " + d.name + ", " + nearest(d.weight,5,5,5) || 10)
//    console.log(d.weight/10 + ", " + d.name + ", " + Math.floor(d.weight/10) * 5 + ", FLOOR TEST")
//    console.log(d.weight/10 + ", " + d.name + ", " + Math.ceil(d.weight/10) * 5 + ", CEILING TEST")
    return nearest(Math.log(d.size) * 10,5,5,5) || 10;})
      .style('stroke', function(d) {return d.url_color;})
      .style('fill', function(d) { return d.color; })
      .on("mouseover", function(d) {
          d3.select(this).attr("r", function (d) {return nearest(Math.log(d.size) * 10,5,5,5) * 1.1 || 10;})
          link.style('stroke-width', function(l) {
          if (d === l.target || d === l.source)
          return 2.5;
        })     
      })
    .on("mouseout", function(d) {
        d3.select(this).attr("r", function (d) {return nearest(Math.log(d.size) * 10,5,5,5) || 10;})
        link.style('stroke-width', 1)
        link.style('stroke', function(d) {return d.color; })
      });
      
  node.append("text")
      .attr("dx", function(d) {return (nearest(Math.log(d.size) * 10,5,5,5) + 5);})
      .attr("dy", ".35em")
      .text(function(d) {return d.name})
      .style('fill', 'gainsboro');

//function dragstart(d) {
//  d3.select(this).classed("fixed", d.fixed = true);
//}

      
  //LEGEND MATERIAL STARTS HERE

  var listTypes = d3.set(json.nodes.map(function(d){return d.type})).values();
  
    console.log(listTypes);
    
  opacityTypes =[];  
  
  for(l = 0; l < listTypes.length; l++) {
  					  opacityTypes[listTypes[l]] = true;
  					  }
    //console.log(opacityTypes);

  listColors = [];

  listPositions = [];

  lineWidths = [];
  
  listBorders = [];
  
  testType = [];
  
  targetLinkages = [];
  
  sourceLinkages =[];
  
  linkages = [];
  
  function typeList(typename) {
  
	  types = [];
	  for(var key in json.nodes) {
  	  if (json.nodes[key].type === typename) {
  			types[key] = json.nodes[key];
  			}
  	  }
  	  
  	  return types;
  }
  
  function linkList(typename) {
  	   links = []
  	   for(var key in json.links) {
  	   
  	   if (json.links[key].source.type === typename) {
  	   		links[key] = json.links[key];
  	   		}
  	   if (json.links[key].target.type === typename) {
  	   		links[key] = json.links[key];
  	   		}
  	   }
  	   
  	   return links;
  	   }
  	   
function poppedType(typename) {
		popped = []
		popped["types"] = typeList(typename)
		popped["links"] = linkList(typename)
		
		return popped;
		}

function poppedNodes(poppeddata) {
//	console.log(poppeddata["types"]);
  	  var popnode = json.nodes;
      popnode.enter();
      
//console.log(json.nodes);
  	  for(var key in popnode){
  	  	  var nodekey = key;
	  	  for(var key in poppeddata["types"]) {
  	  		if (popnode[nodekey].id === poppeddata["types"][key]["id"]) {
  	  			console.log(nodekey + ", " + key + ", " + poppeddata["types"][key]["id"] + ", " + popnode[nodekey].id);
  	  			//function(d, nodekey) {console.log(d.id)};
  	  			popnode.splice(nodekey, 1);
  	  			//console.log(popnode.exit());
  	  		}
  	  	}
  }
  popnode.exit().remove();  
}


  for(l = 0; l < listTypes.length; l++){
        for (var key in json.nodes){
          if (listTypes[l] === json.nodes[key].type) {
            if (listColors.indexOf(json.nodes[key].color) > -1)
            {}
            else
              {
                lineWidths.push(json.nodes[key].type.length);
                listColors.push(json.nodes[key].color);
                listBorders.push("aliceblue");
                var xlegend = (Math.floor(l / 10) * 100 );
                var ycounter;
                var ylegend;
                var oldxlegend;

                if (l===0) {
                  ycounter = 1;
                }

                if (ycounter < 15) {
                    listPositions.push(ycounter * 20);
                    ycounter++;
                }
                else 
                {
                    listPositions.push(ycounter * 20);
                    ycounter = 1;                    
                }
                                            
              }
          }
          else {}
       }
      }
  
  var urlColors = d3.set(json.nodes.map(function(d){return d.url_color})).values();
  
  console.log (urlColors);
  
  for (u = 0; u < urlColors.length; u++) {
  
  		switch (urlColors[u]) {
  		
  		case "red":
  			if (listTypes.indexOf("Has draft transcription") > -1)
  			{}
  			else {
  			listTypes.push("Has draft transcription");
  			lineWidths.push("Has draft transcription".length);
  			listColors.push("aliceblue");
  			listBorders.push(urlColors[u]);
  			listPositions.push(Math.max.apply(Math,listPositions) + 20);
  			}
  		case "chartreuse": 
  			if (listTypes.indexOf("Has proofed transcription") > -1)
  			{}
  			else {
  				if (listTypes.indexOf("Has draft transcription") > -1) {}
  				else {
  					listTypes.push("Has proofed transcription");
  					lineWidths.push("Has proofed transcription".length);
  					listColors.push("aliceblue");
  					listBorders.push(urlColors[u]);
  					listPositions.push(Math.max.apply(Math,listPositions) + 20);
  				}
  			}
  		case "cyan":
  			if (listTypes.indexOf("Has external URL") > -1)
  			{}
  			else {
  			listTypes.push("Has external URL");
  			lineWidths.push("Has external URL".length);
  			listColors.push("aliceblue");
  			listBorders.push(urlColors[u]);
  			listPositions.push(Math.max.apply(Math,listPositions) + 20);
  			}
  		}
  }
  
  
  
 /* console.log(lineWidths); */
//  console.log(listTypes);
//  console.log(testType);
// console.log(listColors);
//  console.log(listBorders);
//  console.log(listPositions);  
//  console.log (Math.max.apply(Math,listPositions));
  

var box = d3.select("#fixed").append("svg")
.attr("height", 275)

  box.append("rect")
  .attr("class", "overlay")
  .attr("x",5)
  .attr("y", 10)
  .attr("width", Math.max.apply(Math,lineWidths) * 10.6)
  .attr("height", (listTypes.length * 21.667) + 10)
  .attr("position", "fixed")
  .style ("fill", "gainsboro")

var opacityType;  
//var currentOpacity = "1";
/*var toggleOpacity = (function(){
        var active   = text.active ? false : true,
          newOpacity = active ? 0 : 1;
          
          svg.selectAll("svg text").filter(function(d){return d.type === opacityType}).transition().style("opacity", newOpacity);
          
          text.active = active;
	});
*/
  var legend = box.selectAll(".legend")
          .data(listTypes)
        .enter().append("g")
          .attr("class", "legend")
          .attr("transform", function(d, i) { return "translate(" + (Math.floor(i / 20)  * 105) + ", " + listPositions[i] + ")"; })

        /*legend.append("rect")
          .attr("x", 10)		
          .attr("width", 15 )
          .attr("height", function(d,i) {return itemHeights[i];})
          .attr("fill", function(d,i) {return listColors[i];});
         */ 
          
        
        legend.append("circle")
          .attr("r", 5)
          .attr("cx", 20)
          .attr("cy", 6)
          .attr("fill",function(d,i) {return listColors[i];})
          .attr("stroke",function(d,i) {return listBorders[i];})
          .on("click", function(d,i) {console.log(listTypes[i]);
 /*                   				   for (var nodekey in json.nodes){
                    				   		if (listTypes[i] === json.nodes[nodekey].type)
                    				   			{
                    				   				// console.log("NODE: " + json.nodes[nodekey].type);
													 for (var linkkey in json.links){
													 	 if (json.nodes[nodekey].id == json.links[linkkey].target.id) {
														 	targetLinkage = [];
														 	targetLinkage.push(listTypes[i], json.links[linkkey].source, json.links[linkkey].target);
														 	targetLinkages.push(targetLinkage);
														 	
														 	testLinkage = json.links[linkkey].source;
														 	console.log(json.links[linkkey].target.id);
														 	for (var linksourcekey in json.links){
														 	if (json.links[linkkey].target.id == json.links[linksourcekey].source.id) {

														 	sourceLinkage = [];
														 	sourceLinkage.push(json.links[linkkey].source.type, json.links[linksourcekey].source, json.links[linksourcekey].target);
														 	sourceLinkages.push(sourceLinkage);
														 	
														 	linkage = [];
														 	linkage.push(json.links[linksourcekey].color, testLinkage, json.links[linksourcekey].target,json.links[linksourcekey].value);
														 	linkages.push(linkage);
														 	}
														 	}
														 	
														 	
														 	
													 	/*		   if (json.nodes[nodekey].id == json.links[linkkey].target.id)
													 			   {
          														   		//console.log(linkkey)
          														   		//console.log(json.links[linkkey]);
          														   		for (var subpasskey in json.links) {
          														   		if (json.links[linkkey].target.id == json.links[subpasskey].source.id) {
          														   				
          														   				linkage=[];
          														   				linkage.push(listTypes[i],json.links[linkkey],json.links[subpasskey]);
          														   		//		linkage["color"] = json.links[linkkey].color;
          														   		//		linkage["source"] = json.links[linkkey].source;
          														   		//		linkage["target"] = json.links[subpasskey].target;
          														   		//		linkage["value"] = 1;
          														   				
          														   				console.log(linkage);
          														   				linkages.push(linkage);
          														   				//linkages.push(color: json.links[linkkey].color, source: json.links[linkkey].source, target: json.links[subpasskey].target, value: "1")
          														   			}
          														   		}

                              									   }
													 	
													 		}
													 }
												}
											}
/*											for (var linkkey in linkages) {
												json.links.push(linkages[linkkey]);
											}
*/											
											//restart();
//										console.log(targetLinkages);
//										console.log(sourceLinkages);
//										console.log(linkages);
//										console.log(json.links);
										}
																
										
									);
          
         											
                    				   	
                    				   	
                    				   
                    				   
                    				
          								
        
        
        legend.append("text")
          .attr("x", 30 )
          .attr("y", 6)
            .attr("dy", ".35em")
          .text(function(d,i){ return titleCase(listTypes[i].replace(/_/g, " "))})
          .on("click", function(d,i) {console.log(listTypes[i]);
                    				   for (var key in json.nodes){
                    				   		if (listTypes[i] === json.nodes[key].type)
                    				   			{
                    				   				 console.log(json.nodes[key].type);
													 opacityType = json.nodes[key].type;
                    				   			}
                    				   		}
                    				   console.log(opacityType);
                    				   if (listTypes.includes(opacityType)){
                    				   console.log(opacityTypes[opacityType]);
                    				   var active   = opacityTypes[opacityType] ? false : true,
          							   newOpacity = active ? 1 : 0;
          							   console.log(active);
          							   console.log(newOpacity);
									   svg.selectAll("svg text").filter(function(d){return d.type === opacityType}).transition().style("opacity", newOpacity);			          
          							   opacityTypes[opacityType] = active;
          							   console.log(opacityTypes);
          							   }
                    				  });

          box.append("g")
        .attr("class", "legend")



  force.on("tick", function() {
    link.attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
    
  });
});

</script>
</div>
</div>
</div>
</body>
