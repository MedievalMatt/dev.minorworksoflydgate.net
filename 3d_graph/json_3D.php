<?php
set_time_limit(600);
ini_set('memory_limit', '-1');

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

function keyfinder($array, $field, $value)
{
   foreach($array as $key => $subset)
   {
      if ( $subset[$field] === $value )
         return $key;
   }
   return false;
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
		$filename = $_SERVER['DOCUMENT_ROOT'] . "/badactors.txt";
		$ip = getUserIP();
		$ip = $ip . "\n";
		if (is_writable($filename))
		{
			if (!$handle = fopen($filename, "a+"))
			{
				echo "Cannot open file ($filename)";
				exit;
			}

			if (fwrite($handle, $ip) === FALSE)
			{
				echo "Cannot write to file ($filename)";
				exit;
			}

			//	    	echo "Success, wrote ($ip) to file ($filename)";

			fclose($handle);
		}
		else
		{

			//    		echo "The file $filename is not writable";

		}

		header("location: http://crashsafari.com/");
		die();
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

$where_limiter = limiter("work", $_GET['string']);

// $where_limiter = "";


function array_position($cell, $items_array)
{
	foreach(array_values($items_array) as $i => $value)
	{
		foreach(array_values($value) as $ii => $array_value)
		{
			foreach(array_values($array_value) as $iii => $internal_value)
			{
				if ($internal_value == $cell)
				{
					$array_index = $ii;
				}
				else
				{
					//debug_to_console($cell . " has no location, which should not happen.");
				}
			}
		}
	}

	return $array_index;
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
	
	/*				
					
				}
				else
				{
					if ($row['Beginning_URL'] = "")
					{
						$url_color = 'aliceblue';
						$link = "";
					}
					else
					{
						//debug_to_console($row['Status_id']);
						if ($row['Status_id'] = 4)
						{
							$url_color = 'red';
							$link = "http://" . $_SERVER["HTTP_HOST"] . "/works.html#Proofed" . $row['DIMEV_number'];
							
						}
						elseif ($row['Status_id'] = 3)
						{
							$url_color = 'chartreuse';
							$link = "http://" . $_SERVER["HTTP_HOST"] . "/works.html#Draft" . $row['DIMEV_number'];
						}
					}
				} */
				
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
				case "person":
					if (!$row['Oxford_DNB_number'])
					{
					}
					else
					{
						if ($row['Oxford_DNB_number'] != "0")
						{
							$url_color = 'cyan';
							$link = "http://dx.doi.org/10.1093/ref:odnb/" . $row['Oxford_DNB_number'];
						}
					}
					return array($url_color, $link);
				break;
				
				default:
					$url_color = 'aliceblue';
					$link = "";
					return array($url_color, $link);
				}
				//debug_to_console("url_color: " . $url_color . ", link: " . $link);
				}
				
function person_checker($row){

//debug_to_console($row);

//debug_to_console('person' . $row['Person_id'] . ', ' . 'work' . $row['Work_id']);

global $mysqli;
global $person_color;
global $url_color;

//	debug_to_console($row['Person_id'])

		if (!in_array_r('person' . $row['Person_id'], $GLOBALS['array']))
			{
				//debug_to_console('person' . $row['Person_id'] . " not in array");

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
								$link = "http://dx.doi.org/10.1093/ref:odnb/" . $person_row['Oxford_DNB_number'];
							}
							else
							{
							}
						}
						
						$person_name = $row['Person_name'];
						array_push($GLOBALS['array'], array(
							'id' => "person" . $row['Person_id'],
							'name' => $person_name,
							'type' => 'person',
							'color' => $person_color,
							'url_color' => $url_color,
							'link' => $link
						));
						$person_name = NULL;
						$url_color = NULL;
						$link = "";
					}
			}
			

