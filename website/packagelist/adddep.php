<?php

include "db.php";
// Recursive function getDepList
function getDepList($packageid) {
	$result = mysql_query("SELECT * FROM packagedeps WHERE package=$packageid");

	while ($dep = mysql_fetch_array($result)) {
		$depresult = mysql_query("SELECT * FROM packages WHERE id=".$dep['dependon']);
		if (mysql_num_rows($depresult) > 0) {
			$dependancy = mysql_fetch_array($depresult);

			$new_dep[$dependancy['id']] = $dependancy;
			$deplist = array_merge($new_dep, getDepList($dependancy['id']));
		}
	}

	return $deplist;
}
?>

<html>
	<head>
		<title>Package Listing</title>
	</head>
	<body>
<?php
	if (IsSet( $_GET['pkgid'] )) {

		if (IsSet( $_GET['add'] )) {
			mysql_query("INSERT INTO packagedeps (package,dependon) VALUES (".$_GET['pkgid'].", ".$_GET['add']. ");");
			echo( mysql_error() );
		}

		$result = mysql_query("SELECT * FROM packages WHERE id=".$_GET['pkgid']." ORDER BY name");
		if (mysql_num_rows($result) > 0) {
			$package = mysql_fetch_array($result);

			$deplist = getDepList($package['id']);
		}
?>
		<h1>Package: <?php echo $package['name']; ?></h1>
		<hr noshade size="1">

		Current version: <?php echo $package['version']; ?><br>
		Source: <a href="<?php echo $package['url']; ?>"><?php echo $package['url']; ?></a>

		<h3>Dependancy Listing...</h3>
		<ul>
<?php
		if ( count( $deplist ) > 0 ) {
			$deplistkey = array_keys($deplist);
		}

		for ($i = 0; $i < count($deplistkey); $i++) {
			$dep = $deplist[$deplistkey[$i]];
?>
			<li><a href="index.php?pkgid=<?php echo $dep['id']; ?>"><?php echo $dep['name']." ".$dep['version']; ?></a></li>
<?php
		}
?>
		</ul>
<?php
		$result = mysql_query("SELECT * FROM packages ORDER BY name");
?>
		<ul>
<?php
		while ($pkg = mysql_fetch_array($result)) {
?>
			<li><a href="adddep.php?pkgid=<?php echo $_GET['pkgid']; ?>&add=<?php echo $pkg['id']; ?>"><?php echo $pkg['name']." ".$pkg['version']; ?></a>
<?php	
		}
?>
		</ul>
<?php
	}
?>
	</body>
</html>
