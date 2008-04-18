require "rexml/document"
require "kconv.rb"
require "CGI"
include REXML

$KCODE = "s"

HEADER = '<HTML><HEAD><meta name="GENERATOR" content="Microsoft&reg; HTML Help Workshop 4.1"><!-- Sitemap 1.0 --></HEAD><BODY><OBJECT type="text/site properties"></OBJECT>'
FOOTER = '</BODY></HTML>'

def createProjectFile(prjname, basedir, title)
    
    books = collectBooks(basedir)
    
    keyword_index = {}
    
    #TOC
    fd_toc = open(prjname+'.hhc', "w"); fd_toc.puts(HEADER+"\n<UL>")
    books.each() do |bookpath|
        print "processing:"+bookpath+"\n"
        parseBookToc(bookpath, fd_toc, keyword_index)
    end
    fd_toc.puts("</UL>\n"+FOOTER); fd_toc.close()
    
    #Keywords
    fd_idx = open(prjname+'.hhk', "w"); fd_idx.puts(HEADER+"\n<UL>")
    keyword_index.keys.sort().each() do |name|
        fd_idx.puts(formatIndexItem(name, keyword_index[name]))
    end
    fd_idx.puts("</UL>\n"+FOOTER); fd_idx.close()
    
    #project
    assetsexplise = /^.*(\/Samples\/.+|\/Dump\/.+|\/.*\/(help_search_index\.xml|help_toc\.xml|help\.map))$/
    
    welcome_page = Document.new(File.new(basedir + "/_sharedassets/help_toc.xml")).root.attributes['defaulthelp']
    
    file = open(prjname+'.hhp', 'w')
    file.puts('[OPTIONS]')
    file.puts('Compatibility=1.1 or later')
    file.puts('Compiled file=' + prjname+'.chm')
    file.puts('Contents file=' + prjname+'.hhc')
    file.puts('Display compile progress=Yes')
    file.puts('Default topic=' + basedir + '/_sharedassets/' + welcome_page)
    file.puts('Full-text search=Yes')
    file.puts('Index file=' + prjname+'.hhk')
    file.puts('Language=0x411 “ú–{Œê')  #TODO to be i18n
    file.puts('Title=' + title)
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

def formatTopicItem(name, href)
    out = '<LI><OBJECT type="text/sitemap">'
    out += sprintf('<param name="Name" value="%s">', name)
    if href != nil then
        out += sprintf('<param name="Local" value="%s">', href)
    end
    out += "</OBJECT>"
    return out
end

def __notinuse__formatIndexItem(name, details)
    #This is like one provided HtmlHelpWorkshop IDE, but invalid !
    out = '<LI><OBJECT type="text/sitemap">'
    out += sprintf('<param name="Name" value="%s">', name)
    details.each() do |det|
        out += sprintf('<param name="Name" value="%s">', det['placement'])
        out += sprintf('<param name="Local" value="%s">', det['href'])
    end
    out += "</OBJECT>"
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

def collectBooks(basedir)
    books = []
    Dir.foreach(basedir + "/Help") do |bookname|
        bookpath = basedir + "/Help/" + bookname
        if File.ftype(bookpath) == 'directory' and File.exist?(bookpath + "/help_toc.xml") then
            print "found:#{bookpath}/help_toc.xml\n"
            sk = Document.new(File.new(bookpath + "/help_toc.xml")).root.attributes['sort']
            books.push({'path'=>bookpath, 'sortkey'=>sk})
        end
    end
    books.sort!() do |a,b|
        Integer(a['sortkey'].split('_')[1]) <=> Integer(b['sortkey'].split('_')[1])
    end
    return books.map() do |e|
        e['path']
    end
end

def parseBookToc(bookpath, fd_toc, keyword_index)
    olv = 1
    book = Document.new(File.new(bookpath + "/help_toc.xml")).root
    title = CGI.escapeHTML(book.attributes['title'].kconv(Kconv::SJIS, Kconv::UTF8))
    
    fd_toc.puts "\t"*olv + formatTopicItem(title, bookpath+"/"+firstpageOfBook(book))
    
    clv = 0
    docpath = [title]
    book.elements.each() do |topic|
        name = CGI.escapeHTML(topic.attributes['name'].kconv(Kconv::SJIS, Kconv::UTF8))
        if topic.attributes['href'] != nil then
            href = bookpath + "/" + topic.attributes['href']
        else
            href = nil
        end
        
        #coordinate indent level and document path
        level = Integer(topic.name[-1, 1])
        if level == clv then
            docpath.pop()
        elsif level < clv then
            #level down / to parent up
            docpath.pop()
            while level < clv do
                clv -= 1
                fd_toc.puts "\t"*(clv+olv) + '</UL>'
                docpath.pop()
            end
        else
            #level up / into child
            while level > clv do
                fd_toc.puts "\t"*(clv+olv) + '<UL>'
                clv += 1
            end
        end
        docpath.push(name)
        
        #write toc entry
        fd_toc.puts "\t"*(level+olv) + formatTopicItem(name, href)
        
        #record entry into keyword dict only if it is unique href
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
    while 0 < clv do
        clv -= 1
        fd_toc.puts "\t"*(clv+olv) + '</UL>'
    end
end

def firstpageOfBook(book)
    book.elements.each() do |topic|
        page = topic.attributes['href']
        return page unless page == nil
    end
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

if ARGV.length < 3 then
    print "usage:ruby parsetoc.rb <project-name> <base-dir> <document-title>\n"
    exit(0)
end

prjname = ARGV[0]
basedir = ARGV[1]
title   = ARGV[2]
createProjectFile(prjname, basedir, title)
