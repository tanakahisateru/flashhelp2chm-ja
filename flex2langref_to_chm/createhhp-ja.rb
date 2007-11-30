def createProjectFile(prjname, basedir)
	
	packagelist = scanPackageTree(basedir)

	createContentsFile(prjname+'.hhc', basedir, packagelist)
	createIndexFile(prjname+'.hhk', basedir, packagelist)
	
	assetsexplise = /^$/
	
	file = open(prjname+'.hhp', 'w')
	file.puts('[OPTIONS]')
	file.puts('Compatibility=1.1 or later')
	file.puts('Compiled file=' + prjname+'.chm')
	file.puts('Contents file=' + prjname+'.hhc')
	file.puts('Display compile progress=Yes')
	file.puts('Default topic=' + basedir + '/package-summary.html')
	file.puts('Full-text search=Yes')
	file.puts('Index file=' + prjname+'.hhk')
	file.puts('Language=0x411 日本語')
	file.puts('Title=' + getIndexTitle(basedir))
	file.puts('')
	file.puts('')
	file.puts('[INFOTYPES]')
	file.puts('')
	file.puts('[FILES]')
	collectAssets(basedir, assetsexplise).each() do |path|
		file.puts(path)
	end
	file.puts('')
	file.close()
end

CONTENTS_TITLE = 'Adobe Flex 2 リファレンスガイド'

def getIndexTitle(basedir)
	
	return CONTENTS_TITLE
	
	title = ""
	open(basedir + '/index.html', 'r') do |fh|
		fh.read() =~ /\<title\>\n*(.+?)\n*\<\/title\>/i
		title = $1
	end
	return title
end

def collectAssets(assetsdir, assetsexplise)
	assets = []
	Dir.foreach(assetsdir) do |asset|
		assetpath = assetsdir + '/' + asset
		if File.ftype(assetpath) == 'file' then
			assets.push(assetpath) unless assetsexplise =~ assetpath
		elsif File.ftype(assetpath) == 'directory' and asset[0,1] != '.' then
			assets.concat(collectAssets(assetpath, assetsexplise))
		end
	end
	return assets
end

HEADER = '<HTML><HEAD><meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1"><!-- Sitemap 1.0 --></HEAD><BODY><OBJECT type="text/site properties"></OBJECT>'
FOOTER = '</BODY></HTML>'

def createContentsFile(filename, basedir, packagelist)
	
	file = open(filename, 'w')
	file.puts HEADER
	
	file.puts "<UL>"
	packagelist.each() do |grp|
		file.puts "\t" * 0 + formatTopicItem(grp['name'], basedir+'/'+grp['file'])
		file.puts "\t" * 0 + "<UL>"
		grp['packages'].each() do |pkg|
			file.puts "\t" * 1 + formatTopicItem(pkg['name'], basedir+'/'+pkg['file'])
			file.puts "\t" * 1 + "<UL>"
			pkg['classes'].each() do |cls|
				file.puts "\t" * 2 + formatTopicItem(cls['name'], basedir+'/'+cls['file'])
				file.puts "\t" * 2 + "<UL>"
				cls['details'].each() do |det|
					file.puts "\t" * 3 + formatTopicItem(det, basedir+'/'+cls['file']+'#'+det.gsub(/\:/, '%3A'))
				end
				file.puts "\t" * 2 + "</UL>"
			end
			file.puts "\t" * 1 + "</UL>"
		end
		file.puts "\t" * 0 + "</UL>"
	end
	file.puts "</UL>"
	
	file.puts FOOTER
	file.close()
end

def createIndexFile(filename, basedir, packagelist)
	
	file = open(filename, 'w')
	file.puts HEADER
	
	indexes = {}
	
	packagelist.each() do |grp|
		grp['packages'].each() do |pkg|
			addKeywordToIndex(indexes, pkg['name'], pkg['name'], basedir+'/'+pkg['file'])
			pkg['classes'].each() do |cls|
				addKeywordToIndex(indexes, cls['name'], pkg['name']+'.'+cls['name'], basedir+'/'+cls['file'])
				cls['details'].each() do |det|
					addKeywordToIndex(indexes, det, pkg['name']+'.'+cls['name']+'.'+det, basedir+'/'+cls['file']+'#'+det.gsub(/\:/, '%3A'))
				end
			end
		end
	end
	
	file.puts "<UL>"
	indexes.keys.sort.each() do |keyword|
		file.puts "\t" + formatIndexItem(keyword, indexes[keyword])
	end
	file.puts "</UL>"
	
	file.puts FOOTER
	file.close()
end

def addKeywordToIndex(indexes, keyword, detail, file)
	if indexes[keyword] == nil then indexes[keyword] = {} end
	indexes[keyword][detail] = file
