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


function debug_to_console( $data ) {
    $output = $data;
    if ( is_array( $output ) )
        $output = implode( ',', $output);

    echo "<script>console.log( 'Debug Objects: " . $output . "' );</script>";
}



function array_search_multidim($array, $column, $key){
    return (array_search($key, array_column($array, $column)));
}

function already_exists($array, $stringtocheck) 
{
    foreach ($array as $name) {
        if (stripos($stringtocheck, $name) !== FALSE) {
            return true;
        }
    }
}

function in_array_r($needle, $haystack, $strict = false)
{
	foreach($haystack as $item)
	{
		if (($strict ? $item === $needle : $item == $needle) || (is_array($item) && in_array_r($needle, $item, $strict)))
		{
			return true;
		}
	}

	return false;
}

function isCommaSeparatedIds($string, $allowEmpty = false)
{
	if ($allowEmpty AND $string === '')
	{
		return true;
	}

	if (!preg_match('#^[1-9][0-9]*(,[1-9][0-9]*)*$#', $string))
	{
		return false;
	}

	$idsArray = explode(',', $string);
	return count($idsArray) == count(array_unique($idsArray));
}


function getUserIP()
{
	$client = @$_SERVER['HTTP_CLIENT_IP'];
	$forward = @$_SERVER['HTTP_X_FORWARDED_FOR'];
	$remote = $_SERVER['REMOTE_ADDR'];
	if (filter_var($client, FILTER_VALIDATE_IP))
	{
		$ip = $client;
	}
	elseif (filter_var($forward, FILTER_VALIDATE_IP))
	{
		$ip = $forward;
	}
	else
	{
		$ip = $remote;
	}

	return $ip;
}

