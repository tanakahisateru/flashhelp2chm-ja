require "CGI"

$KCODE="sjis"

def createProjectFile(prjname, basedir, title)
    
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
    file.puts('Language=0x411 “ú–{Œê')
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

def collectAssets(assetsdir, assetsexplise)
    assets = []
    Dir.foreach(assetsdir) do |asset|
        assetpath = assetsdir + '/' + asset
        if File.ftype(assetpath) == 'file' then
            assets.push(assetpath) unless (assetsexplise =~ assetpath) != nil
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
    
    keyword_index = {}
    
    packagelist.each() do |grp|
        grp['packages'].each() do |pkg|
            addKeywordToIndex(keyword_index,
                pkg['name'],
                "n/a",
                basedir+'/'+pkg['file'])
            pkg['classes'].each() do |cls|
                addKeywordToIndex(keyword_index,
                    cls['name'],
                    pkg['name'],
                    basedir+'/'+cls['file'])
                cls['details'].each() do |det|
                    addKeywordToIndex(keyword_index,
                        det,
                        cls['name']+" - "+pkg['name'],
                        basedir+'/'+cls['file']+'#'+det.gsub(/\:/, '%3A'))
                end
            end
        end
    end
    
    file.puts "<UL>"
    keyword_index.keys.sort.each() do |keyword|
        file.puts(formatIndexItem(keyword, keyword_index[keyword]))
    end
    file.puts "</UL>"
    
    file.puts FOOTER
    file.close()
end

def addKeywordToIndex(keyword_index, keyword, placement, href)
    if keyword_index[keyword] == nil then
        keyword_index[keyword] = []
    end
    keyword_index[keyword].push({'placement'=>placement, 'href'=>href})
end

PACKAGE_LIST_FILENAME = 'package-list.html'

def logfmt(str)
    return CGI.unescapeHTML(str).gsub(/&nbsp;/, " ")
end

def scanPackageTree(basedir)
    rxgrp = /<a style=\"color:black\".* href=\"([\w\d\-\/\#\.]+?)\">([^<>]+)<\/a>/
    rxpkg = /<a.* onclick=\"(.*?)\".* href=\"([\w\d\-\/\#\.]+?)\">([^<>]+)<\/a>/
    rxapx = /<a.* href=\"([\w\d\-\/\#\.]+?)\">([^<>]+)<\/a>/
    
    rxclick = /loadClassListFrame\(\'([^\'\"]+)\'\)/
    
    rxetc = /<a href=\"(package\.html\#[\w\d\-\(\)\.]+?)\">([^<>]+)<\/a>/
    rxcls = /<a href=\"([\w\d\-\(\)\.\/]+?)\".*\>(<i>)?([^<>]+)(<\/i>)?<\/a>/
    
    packagelist = []
    IO.foreach(basedir + '/' + PACKAGE_LIST_FILENAME) do | line |
        if (line =~ rxgrp) != nil then
            gpfile = $1
            gpname = $2
            print "<<group : #{logfmt(gpname)}>>\n"
            packagelist.push({'name'=>gpname, 'file'=>gpfile, 'packages'=>[]});
        elsif (line =~ rxpkg) != nil then
            oncl = $1
            pkgdet  = $2
            pkgname = $3
            if (oncl =~ rxclick) != nil then
                print "  #{logfmt(pkgname)}\n"
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
                        print "    #{logfmt(pkgname)}.#{logfmt(classname)}\n"
                        classes.push({'name'=>classname, 'file'=>pkgdir+classfile, 'details'=>[]})
                    elsif (line =~ rxcls) != nil then
                        classfile = $1
                        classname = $3
                        print "    #{logfmt(pkgname)}.#{logfmt(classname)}\n"
                        details = scanClassDocument(basedir+'/'+pkgdir+classfile)
                        classes.push({'name'=>classname, 'file'=>pkgdir+classfile, 'details'=>details})
                    end
                end
                packagelist[-1]['packages'].push({'name'=>pkgname, 'file'=>pkgdet, 'classes'=>classes})
            else
                print "  appendix : #{logfmt(pkgname)}\n"
                packagelist[-1]['packages'].push({'name'=>pkgname, 'file'=>pkgdet, 'classes'=>[]})
            end
        elsif (line =~ rxapx) != nil then
            pkgdet  = $1
            pkgname = $2
            print "  appendix : #{logfmt(pkgname).gsub(/&nbsp;/, " ")}\n"
            packagelist[-1]['packages'].push({'name'=>pkgname, 'file'=>pkgdet, 'classes'=>[]})
        end
    end
    return packagelist
end

def scanClassDocument(file)
    scanstarts = false
    anchors = []
    IO.foreach(file) do |line|
        line.scan(/\<a name\=\"([^\"]+)\"\>/i) { |hit|
            aname = hit[0]
            if (aname =~ /^([\w\d_]+)\(.*\)$/) != nil then
                newent = $1
                if anchors.include?(newent+"()") then
                    anchors.delete(newent+"()")
                end
            end
            if aname !~ /^[a-z_]\w*(Detail|Summary)$/ then
                #print "#{aname}\n"
                anchors.push(aname)
            end
        }
    end
    return anchors
end

#&nbsp; is not pure XML escape. it is valid in only text node.
def formatTopicItem(name, href)
    out = '<LI><OBJECT type="text/sitemap">'
    out += sprintf('<param name="Name" value="%s">', name.gsub(/&nbsp;/, " "))
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
        out += sprintf('<param name="Name" value="%s">', name.gsub(/&nbsp;/, " "))
        out += sprintf('<param name="Local" value="%s">', details[0]['href'])
        out += "</OBJECT>\n"
    else
        details.each() do |det|
            out += '<LI><OBJECT type="text/sitemap">'
            out += sprintf('<param name="Name" value="%s (%s)">', name.gsub(/&nbsp;/, " "), det['placement'])
            out += sprintf('<param name="Local" value="%s">', det['href'])
            out += "</OBJECT>\n"
        end
    end
    return out
end

if ARGV.length < 3 then
    print "usage:ruby parsetoc.rb <project-name> <base-dir> <document-title>\n"
    exit(0)
end

prjname = ARGV[0]
basedir = ARGV[1]
title   = ARGV[2]
createProjectFile(prjname, basedir, title)

