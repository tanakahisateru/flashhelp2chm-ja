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
            utext.gsub!(/titleBar_setSubTitle\(\"Class.*?([\w\d]+?)\"\)\;/){|hit|
                'titleBar_setSubTitle("Class ' + $1 + '");'
            }
            utext.gsub!(/titleBar_setSubTitle\(\"Interface.*?([\w\d]+?)\"\)\;/){|hit|
                'titleBar_setSubTitle("Interface ' + $1 + '");'
            }
            utext.gsub!("\342\204\242", '&trade;')
            utext.gsub!("\302\256", '&reg;')
            text = utext.tosjis
            $KCODE='SJIS'
            #replace meta tag
            text.sub!(
                /\<meta\s+http-equiv=\"Content-Type\"\s+content=\"text\/html;\s*charset=.+?\"\>/i,
                "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=shift_jis\">")
            #replace : in <a name> to ()
            text.gsub!(/#(event|style|effect):([^\"\']+)/){|hit|
                "#" + $2 + "(" + $1 + ")"
            }
            text.gsub!(/name\=\"(event|style|effect):([^\"]+)/){|hit|
                "name=\"" + $2 + "(" + $1 + ")"
            }
            
            #remove XML header
            text.gsub!(/<\?xml.*?\?>/, '')
            
            #remove frameset operation
            text.gsub!(/&nbsp;\|&nbsp;<a[^>]*id=\"framesLink1\">.*?<\/a><a[^>]*id=\"noFramesLink1\">.*?<\/a>/,
                '<a href="" id="framesLink1"></a><a href="" id="noFramesLink1"></a>')
            
            text.gsub!(/<th class=\"summaryTableOwnerCol\">(.*?)<\/th>/) {|hit|
                '<th class="summaryTableOwnerCol"><span style="white-space:nowrap;">' + String($1) + '</span></th>'
            }
            
            #remove search feature
            text.gsub!(/<form\s+.*?action=.*?search.*?>.+<\/form>/im, '')
            
            #remove livedocs footer
            text.gsub!(/<!--\s*?begin\s+?:\s+?add techNotes\s*?-->.+?<!--\s*?End SiteCatalyst.*-->/m, '')
            
            #####################################################
            # replace bad japanese translation
=begin
            text.gsub!(/\<div class\=\"summaryTableTitle\"\>Protected�v���p�e�B\<\/div\>/){|hit|
                '<div class="summaryTableTitle">�v���e�N�e�B�b�h�v���p�e�B</div>'
            }
            text.gsub!(/class\=\"showHideLinkImage\"\>�p������� Protected �v���p�e�B/){|hit|
                'class="showHideLinkImage">�p�������v���e�N�e�B�b�h�v���p�e�B'
            }
            text.gsub!(/\<div class\=\"summaryTableTitle\"\>�p�u���b�N Methods\<\/div\>/){|hit|
                '<div class="summaryTableTitle">�p�u���b�N���\�b�h</div>'
            }
            text.gsub!(/\<div class\=\"summaryTableTitle\"\>Protected Methods\<\/div\>/){|hit|
                '<div class="summaryTableTitle">�v���e�N�e�B�b�h���\�b�h</div>'
            }
            text.gsub!(/expanded\.gif\" class\=\"showHideLinkImage\"\>�p������� Protected ���\�b�h�̕\��/){|hit|
                'expanded.gif" class="showHideLinkImage">�p�������v���e�N�e�B�b�h���\�b�h�̕\��'
            }
            text.gsub!(/collapsed\.gif\" class\=\"showHideLinkImage\"\>�p������� Protected ���\�b�h�̕\��/){|hit|
                'collapsed.gif" class="showHideLinkImage">�p�������v���e�N�e�B�b�h���\�b�h�̔�\��'
            }
            text.gsub!(/\<tr class\=\"hideInherited���\�b�h\"\>/){|hit|
                '<tr class="hideInheritedMethod">'
            }
            text.gsub!(/\<tr class\=\"hideInheritedProtected���\�b�h\"\>/){|hit|
                '<tr class="hideInheritedProtectedMethod">'
            }
            text.gsub!(/\<table id\=\"summaryTable���\�b�h\"/){|hit|
                '<table id="summaryTableMethod"'
            }
            text.gsub!(/\<table id\=\"summaryTableProtected���\�b�h\"/){|hit|
                '<table id="summaryTableProtectedMethod"'
            }
            text.gsub!(/class\=\"summaryTable hideInheritedProtected���\�b�h\"/){|hit|
                'class="summaryTable hideInheritedProtectedMethod"'
            }
=end
            #####################################################
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