function limiter($type, $ids)
{
	if (isCommaSeparatedIds($ids) != 1)
	{
		$where_limiter = "";
	}
	else
	{
		switch ($type)
		{
		case "work":
			$where_limiter = " where Work.id in ($ids)";
			break;

		case "witness":
			$where_limiter = " where Witness.id in ($ids)";
			break;

		case "location":
			$where_limiter = " where Location.id in ($ids)";
			break;

		case "region":
			$where_limiter = " where Region.id in ($ids)";
			break;

		case "city":
			$where_limiter = " where City.id in ($ids)";
			break;

		case "country":
			$where_limiter = " where Country.id in ($ids)";
			break;

		case "person":
			$where_limiter = " where Person.id in ($ids)";
			break;

		default:
			$where_limiter = "";
		}
	}

	return $where_limiter;
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

function red_green_flipper($row) {

//	debug_to_console($row);
//debug_to_console($row['Status_id']);
if ($row['Beginning_URL'])
				{
					//debug_to_console('Beginning_URL does not exist');
					switch($row['Status_id'])	{
						case "4":
						$url_color = 'red';
						$link = "http://" . $_SERVER["HTTP_HOST"] . "/works.html#Proofed" . $row['DIMEV_number'];
						break;
						case "3":
						$url_color = 'chartreuse';
						$link = "http://" . $_SERVER["HTTP_HOST"] . "/works.html#Draft" . $row['DIMEV_number'];
						break;
						default:
						$url_color = 'aliceblue';
						$link = NULL;
					}
				}
else{
					$url_color = 'aliceblue';
					$link = NULL;
	}
	
				
	//debug_to_console(array($url_color, $link));
	return array($url_color, $link);
	}			


function status_indicator($row,$type)
{
//	debug_to_console($row);
				//debug_to_console($type);
				switch($type) 
				{
				case "work":
					$row_color = red_green_flipper($row);
					return $row_color;
				break;
				
				case "other_work":
					$row_color = red_green_flipper($row);
					return $row_color;
				break;
				case "other_Lydgate_work":
					$row_color = red_green_flipper($row);
					return $row_color;
				break;
				case "multiple_author_work":
					$row_color = red_green_flipper($row);
					return $row_color;
				break;
				
				default:
					$url_color = 'aliceblue';
					$link = "";
					return array($url_color, $link);
				}
				//debug_to_console("url_color: " . $url_color . ", link: " . $link);
				}

function person_checker($row, $size_array){

global $person_color;
global $url_color;


		if (!in_array_r('person' . $row['Person_id'], $GLOBALS['array']))
			{
						if (!$row['Oxford_DNB_number'])
						{
							$url_color = 'aliceblue';
							$link = NULL;
						}
						else
						{
							if ($row['Oxford_DNB_number'] != "0")
							{
								$url_color = 'cyan';
								$link = "http://dx.doi.org/10.1093/ref:odnb/" . $row['Oxford_DNB_number'];
							}
							else
							{
							}
						}
						
						//$size_location = array_search_multidim($size_array,'Person_id',$row['Person_id']);
						//$size = $size_array[$size_location]['Size'];
						
						$person_name = UTF_clean($row['Person_name']);
						array_push($GLOBALS['array'], array(
							'id' => UTF_clean("person" . $row['Person_id']),
							'name' => $person_name,
							'type' => 'person',
							'color' => $person_color,
							'size' => 1,
							'url_color' => $url_color,
							'link' => $link
						));
						$person_name = NULL;
						$url_color = NULL;
						$link = "";
			}
			
		if (!in_array_r('person' . $row['subquery_person_id'], $GLOBALS['array']))
			{
						if (!$row['subquery_oxford_DNB_number'])
						{
							$url_color = 'aliceblue';
							$link = NULL;
						}
						else
						{
							if ($row['subquery_oxford_DNB_number'] != "0")
							{
								$url_color = 'cyan';
								$link = "http://dx.doi.org/10.1093/ref:odnb/" . $row['subquery_oxford_DNB_number'];
							}
							else
							{
							}
						}
						
						//$size_location = array_search_multidim($size_array,'Person_id',$row['subquery_person_id']);
						//$size = $size_array[$size_location]['Size'];
						
						$person_name = UTF_clean($row['subquery_person_name']);
						array_push($GLOBALS['array'], array(
							'id' => UTF_clean("person" . $row['subquery_person_id']),
							'name' => $person_name,
							'type' => 'person',
							'color' => $person_color,
							'size' => 1,
							'url_color' => $url_color,
							'link' => $link
						));
						$person_name = NULL;
						$url_color = NULL;
						$link = "";
			}
}
			
function witness_checker($row, $size_array){

global $witness_color;
global $url_color;


		if (!in_array_r('witness' . $row['Witness_id'], $GLOBALS['array']))
			{
						
						//$size_location = array_search_multidim($size_array,'Witness_id',$row['Witness_id']);
						//$size = $size_array[$size_location]['Size'];
						
						$witness_name = UTF_clean($row['Shelfmark']);
						array_push($GLOBALS['array'], array(
							'id' => UTF_clean("witness" . $row['Witness_id']),
							'name' => $witness_name,
							'type' => 'witness',
							'color' => $witness_color,
							'size' => 1,
							'url_color' => 'aliceblue',
							'link' => ""));
						$person_name = NULL;
						$url_color = NULL;
						$link = "";
			}
}

function work_checker($row, $size_array) {

global $work_color;
global $url_color;
global $multiple_author_color;
global $multi_authors;

$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['Work_id'])]['Num_authors'];

	if ($multi > 1) {
		$type = "multiple_author_work";
		$color = $multiple_author_color;
	}
	else
	{
		$type = "work";
		$color = $work_color;
	}
	

	if(!in_array_r ($type . $row['Work_id'], $GLOBALS['array']))
		{
		
			//$size_location = array_search_multidim($size_array,'Work_id',$row['Work_id']);
			//$size = $size_array[$size_location]['Size'];	
			
			$work_name = UTF_clean($row['Work']);
			array_push($GLOBALS['array'], array(
				'id'=>UTF_clean($type . $row['Work_id']),
				'name'=> $work_name,
				'type'=> $type,
				'color'=> $color,
				'size'=> 1,
				'url_color' => status_indicator($row, $type)[0],
				'link' => status_indicator($row,$type)[1]
			));
			$person_name = NULL;
			$url_color = NULL;
			$link = NULL;
		}
}

function other_work_checker($row, $size_array) {

global $otherwork_color;
global $url_color;
global $multiple_author_color;
global $otherwork_lydgate_color;
global $otherwork_other_color;
global $person_color;
global $otherwork_color;
global $multi_authors;

$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['subquery_work_id'])]['Num_authors'];

	if ($multi > 1) {
		$type = "multiple_author_work";
		$color = $multiple_author_color;
	}
	elseif ($row['subquery_person_id'] != 1)
	{
		$type = "other_work";
		$color = $otherwork_other_color;
	}
	elseif ($row['subquery_person_id'] = 1)
	{
		$type = "other_Lydgate_work";
		$color = $otherwork_lydgate_color;
	}
	
			
	if(!in_array_r($type . $row['subquery_work_id'], $GLOBALS['array']))
		{
			//$size_location = array_search_multidim($size_array,'Work_id',$row['subquery_work_id']);
			//$size = $size_array[$size_location]['Size'];	
					
			$work_name = UTF_clean($row['subquery_work']);
			array_push($GLOBALS['array'], array(
				'id'=>UTF_clean($type . $row['subquery_work_id']),
				'name'=> $work_name,
				'type'=> $type,
				'color'=> $color,
				'size'=> 1,
				'url_color' => status_indicator($row, $type)[0],
				'link' => status_indicator($row,$type)[1]
			));
			$person_name = NULL;
			$url_color = NULL;
			$link = NULL;
		}
}

