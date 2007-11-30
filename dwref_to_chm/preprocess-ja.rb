require "kconv.rb"
require "fileutils.rb"

$KCODE = "SJIS"

def convertFile(orgpath, targetpath)
	c = 0;
	if orgpath =~ /.*\.html?$/ then
		print targetpath + "\n";
		fin = open(orgpath, 'r')
		fout = open(targetpath, 'w')
		
		fin.each("\n") do |text|
			t = text.tosjis().chomp()
			t.gsub!(/\<div(\s+[\w]+\s*\=\s*\"?.*?\"?)*\s+id\s*\=\s*\"(.*?)\"/) do |m|
				nm = $2
				nm.gsub!("�A", ",")
				'<a name="' + nm + '">' + m
			end
			fout.write(t+"\n")
		end
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
				nm.gsub!("�A", ",")
				'id="' + nm + '"'
			end
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
