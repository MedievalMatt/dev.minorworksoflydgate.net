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

require_once ('encoding.php');

use \ForceUTF8\Encoding;
$servername = "witnesses.minorworksoflydgate.net";
$username = "mdavislib";
$password = "dr3am3r1";
$database = "witness_lookup";
$person_color = "darkred";
$work_color = "midnightblue";
$witness_color = "green";
$otherwork_lydgate_color = "cornflowerblue";
$otherwork_other_color = "khaki";
$otherwork_color = "brown";
$multiple_author_color = "saddlebrown";
$location_color = "gold";
$city_color = "darkslategrey";
$region_color = "magenta";
$country_color = "orange";
$edition_color = "indigo";
$default_color = "aliceblue";
$proofed_color = "red";
$draft_color = "chartreuse";
$DNB_color = "cyan";

//$where_limiter = " and Work.id in (" . $get . ")";
//$URL_limiter = " and Work.id not in (" . $get . ")";

$mysqli = new mysqli($servername, $username, $password, $database);

if ($mysqli->connect_errno)
{
  echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
}

$array = array();
$link_array = array();


$work_array = array();
$witness_array = array();
$witness_work_array = array();
$person_array = array();
$edition_array = array();


function debug_to_console( $data ) {
    $output = $data;
    if ( is_array( $output ) )
        $output = implode( ',', $output);

    echo "<script>console.log( 'Debug Objects: " . $output . "' );</script>";
}

function UTF_clean($name)
{
      /* Replace UTF-8 characters.  This is necessary because curly quotations
      (or so-called "smart quotations" were not rendering properly and instead showed
      up as a question mark. */
      $name = str_replace(array(
        "xe2x80x98",
        "xe2x80x99",
        "xe2x80x9c",
        "xe2x80x9d",
        "xe2x80x93",
        "xe2x80x94",
        "xe2x80xa6"
      ) , array(
        "'",
        "'",
        '"',
        '"',
        '-',
        '--',
        '...'
      ) , $name);

      // Next, to be on the safe side replace their Windows-1252 equivalents.

      $name = str_replace(array(
        chr(145) ,
        chr(146) ,
        chr(147) ,
        chr(148) ,
        chr(150) ,
        chr(151) ,
        chr(133)
      ) , array(
        "'",
        "'",
        '"',
        '"',
        '-',
        '--',
        '...'
      ) , $name);
      /* Convert it to UTF-8 if it is not already, and then fix any encoding issues
      with non-English letter forms. */
      if (mb_detect_encoding($name) != "UTF-8")
      {
        $name = Encoding::toUTF8($name);
        $name = Encoding::fixUTF8($name);
      }
      else
      {
        $name = Encoding::fixUTF8($name);
      }
      
      return $name;
}
//echo "<br/><br/>Work<br/><br/>";
//Build work array
$work_sql = "Select * from Work";
$work_result = mysqli_query($mysqli, $work_sql);
$work_data=mysqli_fetch_all($work_result,MYSQLI_ASSOC);

foreach ($work_data as $row) {

$type = "work";
$work_id = $row["id"];
$work_title = UTF_clean($row["Work"]);
$work_DIMEV = $row["DIMEV_number"];

array_push($GLOBALS['work_array'], array(
        'id'=>$work_id,
        'name'=> $work_title,
        'DIMEV' => $work_DIMEV,
        'type'=> $type,
        'color'=> $work_color,
        'size'=> NULL,
        'url_color' => NULL,
        'link' => NULL
      ));
}

$jwork = json_encode($work_array);
//echo $jwork;


$witness_sql = "Select Witness.id as Witness_id, Shelfmark, Short_name, City.Name as City_name, Region.Region as Region_name, Country.Country as Country_name, Open_access, Witness_type from Witness inner join Location on Witness.Location_id = Location.id inner join Witness_type on Witness.Witness_type_id = Witness_type.id inner join City on City.id = Location.City_id inner join Region on Region.id = Location.Region_id inner join Country on Location.Country_id = Country.id";
$witness_result = mysqli_query($mysqli, $witness_sql);
$witness_data=mysqli_fetch_all($witness_result,MYSQLI_ASSOC);