function witness_linker($row) {
//	reset($array);
	global $multi_authors;
	
		$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['Work_id'])]['Num_authors'];
	
		
		if ($multi > 1) {
			$source_type = "multiple_author_work";
		}
		else
		{
			$source_type = "work"; 	
		}
	
		$source_location = array_search_multidim($GLOBALS['array'],'id', $source_type . $row['Work_id']);
	
		$target_location = array_search_multidim($GLOBALS['array'],'id','witness' . $row['Witness_id']);
	
		$color = $GLOBALS['array'][$target_location]['color'];
		
		$item_array = array(
			'color' => $color,
			'source' => $source_type . $row['Work_id'],
			'target' => 'witness' . $row['Witness_id'],
			/*'source' => $source_location,
			'target' => $target_location,*/
			'value' => 1);
		
		//debug_to_console($array);
		
		if (!in_array_r($item_array,$GLOBALS['link_array']))
		{
			array_push($GLOBALS['link_array'],$item_array);
		}
}

function person_linker($row) {
//	reset($array);
	global $multi_authors;
	
		$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['Work_id'])]['Num_authors'];
	
		
		if ($multi > 1) {
			$target_type = "multiple_author_work";
		}
		else
		{
			$target_type = "work"; 	
		}
	
		$source_location = array_search_multidim($GLOBALS['array'],'id','person' . $row['Person_id']);
	
		$target_location = array_search_multidim($GLOBALS['array'],'id',$target_type . $row['Work_id']);
	
		$color = $GLOBALS['array'][$target_location]['color'];
		
		$item_array = array(
			'color' => $color,
			'source' => 'person' . $row['Person_id'],
			'target' => $target_type . $row['Work_id'],
			/*'source' => $source_location,
			'target' => $target_location,*/
			'value' => 1);
		
		//debug_to_console($array);
		
		if (!in_array_r($item_array,$GLOBALS['link_array']))
		{
			array_push($GLOBALS['link_array'],$item_array);
		}
	
}

function person_other_work_linker($row) {
//	reset($array);
	global $multi_authors;
	
		$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['subquery_work_id'])]['Num_authors'];
	
		
		if ($multi > 1) {
			$target_type = "multiple_author_work";
		}
		else
		{
			$target_type = "other_work"; 	
		}
	
		$source_location = array_search_multidim($GLOBALS['array'],'id','person' . $row['subquery_person_id']);
	
		$target_location = array_search_multidim($GLOBALS['array'],'id',$target_type . $row['subquery_work_id']);
	
		$color = $GLOBALS['array'][$target_location]['color'];
		
		$item_array = array(
			'color' => $color,
			'source' => 'person' . $row['subquery_person_id'],
			'target' => $target_type . $row['subquery_work_id'],
			/*'source' => $source_location,
			'target' => $target_location,*/
			'value' => 1);
		
		//debug_to_console($array);
		
		if ($row['subquery_person_id'] != 1) {
		
			if (!in_array_r($item_array,$GLOBALS['link_array']))
			{
					array_push($GLOBALS['link_array'],$item_array);
			}
		}
	
}

function person_other_Lydgate_work_linker($row) {
//	reset($array);
	global $multi_authors;
	
		$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['subquery_work_id'])]['Num_authors'];
	
		
		if ($multi > 1) {
			$target_type = "multiple_author_work";
		}
		else
		{
			$target_type = "other_Lydgate_work"; 	
		}
	
		$source_location = array_search_multidim($GLOBALS['array'],'id','person' . $row['subquery_person_id']);
	
		$target_location = array_search_multidim($GLOBALS['array'],'id',$target_type . $row['subquery_work_id']);
	
		$color = $GLOBALS['array'][$target_location]['color'];
		
		$item_array = array(
			'color' => $color,
			'source' => 'person' . $row['subquery_person_id'],
			'target' => $target_type . $row['subquery_work_id'],
			/*'source' => $source_location,
			'target' => $target_location,*/
			'value' => 1);
		
		//debug_to_console($array);
		
		if ($row['subquery_person_id'] == 1) {
		
			if (!in_array_r($item_array,$GLOBALS['link_array']))
			{
					array_push($GLOBALS['link_array'],$item_array);
			}
		}
	
}


