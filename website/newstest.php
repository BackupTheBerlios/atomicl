<?php
#######################################################################
##                                                                   ##
## phpBB Fetch All - displays phpBB on any page                      ##
## ----------------------------------------------------------------- ##
## A portal example file.                                            ##
##                                                                   ##
#######################################################################
##                                                                   ##
## Authors: Volker 'Ca5ey' Rattel <ca5ey@clanunity.net>              ##
##          http://clanunity.net/portal.php                          ##
##                                                                   ##
## This file is free software; you can redistribute it and/or modify ##
## it under the terms of the GNU General Public License as published ##
## by the Free Software Foundation; either version 2, or (at your    ##
## option) any later version.                                        ##
##                                                                   ##
## This file is distributed in the hope that it will be useful,      ##
## but WITHOUT ANY WARRANTY; without even the implied warranty of    ##
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the      ##
## GNU General Public License for more details.                      ##
##                                                                   ##
#######################################################################

//
// This path points to the directory where phpBB is installed. Do
// not enter an URL here. The path must end with a trailing
// slash.
//
// Examples:
// forum in /aaa/bbb/ccc/ and script in /aaa/bbb/ccc/
// --> $phpbb_root_path = './';
// forum in /aaa/bbb/ccc/ and script in /aaa/bbb/
// --> $phpbb_root_path = './ccc/';
// forum in /aaa/bbb/ccc/ and script in /aaa/bbb/ddd/
// --> $phpbb_root_path = '../ccc/';
//

$phpbb_root_path = '../../../';

//
// this setting is for the clanunity site - ignore it
//
// $phpbb_root_path = './forum/';

define ('IN_PHPBB', true);

if (!file_exists($phpbb_root_path . 'extension.inc'))
{
    die ('<tt><b>phpBB Fetch All:</b>
          $phpbb_root_path is wrong and does not point to your forum.</tt>');
}

//
// phpBB related files
//

include_once ($phpbb_root_path . 'extension.inc');
include_once ($phpbb_root_path . 'common.' . $phpEx);
include_once ($phpbb_root_path . 'includes/bbcode.' . $phpEx);

//
// Fetch All related files - we do need all these because the portal is a
// huge example
//

include_once ($phpbb_root_path . 'mods/phpbb_fetch_all/common.' . $phpEx);
include_once ($phpbb_root_path . 'mods/phpbb_fetch_all/stats.' . $phpEx);
include_once ($phpbb_root_path . 'mods/phpbb_fetch_all/users.' . $phpEx);
include_once ($phpbb_root_path . 'mods/phpbb_fetch_all/polls.' . $phpEx);
include_once ($phpbb_root_path . 'mods/phpbb_fetch_all/posts.' . $phpEx);
include_once ($phpbb_root_path . 'mods/phpbb_fetch_all/forums.' . $phpEx);

//
// start session management
//

$userdata = session_pagestart($user_ip, PAGE_INDEX, $session_length);
init_userprefs($userdata);

//
// since we are demonstrating span pages we need to set the page offset
//

if (isset($HTTP_GET_VARS['start']) or isset($HTTP_POST_VARS['start'])) {
    $CFG['posts_span_pages_offset'] = isset($HTTP_GET_VARS['start']) ? $HTTP_GET_VARS['start'] : $HTTP_POST_VARS['start'];
}

// fetch new posts since last visit
$new_posts = phpbb_fetch_new_posts();

// fetch user online, total posts, etc
$stats       = phpbb_fetch_stats();

// fetch five users by total posts
$top_poster  = phpbb_fetch_top_poster();

// fetch a random user
$random_user = phpbb_fetch_random_user();

// fetch forum structure
$forums      = phpbb_fetch_forums();

// fetch user of a specific group
// this function is disabled because fetching without a specific
// user group can produces a lot of results (all registered users)
// and this may result in an internal server error. If you want to
// use this feature please specify the group id.
# $member      = phpbb_fetch_users();

// fetch a poll
$poll        = phpbb_fetch_poll();

// fetch a single topic by topic id
$download    = phpbb_fetch_topics(1);

// fetch latest postings
$CFG['posts_trim_topic_number'] = 15;
$recent      = phpbb_fetch_posts(null, POSTS_FETCH_LAST);

// fetch postings
$CFG['posts_trim_topic_number'] = 0;
$CFG['posts_span_pages']        = true;
$news        = phpbb_fetch_posts();

//
// these settings are for the clanunity site - ignore them
//
// $forums      = phpbb_fetch_forums(5);
// $member      = phpbb_fetch_users(83);
// $poll        = phpbb_fetch_poll(12);
// $download    = phpbb_fetch_topics(623);
// $CFG['posts_trim_topic_number'] = 25;
// $recent      = phpbb_fetch_posts(12, POSTS_FETCH_LAST);
// $CFG['posts_trim_topic_number'] = 0;
// $CFG['posts_span_pages'] = true;
// $news        = phpbb_fetch_posts(11);

//
// disconnect from the database
//

phpbb_disconnect();

?>

<?php	
	$TITLE = "Test";
	include("http://atomicl.berlios.de/inc.head.php");
?>
<!-- NEWS -->
<?php for ($i = 0; $i < count($news); $i++) { ?>
<table width="100%" cellpadding="3" cellspacing="1" border="0" class="forumline">
  <tr>
    <th class="thTop" height="28"><?php echo $news[$i]['topic_title']; ?><?php if ($news[$i]['topic_trimmed']) { echo '...'; } ?></th>
  </tr>
  <tr>
    <td class="row1" align="left" width="100%">
      <span class="gensmall">
Posted by
<a href="<?php echo append_sid($phpbb_root_path . 'profile.php?mode=viewprofile&amp;u=' . $news[$i]['user_id']); ?>">
<?php echo $news[$i]['username']; ?>
</a>
on <?php echo $news[$i]['date']; ?> at <?php echo $news[$i]['time']; ?>
      </span>
      <span class="gen">
<hr size="1"/>
<?php echo $news[$i]['post_text']; ?><?php if ($news[$i]['trimmed']) { echo '...'; } ?>
      </span>
<hr size="1"/>
      <span class="gensmall">
<div align="right"><font color="#333333" face="Verdana" size="1">(<?php echo $news[$i]['topic_replies']; ?>)
<a href="<?php echo append_sid($phpbb_root_path . 'viewtopic.php?t=' . $news[$i]['topic_id']); ?>">
Comment<?php if ($news[$i]['topic_replies'] != 1) { echo 's'; } ?></a></font></div>
      </span>
    </td>
  </tr>
</table>

<p />
<?php } ?>
<!-- NEWS -->
<?php
	include("inc.foot.php");
?>
