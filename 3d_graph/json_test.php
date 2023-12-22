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

    echo "<script>console.log( 'Debug Objects: " . $output . "' )</script>";
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
				$row_color = 'aliceblue';
				//	$row_color = red_green_flipper($row);
				//	return $row_color;
				break;
				
				case "other_work":
								$row_color = 'aliceblue';
				//	$row_color = red_green_flipper($row);
				//	return $row_color;
				break;
				case "other_Lydgate_work":
								//$row_color = 'aliceblue';
								$row_color = 'aliceblue';
				//	$row_color = red_green_flipper($row);
				//	return $row_color;
				break;
				case "multiple_author_work":
								$row_color = 'aliceblue';
					//$row_color = red_green_flipper($row);
				//	return $row_color;
				break;
				
				default:
					$row_color = 'aliceblue';
					
				//	return $row_color;
				}
				return $row_color;
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
						
						$size_location = array_search_multidim($size_array,'Person_id',$row['Person_id']);
						$size = $size_array[$size_location]['Size'];
						
						$person_name = UTF_clean($row['Person_name']);
						array_push($GLOBALS['array'], array(
							'id' => UTF_clean("person" . $row['Person_id']),
							'name' => $person_name,
							'type' => UTF_clean("person"),
							'color' => $person_color,
							'size' => $size,
							'url_color' => $url_color,
							'link' => $link
						));
						$person_name = NULL;
						$url_color = NULL;
						$link = NULL;
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
						
						$size_location = array_search_multidim($size_array,'Person_id',$row['subquery_person_id']);
						$size = $size_array[$size_location]['Size'];
						
						$person_name = UTF_clean($row['subquery_person_name']);
						array_push($GLOBALS['array'], array(
							'id' => UTF_clean("person" . $row['subquery_person_id']),
							'name' => $person_name,
							'type' => UTF_clean("person"),
							'color' => $person_color,
							'size' => $size,
							'url_color' => $url_color,
							'link' => $link
						));
						$person_name = NULL;
						$url_color = NULL;
						$link = NULL;
			}
}
			