foreach ($witness_data as $row) {
$type = "witness";
$witness_id = $row["Witness_id"];
//$witness_shelfmark = $row["Shelfmark");
//$location = $row["Short_name"];

$shelfmark = UTF_clean($row["Short_name"]) . " " . UTF_clean($row["Shelfmark"]);
//$shelfmark = UTF_clean($location) . " " . UTF_clean($witness_shelfmark);
//echo $shelfmark . "<BR/>";
$city = UTF_clean($row["City_name"]);
$region = UTF_clean($row["Region_name"]);
$country = UTF_clean($row["Country_name"]);
$open_access = $row["Open_access"];
$witness_type = $row["Witness_type"];
//echo $city . "<br/>";
//echo $region . "<br/>";

if ($open_access == "1") {
  $open_access = "yes";
}
else
{
  $open_access = "no";
}

array_push($GLOBALS['witness_array'], array(
  'id'=>$witness_id,
  'type'=> $type,
  'shelfmark' => $shelfmark,
  'city' => $city,
  'region' => $region,
  'country' => $country,
  'open_access' => $open_access,
  'witness_type' => $witness_type,
  'color' => $witness_color
));
}

$jwitness = json_encode($witness_array);

$witness_work_sql = "Select Status.Status as Status, Witness_work_lookup.id as Witness_work_id, Witness_work_lookup.Witness_id as Witness_id, Witness_work_lookup.Work_id as Work_id, Witness_work_lookup.Beginning_URL as URL, Witness_work_lookup.Image_rights as Image_rights from Witness_work_lookup inner join Status on Status.id = Witness_work_lookup.Status_id";
$witness_work_result = mysqli_query($mysqli, $witness_work_sql);
$witness_work_data=mysqli_fetch_all($witness_work_result,MYSQLI_ASSOC);

foreach ($witness_work_data as $row) {
$type = "witness_work";
$witness_work_id = $row["Witness_work_id"];
$work_id = $row["Work_id"];
$witness_id = $row["Witness_id"];
$status = $row["Status"];
$image_rights = $row["Image_rights"];
$url = $row["URL"];
//$witness_shelfmark = $row["Shelfmark");
//$location = $row["Short_name"];

//echo $city . "<br/>";
//echo $region . "<br/>";

if ($image_rights == "1") {
  $image_rights = "yes";
}
else
{
  $image_rights = "no";
}

array_push($GLOBALS['witness_work_array'], array(
  'id'=>$witness_work_id,
  'type'=> $type,
  'work_id' => $work_id,
  'witness_id' => $witness_id,
  'status' => $status,
  'image_rights' => $image_rights,
  'url' => $url
));
}

$jwitness_work = json_encode($witness_work_array);
//echo $jwitness_work;
//echo "<BR><BR>";

$person_sql = "select Witness_work_role_lookup.id as Witness_work_role_id, Witness_work_role_lookup.Witness_work_id as Witness_work_id, People.Name as Person_name, People.Oxford_DNB_number, Role.Role from Witness_work_role_lookup inner join People on People.id = Witness_work_role_lookup.Person_id inner join Role on Witness_work_role_lookup.Role_id = Role.id";
$person_result = mysqli_query($mysqli, $person_sql);
$person_data=mysqli_fetch_all($person_result,MYSQLI_ASSOC);

foreach ($person_data as $row) {
$type = "person";
$witness_work_role_id = $row["Witness_work_role_id"];
$witness_work_id = $row["Witness_work_id"];
$person = $row["Person_name"];
$DNB = $row["Oxford_DNB_number"];
$role = $row["Role"];
$color = $person_color;
//$witness_shelfmark = $row["Shelfmark");
//$location = $row["Short_name"];

//echo $city . "<br/>";
//echo $region . "<br/>";

array_push($GLOBALS['person_array'], array(
  'id'=>$witness_work_role_id,
  'witness_work_id'=>$witness_work_id,
  'type'=>$type,
  'person'=>$person,
  'DNB_number'=>$DNB,
  'role'=>$role,
  'color'=>$color
));
}

$jperson = json_encode($person_array);

$edition_sql = "select Edition_witness_work_lookup.id as Edition_witness_work_lookup_id, Edition_witness_work_lookup.Witness_work_lookup_id as Witness_work_id, Edition_witness_work_lookup.Page_range as Page_range, Edition.Title as Title, People.Name as Editor, Editor2.Name as Editor2, Editor3.Name as Editor3, Year as Year, Press_name as Press from Edition inner join Edition_witness_work_lookup on Edition_witness_work_lookup.Edition_id = Edition.id inner join People on People.id = Edition.Editor1_id left join People as Editor2 on Editor2.id = Edition.Editor2_id left join People as Editor3 on Editor3.id = Edition.Editor3_id";
$edition_result = mysqli_query($mysqli, $edition_sql);
$edition_data = mysqli_fetch_all($edition_result,MYSQLI_ASSOC);