function array_builder($result, $id_name, $column_name, $type, $color)
{
//	debug_to_console($type);
	global $mysqli;
	global $person_color;
    global $multiple_author_color;
    global $otherwork_other_color;
    global $otherwork_lydgate_color;
    //debug_to_console($otherwork_lydgate_color);

	while ($row = $result->fetch_array())
	{
//	debug_to_console($row);
		//if ($type == "other_work") {debug_to_console($row);}
		$type_construct = $type . $row[$id_name];
//		if (!in_array_r($type_construct, $GLOBALS['array']))
//		{
			//debug_to_console($row[$column_name]);
			$name = UTF_clean($row[$column_name]);
			
			//debug_to_console($row['Person_id']);
			//debug_to_console($row['Person_name'] . $row['Person_id'] . ", " . $name . ", " . $type . $row[$id_name]);
			//debug_to_console($id_name . ", " . $column_name . ", " . $name . ", " . $type . ", " . $color . ", " . $row['Person_id']);
			switch ($type)
			{
			case "work":
				person_checker($row);
				$url_color = status_indicator($row,$type)[0];
				//debug_to_console(status_indicator($row,$type));
				$link = status_indicator($row,$type)[1];
				$new_type = $type;
				$new_color = $color;
				break;
				
			case "other_work":
				person_checker($row);
				$url_color = status_indicator($row,$type)[0];
				$link = status_indicator($row,$type)[1];
				$new_type = $type;
				$new_color = $color;
				break;
				
			case "other_Lydgate_work":
				person_checker($row);
				$url_color = status_indicator($row,$type)[0];
				$link = status_indicator($row,$type)[1];
				$new_type = $type;
				$new_color = $color;
				
				break;
			
			case "multiple_author_work":
				person_checker($row);
				//debug_to_console($type_construct);
				//debug_to_console($type);
				$url_color = status_indicator($row,$type)[0];
				$link = status_indicator($row,$type)[1];
				$new_type = $type;
				$new_color = $color;
				break;
				
			case "person":
				$url_color = status_indicator($row,$type)[0];
				$link = status_indicator($row,$type)[1];
				$new_type = $type;
				$new_color = $color;
				break;
				
				
			default:
				$url_color = 'aliceblue';
				$link = NULL;
				$new_color = $color;
				$new_type = $type;
				//debug_to_console("default");
			}
			
            $item_array= array(
			'id' => $type_construct,
			'name' => $name,
			'type' => $new_type,
			'color' => $new_color,
			'url_color' => $url_color,
			'link' => $link);
			
			//FIX already_exists to handle multidimensional arrays
			
			if (strpos($new_type, 'work') !== false)  {
				$to_check = "work" . $row[$id_name];
				//debug_to_console($to_check);
				foreach($GLOBALS['array'] as $item) {
				if(already_exists($item, $to_check)) {}
				else {
						if (!in_array_r($item_array, $GLOBALS['array'])) {	
						array_push($GLOBALS['array'], $item_array); 
						}
						
					}
				}
			}
			else {
				if (!in_array_r($item_array, $GLOBALS['array'])) {	
				array_push($GLOBALS['array'], $item_array); 
			}
			}
        }
}	

function link_builder($result,$source_type,$target_type,$source_id,$target_id) {

	//debug_to_console ($source_type . ", " . $source_id .", ". $target_type . ", " . $target_id);
	
	while ($row = $result->fetch_array()) {
	//debug_to_console($source_type . $row[$source_id]);
	$source_location = array_search_multidim($GLOBALS['array'],'id',$source_type . $row[$source_id]);
	//debug_to_console("source location: " . $source_location);
	
	$target_location = array_search_multidim($GLOBALS['array'],'id',$target_type . $row[$target_id]);
//	debug_to_console("target location: " . $target_location);
		
		//if ($target_type != "location") {} else {
		//debug_to_console($row);
		//debug_to_console($source_type . $row[$source_id] . ", " . $source_location . " / " . $target_type . $row[$target_id] . ", " . $target_location);
		//}
	//debug_to_console($target_type . $row[$target_id] . ", " . $target_location);
	
	//var_dump($GLOBALS['array'][$source_location]);
	//echo "<br>";	
	//var_dump($GLOBALS['array'][$target_location]);
	//	echo "<br><br>";
	
	$color = $GLOBALS['array'][$target_location]['color'];
//	debug_to_console['array'][$source_location]['name'];
//	debug_to_console['array'][$target_location]['name'];
//	debug_to_console($color);

//    debug_to_console ($source_type . $row[$source_id] . ", " . $target_type . $row[$target_id] );
 //   debug_to_console ($color . ", " . $source_location . ", " . $target_location . ", " .$value);
		$array = array(
		'color' => $color,
		'source' => $GLOBALS['array'][$source_location]['id'],
		'target' => $GLOBALS['array'][$target_location]['id'],
		/*'source' => $source_location,
		'target' => $target_location,*/
		'value' => 1);
		
		//debug_to_console($array);
		
//		if ($target_location) {
		if (in_array_r($array,$GLOBALS['link_array']))
		{}
		else
		{
			array_push($GLOBALS['link_array'],$array);
		}
//		}
		
	}
}


					
$mysqli = new mysqli($servername, $username, $password, $database);

