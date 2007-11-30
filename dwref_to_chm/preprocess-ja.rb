require "kconv.rb"
require "fileutils.rb"

$KCODE = "SJIS"

def convertFile(orgpath, targetpath)
	c = 0;
	if orgpath =~ /.*\.html?$/ then
		print targetpath + "\n";
		fin = open(orgpath, 'r')
		fout = open(targetpath, 'w')
		
        text = fin.read()
		text.gsub!("\r", "\n") #avoiding Ruby regexp broken... html has complex return code(0a/0d/0a0d) in same file 
        text = text.kconv(Kconv::SJIS, Kconv::AUTO)
        
        t = text.gsub(/\<div(\s+[\w]+\s*\=\s*\"?.*?\"?)*\s+id\s*\=\s*\"(.*?)\"/) do |m|
            nm = $2
            nm.gsub!("ÅA", ",")
            '<a name="' + nm + '">' + m
        end
        fout.write(t+"\n")
        
		fin.close()
		fout.close()
	elsif orgpath =~ /.*Reference\.xml$/ then
		print targetpath + "\n";
		fin = open(orgpath, 'r')
		fout = open(targetpath, 'w')
		
		fin.each("\n") do |text|
			t = text.tosjis().chomp()
			t.gsub!(/id\=[\"\'](.+?)[\"\']/) do |m|
				nm = $1
				nm.gsub!("ÅA", ",")
				'id="' + nm + '"'
			end
            
            #fix broken xml file(Why can Dreamweaver parse broken xml???????)
            t.gsub!('<subtopic name="frame<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main" id="frame<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main"/>', '<subtopic name="frame" id="frame"/>')
            t.gsub!('<subtopic name="rules<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main" id="rules<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main"/>', '<subtopic name="rules" id="rules"/>')
           
			fout.write(t+"\n")
		end
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