function witness_checker($row, $size_array){

global $witness_color;
global $url_color;


		if (!in_array_r('witness' . $row['Witness_id'], $GLOBALS['array']))
			{
						
						$size_location = array_search_multidim($size_array,'Witness_id',$row['Witness_id']);
						$size = $size_array[$size_location]['Size'];
						
						$witness_name = UTF_clean($row['Shelfmark']);
						array_push($GLOBALS['array'], array(
							'id' => UTF_clean("witness" . $row['Witness_id']),
							'name' => $witness_name,
							'type' => UTF_clean('witness'),
							'color' => $witness_color,
							'size' => $size,
							'url_color' => 'aliceblue',
							'link' => NULL));
						$person_name = NULL;
						$url_color = NULL;
						$link = NULL;
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
		
			$size_location = array_search_multidim($size_array,'Work_id',$row['Work_id']);
			$size = $size_array[$size_location]['Size'];	
			
			$work_name = UTF_clean($row['Work']);
			array_push($GLOBALS['array'], array(
				'id'=>UTF_clean($type . $row['Work_id']),
				'name'=> $work_name,
				'type'=> $type,
				'color'=> $color,
				'size'=> $size,
				'url_color' => status_indicator($row, $type),
				'link' => NULL
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
			$size_location = array_search_multidim($size_array,'Work_id',$row['subquery_work_id']);
			$size = $size_array[$size_location]['Size'];	
					
			$work_name = UTF_clean($row['subquery_work']);
			array_push($GLOBALS['array'], array(
				'id'=>UTF_clean($type . $row['subquery_work_id']),
				'name'=> $work_name,
				'type'=> $type,
				'color'=> $color,
				'size'=> $size,
				'url_color' => status_indicator($row, $type),
				'link' => NULL
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
			/*'source' => $source_type . $row['Work_id'],
			'target' => 'witness' . $row['Witness_id'],*/
			'source' => $source_location,
			'target' => $target_location,
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
			/*'source' => 'person' . $row['Person_id'],
			'target' => $target_type . $row['Work_id'],*/
			'source' => $source_location,
			'target' => $target_location,
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
			/*'source' => 'person' . $row['subquery_person_id'],
			'target' => $target_type . $row['subquery_work_id'],*/
			'source' => $source_location,
			'target' => $target_location,
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
			/*'source' => 'person' . $row['subquery_person_id'],
			'target' => $target_type . $row['subquery_work_id'],*/
			'source' => $source_location,
			'target' => $target_location,
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

		if (is_null($row['subquery_work_id'])) {

		}
		else {
	
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
			/*'source' => $target_type . $row['subquery_work_id'],
			'target' => 'witness' . $row['Witness_id'],*/
			'source' => $source_location,
			'target' => $target_location,
			'value' => 1);
		
		//debug_to_console($array);
		
		if ($row['subquery_person_id'] != 1) {
		
			if (!in_array_r($item_array,$GLOBALS['link_array']))
			{
					array_push($GLOBALS['link_array'],$item_array);
			}
		}
	}
}


function other_Lydgate_work_linker($row) {

	global $multi_authors; 

//	reset($array);
	
		if (is_null($row['subquery_work_id'])) {

		}
		else {
	
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
			/*'source' => $target_type . $row['subquery_work_id'],
			'target' => 'witness' . $row['Witness_id'],*/
			'source' => $source_location,
			'target' => $target_location,
			'value' => 1);
		
		//debug_to_console($array);
		
		if ($row['subquery_person_id'] == 1) {
		
			if (!in_array_r($item_array,$GLOBALS['link_array']))
			{
					array_push($GLOBALS['link_array'],$item_array);
			}
		}
	}
	
}

if (isset($_GET['string']))
{
	$get = $_GET['string'];
}
else
{
	$get = "7,26,165,43,45,55,4,89,30,168,118,140,48,19,39,169,151,159,21,84,122,41,3,54,65,49,223,23,93,94,25,76,40,87,50,128,143,96,98,85,113,138,148,13,51,126,158,17,20,79,28,15,5,99,37,229,31,162,152,46,24,110,69,153,147,144,174,56,57,185,34,2,142,58,91,62,95,42,123,12,135,114,97,64,136,27,66,60,59,6,70,71,68,14,74,63,73,208,78,80,81,82,86,90,175,155,16,205,139,215,92,116,38,176,115,214,100,149,150,67,47,75,9,187,154,18,119,101,102,8,88,156,103,164,104,105,10,108,44,1,53,127,120,35,219,141,109,177,228,22,11,111,77,224,29,83,117,112,178,225,129,130,61,131,132,179,161,133,227,134,72,226,137,166,124,196,183,107,121,106,171,172,160,167,197,157,145,146";
}

$where_limiter = "Work_id in (" . $get . ")";
$URL_limiter = " Work_id not in (" . $get . ")";

$mysqli = new mysqli($servername, $username, $password, $database);

if ($mysqli->connect_errno)
{
	echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
}

$array = array();
$link_array = array();

$work_size_sql = "Select count(Witness_work_lookup.Work_id) as Size, Work.id as Work_id from Work inner join Witness_work_lookup on Witness_work_lookup.Work_id = Work.id Group by Witness_work_lookup.Work_id";
//echo $work_size_sql . "<BR>";
$work_size_result = mysqli_query($mysqli, $work_size_sql);
$work_size = mysqli_fetch_all($work_size_result, MYSQLI_ASSOC);

$witness_size_sql = "Select count(Witness_work_lookup.Work_id) as Size, Witness.id as Witness_id from Witness inner join Witness_work_lookup on Witness_work_lookup.Witness_id = Witness.id inner join Work on Work.id = Witness_work_lookup.Work_id Group by Witness_work_lookup.Witness_id";
//echo $witness_size_sql . "<BR>";
$witness_size_result = mysqli_query($mysqli, $witness_size_sql);
$witness_size = mysqli_fetch_all($witness_size_result, MYSQLI_ASSOC);

//$person_size_sql = "Select count(Subquery.people_id) as Size, People.id as Person_id from People inner join Witness_work_role_lookup on People.id = Witness_work_role_lookup.Person_id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id inner join (Select People.id as people_id from People inner join Witness_work_role_lookup on People.id = Witness_work_role_lookup.Person_id inner join Witness_work_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join Work on Work.id = Witness_work_lookup.Work_id " . $where_limiter . " Group by Witness_work_role_lookup.Person_id, Witness_work_lookup.Work_id) as Subquery on People.id = Subquery.people_id " . $where_limiter . " group by People.id";
//$person_size_sql = "Select count(Person_id) as Size, People.id as Person_id, People.Name from People inner join Witness_work_role_lookup on People.id = Witness_work_role_lookup.Person_id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id inner join (Select People.id as people_id from People inner join Witness_work_role_lookup on People.id = Witness_work_role_lookup.Person_id inner join Witness_work_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join Work on Work.id = Witness_work_lookup.Work_id " . $where_limiter . " group by People.id) as Subquery on People.id = Subquery.people_id " . $where_limiter . " group by People.id";
$person_size_sql = "Select count(People.id) as Size, People.id as Person_id, People.Name from People inner join (Select count(People.id), People.id as Person_id from People inner join Witness_work_role_lookup on People.id = Witness_work_role_lookup.Person_id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id group by Work_id,Person_id) as subquery on subquery.Person_id = People.id group by People.id";
//echo $person_size_sql . "<BR>";
//debug_to_console($person_size_sql);
$person_size_result = mysqli_query($mysqli, $person_size_sql);
$person_size = mysqli_fetch_all($person_size_result, MYSQLI_ASSOC);

$multi_works_sql = "select count(Witness_work_role_lookup.Person_id) as Num_authors, Witness_work_lookup.Witness_id, Work.id as Work_id from Witness_work_role_lookup inner join Witness_work_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join Work on Witness_work_lookup.Work_id = Work.id group by Witness_work_lookup.id order by Witness_id"; 
//echo $multi_works_sql . "<BR>";
//debug_to_console($multi_works_sql);
$multi_works_result = mysqli_query($mysqli, $multi_works_sql);
$multi_authors=mysqli_fetch_all($multi_works_result,MYSQLI_ASSOC);
//var_dump($multi_authors);
//echo "<BR>";

mysqli_free_result($work_size_result);
mysqli_free_result($witness_size_result);
mysqli_free_result($person_size_result);
mysqli_free_result($multi_works_result);


$data_sql = "Select Query.Work, Query.DIMEV_number, Query.Work_id, Query.Witness_id, Query.Shelfmark, Query.Beginning_URL, Query.Person_id, Query.Person_name, Query.Status_id, Query.Oxford_DNB_number, Subquery.Work AS subquery_work, Subquery.DIMEV_number AS subquery_dimev_number, Subquery.Work_id AS subquery_work_id, Subquery.Witness_id AS subquery_witness_id, Subquery.Shelfmark AS subquery_shelfmark, Subquery.Beginning_URL AS subquery_beginning_url, Subquery.Person_id AS subquery_person_id, Subquery.Person_name AS subquery_person_name, Subquery.Status_id AS subquery_status_id, Subquery.Oxford_DNB_number AS subquery_oxford_DNB_number from (SELECT Work.Work, Work.DIMEV_number, Work.id AS Work_id, Witness_work_lookup.Witness_id, CONCAT(Location.Short_name, ' ', Witness.Shelfmark) AS Shelfmark, Witness_work_lookup.Beginning_URL, Witness_work_role_lookup.Person_id, People.Name AS Person_name, Witness_work_lookup.Status_id, People.Oxford_DNB_number FROM People INNER JOIN Witness_work_role_lookup ON Witness_work_role_lookup.Person_id = People.id INNER JOIN Witness_work_lookup ON Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id INNER JOIN Work ON Witness_work_lookup.Work_id = Work.id INNER JOIN Witness ON Witness.id = Witness_work_lookup.Witness_id INNER JOIN Location ON Location.id = Witness.Location_id WHERE " . $where_limiter . ") as Query left join (SELECT Work.Work, Work.DIMEV_number, Work.id AS Work_id, Witness_work_lookup.Witness_id, CONCAT(Location.Short_name, ' ', Witness.Shelfmark) AS Shelfmark, Witness_work_lookup.Beginning_URL, Witness_work_role_lookup.Person_id, People.Name AS Person_name, Witness_work_lookup.Status_id, People.Oxford_DNB_number FROM People INNER JOIN Witness_work_role_lookup ON Witness_work_role_lookup.Person_id = People.id INNER JOIN Witness_work_lookup ON Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id INNER JOIN Work ON Witness_work_lookup.Work_id = Work.id INNER JOIN Witness ON Witness.id = Witness_work_lookup.Witness_id INNER JOIN Location ON Location.id = Witness.Location_id WHERE " . $URL_limiter . ") as Subquery on Query.Witness_id = Subquery.Witness_id";
/*    "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_work_lookup.Witness_id, concat(Location.Short_name, ' ' , Witness.Shelfmark) as Shelfmark, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name,Witness_work_lookup.Status_id, People.Oxford_DNB_number, Subquery.Work as subquery_work, Subquery.DIMEV_number as subquery_dimev_number, Subquery.Work_id as subquery_work_id, Subquery.Witness_id as subquery_witness_id, Subquery.Shelfmark as subquery_shelfmark, Subquery.Beginning_URL as subquery_beginning_url, Subquery.Person_id as subquery_person_id, Subquery.Person_name as subquery_person_name, Subquery.Status_id as subquery_status_id, Subquery.Oxford_DNB_number as subquery_oxford_DNB_number from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Location on Location.id = Witness.Location_id inner join (select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness.id as Witness_id, concat(Location.Short_name, ' ' , Witness.Shelfmark) as Shelfmark, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name,Status_id, People.Oxford_DNB_number from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Location on Location.id = Witness.Location_id " . $URL_limiter . ") as Subquery on Subquery.Witness_id = Witness.id " . $where_limiter; */
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



//for ($i = 0; $i < count($data); $i++) {
//    echo $works[$i]['Work_id'] . " " . $works[$i]['Work'] . "<BR>";
//    echo var_dump($works[$i]);
//    echo "<BR>";
//	other_work_checker($data[$i], $work_size);
//}


$total_array = array(
	'nodes' => $array,
	'links' => $link_array
);

//var_dump(json_encode($total_array));
//echo "<BR><BR>'";
$json = json_encode($total_array);
echo $json;	





?>