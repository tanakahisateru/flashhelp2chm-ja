require "kconv.rb"
require "fileutils.rb"

$KCODE='SJIS'

def convertFile(orgpath, targetpath)
    print orgpath + "\n"
    if (orgpath =~ /.*\.html?/) != nil then
        text = ""
        open(orgpath, 'r') do |fin|
            $KCODE='UTF8'
            utext = fin.read()
            utext.gsub!(/titleBar_setSubTitle\("Class.*?([\w\d]+?)"\)\;/){|hit|
                'titleBar_setSubTitle("Class ' + $1 + '");'
            }
            utext.gsub!(/titleBar_setSubTitle\("Interface.*?([\w\d]+?)"\)\;/){|hit|
                'titleBar_setSubTitle("Interface ' + $1 + '");'
            }
            utext.gsub!("\342\204\242", '&trade;')
            utext.gsub!("\302\256", '&reg;')
            
            text = utext.tosjis
            $KCODE='SJIS'
            #replace meta tag
            text.sub!(
                /\<meta\s+http-equiv="Content-Type"\s+content="text\/html;\s*charset=.+?"\>/i,
                '<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">')
            #replace : in <a name> to ()
            text.gsub!(/#(event|style|effect):([^"']+)/){|hit|
                "#" + $2 + "(" + $1 + ")"
            }
            text.gsub!(/name\="(event|style|effect):([^"]+)/){|hit|
                'name="' + $2 + "(" + $1 + ")"
            }
            
            #remove XML header
            text.gsub!(/<\?xml.*?\?>/, '')
            
            #remove frameset operation
            text.gsub!(/&nbsp;\|&nbsp;<a[^>]+id="framesLink1">.*?<\/a><a[^>]+id="noFramesLink1">.*?<\/a>/,
                '<a href="" id="framesLink1"></a><a href="" id="noFramesLink1"></a>')
            
            text.gsub!(/(<th\s+class="summaryTableOwnerCol">)(.*?)(<\/th>)/) {|hit|
                $1 + '<span style="white-space:nowrap;">' + String($2) + '</span>' + $3
            }
            
            #remove search and navigation
            text.gsub!(/<td[^>]+class="titleTableTitle"/m){|hit|
                $& + ' colspan="3"'
            }
            text.gsub!(/<td[^>]+class="titleTableSearch".*?<\/td>/m, '')
            text.gsub!(/<td[^>]+class="titleTableTopNav".*?<\/td>/m, '')
            
            #remove livedocs footer
            text.gsub!(/<!--\s*?begin\s+?:\s+?add techNotes\s*?-->.+?<!--\s*?End SiteCatalyst.*-->/m, '')
            text.gsub!(/<div[^>]+class="feedbackLink".+?gotoLiveDocs.+?<\/div>/m, '')
            
            #remove tracking javascript
            text.gsub!(/<!--BEGIN IONCOMMENTS-->.*(<\/body><\/html>)/m){|hit|
                $1
            }
            
            #fix buggy script tag
            text.gsub!(/(<script .*?>)\n?(<\!--\s*)([^\n])/m){|hit|
                $1 + "\n" + $2 + "\n" + $3
            }
            text.gsub!(/([^\n])(\s*-->)\n?(<\/script>)/m){|hit|
                $1 + "\n//" + $2 + "\n" + $3
            }
            
        end
        open(targetpath, 'w') do |fout|
            fout.write(text)
        end
    else
        FileUtils.cp(orgpath, targetpath)
    end
end

def convert(orgpath, targetpath)
    t = File.ftype(orgpath)
    if t == 'file' then
        convertFile(orgpath, targetpath)
    elsif t == 'directory' then
        FileUtils.mkdir(targetpath) unless File.exists?(targetpath)
        Dir.foreach(orgpath) do |subfile|
            if subfile[0,1] != '.' then
                convert(orgpath + '/' + subfile, targetpath + '/' + subfile)
            end
        end
    end
end

convert(ARGV[0], ARGV[1])
