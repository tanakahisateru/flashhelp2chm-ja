require "rexml/document"
require "kconv.rb"
require "CGI"
include REXML

def header()
    return '<HTML><HEAD><meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1"><!-- Sitemap 1.0 --></HEAD><BODY><OBJECT type="text/site properties"></OBJECT>'
end

def footer()
    return '</BODY></HTML>'
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
    out = ""
    if details.length <= 1 then
        out += '<LI><OBJECT type="text/sitemap">'
        out += sprintf('<param name="Name" value="%s">', name)
        out += sprintf('<param name="Local" value="%s">', details[0]['href'])
        out += "</OBJECT>\n"
    else
        minelem = 100
        details.each() do |det|
            if minelem > det['placement'].size then
                minelem = det['placement'].size
            end
        end
        
        path_depth_to_remove = 0
        for col in 0...minelem
            has_diff = false
            prev_one = nil
            details.each() do |det|
                path = det['placement']
                if prev_one == nil then
                    prev_one = path[col]
                elsif path[col] != prev_one then
                    has_diff = true
                end
            end
            if has_diff then
                break
            end
            path_depth_to_remove += 1
        end
        
        details.each() do |det|
            out += '<LI><OBJECT type="text/sitemap">'
            if path_depth_to_remove == minelem then
                out += sprintf('<param name="Name" value="%s">', name)
            else
                out += sprintf('<param name="Name" value="%s (%s)">', name, det['placement'][path_depth_to_remove..-1].join(' '))
            end
            out += sprintf('<param name="Local" value="%s">', det['href'])
            out += "</OBJECT>\n"
        end
        
        #if path_depth_to_remove >= 1 then
        #   print sprintf("about %s : merge:%s(depth %d/%d)\n", name, details[0]['placement'][0...path_depth_to_remove].join(' '), path_depth_to_remove, minelem)
        #end
    end
    return out
end

def firstpageOfBook(book)
    book.elements.each() do |topic|
        page = topic.attributes['href']
        return page unless page == nil
    end
end

def parseBook(bookpath, file, keyword_index)
    
    print bookpath + "/Reference.xml "
    
    book = Document.new(File.new(bookpath + "/Reference.xml")).root
    title = CGI.escapeHTML(book.attributes['name'].tosjis)
    print title +"\n"
    
    idx_title = title.split(' ')
    idx_title.shift() if idx_title[0] == "O'REILLY"
    idx_title.pop() if idx_title[-1] == "リファレンス"
    
    file.puts "\t" + formatTopicItem(title, bookpath + "/default.html")
    
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
        name = CGI.escapeHTML(topic.attributes['name'].tosjis)
        href = bookpath + "/" + topic.attributes['location']
        file.puts "\t" * 2 + formatTopicItem(name, href)
        file.puts "\t" * 2 + '<UL>'
        
        appendKeywordIfUnique(keyword_index, name, [idx_title, name], href)
        
        topic.elements.each("subtopic") do |subtopic|
            sub_name = CGI.escapeHTML(subtopic.attributes['name'].tosjis)
            sub_href = href + "#" + subtopic.attributes['id'].tosjis
            file.puts "\t" * 3 + formatTopicItem(sub_name, sub_href)
            appendKeywordIfUnique(keyword_index, sub_name, [idx_title, name, sub_name], sub_href)
        end
        
        file.puts "\t" * 2 + '</UL>'
    end
    
    file.puts "\t" + '</UL>'
end

def appendKeywordIfUnique(keyword_index, name, docpath, href)
    if keyword_index[name] == nil then
        keyword_index[name] = []
    end
    is_newpage = true
    keyword_index[name].each() do |det|
        if det['href'] == href then
            is_newpage = false
            break
        end
    end
    if is_newpage then
        keyword_index[name].push({'placement'=>docpath[0...-1], 'href'=>href})
    end
end

def createContentsFiles(toc_filename, idx_filename, books)
    
    keyword_index = {}
    
    file = open(toc_filename, 'w')
    file.puts header()
    
    file.puts "<UL>"
    books.each() do |bookpath|
        parseBook(bookpath, file, keyword_index)
    end
    file.puts "</UL>"
    
    file.puts footer()
    file.close()
    
    #Keywords
    file = open(idx_filename, "w")
    file.puts header()
    
    file.puts "<UL>"
    keyword_index.keys.sort().each() do |name|
        file.puts(formatIndexItem(name, keyword_index[name]))
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

def createProjectFile(filename, title, toc, idx, target, toppage, assetsdir, assetsexplise)
    file = open(filename, 'w')
    file.puts('[OPTIONS]')
    file.puts('Compatibility=1.1 or later')
    file.puts('Compiled file=' + target)
    file.puts('Contents file=' + toc)
    file.puts('Display compile progress=Yes')
    file.puts('Default topic=' + toppage) unless toppage == nil
    file.puts('Full-text search=Yes')
    file.puts('Index file=' + idx)
    file.puts('Language=0x411 日本語')
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

createContentsFiles(prjname+'.hhc', prjname+'.hhk', [
    basedir + "/HTML",
    basedir + "/CSS",
    basedir + "/JavaScript"
])
    
createProjectFile(
    prjname+'.hhp', title,
    prjname+'.hhc', prjname+'.hhk',
    prjname+'.chm',
    'index.html',
    basedir, /^(.*\.xml|.*(lookupMod|ASP|CF|JIS|JSP|PHP|SQL|Usable|XML|XSLT).*)$/
)

