<?php
	include("inc.db.php");
	include("inc.session.php");

	include("func.getSplotch.php");
	include("func.getNews.php");
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head>
		<title>Atomix :: <?php echo($TITLE); ?></title>
		<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
		<link rel="stylesheet" href="style.css" type="text/css" />
	</head>
	<body>
		<h1 id="head">Atomic Linux :: <?php echo($TITLE); ?></h1>

		<div id="nav">
			<h2>Links</h2>
			<?php if ($_SESSION['id'] > 0) { echo("<p>(".$_SESSION['user'].")</p>"); } ?>
			<ul>
				<li><a href="index.php">Main</a></li>
				<li><a href="http://www.longlandclan.hopto.org/phpBB2/index.php?c=10">Forum</a></li>
				<li><a href="documentation.php">Documentation</a></li>
				<li><a href="download.php">Download</a></li>
			</ul>
		</div>

		<div id="content">
