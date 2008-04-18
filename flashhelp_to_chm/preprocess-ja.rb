require "kconv.rb"
require "fileutils.rb"

$KCODE = "s"

def convertFile(orgpath, targetpath)
    
    if orgpath =~ /.*\.html?/ then
        print targetpath + "\n";
        
        fin = open(orgpath, 'r')
        fout = open(targetpath, 'w')
        
        text = fin.read()
        #remove UTF-8 BOM if available
        if text[0..2] == "\xef\xbb\xbf" then
            text = text[3..-1]
        end
        text = text.kconv(Kconv::SJIS, Kconv::AUTO)
        text.gsub!(
            /\<meta\s+http-equiv=\"Content-Type\"\s+content=\"text\/html;\s+charset=UTF-8\"(\s*\/?)\>/i,
            "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=shift_jis\"\\1>")
        fout.write(text[0..-1])
        
        fin.close()
        fout.close()
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