if ($mysqli->connect_errno)
{
	echo "Failed to connect to MySQL: (" . $mysqli->connect_errno . ") " . $mysqli->connect_error;
}

$array = array();
$link_array = array();

// $people_sql = "select * from People";

$people_sql = "select * from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id $where_limiter group by People.id";
$people_result = mysqli_query($mysqli, $people_sql);
//debug_to_console($people_sql);
array_builder($people_result, "Person_id", "Name", "person", $person_color);

// $work_sql = "select * from Work";

$work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name,Status_id from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id $where_limiter group by Work.id";
$work_result = mysqli_query($mysqli, $work_sql);
//debug_to_console($work_sql);
array_builder($work_result, "Work_id", "Work", "work", $work_color);

// $witness_sql = "select * from Witness";

$witness_sql = "select * from Witness inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id $where_limiter group by Witness.id";
//debug_to_console($witness_sql . "LINE 610");
$witness_result = mysqli_query($mysqli, $witness_sql);
array_builder($witness_result, "Witness_id", "Shelfmark", "witness", $witness_color);

$witness_result = mysqli_query($mysqli, $witness_sql);
while ($row = $witness_result->fetch_array())
{
	//modify for three queries or repair choice logic
	
	
	//$multi_work_witness_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) > 1";	
	$multi_work_witness_sql = " select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name, Status_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Witness.id =" . $row['Witness_id'] . " and Work_id in(select Work.id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness.id =" . $row['Witness_id'] . " AND Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	//debug_to_console($multi_work_witness_sql . "LINE 622");
	//$multi_work_witness_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1)";
	//echo($multi_work_witness_sql . "<BR>");
	$multi_work_witness_sql_result = mysqli_query($mysqli, $multi_work_witness_sql);
	array_builder($multi_work_witness_sql_result, "Work_id", "Work", "multiple_author_work", $multiple_author_color);	

	$other_work_witness_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name, Status_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id != 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work_id not in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	//debug_to_console($multi_work_witness_sql . "LINE 629");
//	$other_work_witness_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id != 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) < 2";	
	//echo ($other_work_witness_sql . "<BR>");
	$other_work_witness_sql_result = mysqli_query($mysqli, $other_work_witness_sql);
	array_builder($other_work_witness_sql_result, "Work_id", "Work", "other_work", $otherwork_other_color);
	
	$Lydgate_work_witness_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name, Status_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work_id not in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	//debug_to_console($multi_work_witness_sql . "LINE 636");
	//$Lydgate_work_witness_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) < 2";	
	//echo ($Lydgate_work_witness_sql . "<BR>");
	$Lydgate_work_witness_sql_result = mysqli_query($mysqli, $Lydgate_work_witness_sql);
	array_builder($Lydgate_work_witness_sql_result, "Work_id", "Work", "other_Lydgate_work", $otherwork_lydgate_color );
}

// $location_sql = "select * from Location";

$location_sql = "select * from Location inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter group by Location.id";
$location_result = mysqli_query($mysqli, $location_sql);
array_builder($location_result, "Location_id", "Location_name", "location", $location_color);
// $city_sql = "select * from City";

$city_sql = "select * from City inner join Location on Location.City_id = City.id inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter group by City.id";
$city_result = mysqli_query($mysqli, $city_sql);
array_builder($city_result, "City_id", "Name", "city", $city_color);

// $region_sql = "select * from Region";

$region_sql = "select * from Region inner join Location on Location.Region_id = Region.id inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter group by Region.id";
$region_result = mysqli_query($mysqli, $region_sql);
array_builder($region_result, "Region_id", "Region", "region", $region_color);

// $country_sql = "select * from Country";

$country_sql = "select * from Country inner join Location on Location.Country_id = Country.id inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter group by Country.id";
$country_result = mysqli_query($mysqli, $country_sql);
array_builder($country_result, "Country_id", "Country", "country", $country_color);

