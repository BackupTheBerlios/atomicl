<?php
	// Gets a splotch and returns it in a nicely formatted way.
	
	function getSplotch($id) {
		$query = mysql_query("SELECT title,content FROM splotch WHERE id='$id' LIMIT 1");
		$result = mysql_fetch_array($query);

		$out = "<div class=\"splotch\" id=\"$id\">".
						"<h2>".$result['title']."</h2>".
						"<p>".eregi_replace("\n", "</p><p>", $result['content'])."</p>".
						"</div>";

		return($out);
	}
?>
