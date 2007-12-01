require "rexml/document"
require "kconv.rb"
include REXML

def header()
	return '<HTML><HEAD><meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1"><!-- Sitemap 1.0 --></HEAD><BODY><OBJECT type="text/site properties"></OBJECT>'
end

def footer()
	return '</BODY></HTML>'
end

def formatTopicItem(name, href, bookpath)
	out = '<LI><OBJECT type="text/sitemap">'
	out += sprintf('<param name="Name" value="%s">', name)
	if href != nil then
		out += sprintf('<param name="Local" value="%s/%s">', bookpath, href)
	end
	out += "</OBJECT>"
	return out
end


def firstpageOfBook(book)
	book.elements.each() do |topic|
		page = topic.attributes['href']
		return page unless page == nil
	end
end

def parseBooks(bookpath, file)
	
	print bookpath + "/Reference.xml "
	
	book = Document.new(File.new(bookpath + "/Reference.xml")).root
	
	print  book.attributes['name'].tosjis + "\n"
	
	title = book.attributes['name'].tosjis
	file.puts "\t" + formatTopicItem(title, "default.html", bookpath)
	
	file.puts "\t" + "<UL>"
	
	topics = []
	book.elements.each("topic") do |topic|
		topics.push(topic)
	end
	topics.sort!() do |a,b|
		a.attributes['name'].upcase <=> b.attributes['name'].upcase
	end
	
	clv = 0
	topics.each() do |topic|
		file.puts "\t" * 2 + formatTopicItem(
			topic.attributes['name'].tosjis,
			topic.attributes['location'],
			bookpath
		)
		file.puts "\t" * 2 + '<UL>'
		
		topic.elements.each("subtopic") do |subtopic|
			file.puts "\t" * 3 + formatTopicItem(
				subtopic.attributes['name'].tosjis,
				topic.attributes['location'] + "#" + subtopic.attributes['id'].tosjis,
				bookpath
			)
		end
		file.puts "\t" * 2 + '</UL>'
	end
	
	file.puts "\t" + '</UL>'
end

def createTocFile(filename, books)
	
	file = open(filename, 'w')
	file.puts header()
	
	file.puts "<UL>"
	books.each() do |bookpath|
		parseBooks(bookpath, file)
	end
	file.puts "</UL>"
	
	file.puts footer()
	file.close()
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

def createProjectFile(filename, title, toc, target, toppage, assetsdir, assetsexplise)
	file = open(filename, 'w')
	file.puts('[OPTIONS]')
	file.puts('Compatibility=1.1 or later')
	file.puts('Compiled file=' + target)
	file.puts('Contents file=' + toc)
	file.puts('Display compile progress=Yes')
	file.puts('Default topic=' + toppage) unless toppage == nil
	file.puts('Full-text search=Yes')
	file.puts('Language=0x411 “ú–{Œê')
	file.puts('Title=' + title)
	file.puts('')
	file.puts('')
	file.puts('[INFOTYPES]')
	file.puts('')
	file.puts('[FILES]')
	collectAssets(assetsdir, assetsexplise).each() do |path|
		file.puts(path)
	end
	file.puts('')
	file.close()
end

if ARGV.length < 3 then
	print "usage:ruby parsetoc.rb <project-name> <base-dir> <document-title>\n"
	exit(0)
end

prjname = ARGV[0]
basedir = ARGV[1]
title   = ARGV[2]

createTocFile(prjname+'.hhc', [
		basedir + "/HTML",
		basedir + "/CSS",
		basedir + "/JavaScript"
])
	
createProjectFile(
	prjname+'.hhp', title,
	prjname+'.hhc', prjname+'.chm',
	'index.html',
	basedir, /^(.*\.xml|.*(lookupMod|ASP|CF|JIS|JSP|PHP|SQL|Usable|XML|XSLT).*)$/
)