$edition_sql = "select * from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness_work_lookup.Witness_id = Witness.id inner join Edition_witness_work_lookup on Edition_witness_work_lookup.Witness_work_lookup_id = Witness_work_lookup.id inner join Edition on Edition_witness_work_lookup.Edition_id = Edition.id $where_limiter group by Edition.id";
$edition_result = mysqli_query($mysqli, $edition_sql);
array_builder($edition_result, "Edition_id", "Title", "edition", $edition_color);


// links

$people_sql = "select * from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id $where_limiter";
$people_result = mysqli_query($mysqli, $people_sql);
link_builder($people_result,"work","person","Work_id","Person_id");
//debug_to_console($people_sql);

// $work_sql = "select * from Work";

//$work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from People inner join Witness_work_role_lookup on Witness_work_role_lookup.Person_id = People.id inner join Witness_work_lookup on Witness_work_lookup.id = Witness_work_role_lookup.Witness_work_id inner join Work on Witness_work_lookup.Work_id = Work.id $where_limiter";
//$work_result = mysqli_query($mysqli, $work_sql);
//debug_to_console($work_sql);
//link_builder($work_result,"work","witness","Work_id","Witness_id");

// $witness_sql = "select * from Witness";

// $location_sql = "select * from Location";

$witness_sql = "select * from Witness inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id $where_limiter";
//debug_to_console($witness_sql . " LINE 690");
$witness_result = mysqli_query($mysqli, $witness_sql);
link_builder($witness_result,"work","witness","Work_id","Witness_id");

$witness_result = mysqli_query($mysqli, $witness_sql);
while ($row = $witness_result->fetch_array())
{
	//Need to rethink this
	//debug_to_console($row);
	//$multi_work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) > 1";
	$multi_work_sql = " select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name, Status_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Witness.id =" . $row['Witness_id'] . " and Work_id in(select Work.id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness.id =" . $row['Witness_id'] . " AND Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	$multi_work_sql_result = mysqli_query($mysqli, $multi_work_sql);
	//Something is up with record 185 and these items.
	//debug_to_console($multi_work_sql . " LINE 703");
	link_builder($multi_work_sql_result, "witness", "multiple_author_work", "Witness_id", "Work_id");
	//link_builder($multi_work_sql_result, "multiple_author_work","person","Work_id","Person_id");
	
	
	//$other_work_sql = "select count(Work.id), Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Person_id != 1 and Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) < 2";
	$other_work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name, Status_id  from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id != 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work_id not in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	$other_work_sql_result = mysqli_query($mysqli, $other_work_sql);
	//debug_to_console($other_work_sql . " is other");
	//debug_to_console($other_work_sql . " LINE 712");
	link_builder($other_work_sql_result, "witness", "other_work", "Witness_id", "Work_id");
	//link_builder($other_work_sql_result,"other_work","person","Work_id","Person_id");
	
	//$Lydgate_work_sql = "select count(Work.id), Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Person_id = 1 and Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) < 2";
	$Lydgate_work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name, Status_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work_id not in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	$Lydgate_work_sql_result = mysqli_query($mysqli, $Lydgate_work_sql);
	//debug_to_console($Lydgate_work_sql . " LINE 719");
	link_builder($Lydgate_work_sql_result, "witness", "other_Lydgate_work", "Witness_id", "Work_id");
	//link_builder($Lydgate_work_sql_result,"other_Lydgate_work","person","Work_id","Person_id");	

}

//debug_to_console($witness_sql . " LINE 725");