function other_work_linker($row) {

	global $multi_authors; 

//	reset($array);
	
		$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['subquery_work_id'])]['Num_authors'];
	
		
		if ($multi > 1) {
			$target_type = "multiple_author_work";
		}
		else
		{
			$target_type = "other_work"; 	
		}
	
		$target_location = array_search_multidim($GLOBALS['array'],'id',$target_type . $row['subquery_work_id']);
	
		$source_location = array_search_multidim($GLOBALS['array'],'id','witness' . $row['Witness_id']);
	
		$color = $GLOBALS['array'][$target_location]['color'];
		
		$item_array = array(
			'color' => $color,
			'target' => $target_type . $row['subquery_work_id'],
			'source' => 'witness' . $row['Witness_id'],
			/*'source' => $source_location,
			'target' => $target_location,*/
			'value' => 1);
		
		//debug_to_console($array);
		
		if ($row['subquery_person_id'] != 1) {
		
			if (!in_array_r($item_array,$GLOBALS['link_array']))
			{
					array_push($GLOBALS['link_array'],$item_array);
			}
		}
}


function other_Lydgate_work_linker($row) {

	global $multi_authors; 

//	reset($array);
	
	
		$multi = $multi_authors[array_search_multidim($multi_authors, 'Work_id', $row['subquery_work_id'])]['Num_authors'];
	
		
		if ($multi > 1) {
			$target_type = "multiple_author_work";
		}
		else
		{
			$target_type = "other_Lydgate_work"; 	
		}
	
		$target_location = array_search_multidim($GLOBALS['array'],'id',$target_type . $row['subquery_work_id']);
	
		$source_location = array_search_multidim($GLOBALS['array'],'id','witness' . $row['Witness_id']);
	
		$color = $GLOBALS['array'][$target_location]['color'];
		
		$item_array = array(
			'color' => $color,
			'target' => $target_type . $row['subquery_work_id'],
			'source' => 'witness' . $row['Witness_id'],
			/*'source' => $source_location,
			'target' => $target_location,*/
			'value' => 1);
		
		//debug_to_console($array);
		
		if ($row['subquery_person_id'] == 1) {
		
			if (!in_array_r($item_array,$GLOBALS['link_array']))
			{
					array_push($GLOBALS['link_array'],$item_array);
			}
		}
	
}

if (isset($_GET['select']))
{
	$get = implode(",",$_GET['select']);
}
else
{
	$get = "7,26,165,43,45,55,4,89,30,168,118,140,48,19,39,169,151,159,21,84,122,41,3,54,65,49,223,23,93,94,25,76,40,87,50,128,143,96,98,85,113,138,148,13,51,126,158,17,20,79,28,15,5,99,37,229,31,162,152,46,24,110,69,153,147,144,174,56,57,185,34,2,142,58,91,62,95,42,123,12,135,114,97,64,136,27,66,60,59,6,70,71,68,14,74,63,73,208,78,80,81,82,86,90,175,155,16,205,139,215,92,116,38,176,115,214,100,149,150,67,47,75,9,187,154,18,119,101,102,8,88,156,103,164,104,105,10,108,44,1,53,127,120,35,219,141,109,177,228,22,11,111,77,224,29,83,117,112,178,225,129,130,61,131,132,179,161,133,227,134,72,226,137,166,124,196,183,107,121,106,171,172,160,167,197,157,145,146";
}

$where_limiter = " and Work.id in (" . $get . ")";
$URL_limiter = " and Work.id not in (" . $get . ")";

$mysqli = new mysqli($servername, $username, $password, $database);

if ($mysqli->connect_errno)
{
	echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
}

$array = array();
$link_array = array();


$multi_works_sql = "select count(Witness_work_role_lookup.Person_id) as Num_authors, Witness_work_lookup.Witness_id, Work.id as Work_id from Witness_work_role_lookup inner join Witness_work_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join Work on Witness_work_lookup.Work_id = Work.id group by Witness_work_lookup.id order by Witness_id"; 
//echo $multi_works_sql . "<BR>";
//debug_to_console($multi_works_sql);
$multi_works_result = mysqli_query($mysqli, $multi_works_sql);
$multi_authors=mysqli_fetch_all($multi_works_result,MYSQLI_ASSOC);
//var_dump($multi_authors);
//echo "<BR>";

mysqli_free_result($multi_works_result);

$data_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_work_lookup.Witness_id, concat(Location.Short_name, ' ' , Witness.Shelfmark) as Shelfmark, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name,Witness_work_lookup.Status_id, People.Oxford_DNB_number, Subquery.Work as subquery_work, Subquery.DIMEV_number as subquery_dimev_number, Subquery.Work_id as subquery_work_id, Subquery.Witness_id as subquery_witness_id, Subquery.Shelfmark as subquery_shelfmark, Subquery.Beginning_URL as subquery_beginning_url, Subquery.Person_id as subquery_person_id, Subquery.Person_name as subquery_person_name, Subquery.Status_id as subquery_status_id, Subquery.Oxford_DNB_number as subquery_oxford_DNB_number from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Location on Location.id = Witness.Location_id inner join (select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness.id as Witness_id, concat(Location.Short_name, ' ' , Witness.Shelfmark) as Shelfmark, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name,Status_id, People.Oxford_DNB_number from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Location on Location.id = Witness.Location_id " . $URL_limiter . ") as Subquery on Subquery.Witness_id = Witness.id " . $where_limiter; 
//echo $data_sql . "<BR>";
//debug_to_console($data_sql);
$data_result = mysqli_query($mysqli, $data_sql);
$data=mysqli_fetch_all($data_result,MYSQLI_ASSOC);
//var_dump($data);

