<?php	
	$TITLE = "Main";
	include("inc.head.php");

	echo(getSplotch("missionstatement"));
	echo(getNews(0, 10));

	include("inc.foot.php");
?>