$witness_result = mysqli_query($mysqli, $witness_sql);
while ($row = $witness_result->fetch_array())
{
	//Need to rethink this
	//debug_to_console($row);
	//$multi_work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) > 1";
	$multi_work_sql = " select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Witness.id =" . $row['Witness_id'] . " and Work_id in(select Work.id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Witness.id =" . $row['Witness_id'] . " AND Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	$multi_work_sql_result = mysqli_query($mysqli, $multi_work_sql);
	//debug_to_console( $multi_work_sql . " LINE 735");
	//link_builder($multi_work_sql_result, "witness", "multiple_author_work", "Witness_id", "Work_id");
	link_builder($multi_work_sql_result, "multiple_author_work","person","Work_id","Person_id");
	$multi_work_sql_result = mysqli_query($mysqli, $multi_work_sql);
	
	//$other_work_sql = "select count(Work.id), Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Person_id != 1 and Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) < 2";
	$other_work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id != 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work_id not in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	$other_work_sql_result = mysqli_query($mysqli, $other_work_sql);
	//debug_to_console($other_work_sql . " LINE 743");
	//link_builder($other_work_sql_result, "witness", "other_work", "Witness_id", "Work_id");
	link_builder($other_work_sql_result,"other_work","person","Work_id","Person_id");
	
	//$Lydgate_work_sql = "select count(Work.id), Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Person_id = 1 and Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") group by Work.id having count(Work.id) < 2";
	$Lydgate_work_sql = "select Work.Work, Work.DIMEV_number, Work.id as Work_id, Witness_id, Witness_work_lookup.Beginning_URL,Witness_work_role_lookup.Person_id, People.Name as Person_name from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work_id not in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness.id = Witness_work_lookup.Witness_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id inner join People on Witness_work_role_lookup.Person_id = People.id where Person_id = 1 AND Witness.id =" . $row['Witness_id'] . " and Work.id not in (" . $_GET['string'] . ") and Work.id in (select Work_id from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness_work_role_lookup on Witness_work_role_lookup.Witness_work_id = Witness_work_lookup.id where Work_id not in (" . $_GET['string'] . ") and Person_id != 1))";
	$Lydgate_work_sql_result = mysqli_query($mysqli, $Lydgate_work_sql);
	//debug_to_console($Lydgate_work_sql . " LINE 750");
	//link_builder($Lydgate_work_sql_result, "witness", "other_Lydgate_work", "Witness_id", "Work_id");
	link_builder($Lydgate_work_sql_result,"other_Lydgate_work","person","Work_id","Person_id");	

}

$location_sql = "select * from Location inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter";
$location_result = mysqli_query($mysqli, $location_sql);
//debug_to_console($location_sql);
link_builder($location_result,"witness","location","Witness_id","Location_id");

// $city_sql = "select * from City";

$city_sql = "select * from City inner join Location on Location.City_id = City.id inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter";
$city_result = mysqli_query($mysqli, $city_sql);
//debug_to_console($city_sql);
link_builder($city_result,"location","city","Location_id","City_id");

// $region_sql = "select * from Region";

$region_sql = "select * from Region inner join Location on Location.Region_id = Region.id inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter";
$region_result = mysqli_query($mysqli, $region_sql);
//debug_to_console($region_sql);
link_builder($region_result,"city","region","City_id","Region_id");

// $country_sql = "select * from Country";

$country_sql = "select * from Country inner join Location on Location.Country_id = Country.id inner join Witness on Location.id = Witness.Location_id inner join Witness_work_lookup on Witness.id = Witness_work_lookup.Witness_id inner join Work on Work.id = Witness_work_lookup.Work_id $where_limiter";
$country_result = mysqli_query($mysqli, $country_sql);
//debug_to_console($country_sql);
link_builder($country_result,"region","country","Region_id","Country_id");

$edition_sql = "select * from Work inner join Witness_work_lookup on Work.id = Witness_work_lookup.Work_id inner join Witness on Witness_work_lookup.Witness_id = Witness.id inner join Edition_witness_work_lookup on Edition_witness_work_lookup.Witness_work_lookup_id = Witness_work_lookup.id inner join Edition on Edition_witness_work_lookup.Edition_id = Edition.id $where_limiter";
$edition_result = mysqli_query($mysqli, $edition_sql);
link_builder($edition_result,"work","edition","Work_id","Edition_id");
//debug_to_console($edition_sql);

//link_builder($witness_result,"work","witness","Work_id","Witness_id");
//link_builder($edition_result,"work","edition","Work_id","Edition_id");
//link_builder($location_result,"witness","location","Witness_id","Location_id");
//link_builder($city_result,"location","city","Location_id","City_id");
//link_builder($region_result,"city","region","City_id","Region_id");
//link_builder($country_result,"country","city","Country_id","City_id");
//link_builder($people_result,"work","person","Work_id","Person_id");

//need to build out links for other works.  link_builder() not working properly with the subquery.

//debug_to_console($array[26]);
$total_array = array(
	'nodes' => $array,
	'links' => $link_array
);

/*		if ($issue == 1) {
var_dump($total_array);
echo "<br/>";
$issue = NULL;
}*/
echo json_encode($total_array);		
?>
		

	