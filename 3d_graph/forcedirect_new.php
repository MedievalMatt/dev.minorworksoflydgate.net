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
      $selection = "json_test.php";
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
<meta charset="utf-8">
<style>

.links line {
  stroke: #999;
  stroke-opacity: 0.6;
}

.nodes circle {
  stroke: #fff;
  stroke-width: 1.5px;
}

text {
  font-family: sans-serif;
  font-size: 10px;
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
<!--<script src="//d3js.org/d3.v3.min.js"></script>-->
<script src="https://d3js.org/d3.v4.js"></script>
<div id="fixed">
<div id="spinner" class="spinner">
<div id="visbox">
<script src="https://d3js.org/d3.v4.min.js"></script>
<script>

var width = window.innerWidth - 10,
   // height = window.innerHeight - clientHeight;
	height = window.innerHeight - 10;

var screen_size = Math.min(width, height || 0 );
var dynamic_weight = (0 - screen_size) / 3;

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .style("background-color", "#084c8d")

//var color = d3.scaleOrdinal(d3.schemeCategory20);

var simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id(function(d) { return d.id; }))
    .force("charge", d3.forceManyBody().strength(function (d) {return d.size * dynamic_weight;}))
    .force("center", d3.forceCenter(width / 2, height / 2))
    .force('collision', d3.forceCollide().radius(function(d) {
      return nearest(Math.log(d.size) * 10,5,5,5) || 10;}
  ));

d3.json(<?php echo "\"" . $url_string . "\""?>, function(error, graph) {
  if (error) throw error;

  var link = svg.append("g")
      .attr("class", "links")
    .selectAll("line")
    .data(graph.links)
    .enter().append("line")
    .style("stroke", function(d) { return d.color; })
    .style("stroke-width", 1);

  var node = svg.append("g")
      .attr("class", "nodes")
    .selectAll("g")
    .data(graph.nodes)
    .enter().append("g")
    
  var circles = node.append("circle")
      .attr("r", function (d) {
        return nearest(Math.log(d.size) * 10,5,5,5) || 10;})
      .attr("fill", function(d) { return d.color; })
      .attr("stroke", function(d) {return d.url_color;})
      .call(d3.drag()
          .on("start", dragstarted)
          .on("drag", dragged)
          .on("end", dragended));

  var labels = node.append("text")
      .text(function(d) {
        return d.name;
      })
      .attr('x', 6)
      .attr('y', 3);

  node.append("title")
      .text(function(d) { return d.name; });

  simulation
      .nodes(graph.nodes)
      .on("tick", ticked);

  simulation.force("link")
      .links(graph.links);

  function ticked() {
    link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node
        .attr("transform", function(d) {
          return "translate(" + d.x + "," + d.y + ")";
        })
  }
});

function dragstarted(d) {
  if (!d3.event.active) simulation.alphaTarget(0.3).restart();
  d.fx = d.x;
  d.fy = d.y;
}

function dragged(d) {
  d.fx = d3.event.x;
  d.fy = d3.event.y;
}

function dragended(d) {
  if (!d3.event.active) simulation.alphaTarget(0);
  d.fx = null;
  d.fy = null;
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

</script>
</div>
</div>
</div>
</body>