//var_dump(count($data));

$idsArray = explode(',', $get);

foreach ($data as $row) {
//    echo $works[$i]['Work_id'] . " " . $works[$i]['Work'] . "<BR>";
//    echo var_dump($works[$i]);
//    echo "<BR>";
//var_dump($data[$i]);
//echo "<BR>";
	person_checker($row, $person_size);
	witness_checker($row, $witness_size);
	work_checker($row, $work_size);
	other_work_checker($row, $work_size);
}

reset($data);

foreach ($data as $row) {
//    echo $works[$i]['Work_id'] . " " . $works[$i]['Work'] . "<BR>";
//    echo var_dump($works[$i]);
//    echo "<BR>";
//var_dump($data[$i]);
//echo "<BR>";

witness_linker($row);
person_linker($row);
person_other_work_linker($row);
person_other_Lydgate_work_linker($row);
other_work_linker($row);
other_Lydgate_work_linker($row);
}




$size_array = array();
foreach ($link_array as $key => $value){
    foreach ($value as $key2 => $value2){
        $index = $value2;
        if (array_key_exists($index, $size_array)){
        	if ($key2 == 'source') {
            	$size_array[$index]++;
            }
            elseif ($key2 == 'target') {
            	$size_array[$index]++;
            }
            else {
            	$size_array[$index] = 1;
        	}
        } else {
            $size_array[$index] = 1;
        }
    }
}
//var_dump($size_array);

foreach($array as &$value) {
  $value['size'] = $size_array[$value['id']];
}

$total_array = array(
	'nodes' => $array,
	'links' => $link_array
);

//var_dump(json_encode($total_array));
//echo "<BR><BR>'";
$json = UTF_clean(json_encode($total_array));

$sizes = UTF_clean(json_encode($size_array));

//echo $json;

//echo $sizes;


//var_dump ($_GET['select']);
//echo "<BR>";

    $work_sql = "select Work.Work as name, Work.id as id, Work.DIMEV_number as DIMEV from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness_work_role_lookup.Person_id = 1 group by Work.id order by case when Work.Work like 'The %' then substring(Work.Work from 5) when Work.Work like 'An %' then substring(Work.Work from 4) when Work.Work like 'A %' then substring(Work.Work from 3) else Work.Work END";
    $result = mysqli_query($mysqli,$work_sql);


	if (!empty($_GET['select']))
    	{
    	//  $selection = "json_1.php";
    	//$selection = "json_2.php";
    	$selection = "3d_graph.php";
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
		//echo isCommaSeparatedIds($conflate_select) . "<BR>";

		if (isCommaSeparatedIds($conflate_select) == 1)
			{$select =  "?select=" . $conflate_select;}
				//echo $conflate_select . "<BR>";}
		else
			{
				//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   		//$selection = "json_full.php";
            	//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C215%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    			$selection = "3d_graph.php?select=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C215%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   		
    	   		$select = NULL;
    		}
    	}
    else 
    	{
    		$conflate_select = NULL;
    		
    		//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   	//$selection = "json_full.php";
    	   	//$selection = "json_2.php?string=7%2C26%2C165%2C43%2C45%2C55%2C4%2C89%2C30%2C168%2C118%2C140%2C48%2C19%2C39%2C169%2C151%2C159%2C21%2C84%2C122%2C41%2C3%2C54%2C65%2C49%2C223%2C23%2C93%2C94%2C25%2C76%2C40%2C87%2C50%2C128%2C143%2C96%2C98%2C85%2C113%2C138%2C148%2C13%2C51%2C126%2C158%2C17%2C20%2C79%2C28%2C15%2C5%2C99%2C37%2C229%2C31%2C162%2C152%2C46%2C24%2C110%2C69%2C153%2C147%2C144%2C174%2C56%2C57%2C185%2C34%2C2%2C142%2C58%2C91%2C62%2C95%2C42%2C123%2C12%2C135%2C114%2C97%2C64%2C136%2C27%2C66%2C60%2C59%2C6%2C70%2C71%2C68%2C14%2C74%2C63%2C73%2C208%2C78%2C80%2C81%2C82%2C86%2C90%2C175%2C155%2C16%2C205%2C139%2C215%2C92%2C116%2C38%2C176%2C115%2C214%2C100%2C149%2C150%2C67%2C47%2C75%2C9%2C187%2C154%2C18%2C119%2C101%2C102%2C8%2C88%2C156%2C103%2C164%2C104%2C105%2C10%2C108%2C44%2C1%2C53%2C127%2C120%2C35%2C219%2C141%2C109%2C177%2C228%2C22%2C11%2C111%2C77%2C224%2C29%2C83%2C117%2C112%2C178%2C225%2C129%2C130%2C61%2C131%2C132%2C179%2C161%2C133%2C227%2C134%2C72%2C226%2C137%2C166%2C124%2C196%2C183%2C107%2C121%2C106%2C171%2C172%2C160%2C167%2C197%2C157%2C145%2C146";
    	   	
    	   	$selection = "3d_graph.php";
    	   	$select = NULL;
    	}
    	$url_string = $selection . $select;
    