end

PACKAGE_LIST_FILENAME   = 'package-list.html'

def scanPackageTree(basedir)
	#rxpkg = /\<A\s+HREF\=\"([\w\d\-\/]+?)\/package\-frame\.html\"\s+target\=\"packageFrame\"\>([\w\d\.]+)\<\/A\>/i
	#rxcls = /\<A\s+HREF\=\"([^\.][\w\d\-\.]+?)\"(\s+title\=\".+\")?\s+target\=\"classFrame\"\>(\<I\>)?([\w\d\.]+)(\<\/I\>)?\<\/A\>/i
	
	rxgrp = /\<a style\=\"color\:black\".* href\=\"([\w\d\-\/\#\.]+?)\"\>([^\<\>]+)\<\/a\>/
	rxpkg = /\<a.* onclick\=\"(.*?)\".* href\=\"([\w\d\-\/\#\.]+?)\"\>([^\<\>]+)\<\/a\>/
	rxapx = /\<a.* href\=\"([\w\d\-\/\#\.]+?)\"\>([^\<\>]+)\<\/a\>/
	
	rxclick = /loadClassListFrame\(\'([^\'\"]+)\'\)/
	
	rxetc = /\<a href\=\"(package\.html\#[\w\d\-\(\)\.]+?)\"\>([^\<\>]+)\<\/a\>/
	rxcls = /\<a href\=\"([\w\d\-\(\)\.\/]+?)\".*\>(\<i\>)?([^\<\>]+)(\<\/i\>)?\<\/a\>/
	
	packagelist = []
	IO.foreach(basedir + '/' + PACKAGE_LIST_FILENAME) do | line |
		if (line =~ rxgrp) != nil then
			gpfile = $1
			gpname = $2
			print "<<group : #{gpname}>>\n"
			packagelist.push({'name'=>gpname, 'file'=>gpfile, 'packages'=>[]});
		elsif (line =~ rxpkg) != nil then
			oncl = $1
			pkgdet  = $2
			pkgname = $3
			if (oncl =~ rxclick) != nil then
				print "  #{pkgname}\n"
				classes = []
				pkgcl = $1
				pkgdir = ""
				if (pkgcl =~ /^(([\w\d\-\.]+\/)+)[\w\d\-\.\#]*$/) != nil then
					pkgdir = $1
				end
				IO.foreach(basedir + '/' + pkgcl) do | line |
					if (line =~ rxetc) != nil then
						classfile = $1
						classname = $2
						print "    #{pkgname}.#{classname}\n"
						classes.push({'name'=>classname, 'file'=>pkgdir+classfile, 'details'=>[]})
					elsif (line =~ rxcls) != nil then
						classfile = $1
						classname = $3
						print "    #{pkgname}.#{classname}\n"
						details = scanClassDocument(basedir+'/'+pkgdir+classfile)
						classes.push({'name'=>classname, 'file'=>pkgdir+classfile, 'details'=>details})
					end
				end
				packagelist[-1]['packages'].push({'name'=>pkgname, 'file'=>pkgdet, 'classes'=>classes})
			else
				print "  appendix : #{pkgname}\n"
				packagelist[-1]['packages'].push({'name'=>pkgname, 'file'=>pkgdet, 'classes'=>[]})
			end
		elsif (line =~ rxapx) != nil then
			pkgdet  = $1
			pkgname = $2
			print "  appendix : #{pkgname}\n"
			packagelist[-1]['packages'].push({'name'=>pkgname, 'file'=>pkgdet, 'classes'=>[]})
		end
	end
	return packagelist
end

def scanClassDocument(file)
	scanstarts = false
	anchors = []
	IO.foreach(file) do |line|
		if (line =~ /\<a name\=\"([^\"]+)\"\>/i) != nil then
			aname = $1
			if (aname !~ /^[a-z]\w*(Detail|Summary)$/) then
				#print "#{aname}\n"
				anchors.push(aname)
			end
		end
	end
	return anchors
end

def formatTopicItem(name, href)
	out = '<LI><OBJECT type="text/sitemap">'
	out += sprintf('<param name="Name" value="%s">', name)
	if href != nil then
		out += sprintf('<param name="Local" value="%s">', href)
	end
	out += "</OBJECT>"
	return out
end

def formatIndexItem(name, details)
	out = '<LI><OBJECT type="text/sitemap">'
	out += sprintf('<param name="Name" value="%s">', name)
	details.keys.each() do |det|
		out += sprintf('<param name="Name" value="%s">', det)
		out += sprintf('<param name="Local" value="%s">', details[det])
	end
	out += "</OBJECT>"
	return out
end

createProjectFile(ARGV[0], ARGV[1])
