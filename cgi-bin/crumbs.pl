#!/usr/bin/perl
#
# Stores all global crumbs and builds the crumbs hash

use Errno qw(ENOENT);

%LJ::CRUMBS = (
    'acctstatus' => ['Account Status', '/accountstatus.bml', 'manage'],
    'addfriend' => ['Add Friend', '', 'friends'],
    'advcustomize' => ['Customize Advanced S2 Settings', '/customize/advanced/', 'manage'],
    'advsearch' => ['Advanced Search', '/directorysearch.bml', 'search'],
    'birthdays' => ['Birthdays', '/birthdays.bml', 'friends'],
    'changeemail' => ['Change Email Address', '/changeemail.bml', 'editprofile'],
    'changepass' => ['Change Password', '/changepassword.bml', 'manage'],
    'comminvites' => ['Community Invitations', '/manage/invites.bml', 'manage'],
    'commmembers' => ['Community Membership', '', 'managecommunity'],
    'commpending' => ['Pending Memberships', '', 'managecommunity'],
    'commsearch' => ['Community Search', '/community/search.bml', 'community'],
    'commsentinvites' => ['Sent Invitations', '/community/sentinvites.bml', 'managecommunity'],
    'commsettings' => ['Community Settings', '/community/settings.bml', 'managecommunity'],
    'community' => ['Community Center', '/community/', 'home'],
    'createcommunity' => ['Create Community', '/community/create.bml', 'managecommunity'],
    'createjournal_1' => ['Create Your Account', '/create.bml', 'home'],
    'createstyle' => ['Create Style', '/styles/create.bml', 'modify'],
    'customize' => ['Customize S2 Settings', '/customize/', 'manage'],
    'customizelayer' => ['Individual Customizations', '/customize/layer.bml', 'customize'],
    'domain' => ['Domain Aliasing', '/manage/domain.bml', 'manage'],
    'delcomment' => ['Delete Comment', '/delcomment.bml', 'home'],
    'editentries' => ['Edit Entries', '/editjournal.bml', 'manage'],
    'editinfo' => ['Personal Info', '/manage/profile/', 'manage'],
    'editprofile' => ['Edit Profile', '/manage/profile/', 'manage'],
    'editsettings' => ['Viewing Options', '/manage/profile/', 'manage'],
    'editstyle' => ['Edit Style', '/styles/edit.bml', 'modify'],
    'emailmanage' => ['Email Management', '/tools/emailmanage.bml', 'manage'],
    'export' => ['Export Journal', '/export.bml', 'home'],
    'faq' => ['Frequently Asked Questions', '/support/faq.bml', 'support'],
    'feedstersearch' => ['Search a Journal', '/tools/search.bml', 'home'],
    'filterfriends' => ['Filter Reading Page', '/manage/circle/filter.bml', 'friends'],
    'friends' => ['Circle Tools', '/manage/circle/', 'manage'],
    'home' => ['Home', '/', ''],
    'invitefriend' => ['Invite a Friend', '/manage/circle/invite.bml', 'friends'],
    'joincomm' => ['Join Community', '', 'community'],
    'latestposts' => ['Latest Posts', '/stats/latest.bml', 'stats'],
    'layerbrowse' => ['Public Layer Browser', '/customize/advanced/layerbrowse.bml', 'advcustomize'],
    'leavecomm' => ['Leave Community', '', 'community'],
    'login' => ['Login', '/login.bml', 'home'],
    'logout' => ['Logout', '/logout.bml', 'home'],
    'lostinfo' => ['Lost Info', '/lostinfo.bml', 'manage'],
    'manage' => ['Manage Accounts', '/manage/', 'home'],
    'managecomments' => ['Manage Comments', '/tools/recent_comments.bml', 'manage'],
    'managecommentsettings' => [ 'Manage Comment Settings', '/manage/comments', 'manage'],
    'managecommunities' => ['Manage Communities', '/community/manage.bml', 'manage'],
    'managefriends' => ['Manage Circle', '/manage/circle/edit.bml', 'friends'],
    'managefriendgrps' => ['Manage Filters', '/manage/circle/editfilters.bml', 'friends'],
    'managetags' => ['Manage Tags', '/manage/tags.bml', 'manage'],
    'managelogins' => ['Manage Your Login Sessions', '/manage/logins.bml', 'manage'],
    'manageuserpics' => ['Manage Userpics', '/editpics.bml', 'manage'],
    'memories' => ['Memorable Posts', '/tools/memories.bml', 'manage'],
    'mobilepost' => ['Mobile Post Settings', '/manage/emailpost.bml', 'manage'],
    'moderate' => ['Community Moderation', '/community/moderate.bml', 'community'],
    'moodeditor' => ['Custom Mood Theme Editor', '/manage/moodthemes.bml', 'manage'],
    'moodlist' => ['Mood Viewer', '/moodlist.bml', 'manage'],
    'popfaq' => ['Popular FAQs', '/support/popfaq.bml', 'faq'],
    'postentry' => ['Post an Entry', '/update.bml', 'home'],
    'register' => ['Validate Email', '/register.bml', 'home'],
    'schools' => ['Schools Directory', '/schools/', 'home'],
    'schoolsfind' => ['Find a School', '', 'schools'],
    'schoolsmy' => ['My Schools', '/schools/manage.bml', 'schools'],
    'searchinterests' => ['Search By Interest', '/interests.bml', 'search'],
    'searchregion' => ['Search By Region', '/directory.bml', 'search'],
    'seeoverrides' => ['View User Overrides', '', 'support'],
    'setpgpkey' => ['Public Key', '/manage/pubkey.bml', 'manage'],
    'sitestats' => ['Site Statistics', '/stats/site.bml', 'about'],
    'stats' => ['Statistics', '/stats.bml', 'about'],
    'styles' => ['Styles', '/styles/', 'modify'],
    'support' => ['Support', '/support/', 'home'],
    'supportact' => ['Request Action', '', 'support'],
    'supportappend' => ['Append to Request', '', 'support'],
    'supporthelp' => ['Request Board', '/support/help.bml', 'support'],
    'supportnotify' => ['Notification Settings', '/support/changenotify.bml', 'support'],
    'supportscores' => ['High Scores', '/support/highscores.bml', 'support'],
    'supportsubmit' => ['Submit Request', '/support/submit.bml', 'support'],
    'textmessage' => ['Send Text Message', '/tools/textmessage.bml', 'home'],
    'transfercomm' => ['Transfer Community', '/community/transfer.bml', 'managecommunity'],
    'translate' => ['Translation Area', '/translate/', 'home'],
    'translateteams' => ['Translation Teams', '/translate/teams.bml', 'translate'],
    'unsubscribe' => ['Unsubscribe', '/unsubscribe.bml', 'home'],
    'utf8convert' => ['UTF-8 Converter', '/utf8convert.bml', 'manage'],
    'yourlayers' => ['Your Layers', '/customize/advanced/layers.bml', 'advcustomize'],
    'yourstyles' => ['Your Styles', '/customize/advanced/styles.bml', 'advcustomize'],
);

# include the local crumbs info
eval { require "crumbs-local.pl" };
die $@ if $@ && $! != ENOENT;

1;
