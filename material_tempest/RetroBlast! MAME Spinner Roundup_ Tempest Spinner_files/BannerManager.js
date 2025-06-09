function FlashInstalled()
{
	result = false;
	if (navigator.mimeTypes && navigator.mimeTypes["application/x-shockwave-flash"])
	{
		result = navigator.mimeTypes["application/x-shockwave-flash"].enabledPlugin;
	}
	else if (document.all && (navigator.appVersion.indexOf("Mac")==-1))
	{
		// IE Windows only -- check for ActiveX control, have to hide code in eval from Netscape (doesn't like try)
		eval ('try {var xObj = new ActiveXObject("ShockwaveFlash.ShockwaveFlash");if (xObj)	result = true; xObj = null;	} catch (e)	{}');
	}
	return result;
}

function GetFlashHTML(url,width,height)
{
	var htm = '<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"';
	htm += '  codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0" ';
	htm += ' WIDTH=' + width + ' HEIGHT=' + height + '>';
	htm += ' <PARAM NAME=movie VALUE="' + url + '"> <PARAM NAME=quality VALUE=high> <PARAM NAME=bgcolor VALUE=#FFFFFF>  '; 
	htm += ' <EMBED src="' + url + '" quality=high bgcolor=#FFFFFF  ';
	htm += ' swLiveConnect=FALSE WIDTH=' + width + ' HEIGHT=' + height;
	htm += ' TYPE="application/x-shockwave-flash" PLUGINSPAGE="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash">';
	htm += ' </EMBED></OBJECT>';
	return htm;
}

function BannerMgr_Switch(imageObj,kind,criteria)
{
	var banObj = this.GetBanner(kind,criteria);
	if (banObj != null)
	{
		imageObj.src = banObj.imgSrc;
		this.SetAnchorRef(imageObj.name+"Ref",banObj.ref);
	}
}

function BannerMgr_SetAnchorRef(name,ref)
{
	for (var i=0;i<document.anchors.length;i++)
	{
		if (document.anchors[i].name == name)
		{
			document.anchors[i].href = ref;
			break;
		}
	}
}

function BannerMgr_GetBanner(kind, criteriaStr)
{
	var banArray = this.banners[kind];
	var possibles = new Array();
	var result = null;
	
	for (var i=0;i<banArray.length;i++)
	{
		var criteria = criteriaStr.split(",");
		
		var matches = false;
		for (var j=0;j<criteria.length;j++)
		{
			if ((criteria[j]=="all") || (banArray[i].keywords.indexOf(criteria[j]) >= 0))
			{
				matches = true;
			}
			else
				matches = false;
		}
		if (matches)
			possibles[possibles.length] = banArray[i];
	}
	
	
	if (possibles.length > 0)
	{
		var choice = Math.floor(Math.random()*possibles.length);
		result = possibles[choice];
	}

	return result;	
}

function BannerMgr_Add(kind, keywords, imgSrc, altText, ref, flashSrc)
{
	var banArray = this.banners[kind];
	var banObj = new Object();
	banObj.name = "ban" + banArray.length;
	banObj.keywords = keywords;
	banObj.imgSrc = imgSrc;
	banObj.altText = altText;
	banObj.ref = ref;
	
	if (arguments.length > 5)
		banObj.flashSrc = flashSrc;
	else
		banObj.flashSrc = null;
	
	banArray[banArray.length] = banObj;
}

function BannerMgr_WriteBanner(kind,criteria)
{
	var htm = this.GetBannerHTML(kind,criteria);
	document.write(htm);

}

function BannerMgr_GetBannerHTML(kind,criteria)
{
	var banObj = this.GetBanner(kind,criteria);
	var wh = this.GetWidthHeight(kind);
	
	var htm = '';
	if (banObj.flashSrc && FlashInstalled())
	{
		htm = GetFlashHTML(banObj.flashSrc+"?link="+banObj.ref,wh.width,wh.height);
	}
	else
	{
		htm += '<a name="' + banObj.name + 'Ref" href="' + banObj.ref + '" target="_blank">';
		htm += '<img name="' + banObj.name + '" src="' + banObj.imgSrc + '" width=';
		htm += wh.width + ' height=' + wh.height + ' onerror="gBannerMgr.Switch(this,' + kind + ',\'local,' + criteria + '\')" ';
		htm += 'alt="' + banObj.altText + '" border=0></a>';

		// support for airplane banner
		if (kind==BannerMgr.BAN)
		{
			gBannerName = banObj.name;
			gBannerLinkName = banObj.name;
			gBannerLinkURL = banObj.ref;
		}
	}

	return htm;
}

