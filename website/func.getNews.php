<?php
	// Fetches news
	
	function getNews($offset, $limit) {
			$query = mysql_query("SELECT n.title,
															DATE_FORMAT(n.timestamp, '%H:%i - %W, %D %M %Y') AS timestamp,
															n.formatted,
															n.content,
															u.user
														FROM news AS n,user AS u
														WHERE n.author = u.id
														ORDER BY n.timestamp DESC
														LIMIT $offset, $limit");

			$out = "<div id=\"news\">".
							"<h2>News</h2>";

			while ($row = mysql_fetch_array($query)) {
				$out .= "<div id=\"item\">".
									"<h3 id=\"title\">".$row['title']."</h3>";
				
				if ($row['formatted'] == 0) {
					$out .= "<p>".eregi_replace("\n", "</p><p>", $row['content'])."</p>";
				} else {
					$out .= $row['content'];
				}

				$out .= "<div id=\"foot\">".
									"<span id=\"timestamp\">".$row['timestamp']."</span>".
									" <span id=\"author\">(".$row['user'].")</span>".
								"</div>".
							"</div>";
			}

			$out .= "</div>";

			return $out;
	}
?>