?>
<!DOCTYPE html>
<head>

    <script src="//cdnjs.cloudflare.com/ajax/libs/qwest/4.4.5/qwest.min.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/PapaParse/4.1.4/papaparse.min.js"></script>
    <script src="//unpkg.com/3d-force-graph"></script>
    <script src="//unpkg.com/force-graph"></script>
    
    <script src="//unpkg.com/d3-octree"></script>
    <script src="//unpkg.com/d3-force-3d"></script>
    <script src="//unpkg.com/three"></script>
    <script src="//unpkg.com/three-spritetext"></script>
    
    <script src="data-set-loader.js"></script>
    <script src="spin.min.js"></script>
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
 margin-left: 300px;
 margin-right: auto;
 margin-top: 10px;
 text-align:center;
 width: 60%;
 position:fixed;
 z-index:3;
 background: gainsboro;
 padding: 3px;
 }
 
 #dropdown p { margin:0px; }
 
 svg {
 position: relative;
 }
        
.scene-tooltip {
display: none;
}


</style>
</head>

<body>
<div id="dropdown">
<!--<p>Please select the Lydgate works, by <i>DIMEV</i> title, from the dropdown to limit the visualization of the connections between them (crtl+click on PC, command+click on Mac). Note that it may take some time for the force-directed graph to appear, depending on the number of items chosen.</p><br> 	
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
 <!--   <input type= "checkbox" id="editionBox" name ="edition" value ="1">
    <label for="editionBox">Toggle edition</label> -->
  <!--  <input type="submit" value="Submit">
  </form> -->
  <form action="javascript:;" onsubmit="addNode()">
  	<input type ="submit" value="Add Node">
  	</form>   
  <!--  <form action="javascript:;" onsubmit="removeNode(data.nodes[getObjectKeyIndex(data.nodes,'witness2')]);removeNode(data.nodes[getObjectKeyIndex(data.nodes,'witness3')]);removeNode(data.nodes[getObjectKeyIndex(data.nodes,'witness4')]);removeNode(data.nodes[getObjectKeyIndex(data.nodes,'witness8')]);removeNode(data.nodes[getObjectKeyIndex(data.nodes,'witness9')]);removeNode(data.nodes[getObjectKeyIndex(data.nodes,'witness14')])">
  	<input type ="submit" value="Remove New Center">->
  	</form>
  <!-- put hide instructions text here -->