function BannerMgr_GetWidthHeight(kind)
{
	var returnObj = new  Object();
	switch(kind)
	{
		case 0:
			returnObj.width = 468;
			returnObj.height = 60;
			break;
		case 1:
			returnObj.width = 88;
			returnObj.height = 31;
			break;
		case 2:
			returnObj.width = 115;
			returnObj.height = 80;
			break;
	}
	return returnObj;		
}

function BannerMgr()
{
	this.banners = new Array( new Array(), new Array(),new Array() );
	// Methods
	this.GetWidthHeight = BannerMgr_GetWidthHeight;
	this.WriteBanner = BannerMgr_WriteBanner;
	this.Add = BannerMgr_Add;
	this.GetBanner = BannerMgr_GetBanner;
	this.SetAnchorRef = BannerMgr_SetAnchorRef;
	this.Switch = BannerMgr_Switch;
	this.GetBannerHTML = BannerMgr_GetBannerHTML;
}
BannerMgr.BAN = 0;
BannerMgr.BTN = 1;
BannerMgr.BTN2X = 2;

var gBannerMgr = new BannerMgr();

// BANNER ADS
// RetroBlast! Ad Banners
//gBannerMgr.Add(BannerMgr.BAN, "local,general", "http://retroblast.com/banners/Retroblast2.gif", "RetroBlast! Retrogaming News and Reviews", "http://retroblast.com");
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/Retroblast1.gif", "RetroBlast! Retrogaming News and Reviews", "http://retroblast.com");
// Dream Authentics Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/dauth_banner_1.gif", "Your dream arcade cabinet, direct from Dream Authentics", "http://www.dreamauthentics.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/dauth_act_banner_1.gif", "Your dream arcade cabinet, direct from Dream Authentics", "http://www.dreamauthentics.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/dauth_act_banner_1.gif", "Your dream arcade cabinet, direct from Dream Authentics", "http://www.dreamauthentics.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/dauth_banner_1s.gif", "Your dream arcade cabinet, direct from Dream Authentics", "http://www.dreamauthentics.com/");
// MAMERoom Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/MAMERoom.gif", "Build your own arcade cabinet with plans from MAMERoom.com!", "http://www.mameroom.com/order_uaII.asp?affid=A220");
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/mameroombanner_blue.jpg", "MAMERoom, The Ultimate Gaming Experience", "http://www.mameroom.com/order_uaII.asp?affid=A220");
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/MAMERoom.gif", "MAMERoom, The Ultimate Gaming Experience", "http://www.mameroom.com/order_uaII.asp?affid=A220", "http://www.cybertechdesign.net/mameroom/images/media/banner_468x60.swf");
// X-Gaming Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://www.xgaming.com/Rotate1.php?id=79046", "X-Arcade - Classic Arcade Gaming For Any Game System", "http://www.x-arcade.com/landingpage.shtml?kbid=79046");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://xgaming.com/ShowBanner.php?id=79046&img=468x60.jpg", "X-Arcade - Classic Arcade Gaming For Any Game System", "http://www.x-arcade.com/htm/cabinet.shtml?kbid=79046&img=468x60.jpg");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://xgaming.com/ShowBanner.php?id=79046&img=468x60.jpg", "X-Arcade - Classic Arcade Gaming For Any Game System", "http://www.x-arcade.com/htm/cabinet.shtml?kbid=79046&img=468x60.jpg");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://xgaming.com/ShowBanner.php?img=17&id=79046", "Relive the Arcade Experience - X-Arcade", "http://www.x-arcade.com/landingpage.shtml?kbid=79046", "http://www.x-arcade.com/banners/affiliate/banner1.swf");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://xgaming.com/ShowBanner.php?img=17&id=79046", "Relive the Arcade Experience - X-Arcade", "http://www.x-arcade.com/landingpage.shtml?kbid=79046", "http://www.x-arcade.com/banners/affiliate/banner1.swf");
// SlikStik Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ss_ledanim1.gif", "SlikStik: The Ultimate Arcade Controller", "http://www.slikstik.com/default.aspx?Affiliate=139");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ss_banner1.jpg", "SlikStik: The Ultimate Arcade Controller", "http://www.slikstik.com/default.aspx?Affiliate=139");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ss_anim1.gif", "SlikStik: The Ultimate Arcade Controller", "http://www.slikstik.com/default.aspx?Affiliate=139");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ss_anim2.gif", "SlikStik: The Ultimate Arcade Controller", "http://www.slikstik.com/default.aspx?Affiliate=139");
// ArcadeGames4U Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ag4u_banner_1.jpg", "Find your perfect arcade cab at ArcadeGames4U.com", "http://www.arcadegames4u.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ag4u_banner_2.jpg", "Find your perfect arcade cab at ArcadeGames4U.com", "http://www.arcadegames4u.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ag4u_banner_3.jpg", "Find your perfect arcade cab at ArcadeGames4U.com", "http://www.arcadegames4u.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/ag4u_banner_4.jpg", "Find your perfect arcade cab at ArcadeGames4U.com", "http://www.arcadegames4u.com/");
// Quasimoto Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/qm_banner_1.gif", "Quasimoto - Revolutionizing Arcade Systems", "http://www.quasimoto.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/qm_banner_1.gif", "Quasimoto - Revolutionizing Arcade Systems", "http://www.quasimoto.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/qm_banner_1.gif", "Quasimoto - Revolutionizing Arcade Systems", "http://www.quasimoto.com/");
// Dream Arcades Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/da_banner.gif", "Dream Arcades Arcade Cabinets", "http://www.dreamarcades.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/da_banner.gif", "Dream Arcades Arcade Cabinets", "http://www.dreamarcades.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/da_banner.gif", "Dream Arcades Arcade Cabinets", "http://www.dreamarcades.com/");
// Game Room Magazine
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gmr_banner_1.gif", "GameRoom Magazine", "http://www.gameroommagazine.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gmr_banner_1.gif", "GameRoom Magazine", "http://www.gameroommagazine.com/");
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gmr_banner_1.gif", "GameRoom Magazine", "http://www.gameroommagazine.com/");
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gmr_banner_1.gif", "GameRoom Magazine", "http://www.gameroommagazine.com/");
// The Stinger Report
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/stinger_banner1.gif", "The Stinger Report Newsletter", "http://www.thestingerreport.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/stinger_banner1.gif", "The Stinger Report Newsletter", "http://www.thestingerreport.com/");
// Groovy Game Gear Ads
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gggbanner.jpg", "Groovy Game Gear, Be a Control Freak", "http://www.groovygamegear.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gggbanner.jpg", "Groovy Game Gear, Be a Control Freak", "http://www.groovygamegear.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/gggbanner.jpg", "Groovy Game Gear, Be a Control Freak", "http://www.groovygamegear.com/");
// PinGame Journal
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/pgj_banner3.gif", "PinGame Journal, Covering the World of Pinball", "http://www.pingamejournal.com/");
// MAME Marquees Ads
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/mm_banner_1.jpg", "Marquees, Sideart, Overlays and more at MAME Marquees", "http://www.mamemarquees.com/");
// DreamHost Ads
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/dreamhost_468x60-d.gif", "DreamHost Web Site Hosting", "http://www.dreamhost.com/rewards.cgi?retroblast");
//gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/dreamhost_468x60-e.gif", "DreamHost Web Site Hosting", "http://www.dreamhost.com/rewards.cgi?retroblast");
// Act-Labs
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/act_large.gif", "Act-Labs, When a Toy Just Won't Do", "http://www.act-labs.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/actlabs_oilhead.gif", "Act-Labs, When a Toy Just Won't Do", "http://www.act-labs.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/actlabs_oilhead.gif", "Act-Labs, When a Toy Just Won't Do", "http://www.act-labs.com/");
// Arcade-in-a-box - added July 02, 2006
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/arcadeinabox/468x60-rb.jpg", "Relive Your Childhood", "http://www.arcadeinabox.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/arcadeinabox/468x60-rb.jpg", "Relive Your Childhood", "http://www.arcadeinabox.com/");
gBannerMgr.Add(BannerMgr.BAN, "general", "http://retroblast.com/banners/arcadeinabox/468x60-rb.jpg", "Relive Your Childhood", "http://www.arcadeinabox.com/");