foreach ($edition_data as $row) {
$type = "edition";
$edition_witness_work_lookup_id = $row["Edition_witness_work_lookup_id"];
$edition_id = $row["Edition_id"];
$witness_work_id = $row["Witness_work_id"];
$page_range = $row["Page_range"];
$title = UTF_clean($row["Title"]);
$editor = UTF_clean($row["Editor"]);
$editor2 = UTF_clean($row["Editor2"]);
$editor3 = UTF_clean($row["Editor3"]);
$year = $row["Year"];
$press = UTF_clean($row["Press"]);
$color = $edition_color;

array_push($GLOBALS['edition_array'], array(
  'id'=>$edition_witness_work_lookup_id,
  'edition'=>$title,
  'witness_work_id'=>$witness_work_id,
  'type'=> $type,
  'press' => $press,
  'year' => $year,
  'editor1' => $editor,
  'editor2' => $editor2,
  'editor3' => $editor3,
  'page_range' => $page_range,
  'color' => $color
));
}

$jedition = json_encode($edition_array);

?>
<script>
var values = [];

values.push(83);
values.push(27);
values.push(31);

//console.log(values);

var witness_work_array = <?php echo $jwitness_work ?>;
var work_array = <?php echo $jwork; ?>;
var witness_array = <?php echo $jwitness; ?>;
var person_array = <?php echo $jperson; ?>;
var edition_array = <?php echo $jedition; ?>; 
var work = [];

var nodes = [];
var works = [];
var otherworks = [];

var witnesses = [];

var witness_list;
var work_list;

//work_size = 0;
//witness_size = 0;


function builder(row, values) {

    for (var value in values) {
    ///console.log(values[value]);
    var work = work_array.find(x => x.id === row.work_id);
    var witness = witness_array.find(x => x.id === row.witness_id);
    //console.log (witness_work_array[i].id);

    if (work.id == values[value]) {
      //console.log(values[value] + " is a value");
      if (nodes.find(x => x.id === work.type + work.id))
        { //console.log(work.type + work.id + " already exists");
          if (witnesses.find(x=>x.id === row.witness_id)) {}
            else {witnesses.push (row.witness_id);
                  witness = {...witness, id: witness.type + witness.id};
                  nodes.push(witness);

                }
        }
      else
        {
//        if (work.id != value) {
//          work = {...work, id: "otherwork" + work.id, color: "brown"};
//        }
//        else
//        {
//          console.log (work_size);
          work = {...work, id: work.type + work.id};
          if (witnesses.find(x=>x.id === row.witness_id)) {}
            else {witnesses.push (row.witness_id);
                  witness = {...witness, id: witness.type + witness.id};
                  nodes.push(witness);
                }
          works.push(row.work_id);
          nodes.push(work);

          //console.log(work.id + " added");
        }
      }
    }

/*    for (witval in witnesses) {
      var otherwork = work_array.find(x => x.id === row.work_id);
      var witness = witness_array.find (x => x.id === row.witness_id);
    }

    if (witness.id == witnesses[witval]) {
      if (nodes.find(x => x.id === otherwork.type + otherwork.id))
      {console.log("Work found in nodes for id " + otherwork.id)}
      else if (nodes.find (x => x.id === "otherwork" + otherwork.id))
        {
          console.log("Otherwork found in nodes for id " + otherwork.id)
        }
      else {
        console.log("Otherwork not found in nodes for id " + otherwork.id)
        otherwork = {...otherwork, id: "otherwork" + otherwork.id};
        otherworks.push(row.work_id);
        nodes.push(otherwork);
      }
    }
    */

    //console.log(witnesses.length);
}

for (var i = 0; i < witness_work_array.length; i++) {

    //console.log (test);
    builder(witness_work_array[i], values);
}

console.log(witnesses);
console.log(nodes);
console.log(works);
//console.log(witness_work_array);
//console.log(work_array);
//console.log(witness_array);
//console.log(person_array);
//console.log(edition_array);
</script>