</div>

    <div id="3d-graph"></div>
    <script>


    
    var width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
	var height = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
	var size = Math.min(width, height || 0 );
	
	
	function getWidthOfText(txt, fontname, fontsize){
    if(getWidthOfText.c === undefined){
        getWidthOfText.c=document.createElement('canvas');
        getWidthOfText.ctx=getWidthOfText.c.getContext('2d');
    }
    getWidthOfText.ctx.font = fontsize + ' ' + fontname;
    return getWidthOfText.ctx.measureText(txt).width;
}
    
        function getJSON(url, success) {
			var ud = '_' + +new Date,
        	script = document.createElement('script'),
        	head = document.getElementsByTagName('head')[0] 
            	   || document.documentElement;

		    window[ud] = function(data) {
        		head.removeChild(script);
        		success && success(data);
    		};

		    script.src = url.replace('callback=?', 'callback=' + ud);
    		head.appendChild(script);
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
                      
    function removeNode(node) {
      let { nodes, links } = Graph.graphData();
      links = links.filter(l => l.source !== node && l.target !== node); // Remove links attached to node
      nodes.splice(node.id, 1); // Remove node
      nodes.forEach((n, idx) => { n.id = idx; }); // Reset node ids to array index
      Graph.graphData({ nodes, links });
    }
                      
    function removeNodes(nodeList) {
        var arrayLength = nodeList.length;
        for (var i = 0; i < arrayLength; i++) {
            removeNode(getObjectKeyIndex(data.nodes,nodeList[i]));
        }
    }
                      
  
                      
function getObjectKeyIndex(obj, keyToFind) {
    var i = 0, key;

    for (key in obj) {
        if (data.nodes[key].id == keyToFind) {
            return key;
        }

        i++;
    }

    return null;
    }
                      
                      
function addNode() {
      let { nodes, links } = Graph.graphData();
      const id = "other_Lydgate_work" + nodes.length;   
      var ranNum = Math.floor((Math.random() * 10) + 1); 
      var NewItem = {id:id,name:'OTHER',type:'other_Lydgate_work',color:'blueviolet',size:ranNum,url_color:'aliceblue',link:null };
      nodeSelect = Math.floor(Math.random()*nodes.length)                              
      nodes[nodeSelect].size = (nodes[nodeSelect].size + ranNum);
      nodeTarget = nodes[nodeSelect].id;                                
      // console.log(nodes[nodeSelect]);
                                     
      var NewLink = { color:'cornflowerblue',source: id, target: nodeTarget, value:1 }  ;                               
      nodes.push(NewItem);
      links.push(NewLink);                                 
    Graph.graphData({ nodes, links });
                      
}
                      
        
        
        function DragControls(_objects, _camera, _domElement) {

  if (_objects instanceof THREE.Camera) {

    console.warn('THREE.DragControls: Constructor now expects ( objects, camera, domElement )');
    var temp = _objects;
    _objects = _camera;
    _camera = temp;

  }

  var _plane = new THREE.Plane();
  var _raycaster = new THREE.Raycaster();

  var _mouse = new THREE.Vector2();
  var _offset = new THREE.Vector3();
  var _intersection = new THREE.Vector3();

  var _selected = null,
    _hovered = null;

  //

  var scope = this;

  function activate() {

    _domElement.addEventListener('mousemove', onDocumentMouseMove, false);
    _domElement.addEventListener('mousedown', onDocumentMouseDown, false);
    _domElement.addEventListener('mouseup', onDocumentMouseCancel, false);
    _domElement.addEventListener('mouseleave', onDocumentMouseCancel, false);
    _domElement.addEventListener('touchmove', onDocumentTouchMove, false);
    _domElement.addEventListener('touchstart', onDocumentTouchStart, false);
    _domElement.addEventListener('touchend', onDocumentTouchEnd, false);

  }

  function deactivate() {

    _domElement.removeEventListener('mousemove', onDocumentMouseMove, false);
    _domElement.removeEventListener('mousedown', onDocumentMouseDown, false);
    _domElement.removeEventListener('mouseup', onDocumentMouseCancel, false);
    _domElement.removeEventListener('mouseleave', onDocumentMouseCancel, false);
    _domElement.removeEventListener('touchmove', onDocumentTouchMove, false);
    _domElement.removeEventListener('touchstart', onDocumentTouchStart, false);
    _domElement.removeEventListener('touchend', onDocumentTouchEnd, false);

  }

  function dispose() {

    deactivate();

  }

  function onDocumentMouseMove(event) {

    event.preventDefault();

    var rect = _domElement.getBoundingClientRect();

    _mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    _mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    _raycaster.setFromCamera(_mouse, _camera);

    if (_selected && scope.enabled) {

      if (_raycaster.ray.intersectPlane(_plane, _intersection)) {

        _selected.position.copy(_intersection.sub(_offset));

      }

      scope.dispatchEvent({
        type: 'drag',
        object: _selected
      });

      return;

    }

    _raycaster.setFromCamera(_mouse, _camera);

    var intersects = _raycaster.intersectObjects(_objects);

    if (intersects.length > 0) {

      var object = intersects[0].object;

      _plane.setFromNormalAndCoplanarPoint(_camera.getWorldDirection(_plane.normal), object.position);

      if (_hovered !== object) {

        scope.dispatchEvent({
          type: 'hoveron',
          object: object
        });

        _domElement.style.cursor = 'pointer';
        _hovered = object;

      }

    } else {

      if (_hovered !== null) {

        scope.dispatchEvent({
          type: 'hoveroff',
          object: _hovered
        });

        _domElement.style.cursor = 'auto';
        _hovered = null;

      }

    }

  }

  function onDocumentMouseDown(event) {

    event.preventDefault();

    _raycaster.setFromCamera(_mouse, _camera);

    var intersects = _raycaster.intersectObjects(_objects);

    if (intersects.length > 0) {

      _selected = intersects[0].object;

      if (_raycaster.ray.intersectPlane(_plane, _intersection)) {

        _offset.copy(_intersection).sub(_selected.position);

      }

      _domElement.style.cursor = 'move';

      scope.dispatchEvent({
        type: 'dragstart',
        object: _selected
      });

    }


  }

  function onDocumentMouseCancel(event) {

    event.preventDefault();

    if (_selected) {

      scope.dispatchEvent({
        type: 'dragend',
        object: _selected
      });

      _selected = null;

    }

    _domElement.style.cursor = 'auto';

  }

  function onDocumentTouchMove(event) {

    event.preventDefault();
    event = event.changedTouches[0];

    var rect = _domElement.getBoundingClientRect();

    _mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    _mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    _raycaster.setFromCamera(_mouse, _camera);

    if (_selected && scope.enabled) {

      if (_raycaster.ray.intersectPlane(_plane, _intersection)) {

        _selected.position.copy(_intersection.sub(_offset));

      }

      scope.dispatchEvent({
        type: 'drag',
        object: _selected
      });

      return;

    }

  }

  function onDocumentTouchStart(event) {

    event.preventDefault();
    event = event.changedTouches[0];

    var rect = _domElement.getBoundingClientRect();

    _mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    _mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    _raycaster.setFromCamera(_mouse, _camera);

    var intersects = _raycaster.intersectObjects(_objects);

    if (intersects.length > 0) {

      _selected = intersects[0].object;

      _plane.setFromNormalAndCoplanarPoint(_camera.getWorldDirection(_plane.normal), _selected.position);

      if (_raycaster.ray.intersectPlane(_plane, _intersection)) {

        _offset.copy(_intersection).sub(_selected.position);

      }

      _domElement.style.cursor = 'move';

      scope.dispatchEvent({
        type: 'dragstart',
        object: _selected
      });

    }


  }

  function onDocumentTouchEnd(event) {

    event.preventDefault();

    if (_selected) {

      scope.dispatchEvent({
        type: 'dragend',
        object: _selected
      });

      _selected = null;

    }

    _domElement.style.cursor = 'auto';

  }

  activate();

  // API

  this.enabled = true;

  this.activate = activate;
  this.deactivate = deactivate;
  this.dispose = dispose;

  // Backward compatibility

  this.setObjects = function() {

    console.error('THREE.DragControls: setObjects() has been removed.');

  };

  this.on = function(type, listener) {

    console.warn('THREE.DragControls: on() has been deprecated. Use addEventListener() instead.');
    scope.addEventListener(type, listener);

  };

  this.off = function(type, listener) {

    console.warn('THREE.DragControls: off() has been deprecated. Use removeEventListener() instead.');
    scope.removeEventListener(type, listener);

  };

  this.notify = function(type) {

    console.error('THREE.DragControls: notify() has been deprecated. Use dispatchEvent() instead.');
    scope.dispatchEvent({
      type: type
    });

  };

}

DragControls.prototype = Object.create(THREE.EventDispatcher.prototype);
DragControls.prototype.constructor = DragControls;




        const data = <?php echo $json ?>;
        
        console.log(data);
        
        const elem = document.getElementById('3d-graph');
        
        const Graph = ForceGraph3D()
        (elem)
		.graphData(data)
        .forceEngine("d3")
        .nodeRelSize(10)                 
        .nodeVal(function(d) {return d.size})
        .nodeResolution('25')
        .nodeOpacity('0.9')
        .enableNodeDrag(false)
        .enablePointerInteraction(true)
        .onNodeClick(removeNode);
//        .onNodeClick(function(d) {return console.log(d)});
//        .onNodeClick(node => {
//        	console.log(Math.max(node.size, getWidthOfText(node.name,"Baskerville","6px") / 2));
        // Aim at node from outside it
//       		const distance = 1000;
//        	const distRatio = 1 + distance/Math.hypot(node.x, node.y, node.z);
//        	Graph.cameraPosition(
//        		{ x: node.x * distRatio, y: node.y * distRatio, z: node.z * distRatio }, // new position
//        		node, // lookAt ({ x, y, z })
//        		3000  // ms transition duration
//        	);
//        });


		
           
        Graph.d3Force('center', d3.forceCenter())
        	 .d3Force('manyBody', d3.forceManyBody().strength((nearest(function(d,i) {return (d.size)} / 3),5,5,5) * -100))
        	.d3Force('collide', d3.forceCollide(getWidthOfText((function(d,i) {return (d.name)}),"Baskerville","6px") / 2));
  		 
  		 Graph.backgroundColor('gray')
  		 
  		  //.warmupTicks(200) // Adjust number of iterations to taste
  		  //.cooldownTicks(0)
  		  .linkOpacity(0.9)
          //.linkWidth(1)
          //.linkResolution(25);
  		 
  		 camera = Graph.camera();
  		 
  		 //const dragControls = new DragControls(Graph.nodeThreeObject, camera, Graph.nodeThreeObject(node => {node}));
  		 
        
        
    </script>
</body>